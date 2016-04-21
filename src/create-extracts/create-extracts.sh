#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

readonly WORLD_MBTILES=${WORLD_MBTILES:-"world.mbtiles"}
readonly PATCH_MBTILES=${PATCH_MBTILES:-"world_z0-z5.mbtiles"}
readonly EXTRACT_DIR=$(dirname "$WORLD_MBTILES")
readonly VERSION=${VERSION:-1}
readonly GLOBAL_BBOX="-180, -85.0511, 180, 85.0511"
readonly S3_CONFIG_FILE=${S3_CONFIG_FILE:-"$HOME/.s3cfg"}
readonly S3_BUCKET_NAME=${S3_BUCKET_NAME:-"osm2vectortiles-downloads"}
readonly S3_PREFIX=${S3_PREFIX:-"v1.0/extracts/"}

function upload_extract() {
    local mbtiles_extract="$1"
    s3cmd --config="$S3_CONFIG_FILE" \
          --access_key="$S3_ACCESS_KEY" \
          --secret_key="$S3_SECRET_KEY" \
        put "$mbtiles_extract" "s3://$S3_BUCKET_NAME/$S3_PREFIX" \
          --acl-public \
          --multipart-chunk-size-mb=50
}

function patch_mbtiles() {
	local mbtiles_source="$1"
	local mbtiles_dest="$2"
	echo "
	PRAGMA journal_mode=PERSIST;
	PRAGMA page_size=80000;
	PRAGMA synchronous=OFF;
	ATTACH DATABASE '$mbtiles_source' AS source;
	REPLACE INTO map SELECT * FROM source.map;
	REPLACE INTO images SELECT * FROM source.images;"\
	| sqlite3 "$mbtiles_dest"
}

function create_extract() {
    local extract_file="$EXTRACT_DIR/$1"
    local min_longitude="$2"
    local min_latitude="$3"
    local max_longitude="$4"
    local max_latitude="$5"
    local min_zoom="0"
    local max_zoom="14"
    local bounds="$min_longitude,$min_latitude,$max_longitude,$max_latitude"

    local center_zoom="10"
    local center_longitude=$(echo "scale = 10; ($min_longitude+$max_longitude)/2.0" | bc)
    local center_latitude=$(echo "scale = 10; ($min_latitude+$max_latitude)/2.0" | bc)
    local center="$center_longitude,$center_latitude,$center_zoom"

    echo "Create extract $extract_file"
    tilelive-copy \
        --minzoom="$min_zoom" \
        --maxzoom="$max_zoom" \
        --bounds="$bounds" \
        "$WORLD_MBTILES" "$extract_file"

    echo "Update metadata $extract_file"
    update_metadata "$extract_file" "$bounds" "$center" "$min_zoom" "$max_zoom"

    echo "Patching upper zoom levels $extract_file"
    patch_mbtiles "$PATCH_MBTILES" "$extract_file"

    echo "Uploading $extract_file"
    upload_extract "$extract_file"
}

function create_lower_zoomlevel_extract() {
    local extract_file="$EXTRACT_DIR/$1"
    local min_zoom="$2"
    local max_zoom="$3"

    local center_zoom="1"
    local center_longitude="-94.1629"
    local center_latitude="34.5133"
    local center="$center_longitude,$center_latitude,$center_zoom"

    echo "Create extract $extract_file"
    tilelive-copy \
        --minzoom="$min_zoom" \
        --maxzoom="$max_zoom" \
        --bounds="$GLOBAL_BBOX" \
        "$WORLD_MBTILES" "$extract_file"

    echo "Update metadata $extract_file"
    update_metadata "$extract_file" "$GLOBAL_BBOX" "$center" "$min_zoom" "$max_zoom"

    echo "Uploading $extract_file"
    upload_extract "$extract_file"
}

function update_metadata_entry() {
    local extract_file="$1"
    local name="$2"
    local value="$3"
    local stmt="UPDATE metadata SET VALUE='$value' WHERE name = '$name';"
    sqlite3 "$extract_file" "$stmt"
}

function insert_metadata_entry() {
    local extract_file="$1"
    local name="$2"
    local value="$3"
    local stmt="INSERT OR IGNORE INTO metadata VALUES('$name','$value');"
    sqlite3 "$extract_file" "$stmt"
}

