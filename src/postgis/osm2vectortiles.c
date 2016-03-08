#include "postgres.h"
#include "funcapi.h"
#include "fmgr.h"
#include "math.h"
#include "utils/builtins.h"

PG_MODULE_MAGIC;

const float8 D2R = M_PI / 180.0;
const int32 MAX_TILES = M_PI / 180.0;

PG_FUNCTION_INFO_V1(point_to_tiles);
Datum point_to_tiles(PG_FUNCTION_ARGS)
{
    FuncCallContext     *funcctx;
    int                  call_cntr;
    int                  max_calls;
    TupleDesc            tupdesc;
    AttInMetadata       *attinmeta;

     /* stuff done only on the first call of the function */
     if (SRF_IS_FIRSTCALL())
     {
        MemoryContext   oldcontext;

        /* create a function context for cross-call persistence */
        funcctx = SRF_FIRSTCALL_INIT();

        /* switch to memory context appropriate for multiple function calls */
        oldcontext = MemoryContextSwitchTo(funcctx->multi_call_memory_ctx);

        /* number of zoom levels to go down is equal
         * to the amount of tuples returned
         * */
        funcctx->max_calls = PG_GETARG_INT32(2) + 1;

        /* Build a tuple descriptor for our result type */
        if (get_call_result_type(fcinfo, NULL, &tupdesc) != TYPEFUNC_COMPOSITE)
            ereport(ERROR,
                    (errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
                     errmsg("function returning record called in context "
                            "that cannot accept type record")));

        /*
         * generate attribute metadata needed later to produce tuples from raw
         * C strings
         */
        attinmeta = TupleDescGetAttInMetadata(tupdesc);
        funcctx->attinmeta = attinmeta;

        MemoryContextSwitchTo(oldcontext);
    }

    /* stuff done on every call of the function */
    funcctx = SRF_PERCALL_SETUP();

    call_cntr = funcctx->call_cntr;
    max_calls = funcctx->max_calls;
    attinmeta = funcctx->attinmeta;
 
    if (call_cntr < max_calls)    /* do when there is more left to send */
    {
        char       **values;
        HeapTuple    tuple;
        Datum        result;

        /*
         * Actual user defined code that does something useful
         * This calculates the x and y coordinates of a tile
         * based on the WGS84 latitude and longitude
         */
		const int32 zoom_level = call_cntr;
		const float8 lat = PG_GETARG_FLOAT8(0);
		const float8 lon = PG_GETARG_FLOAT8(1);
		const float8 _sin = sin(lat * D2R);
		const float8 z2 = pow(2, zoom_level);
		const int32 x = floor(z2 * (lon / 360 + 0.5));
		const int32 y = floor(z2 * (0.5 - 0.25 * log((1 + _sin) / (1 - _sin)) / M_PI));

        /*
         * Prepare a values array for building the returned tuple.
         * This should be an array of C strings which will
         * be processed later by the type input functions.
         */
        values = (char **) palloc(3 * sizeof(char *));
        values[0] = (char *) palloc(16 * sizeof(char));
        values[1] = (char *) palloc(16 * sizeof(char));
        values[2] = (char *) palloc(16 * sizeof(char));

        /* Store tuple values into C string array */
        snprintf(values[0], 16, "%d", x);
        snprintf(values[1], 16, "%d", y);
        snprintf(values[2], 16, "%d", zoom_level);

        /* Build a tuple */
        tuple = BuildTupleFromCStrings(attinmeta, values);

        /* make the tuple into a datum */
        result = HeapTupleGetDatum(tuple);

        /* clean up (this is not really necessary) */
        pfree(values[0]);
        pfree(values[1]);
        pfree(values[2]);
        pfree(values);

        SRF_RETURN_NEXT(funcctx, result);
    }
    else    /* do when there is no more left */
    {
        SRF_RETURN_DONE(funcctx);
    }
}

