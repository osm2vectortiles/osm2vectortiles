#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset
set -o verbose

# Example call
#                 ./qa_test.sh  443c7a5
#                 ./qa_test.sh  806a5d9
#                 ./qa_test.sh  2904e5a
#  Parameter1  =  git revision number


#TO RUN ----------------------------------------------------------------------------------------------

#1.  and check/replace    the PBF in the ./import directory 
ls ./import/*.pbf
#3. run this script with parameter :   ./qa_test.sh  443c7a5
#                 ./qa_test.sh  443c7a5
#                 ./qa_test.sh  806a5d9
#4. check the report from the  ./wrk/443c7a5*
#5. cleaninig ...
#        cd ./wrk/${REVISION}_osm2vectortiles &&  docker-compose stop && docker-compose rm -f -v -a
#------------------------------------------------------------------------------------------------------


readonly REVISION=${1:-806a5d9}


REPORT_HASH=${REVISION}-$(md5sum ./import/*.osm.pbf | sed 's#./import/#-#g' | sed 's#.osm##g'| sed 's#.pbf##g' | sed 's# ##g'  )
echo ${REPORT_HASH}  "== ( REVISION - import md5sum - import osm-filename )"



# ---not modify from here -----------------------------------------------------
#DOCKER_CACHE=--no-cache
DOCKER_CACHE=
REPORTDIR=../../tools/qa-reports


#
#  ---------------------------------------------------------------------
#

function runtest { 

 rm -f -r ./wrk/${REVISION}_osm2vectortiles
 git clone https://github.com/osm2vectortiles/osm2vectortiles.git  ./wrk/${REVISION}_osm2vectortiles
 cd ./wrk/${REVISION}_osm2vectortiles
 git reset --hard ${REVISION}
 cp ../../import/*     ./import/

 #  fix:   build: "src/postgis"  ->  image: "osm2vectortiles/import-osm"
 sed -i 's#build: "src/postgis"#image: "osm2vectortiles/postgis"#g' docker-compose.yml
 
 #  add a $REVISION prefix  for the images
 sed -i s#osm2vectortiles/#${REVISION}_osm2vectortiles/#g docker-compose.yml
 
 cat docker-compose.yml | grep ${REVISION}
# sed -i 's#image: "osm2vectortiles/#image: "${REVISION}_osm2vectortiles/"#g' docker-compose.yml

 # stop & clean docker environment.
 docker-compose stop
 docker-compose rm -f -v -a
 
 # rebuild  dockerimages from the local source 
 cd ./src/postgis         && docker build ${DOCKER_CACHE} -t ${REVISION}_osm2vectortiles/postgis  .         && cd ../..
 cd ./src/import-external && docker build ${DOCKER_CACHE} -t ${REVISION}_osm2vectortiles/import-external .  && cd ../..
 cd ./src/import-osm      && docker build ${DOCKER_CACHE} -t ${REVISION}_osm2vectortiles/import-osm .       && cd ../..
 cd ./src/import-sql      && docker build ${DOCKER_CACHE} -t ${REVISION}_osm2vectortiles/import-sql .       && cd ../..
    
 # Start images
 docker-compose up -d postgis
 
 # wait for postgis
 postgis_cid=$(docker ps | grep ${REVISION} | grep osm2vectortiles | grep postgis | cut -d" " -f 1)
 postgis_ip=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' ${postgis_cid})
 echo "postgis_ip = $postgis_ip" 
 while ! pg_isready -h $postgis_ip
 do
    echo "$(date) - waiting for PG database to start"
    sleep 2
 done
 
 # run test
 docker-compose up import-external
 docker-compose up import-osm
 docker-compose up import-sql
 
}
 
 
 
#
#  ---------------------------------------------------------------------
#



function generate_reports {

 postgis_cid=$(docker ps | grep ${REVISION} | grep osm2vectortiles | grep postgis | cut -d" " -f 1)
 postgis_ip=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' ${postgis_cid})
 echo "postgis_ip = $postgis_ip" 


 # ----- Environment report
 testfile=../${REPORT_HASH}--R000.txt
 psql -P pager=off -h $postgis_ip -d osm -U osm -f ${REPORTDIR}/o2v_qa_r000.sql     > ${testfile}
 echo "#--------------------------------------------"                              >> ${testfile} 
 echo "# md5sum ./import/* "                                                       >> ${testfile}
 md5sum ./import/*                                                                 >> ${testfile} 
 echo "#--------------------------------------------"                              >> ${testfile}   
 echo "#"                                                                          >> ${testfile} 
 echo "# git show --summary "                                                      >> ${testfile} 
 git show --summary                                                                >> ${testfile}
 echo "#--------------------------------------------"                              >> ${testfile}   
 echo "#"                                                                          >> ${testfile} 
 echo "# docker images      "                                                      >> ${testfile}  
 docker images   | grep ${REVISION} | grep osm2vectortiles  | sort                 >> ${testfile}
 
 
 psql -P pager=off -h $postgis_ip -d osm -U osm -f ${REPORTDIR}/o2v_qa_r001.sql     >  ../${REPORT_HASH}--R001.txt
 psql -P pager=off -h $postgis_ip -d osm -U osm -f ${REPORTDIR}/o2v_qa_r002.sql     >  ../${REPORT_HASH}--R002.txt


 # ----  export distinct osm_id  ---for OSM_ID  comparing 
 psql -P pager=off -h $postgis_ip -d osm -U osm -c "SELECT distinct osm_id FROM landuse_z5toz6 ORDER BY osm_id     ; " > ../${REPORT_HASH}__id_landuse_z5toz6.txt 
 psql -P pager=off -h $postgis_ip -d osm -U osm -c "SELECT distinct osm_id FROM landuse_z7toz8 ORDER BY osm_id     ; " > ../${REPORT_HASH}__id_landuse_z7toz8.txt 
 psql -P pager=off -h $postgis_ip -d osm -U osm -c "SELECT distinct osm_id FROM landuse_overlay_z5 ORDER BY osm_id ; " > ../${REPORT_HASH}__id_landuse_overlay_z5.txt
 psql -P pager=off -h $postgis_ip -d osm -U osm -c "SELECT distinct osm_id FROM landuse_overlay_z6 ORDER BY osm_id ; " > ../${REPORT_HASH}__id_landuse_overlay_z6.txt
 psql -P pager=off -h $postgis_ip -d osm -U osm -c "SELECT distinct osm_id FROM landuse_overlay_z7 ORDER BY osm_id ; " > ../${REPORT_HASH}__id_landuse_overlay_z7.txt
 psql -P pager=off -h $postgis_ip -d osm -U osm -c "SELECT distinct osm_id FROM landuse_overlay_z8 ORDER BY osm_id ; " > ../${REPORT_HASH}__id_landuse_overlay_z8.txt
 psql -P pager=off -h $postgis_ip -d osm -U osm -c "SELECT distinct osm_id FROM landuse_overlay_z9 ORDER BY osm_id ; " > ../${REPORT_HASH}__id_landuse_overlay_z9.txt
    
}


runtest
generate_reports

docker-compose stop
#  docker-compose rm -f -v -a