function update_metadata() {
    local extract_file="$1"
    local extract_bounds="$2"
    local extract_center="$3"
    local min_zoom="$4"
    local max_zoom="$5"
    local attribution='<a href="http://www.openstreetmap.org/about/">&copy; OpenStreetMap contributors</a>'
    local filesize="$(wc -c $extract_file)"

    insert_metadata_entry "$extract_file" "type" "baselayer"
    insert_metadata_entry "$extract_file" "attribution" "$attribution"
    insert_metadata_entry "$extract_file" "version" "$VERSION"
    update_metadata_entry "$extract_file" "minzoom" "$min_zoom"
    update_metadata_entry "$extract_file" "maxzoom" "$max_zoom"
    update_metadata_entry "$extract_file" "name" "osm2vectortiles"
    update_metadata_entry "$extract_file" "id" "osm2vectortiles"
    update_metadata_entry "$extract_file" "description" "Extract from osm2vectortiles.org"
    update_metadata_entry "$extract_file" "bounds" "$extract_bounds"
    update_metadata_entry "$extract_file" "center" "$extract_center"
    update_metadata_entry "$extract_file" "basename" "${extract_file##*/}"
    update_metadata_entry "$extract_file" "filesize" "$filesize"
}

function create_extracts() {
	create_lower_zoomlevel_extract "world_z0-z5.mbtiles" 0 5
	create_lower_zoomlevel_extract "world_z0-z8.mbtiles" 0 8
	create_extract "puerto_rico.mbtiles" "-68.1976318" "17.6701939" "-65.088501" "18.7347042"
	create_extract "afghanistan.mbtiles" "60.403889" "29.288333" "74.989862" "38.5899217"
	create_extract "albania.mbtiles" "19.0246095" "39.5448625" "21.1574335" "42.7611669"
	create_extract "algeria.mbtiles" "-8.7689089" "18.868147" "12.097337" "37.3962055"
	create_extract "andorra.mbtiles" "1.3135781" "42.3288238" "1.8863837" "42.7559357"
	create_extract "angola.mbtiles" "11.3609793" "-18.1389449" "24.18212" "-4.2888889"
	create_extract "anguilla.mbtiles" "-63.7391991" "17.9609378" "-62.6125448" "18.8951194"
	create_extract "argentina.mbtiles" "-73.6603073" "-55.285076" "-53.5374514" "-21.6811679"
	create_extract "armenia.mbtiles" "43.3471395" "38.7404775" "46.7333087" "41.400712"
	create_extract "australia.mbtiles" "72.1460938" "-55.4228174" "168.3249543" "-9.090427"
	create_extract "austria.mbtiles" "9.4307487" "46.2722761" "17.260776" "49.1205264"
	create_extract "azerbaijan.mbtiles" "44.6633701" "38.2929551" "51.1090302" "42.0502947"
	create_extract "bahrain.mbtiles" "50.1697989" "25.435" "51.0233693" "26.7872444"
	create_extract "bangladesh.mbtiles" "87.9075306" "20.2756582" "92.7804979" "26.7382534"
	create_extract "barbados.mbtiles" "-59.9562114" "12.745" "-59.1147174" "13.635"
	create_extract "belarus.mbtiles" "23.0783386" "51.1575982" "32.8627809" "56.2722235"

	create_extract "belgium.mbtiles" "2.2889137" "49.3969821" "6.508097" "51.6516667"
	create_extract "belize.mbtiles" "-89.3261456" "15.7857286" "-87.2098493" "18.596001"
	create_extract "benin.mbtiles" "0.676667" "5.9398696" "3.943343" "12.5065612"
	create_extract "bermuda.mbtiles" "-65.2232221" "31.9469651" "-64.3109841" "32.6913693"
	create_extract "bhutan.mbtiles" "88.6464724" "26.602016" "92.2252321" "28.346987"
	create_extract "bolivia.mbtiles" "-69.7450072" "-23.0005473" "-57.3529999" "-9.5689437"
	create_extract "bosnia_and_herzegovina.mbtiles" "15.6287433" "42.4543231" "19.7217086" "45.3764771"
	create_extract "botswana.mbtiles" "19.8986474" "-27.0059668" "29.475304" "-17.6781369"
	create_extract "brazil.mbtiles" "-74.0830624" "-33.9689055" "-28.5341163" "5.3842873"
	create_extract "british_indian_ocean_territory.mbtiles" "70.936504" "-7.7454078" "72.8020157" "-4.9370659"
	create_extract "british_virgin_islands.mbtiles" "-65.055961" "18.0055311" "-63.9597293" "19.0503802"
	create_extract "brunei.mbtiles" "113.976123" "3.902508" "115.4635623" "5.2011857"
	create_extract "bulgaria.mbtiles" "22.257337" "41.1353929" "28.9875409" "44.3162214"
	create_extract "burkina_faso.mbtiles" "-5.6175099" "9.293889" "2.50261" "15.184"
	create_extract "burundi.mbtiles" "28.9007401" "-4.5693154" "30.9495759" "-2.2096795"
	create_extract "cote_d_ivoire.mbtiles" "-8.7017249" "4.0621205" "-2.3930309" "10.840015"

	create_extract "cambodia.mbtiles" "102.2338282" "9.3230459" "107.7276788" "14.7902471"
	create_extract "cameroon.mbtiles" "8.2822176" "1.5546659" "16.2921476" "13.183333"
	create_extract "canada.mbtiles" "-141.1027499" "41.5765556" "-52.223198" "83.4362128"
	create_extract "cape_verde.mbtiles" "-25.6731072" "14.5066229" "-22.3547751" "17.507117"
	create_extract "cayman_islands.mbtiles" "-81.7313747" "18.9620619" "-79.4110953" "20.0573759"
	create_extract "central_african_republic.mbtiles" "14.3155426" "2.1156553" "27.5540764" "11.101389"
	create_extract "chad.mbtiles" "13.37348" "7.34107" "24.1" "23.5975"
	create_extract "chile.mbtiles" "-109.7795788" "-56.8249999" "-65.9734088" "-17.3983997"
	create_extract "china.mbtiles" "73.3997347" "14.8082548" "134.8754563" "53.6608154"
	create_extract "colombia.mbtiles" "-82.1000001" "-4.3316871" "-66.7511906" "16.2219145"
	create_extract "comoros.mbtiles" "42.925305" "-12.7209999" "44.8451922" "-11.0649999"
	create_extract "congo-brazzaville.mbtiles" "10.9048205" "-5.2358572" "18.743611" "3.813056"
	create_extract "congo-kinshasa.mbtiles" "11.9374291" "-13.5590349" "31.4056758" "5.4920026"
	create_extract "cook_islands.mbtiles" "-166.1856467" "-22.2580699" "-157.0154965" "-8.6168791"
	create_extract "costa_rica.mbtiles" "-87.3722646" "5.2329698" "-82.4060207" "11.3196781"
	create_extract "croatia.mbtiles" "13.101983" "42.0748212" "19.5470842" "46.655029"

	create_extract "cuba.mbtiles" "-85.2679701" "19.5275294" "-73.8190003" "23.5816972"
	create_extract "cyprus.mbtiles" "31.9227581" "34.3383706" "34.9553182" "36.013252"
	create_extract "czech_republic.mbtiles" "11.9905901" "48.4518144" "18.959216" "51.1557036"
	create_extract "denmark.mbtiles" "7.6153255" "54.3516667" "15.6530641" "58.0524297"
	create_extract "djibouti.mbtiles" "41.6713139" "10.8149547" "43.7579046" "12.8923081"
	create_extract "dominica.mbtiles" "-61.7869183" "14.9074207" "-60.9329894" "15.8872222"
	create_extract "dominican_republic.mbtiles" "-72.1657709" "17.166222" "-68.0148509" "20.234528"
	create_extract "east_timor.mbtiles" "123.9415703" "-9.6642774" "127.6335392" "-7.9895458"
	create_extract "ecuador.mbtiles" "-92.7828789" "-5.1159313" "-75.0925039" "2.4495499"
	create_extract "egypt.mbtiles" "24.606389" "21.8999975" "37.2153517" "31.9330854"
	create_extract "el_salvador.mbtiles" "-90.2602721" "12.9262117" "-87.4498059" "14.551667"
	create_extract "equatorial_guinea.mbtiles" "5.3172943" "-1.7732195" "11.4598628" "4.089"
	create_extract "eritrea.mbtiles" "36.343333" "12.2548219" "43.4001714" "18.1479356"
	create_extract "estonia.mbtiles" "21.2826069" "57.4093124" "28.3100175" "60.0383754"
	create_extract "ethiopia.mbtiles" "32.897734" "3.297448" "48.0823797" "14.9944684"
	create_extract "falkland_islands.mbtiles" "-61.8726771" "-53.2186765" "-57.2662366" "-50.6973006"

	create_extract "faroe_islands.mbtiles" "-7.8983833" "61.1880991" "-6.0413261" "62.5476162"
	create_extract "federated_states_of_micronesia.mbtiles" "137.1234512" "0.727" "163.3364054" "10.391"
	create_extract "fiji.mbtiles" "-180.0999999" "-21.3286516" "180.1" "-12.1613865"
	create_extract "finland.mbtiles" "18.9832098" "59.3541578" "31.6867044" "70.1922939"
	create_extract "france.mbtiles" "-178.4873748" "-50.3187168" "172.4057152" "51.368318"
	create_extract "gabon.mbtiles" "8.4002246" "-4.201226" "14.639444" "2.4182171"
	create_extract "georgia.mbtiles" "39.7844803" "40.9552922" "46.8365373" "43.6864294"
	create_extract "germany.mbtiles" "5.7663153" "47.1701114" "15.1419319" "55.199161"
	create_extract "ghana.mbtiles" "-3.3607859" "4.4392525" "1.3732942" "11.2748562"
	create_extract "greece.mbtiles" "19.1477876" "34.6006096" "29.8296986" "41.8488862"
	create_extract "greenland.mbtiles" "-74.394555" "59.4209376" "-9.4914437" "83.8491212"
	create_extract "grenada.mbtiles" "-62.1065867" "11.686" "-61.0732142" "12.6966532"
	create_extract "guatemala.mbtiles" "-92.4105241" "13.5278662" "-88.0648019" "17.9166179"
	create_extract "guernsey.mbtiles" "-3.1204014" "49.1208333" "-1.9351849" "50.0416066"
	create_extract "guinea-bissau.mbtiles" "-16.9945229" "10.5514215" "-13.5348776" "12.7862384"
	create_extract "guinea.mbtiles" "-15.3470907" "7.0906045" "-7.5381992" "12.77563"

	create_extract "guyana.mbtiles" "-61.5149049" "1.0710017" "-56.3689542" "8.7038842"
	create_extract "haiti.mbtiles" "-74.7575356" "17.8099291" "-71.5221296" "20.3181368"
	create_extract "honduras.mbtiles" "-89.4519439" "12.879722" "-82.0816379" "17.719526"
	create_extract "hungary.mbtiles" "16.0138867" "45.637128" "22.9974573" "48.685257"
	create_extract "iceland.mbtiles" "-25.1135068" "62.9859177" "-12.7046161" "67.453"
	create_extract "india.mbtiles" "68.0113787" "6.4546079" "97.495561" "35.7745457"
	create_extract "indonesia.mbtiles" "94.6717124" "-11.3085668" "141.1194444" "6.3744496"
	create_extract "iran.mbtiles" "43.9318908" "24.7465103" "63.4332704" "39.8816502"

	create_extract "iraq.mbtiles" "38.6936612" "28.9612087" "48.9412702" "37.480932"
	create_extract "ireland.mbtiles" "-11.1133787" "51.122" "-5.5582362" "55.736"
	create_extract "isle_of_man.mbtiles" "-5.2707284" "53.745" "-3.865406" "54.6534288"
	create_extract "israel.mbtiles" "34.1674994" "29.3533796" "35.9950234" "33.4356317"
	create_extract "italy.mbtiles" "6.5272658" "35.1889616" "18.8844746" "47.1921462"
	create_extract "jamaica.mbtiles" "-78.6782365" "16.4899443" "-75.6541142" "18.8256394"
	create_extract "japan.mbtiles" "122.6141754" "20.1145811" "154.305541" "45.8112046"
	create_extract "jersey.mbtiles" "-2.6591666" "48.7721667" "-1.7333332" "49.5605"
	create_extract "jordan.mbtiles" "34.7844372" "29.083401" "39.4012981" "33.4751558"
	create_extract "kazakhstan.mbtiles" "46.392161" "40.4686476" "87.4156316" "55.5804002"
	create_extract "kenya.mbtiles" "33.8098987" "-4.9995203" "41.999578" "4.72"
	create_extract "kiribati.mbtiles" "-174.8433549" "-11.7459999" "177.1479136" "5"
	create_extract "kenya.mbtiles" "46.4526837" "28.4138452" "49.1046809" "30.2038082"
	create_extract "kyrgyzstan.mbtiles" "69.1649523" "39.0728437" "80.3295793" "43.3667971"
	create_extract "laos.mbtiles" "99.9843247" "13.8096752" "107.7349989" "22.602872"
	create_extract "latvia.mbtiles" "20.5715407" "55.5746671" "28.3414904" "58.1855688"

	create_extract "lebanon.mbtiles" "34.7825667" "32.9479858" "36.725" "34.7923543"
	create_extract "lesotho.mbtiles" "26.91123" "-30.7755749" "29.5557099" "-28.4705972"
	create_extract "liberia.mbtiles" "-11.7080763" "4.0555907" "-7.2673229" "8.6519717"
	create_extract "libya.mbtiles" "9.291081" "19.4008138" "25.4541226" "33.4512055"
	create_extract "liechtenstein.mbtiles" "9.3716736" "46.9484291" "9.7357143" "47.370581"
	create_extract "lithuania.mbtiles" "20.553783" "53.7967893" "26.9355198" "56.5504213"
	create_extract "luxemburg.mbtiles" "5.6357006" "49.3478539" "6.6312481" "50.2827712"
	create_extract "macedonia.mbtiles" "20.3532236" "40.7545226" "23.134051" "42.4735359"
	create_extract "madagascar.mbtiles" "42.8729705" "-25.9054593" "50.7983545" "-11.6490749"
	create_extract "malawi.mbtiles" "32.5703616" "-17.2295216" "36.0185731" "-9.268326"
	create_extract "malaysia.mbtiles" "98.8372144" "0.753821" "119.5390876" "7.6111989"
	create_extract "maldives.mbtiles" "72.2554187" "-1.0074934" "74.0700962" "7.4106246"
	create_extract "mali.mbtiles" "-12.3407704" "10.047811" "4.3673828" "25.101084"
	create_extract "malta.mbtiles" "13.8324226" "35.5029696" "14.9267966" "36.3852706"
	create_extract "marshall_islands.mbtiles" "160.494934" "4.274" "172.4737007" "14.973"
	create_extract "mauritania.mbtiles" "-17.1684993" "14.6206601" "-4.7333343" "27.414942"

	create_extract "mauritius.mbtiles" "56.2825151" "-20.8249999" "63.8151319" "-10.0379999"
	create_extract "mexico.mbtiles" "-118.6991899" "14.2886243" "-86.3932659" "32.8186553"
	create_extract "moldova.mbtiles" "26.5162823" "45.3667022" "30.2635137" "48.5918695"
	create_extract "monaco.mbtiles" "7.3090279" "43.416333" "7.633167" "43.8519311"
	create_extract "mongolia.mbtiles" "87.63762" "41.4804176" "120.031949" "52.2496"
	create_extract "montenegro.mbtiles" "18.3334249" "41.6495999" "20.4638002" "43.658844"
	create_extract "montserrat.mbtiles" "-62.5506669" "16.375" "-61.8353817" "17.1152978"
	create_extract "morocco.mbtiles" "-17.4479238" "20.5144392" "-0.8984289" "36.1027875"
	create_extract "mozambique.mbtiles" "30.1131759" "-27.0209426" "41.1545908" "-10.2252148"
	create_extract "myanmar.mbtiles" "92.0719423" "9.4375" "101.2700796" "28.647835"
	create_extract "namibia.mbtiles" "11.4280384" "-29.0694499" "25.3617476" "-16.8634854"
	create_extract "nauru.mbtiles" "166.6099864" "-0.8529999" "167.2597301" "-0.2029999"
	create_extract "nepal.mbtiles" "79.9586109" "26.2477172" "88.3015257" "30.546945"
	create_extract "new_zealand.mbtiles" "-179.1591529" "-52.9213686" "179.4643594" "-28.9303302"
	create_extract "nicaragua.mbtiles" "-87.933972" "10.6084923" "-82.5227022" "15.1331183"
	create_extract "niger.mbtiles" "0.0689653" "11.593756" "16.096667" "23.617178"

	create_extract "nigeria.mbtiles" "2.576932" "3.9690959" "14.777982" "13.985645"
	create_extract "niue.mbtiles" "-170.2595028" "-19.4548664" "-169.4647228" "-18.6534558"
	create_extract "north_korea.mbtiles" "123.9913902" "37.5279512" "131.024647" "43.1089642"
	create_extract "norway.mbtiles" "-9.7848145" "-54.7539999" "34.7891253" "81.128076"
	create_extract "oman.mbtiles" "51.9" "16.3649608" "60.154577" "26.8026737"
	create_extract "pakistan.mbtiles" "60.766944" "23.4393916" "77.2203914" "37.184107"
	create_extract "palau.mbtiles" "130.9685462" "2.648" "134.8714735" "8.322"
	create_extract "palestine.mbtiles" "33.9689732" "31.1201289" "35.6734946" "32.6521479"
	create_extract "panama.mbtiles" "-83.1517244" "6.9338679" "-77.0393778" "9.9701757"
	create_extract "papua_new_guinea.mbtiles" "140.7416553" "-11.9555738" "159.792724" "-0.4573575"
	create_extract "paraguay.mbtiles" "-62.7442035" "-27.7069156" "-54.1579999" "-19.1876463"
	create_extract "peru.mbtiles" "-84.7732789" "-20.2984471" "-68.5519905" "0.0607183"
	create_extract "philippines.mbtiles" "113.9783252" "4.1158064" "126.9072562" "21.4217806"
	create_extract "pitcairn_islands.mbtiles" "-130.9049861" "-25.2306735" "-124.6175339" "-23.7655768"
	create_extract "poland.mbtiles" "14.0229707" "48.9020468" "24.245783" "55.1336963"
	create_extract "portugal.mbtiles" "-31.6575302" "29.7288021" "-6.0891591" "42.2543112"

	create_extract "qatar.mbtiles" "50.4675" "24.3707534" "52.738011" "26.4830212"
	create_extract "republic_of_china.mbtiles" "114.2521088" "10.2706406" "122.397" "26.5015754"
	create_extract "republic_of_kosovo.mbtiles" "19.9185549" "41.7554981" "21.8995285" "43.3691934"
	create_extract "romania.mbtiles" "20.1619773" "43.518682" "30.1454257" "48.3653964"
	create_extract "russian_federation.mbtiles" "-180.0999999" "41.0858711" "180.1" "82.1586232"
	create_extract "rwanda.mbtiles" "28.7617546" "-2.9389803" "30.9990738" "-0.9474509"
	create_extract "sao_tome_and_principe.mbtiles" "6.160642" "-0.3135136" "7.7704783" "2.0257601"
	create_extract "sahrawi_arab_democratic_republic.mbtiles" "-15.1405655" "21.2370952" "-8.5663889" "27.7666834"
	create_extract "saint_helena_scension_and_tristan_da_cunha.mbtiles" "-14.7226944" "-40.6699999" "-5.3234152" "-7.5899999"
	create_extract "saint_kitts_and_nevis.mbtiles" "-63.1511289" "16.795" "-62.2303518" "17.7158146"
	create_extract "saint_lucia.mbtiles" "-61.3853866" "13.408" "-60.5669362" "14.3725"
	create_extract "saint_vincent_and_the_grenadines.mbtiles" "-61.765747" "12.4166548" "-60.8094145" "13.683"
	create_extract "samoa.mbtiles" "-173.1091863" "-14.3770915" "-171.0929228" "-13.1381891"
	create_extract "san_marino.mbtiles" "12.3033246" "43.7937002" "12.6160665" "44.092093"
	create_extract "saudi_arabia.mbtiles" "34.3571718" "16.19" "55.7666985" "32.3305891"
	create_extract "senegal.mbtiles" "-17.8862418" "12.1372838" "-11.2458995" "16.7919959"

	create_extract "serbia.mbtiles" "18.71403" "42.1357356" "23.106309" "46.2900608"
	create_extract "seychelles.mbtiles" "45.8988759" "-10.5649257" "56.5979396" "-3.4119999"
	create_extract "sierra_leone.mbtiles" "-13.6003388" "6.655" "-10.1716829" "10.1000481"
	create_extract "singapore.mbtiles" "103.4666667" "1.0303611" "104.6706735" "1.6130449"
	create_extract "slovakia.mbtiles" "16.7331891" "47.6314286" "22.6657096" "49.7138162"
	create_extract "slovenia.mbtiles" "13.2754696" "45.3214242" "16.6967702" "46.9766816"
	create_extract "solomon_islands.mbtiles" "155.2190556" "-13.3424297" "170.4964667" "-4.7108499"
	create_extract "somalia.mbtiles" "40.8864985" "-1.9031968" "51.7177696" "12.2889121"
	create_extract "south_africa.mbtiles" "16.2335213" "-47.2788334" "38.3898954" "-22.02503"
	create_extract "south_georgia_and_the_south_sandwich_islands.mbtiles" "-42.2349052" "-59.7839999" "-25.7468302" "-53.3531685"
	create_extract "south_korea.mbtiles" "124.254847" "32.77788" "132.2483256" "38.7234602"
	create_extract "south_sudan.mbtiles" "23.347778" "3.38898" "36.048997" "12.336389"
	create_extract "spain.mbtiles" "-18.4936844" "27.3335426" "4.6918885" "44.0933088"
	create_extract "sri_lanka.mbtiles" "79.2741141" "5.619" "82.1810141" "10.135"
	create_extract "sudan.mbtiles" "21.7145046" "9.247221" "39.1576252" "22.324918"
	create_extract "suriname.mbtiles" "-58.1708329" "1.7312802" "-53.7433357" "6.325"

	create_extract "swaziland.mbtiles" "30.6908" "-27.41752" "32.2349923" "-25.6187599"
	create_extract "sweden.mbtiles" "10.4920778" "55.0331192" "24.2776819" "69.1599699"
	create_extract "switzerland.mbtiles" "5.8559113" "45.717995" "10.5922941" "47.9084648"
	create_extract "syria.mbtiles" "35.3714427" "32.211354" "42.4745687" "37.4184589"
	create_extract "tajikistan.mbtiles" "67.2308737" "36.5710411" "75.2539563" "41.1450935"
	create_extract "tanzania.mbtiles" "29.2269773" "-11.8612539" "40.7584071" "-0.8820299"
	create_extract "thailand.mbtiles" "97.2438072" "5.512851" "105.7370925" "20.5648337"
	create_extract "the_bahamas.mbtiles" "-80.800194" "20.6059846" "-72.347752" "27.5734551"
	create_extract "the_gambia.mbtiles" "-17.1288253" "12.961" "-13.6977779" "13.9253137"
	create_extract "the_netherlands.mbtiles" "-70.3695875" "11.677" "7.3274985" "53.8253321"
	create_extract "togo.mbtiles" "-0.2439718" "5.826547" "1.9025" "11.2395355"
	create_extract "tokelau.mbtiles" "-172.8213672" "-9.7442498" "-170.8797585" "-8.232863"
	create_extract "tonga.mbtiles" "-179.4951979" "-24.2625705" "-173.4295457" "-15.2655721"
	create_extract "trinidad_and_tobago.mbtiles" "-62.1830559" "9.7732106" "-60.1895847" "11.6628372"
	create_extract "tunisia.mbtiles" "7.4219807" "30.14238" "11.9801133" "37.8612052"
	create_extract "turkey.mbtiles" "25.5212891" "35.7076804" "44.9176638" "42.397"

	create_extract "turkmenistan.mbtiles" "52.235076" "35.0355776" "66.784303" "42.8975571"
	create_extract "turks_and_caicos_islands.mbtiles" "-72.7799045" "20.8553418" "-70.764359" "22.2630989"
	create_extract "tuvalu.mbtiles" "-180.0999999" "-11.0939388" "180.1" "-5.336961"
	create_extract "uganda.mbtiles" "29.4727424" "-1.5787899" "35.100308" "4.3340766"
	create_extract "ukraine.mbtiles" "22.037059" "44.084598" "40.3275801" "52.4791473"
	create_extract "united_arab_emirates.mbtiles" "51.3160714" "22.5316214" "56.7024458" "26.2517219"
	create_extract "united_kingdom.mbtiles" "-14.1155169" "49.574" "2.1919117" "61.161"
	create_extract "united_states_of_america.mbtiles" "-180.0999999" "-14.8608357" "180.1" "71.7048217"
	create_extract "uruguay.mbtiles" "-58.5948437" "-35.8847311" "-52.9755832" "-29.9853439"
	create_extract "uzbekistan.mbtiles" "55.8985781" "37.0772144" "73.2397362" "45.690118"
	create_extract "vanuatu.mbtiles" "166.2355255" "-20.5627424" "170.549982" "-12.7713776"
	create_extract "vatican_city.mbtiles" "12.3457442" "41.8002044" "12.5583555" "42.0073912"
	create_extract "venezuela.mbtiles" "-73.4529631" "0.547529" "-59.4427078" "16.0158431"
	create_extract "vietnam.mbtiles" "102.04441" "8.0790665" "114.4341924" "23.493395"
	create_extract "yemen.mbtiles" "41.50825" "11.8084802" "54.8389375" "19.1"
	create_extract "zambales.mbtiles" "117.411894" "14.5033824" "120.549421" "15.958218"

	create_extract "zambia.mbtiles" "21.896389" "-18.1766964" "33.8025" "-8.1712821"
	create_extract "zimbabwe.mbtiles" "25.1373" "-22.5241095" "33.1627122" "-15.5097038"

	create_extract "zurich.mbtiles" "8.448060" "47.320230" "8.625370" "47.434680"
	create_extract "london.mbtiles" "-0.563" "51.261318" "0.28036" "51.686031"
	create_extract "paris.mbtiles" "2.08679" "48.658291" "2.63791" "49.04694"
	create_extract "istanbul.mbtiles" "28.448009" "40.802731" "29.45787" "41.23595"
	create_extract "berlin.mbtiles" "13.05355" "52.330269" "13.72616" "52.667511"
	create_extract "san_francisco.mbtiles" "-123.013657" "37.604031" "-122.355301" "37.832371"
	create_extract "new_york.mbtiles" "-74.255653" "40.495682" "-73.689484" "40.917622"
	create_extract "montreal.mbtiles" "-73.976608" "45.413479" "-73.476418" "45.704788"
	create_extract "moscow.mbtiles" "37.31926" "55.4907" "38.09008" "56.022171"
	create_extract "melbourne.mbtiles" "144.553207" "-38.411251" "145.507736" "-37.540112"
	create_extract "rio_de_janeiro.mbtiles" "-43.795799" "-23.078119" "-43.101261" "-22.74906"
	create_extract "mexico_city.mbtiles" "-99.507149" "18.94665" "-98.742912" "19.69857"
	create_extract "bogota.mbtiles" "-74.171494" "4.56282" "-74.055634" "4.70989"
	create_extract "singapore.mbtiles" "103.84417" "1.28469" "103.86235" "1.30287"
	create_extract "beijing.mbtiles" "116.04142" "39.75872" "116.638641" "40.159191"
	create_extract "tokyo.mbtiles" "139.562881" "35.523449" "139.918961" "35.81749"
	create_extract "seoul.mbtiles" "126.7686" "37.421341" "127.18615" "37.692902"
	create_extract "delhi.mbtiles" "76.83831" "28.404181" "77.343689" "28.88382"
	create_extract "cairo.mbtiles" "31.20372" "30.00688" "31.311171" "30.1171"
	create_extract "lagos.mbtiles" "3.38106" "6.42833" "3.44309" "6.46103"
}

function main() {
	if [ ! -f "$WORLD_MBTILES" ]; then
		echo "$WORLD_MBTILES not found."
		exit 10
	fi

	if [ -z "${S3_ACCESS_KEY}" ]; then
		echo "Specify the S3_ACCESS_KEY and S3_SECRET_KEY to upload extract."
		exit 30
	fi

    create_extracts
}

main
