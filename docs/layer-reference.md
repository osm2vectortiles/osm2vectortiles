---
layout: page
title: Layer Reference
published: true
---

# Layer Reference

This is a guide to the data inside the OSM Vector Tiles to help you with styling.

Available layers:

- [#landuse](#landuse)
- [#waterway](#waterway)
- [#water](#water)
- [#aeroway](#aeroway)
- [#barrier_line](#barrier_line)
- [#building](#building)
- [#landuse_overlay](#landuse_overlay)
- [#tunnel](#tunnel)
- [#road](#road)
- [#bridge](#bridge)
- [#admin](#admin)
- [#country_label](#country_label)
- [#marine_label](#marine_label)
- [#place_label](#place_label)
- [#water_label](#water_label)
- [#poi_label](#poi_label)
- [#road_label](#road_label)
- [#waterway_label](#waterway_label)
- [#housenum_label](#housenum_label)

## Zoom Level Reference
The zoom level reference helps to see which layer is included on which zoom level. The zoom levels are ordered by how they get drawn. The layer landuse is at the bottom and housenum_label is at top of all the others.

|                 | z0 | z1 | z2 | z3 | z4 | z5 | z6 | z7 | z8 | z9 | z10 | z11 | z12 | z13 | z14 |
|-----------------|----|----|----|----|----|----|----|----|----|----|-----|-----|-----|-----|-----|
| landuse         |    |    |    |    |    |  x |  x |  x |  x |  x |  x  |  x  |  x  |  x  |  x  |
| waterway        |    |    |    |    |    |    |    |    |  x |  x |  x  |  x  |  x  |  x  |  x  |
| water           |  x |  x |  x |  x |  x |  x |  x |  x |  x |  x |  x  |  x  |  x  |  x  |  x  |
| aeroway         |    |    |    |    |    |    |    |    |    |    |     |     |  x  |  x  |  x  |
| barrier_line    |    |    |    |    |    |    |    |    |    |    |     |     |     |     |  x  |
| building        |    |    |    |    |    |    |    |    |    |    |     |     |     |  x  |  x  |
| landuse_overlay |    |    |    |    |    |    |    |  x |  x |  x |  x  |  x  |  x  |  x  |  x  |
| tunnel          |    |    |    |    |    |    |    |    |    |    |     |  x  |  x  |  x  |  x  |
| road            |    |    |    |    |    |  x |  x |  x |  x |  x |  x  |  x  |  x  |  x  |  x  |
| bridge          |    |    |    |    |    |    |    |    |    |    |     |     |  x  |  x  |  x  |
| admin           |  x |  x |  x |  x |  x |  x |  x |  x |  x |  x |  x  |  x  |  x  |  x  |  x  |
| country_label   |    |  x |  x |  x |  x |  x |  x |  x |  x |  x |  x  |  x  |  x  |  x  |  x  |
| marine_label    |    |  x |  x |  x |  x |  x |  x |  x |  x |  x |  x  |  x  |  x  |  x  |  x  |
| state_label     |    |    |    |    |  x |  x |  x |  x |  x |  x |  x  |  x  |  x  |  x  |  x  |
| place_label     |    |    |    |    |  x |  x |  x |  x |  x |  x |  x  |  x  |  x  |  x  |  x  |
| water_label     |    |    |    |    |    |    |    |    |    |    |  x  |  x  |  x  |  x  |  x  |
| poi_label       |    |    |    |    |    |    |    |    |    |    |     |     |     |     |  x  |
| road_label      |    |    |    |    |    |    |    |    |  x |  x |  x  |  x  |  x  |  x  |  x  |
| waterway_label  |    |    |    |    |    |    |    |    |  x |  x |  x  |  x  |  x  |  x  |  x  |
| housenum_label  |    |    |    |    |    |    |    |    |    |    |     |     |     |     |  x  |

## #landuse

This layer includes polygons representing both land-use and land-cover.

It’s common for many different types of landuse/landcover to be overlapping, so the polygons in this layer are ordered by the area of their geometries to ensure smaller objects will not be obscured by larger ones. Pay attention to use of transparency when styling - the overlapping shapes can cause muddied or unexpected colors.

![](/media/layer_diagrams/landuse.png)

### Classes

The main field used for styling the landuse layer is `class`.
Class is a generalization of the various OSM values described as `types`.

| Class              | Aggregated Types
|--------------------|-----------------------------------------------------------------
|`agriculture`       | `orchard`, `farm`, `farmland`, `farmyard`, `allotments`, `vineyard`, `plant_nursery`
|`cemetery`          | `cemetery`, `christian`, `jewish`
|`glacier`           | `glacier`
|`grass`             | `grass`, `grassland`, `meadow`
|`hospital`          | `hospital`
|`industrial`        | `industrial`
|`park`              | `park`, `dog_park`, `common`, `garden`, `golf_course`, `playground`, `recreation_ground`, `nature_reserve`, `national_park`, `village_green`, `zoo`
|`pitch`             | `athletics`, `chess`, `pitch`
|`sand`              | `sand`
|`school`            | `school`, `college`, `university`
|`scrub`             | `scrub`
|`wood`              | `wood`, `forest`,

## #water

This is a simple polygon layer with no differentiating types or classes. Water bodies are filtered and simplified according to scale - only oceans and very large lakes are shown at the lowest zoom levels, while smaller and smaller lakes and ponds appear as you zoom in.

![](/media/layer_diagrams/water.png)

## #waterway

The waterway layer contains rivers, streams, canals, etc represented as lines.

![](/media/layer_diagrams/waterway.png)

### Types

The `type` column can contain one of the following types:

- `ditch`
- `stream`
- `stream_intermittent`
- `river`
- `canal`
- `drain`
- `ditch`

## #aeroway

The aeroway layer contains the types runway, taxiway, apron and helipad.

![](/media/layer_diagrams/aeroway.png)

## #barrier_line

The barrier_line layer contains the classes fence, cliff, gate.

![](/media/layer_diagrams/barrier_line.png)

### Classes

| Class             | Aggregated Types
|-------------------|-----------------------------------------------------------------
| cliff             | `cliff`
| fence             | `city_wall`, `fence`, `retaining_wall`, `wall`, `wire_fence`, `yes`, `embankment`, `cable_barrier`, `jersey_barrier`
| gate              | `gate`, `entrance`, `spikes`, `bollard`, `lift_gate`, `kissing_gate`, `stile`

## #building

This layer contains buildings. Buildings are shown starting zoom level 13.

![](/media/layer_diagrams/building.png)

## #landuse_overlay

This layer is for landuse polygons that should be drawn above the #water layer.

![](/media/layer_diagrams/landuse_overlay.png)

### Classes

| Class             | Aggregated Types
|-------------------|-----------------------------------------------------------------
| wetland           | `wetland`, `marsh`, `swamp`, `bog


## #tunnel #road #bridge

The layers tunnel and bridge are based of the layer road. 

![](/media/layer_diagrams/tunnel.png) ![](/media/layer_diagrams/road.png) ![](/media/layer_diagrams/bridge.png)

### Classes

The main field used for styling the tunnel, road, and bridge layers is class.

| Class             | Aggregated Types
|-------------------|-----------------------------------------------------------------
| `motorway`        | `motorway`
| `motorway_link`   | `motorway_link`
| `driveway`        | `driveway`
| `main`            | `primary`, `primary_link`, `trunk`, `trunk_link`, `secondary`, `secondary_link`, `tertiary`, `tertiary_link`
| `street`          | `residential`, `unclassified`, `living_street`, `road`, `raceway`
| `street_limited`  | `pedestrian`, `construction`, `private`
| `service`         | `service`, `track`, `alley`, `spur`, `siding`, `crossover`
| `path`            | `path`, `cycleway`, `ski`, `steps`, `bridleway`, `footway`
| `major_rail`      | `rail`, `monorail`, `narrow_gauge`, `subway`
| `minor_rail`      | `funicular`, `light_rail`, `preserved`, `tram`, `disused`, `yard`
| `aerialway`       | `chair_lift`, `mixed_lift`, `drag_lift`, `platter`, `t-bar` `magic_carpet`, `gondola`, `cable_car`, `rope_tow`, `zip_line`, `j-bar`, `canopy`
| `golf`            | `hole`

## #admin

This layer contains the administrative boundary lines. These are based on Natural Earth data on lower zoom levels (0-6) and OSM data (7-14) on upper zoom levels.

![](/media/layer_diagrams/admin.png)

### Administrative Level

| Value             | Aggregated Types
|-------------------|-----------------------------------------------------------------
| `2`        		| counties
| `4`        		| states, provinces

### Disputes

The disputed field should be used to apply a dashed or otherwise distinct style to disputed boundaries. No single map of the world will ever keep everybody happy, but acknowledging disputes where they exist is an important aspect of good cartography.

### Maritime boundaries

The maritime field can be used as a filter to downplay or hide maritime boundaries, which are often not shown on maps.  

## #country_label

The country_label layer contains the labels of all countries with translated names.

![](/media/layer_diagrams/country_label.png)

### Scalerank

The scalerank field is used to hide or show the label based on the importance, size and available room.

## #marine_label

The marine_label layer contains labels for marine features such as oceans, seas, large lakes and bays.

![](/media/layer_diagrams/marine_label.png)

### Labelrank

The labelrank is used to hide or show the label based on the importance, size and available room.

## #state_label

The layer state_label contains labels for large provinces in large countries such as China, USA, Russia, Australia and UK. 

## #place_label

The layer place_label contains labels for cities. 

![](/media/layer_diagrams/place_label.png)

### Scalerank

The scalerank is used to hide or show the label based on the importance, size and available room.

### Localrank

The localrank field can be used to adjust the label density by showing fewer labels. 

## #water_label

The layer water_label contains labels for bodies of water such as lakes.

![](/media/layer_diagrams/water_label.png)

## #road_label

![](/media/layer_diagrams/road_label.png)

### Classes

| Class             | Aggregated Types
|-------------------|-----------------------------------------------------------------
| `motorway`        | `motorway`
| `motorway_link`   | `motorway_link`
| `driveway`        | `driveway`
| `main`            | `primary`, `primary_link`, `trunk`, `trunk_link`, `secondary`, `secondary_link`, `tertiary`, `tertiary_link`
| `street`          | `residential`, `unclassified`, `living_street`, `road`, `raceway`
| `street_limited`  | `pedestrian`, `construction`, `private`
| `service`         | `service`, `track`, `alley`, `spur`, `siding`, `crossover`
| `path`            | `path`, `cycleway`, `ski`, `steps`, `bridleway`, `footway`
| `major_rail`      | `rail`, `monorail`, `narrow_gauge`, `subway`
| `minor_rail`      | `funicular`, `light_rail`, `preserved`, `tram`, `disused`, `yard`
| `aerialway`       | `chair_lift`, `mixed_lift`, `drag_lift`, `platter`, `t-bar` `magic_carpet`, `gondola`, `cable_car`, `rope_tow`, `zip_line`, `j-bar`, `canopy`
| `golf`            | `hole`

## #waterway_label

The layer waterway_label contains labels for rivers.

![](/media/layer_diagrams/waterway_label.png)

## #housenum_label

![](/media/layer_diagrams/housenum_label.png)

This layer contains points used to label the street number parts of specific addresses.
Both housenumber polygons and points were mapped to a single layer.

The `house_num` field countains house and building numbers.

## #poi_label

The poi_label layer is used to place icons and labels for various point of interests.

![](/media/layer_diagrams/poi_label.png)

### Names

Names are available in all languages (`name`, `name_en`, `name_de`, `name_fr`, `name_es`, `name_ru`, `name_zh`).

### Scalerank

| Scalerank         | Description
|-------------------|-----------------------------------------------------------------
| 1                 | The POI has a very large area `>145000`
| 2                 | The POI has a medium-large area `>12780`
| 3                 | The POI has a small area `2960` or is a `station`
| 4                 | The POI has no known area 

### Localrank

The `localrank` field can be used to adjust the label density by showing fewer labels.
The `localrank` is a whole number which starts at `1` and groups places in a grid
by their importance.

Importance of POIs are weighted in the following order:

 1. `station`, `subway_entrance`, `park`, `cemetery`, `bank`, `supermarket`, `car`, `library`, `university`, `college`, `police`, `townhall`, `courthouse`
 2. `nature_reserve`, `garden`, `public_building`
 3. `stadium`
 4. `hospital`
 5. `zoo`
 6. `university`, `school`, `college`, `kindergarten`
 7. `supermarket`, `department_store`
 8. `nature_reserve`, `swimming_area`
 9. `attraction`



### Maki Labels and Types

The `type` field in the `#poi_label` layer is mapped to the appropriate Maki label
which can be queried in `maki`. Types are stored in a human readable format
in the data where `chair_lift` becomes `Chair lift` so you can use the `type` field
for as label.

| Maki Label              | Aggregated Types
|-------------------------|-----------------------------------------------------------------
| `aerialway`               | `chair_lift`, `mixed_lift`, `drag_lift`, `platter`, `t`-bar, `magic_carpet`, `gondola`, `cable_car`, `rope_tow`, `zip_line`, `j`-bar, `canopy`
| `airport`                 | `aerodrome`, `terminal`, `apron`, `gate`, `taxiway`
| `american-football`       | `american_football`
| `art-gallery`             | `accessories`, `antiques`, `art`, `artwork`, `gallery`, `arts_centre`
| `alcohol-shop`            | `alcohol`, `beverages`, `wine`
| `amenity`                 | `courthouse`, `community_centre`, `nursing_home`, `veterinary`, `nightclub`, `recycling`, `food_court`
| `barrier`                 | `sally_port`, `lift_gate`, `gate`, `bollard`, `stile`, `cycle_barrier`, `toll_booth`, `border_control`
| `bakery`                  | `bakery`
| `bank`                    | `bank`
| `bar`                     | `bar`
| `beer`                    | `biergarten`, `pub`
| `baseball`                | `baseball`
| `basketball`              | `basketball`
| `building`                | `public_building`
| `bus`                     | `bus_stop`
| `bicycle`                 | `bicycle`, `bicycle_rental`
| `cafe`                    | `cafe`
| `campsite`                | `camp_site`
| `car`                     | `car`, `car_repair`
| `camera`                  | `video`, `electronics` 
| `cemetery`                | `grave_yard`, `cemetery`
| `cinema`                  | `cinema`
| `clothing-store`          | `bag`, `clothes`
| `college`                 | `university`, `college`
| `cricket`                 | `cricket`
| `dentist`                 | `dentist`, `doctor`
| `dog-park`                | `dog_park`
| `embassy`                 | `embassy`
| `entrance`                | `subway_entrance`
| `ferry`                   | `ferry_terminal`
| `fast-food`               | `fast_food`
| `fire-station`            | `fire_station`
| `fuel`                    | `fuel`
| `garden`                  | `garden`
| `gift`                    | `gift` 
| `golf`                    | `golf`, `golf_course`
| `grocery`                 | `supermarket`, `deli`, `delicatessen`, `department_store`, `greengrocer`
| `sport`                   | `multi`, `equestrian`, `athletics`, `volleyball`, `climbing`, `bowls`, `skateboard`, `shooting`, `skiing`, `boules`, `beachvolleyball`, `cricket`, `table_tennis`, `hockey`, `gymnastics`, `running`, `canoe`, `rugby_union`, `skating`, `scuba_diving`, `motor`, `horse_racing`, `handball`, `team_handball`, `karting`, `cycling`, `archery`, `motocross`, `pelota`, `rugby`, `gaelic_games`, `model_aerodrome`, `netball`, `rugby_league`, `free_flying`, `rowing`, `chess`, `australian_football`, `cricket_nets`, `racquet`, `bmx`, `sailing`, `ice_stock`, `badminton`, `paddle_tennis`, `dog_racing`, `fatsal`, `billiards`, `ice_hockey`, `yoga`, `disc_golf`, `orienteering`, `toboggan`, `horseshoes`, `paragliding`, `korfball`, `diving`, `rc_car`, `canadian_football`, `field_hockey`, `shooting_range`, `boxing`, `curling`, `surfing`, `water_ski`, `judo`, `croquet`, `paintball`, `climbing_adventure`, `long_jump`, `table_soccer`
| `tourism`                 | `attraction`, `caravan_site`, `theme_park`
| `hairdresser`             | `hairdresser`
| `heliport`                | `helipad`
| `hospital`                | `hospital`
| `highway`                 | `motorway_junction`, `turning_circle`
| `ice-cream`               | `chocolate`, `confectionery`
| `laundry`                 | `laundry`, `dry_cleaning`
| `library`                 | `books`, `library`
| `lodging`                 | `hotel`, `motel`, `bed_and_breakfast`, `guest_house`, `hostel`, `chalet`, `alpine_hut`, `camp_site`
| `leisure`                 | `sports_centre`, `water_park`, `stadium`, `ice_rink`
| `mobilephone`             | `mobile_phone`
| `monument`                | `monument`
| `museum`                  | `museum`
| `music`                   | `music`, `musical_instrument`
| `park`                    | `park`, `viewpoint`
| `pharmacy`                | `pharmacy`
| `pitch`                   | `pitch`
| `place-of-worship`        | `place_of_worship`
| `playground`              | `playground`
| `police`                  | `police`
| `post`                    | `post_box`, `post_office`
| `prison`                  | `prison`
| `rail`                    | `station`
| `railway`                 | `halt`, `tram_stop`, `crossing`, `level_crossing`
| `restaurant`              | `restaurant`
| `school`                  | `school`, `kindergarten`
| `shop`                    | `accessories`, `antiques`, `art`, `beauty`, `bed`, `boutique`, `carpet`, `charity`, `chemist`, `chocolate`, `coffee`, `computer`, `confectionery`, `convenience`, `copyshop`, `cosmetics`, `garden_centre`, `doityourself`, `erotic`, `fabric`, `florist`, `furniture`, `video_games`, `general`, `gift`, `hardware`, `hearing_aids`, `hifi`, `ice_cream`, `interior_decoration`, `jewelry`, `kiosk`, `lamps`, `mall`, `massage`, `motorcycle`, `newsagent`, `optician`, `outdoor`, `perfumery`, `perfume`, `pet`, `photo`, `second_hand`, `shoes`, `sports`, `stationery`, `tailor`, `tattoo`, `ticket`, `tobacco`, `toys`, `travel_agency`, `watches`, `weapons`, `wholesale`
| `skiing`                  | `skiing`
| `slaughterhouse`          | `butcher` 
| `soccer`                  | `soccer`
| `swimming`                | `swimming_pool`, `swimming_area`, `swimming`
| `telephone`               | `telephone`
| `tennis`                  | `tennis`
| `theater`                 | `theater`
| `town-hall`               | `townhall`
| `waste-basket`            | `waste_basket`
| `zoo`                     | `zoo`
