# Compare vector tiles

A vector tile can have multiple layers(admin, landuse, water), each layer can have a class(park, wood) and every class can have a type(nature_reserve, forest).

To compare two styles just click on the green compare pull request button and choose which styles you want to compare.

Ouput structure:

```
[style-name]
[tile-number z/y/x]
[amount-features]
[amount-layers]
[amount-classes]
[amount-types]

[layer]
    [class]
        [type]
```

Output sample:

```
name: mapbox-streets-v5
tile: 7/67/44
features: 2298
layers: 9
classes: 6
types: 3

landuse (features: 1314)
	park
		nature_reserve
		park
	wood
		forest
		wood

```
