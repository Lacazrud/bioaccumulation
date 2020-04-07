globals [
  time
  lpop
  algaestart
  smallstart
  bigstart
  hgalgae
  sample
  hgbigstotal
  hgsmallstotal
  hgalgaetotal
  bigstotal
  smallstotal
  bigagetotal
  smallagetotal
]

breed [smalls small]

breed [bigs big ]
turtles-own [hg age eatcount]
patches-own [phg]
smalls-own [smallenergy]
bigs-own [bigenergy]

to default
  set EnergyUsageSliderBig 6
  set EnergyUsageSliderSmall 4
  set ReproduceThresholdSliderBig 0.15
  set ReproduceThresholdSliderSmall 0.20
  set SmallFishNutrition 50
  set AlgaeNutrition 16
  set SliderAlgaePopulation 0.60
  set startticks 1000
  set stopticks 5000

end


to setup

  clear-all
  reset-ticks
  set sample stopticks - startticks
  ifelse hgon = true
  [set hgalgae 1][set hgalgae 0]
  set algaestart sliderAlgaePopulation
  set smallstart 1000
  set bigstart 400


  ; PLOT ALGAE, USE SLIDER VALUE
  ask patches [
    if random-float 1.0 < algaestart [
      set phg hgalgae
      set pcolor green
    ]
  ]


  ; PLOT BIG FISH, USE SLIDER VALUE
  set-default-shape bigs "fish"
  create-bigs bigstart [
    set eatcount 0
    set color red
    move-to one-of patches
    rt random 360
    set bigenergy 100
  ]

  ;PLOT SMALL FISH, USE SLIDER VALUE
  set-default-shape smalls "turtle"
  create-smalls smallstart [
    set eatcount 0
    set color blue
    move-to one-of patches
    rt random 360
    set smallenergy 100
  ]

  ;set up age
  ask turtles [set age 0]
  reset-ticks
end

; Movement of fish (regardless of breed) over time. This function works fine.
to move
  if random 8 > 0 [
    let target one-of neighbors
    face target
    move-to target
  ]
end

; Energy consumption over time for small fish. This function works fine.
to energy-usage-small
  set smallenergy (smallenergy - EnergyUsageSliderSmall)
  ;print energy
end

; Energy consumption over time for big fish. This funtion works fine.
to energy-usage-big
  set bigenergy (bigenergy - EnergyUsageSliderBig)
end


; Algae eat function for small fish. This function works fine.
to eat-algae
  if pcolor = green [
    set smallenergy (smallenergy + AlgaeNutrition)
    set hg hg + [phg] of patch-here
    set pcolor black
    set phg 0
      set eatcount eatcount + 1
  ]
end


; Death of small fish. Small fish dies if random number is between smallenergy and 300. Slider has been commented out. This function works fine.
to death-small
    if smallenergy <= 0 [die]
  if random-float 1.0 < (1 - (smallenergy / 100 ) + hg / 25)
  [
      die
  ]
end


to eat-small-fish
let prey one-of smalls-here
if prey != nobody
  [
    ifelse random-float 1.0 < 0.4 ;40% chance to eat small, 60% chance the fish escapes
    [
      set eatcount eatcount + 1
     set hg (hg + ( [hg] of prey ))
      ask prey
      [
        die
      ]
        set bigenergy (bigenergy + SmallFishNutrition)

   set eatcount eatcount + 1
  ]
    [ask prey [move]]
  ]
end


; Big fish death function. Big fish dies if random number is larger than the large fish's energy level 'bigenergy'. This function works fine.
to death-big
  if bigenergy <= 0 [die]
if random-float 1.0 < (1 - ( bigenergy / 100 ) + hg / 200)
  [
      die
  ]
end

; Reproduction of small fish. Hatches 1 small fish if random number is larger than slider value. This function works fine.
to reproduce-small
  if random-float 1.0 < ReproduceThresholdSliderSmall  [
    ask patch-here [
    sprout-smalls 1 [
        set hg 0
          set color blue
          set age 0
      set smallenergy 100
      move
    ]
  ]
  ]
end

to reproduce-big

if random-float 1.0 < ReproduceThresholdSliderBig
  [
    ask patch-here [
        sprout-bigs 1 [
        set hg 0
          set color red
          set age 0
      set bigenergy 100
      move
    ]
  ]
    ]
end

to grow-algae
  if pcolor = green [
    ask one-of neighbors[
    if random-float 1.0 < 0.95 [
        set pcolor green
        ifelse hgon = true
  [set phg 1][set phg 0]
      ]
  ]
  ]
end

to go

  if (not any? bigs) or (not any? smalls) [stop]

  ask smalls [

    if smallenergy >= 100 [set smallenergy 100]
    move
    energy-usage-small
    if smallenergy <= 90
    [
    eat-algae
    ]

    death-small
    reproduce-small

  ]

  ask bigs [
    if bigenergy >= 100 [set bigenergy 100]
   move
   energy-usage-big
    if bigenergy <= 90
    [
      eat-small-fish
    ]
    death-big
    reproduce-big
  ]
  ;algae growth
  ask patches [ ifelse hgon = true
  [set phg phg + 0.01 ][set phg 0]
    grow-algae ]

  ask turtles [ ifelse hgon = true
  [set hg hg + 0.1][set phg 0]
  ]
  plot-conc

  tick

    if ticks > startticks
  [
    if ticks < stopticks
    [
     set hgalgaetotal hgalgaetotal + (mean [phg] of patches)
     set hgsmallstotal hgsmallstotal + (mean [hg] of smalls)
     set hgbigstotal hgbigstotal + (mean [hg] of bigs)
     set smallstotal smallstotal + (count smalls)
     set bigstotal bigstotal + (count bigs)
     set bigagetotal bigagetotal + (mean [age] of bigs)
     set smallagetotal smallagetotal + (mean [age] of smalls)
    ]
  ]
  if ticks = stopticks [
    type "average age of small fish = " print ( smallagetotal / sample )
    type "average age of big fish = " print ( bigagetotal / sample )
    type "average hg in patches = " print ( hgalgaetotal / sample )
    type "average hg in big fish = " print ( hgbigstotal / sample )
    type "average hg in small fish = " print ( hgsmallstotal / sample )
    type "average big population = " print ( bigstotal / sample )
    type "average small population = " print ( smallstotal / sample )
    stop
  ]
  ask turtles [set age age + 1]
  set time (time + 1)

end

to plot-conc
  set-current-plot "PopulationDensity"
  set-current-plot-pen "big-fish"
  plotxy time count bigs

  set-current-plot-pen "small-fish"
  plotxy time count smalls

  set-current-plot "Histogram-Mercury-Level"
  set-current-plot-pen "pen-1"
  histogram [hg] of bigs with [age > 5]
  set-current-plot-pen "pen-2"
  histogram [hg] of smalls with [age > 3]

  set-current-plot "Histogram-Age"
  set-current-plot-pen "bigage"
  histogram [age] of bigs
  set-current-plot-pen "smallage"
  histogram [age] of smalls
end
@#$#@#$#@
GRAPHICS-WINDOW
375
10
812
448
-1
-1
13.0
1
10
1
1
1
0
1
1
1
-16
16
-16
16
0
0
1
ticks
30.0

BUTTON
375
455
545
488
setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
552
456
702
489
go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
584
579
807
612
AlgaeNutrition
AlgaeNutrition
0
25
16.0
1
1
NIL
HORIZONTAL

SLIDER
391
577
579
610
SmallFishNutrition
SmallFishNutrition
0
500
50.0
1
1
NIL
HORIZONTAL

SLIDER
392
538
579
571
ReproduceThresholdSliderBig
ReproduceThresholdSliderBig
0
1
0.15
0.01
1
NIL
HORIZONTAL

SLIDER
585
538
807
571
ReproduceThresholdSliderSmall
ReproduceThresholdSliderSmall
0
1
0.2
0.01
1
NIL
HORIZONTAL

PLOT
1089
15
1458
303
PopulationDensity
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"big-fish" 1.0 0 -2674135 true "" ""
"small-fish" 1.0 0 -13345367 true "" ""
"pen-2" 1.0 0 -13840069 true "" "plot count patches with [pcolor = green]"

SLIDER
586
501
808
534
EnergyUsageSliderSmall
EnergyUsageSliderSmall
0
10
4.0
1
1
NIL
HORIZONTAL

SLIDER
390
500
579
533
EnergyUsageSliderBig
EnergyUsageSliderBig
0
10
6.0
1
1
NIL
HORIZONTAL

TEXTBOX
0
25
366
202
AlgaeNutrition = energy gained by eating algae\nSmallFishNutrition = energy gained by eating small fish\nEnergyUsageSliderSmall = energy lost by small fish for every tick.\nEnergyUsageSliderBig = energy lost by big fish for every tick.\nReproduceThresholdSliderSmall = reproduction rate of small fish\nReproduceThresholdSLiderBig = reproduction rate of big fish
11
0.0
1

PLOT
832
14
1079
164
Energy
NIL
NIL
0.0
1000.0
0.0
200.0
true
false
"" ""
PENS
"default" 1.0 0 -2674135 true "" "plot mean [bigenergy] of bigs"
"pen-1" 1.0 0 -13345367 true "" "plot mean [smallenergy] of smalls"

SLIDER
392
628
812
661
sliderAlgaePopulation
sliderAlgaePopulation
0
1
0.6
0.01
1
NIL
HORIZONTAL

MONITOR
1476
177
1628
222
NIL
mean [bigenergy] of bigs
17
1
11

MONITOR
1206
672
1367
717
NIL
max [hg] of turtles
17
1
11

MONITOR
1476
224
1628
269
NIL
min [bigenergy] of bigs
17
1
11

MONITOR
1476
424
1638
469
NIL
min [smallenergy] of smalls
17
1
11

PLOT
832
173
1080
450
Histogram-Mercury-Level
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"pen-1" 1.0 0 -2674135 true "" ""
"pen-2" 1.0 0 -13345367 true "" ""

PLOT
1090
333
1459
659
Mean Mercury
NIL
NIL
0.0
10.0
0.0
1.0
true
false
"" ""
PENS
"default" 1.0 0 -2674135 true "" "plot mean [hg] of bigs "
"pen-1" 1.0 0 -13345367 true "" "plot mean [hg] of smalls"
"pen-2" 1.0 0 -13840069 true "" "plot mean [phg] of patches"

SWITCH
706
454
814
487
hgon
hgon
0
1
-1000

PLOT
834
460
1081
657
Histogram-Age
NIL
NIL
0.0
20.0
0.0
10.0
true
false
"" ""
PENS
"bigage" 1.0 0 -2674135 true "" ""
"smallage" 1.0 0 -13345367 true "" ""

MONITOR
1477
377
1638
422
NIL
mean [smallenergy] of smalls
17
1
11

PLOT
161
263
361
413
Age
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -2674135 true "" "plot mean [age] of bigs"
"pen-1" 1.0 0 -13345367 true "" "plot mean [age] of smalls"

PLOT
168
494
368
644
eatcount
NIL
NIL
0.0
10.0
0.0
5.0
true
false
"" ""
PENS
"default" 1.0 0 -2674135 true "" "plot mean [eatcount] of bigs"
"pen-1" 1.0 0 -13345367 true "" "plot mean [eatcount] of smalls"

SLIDER
394
677
566
710
startticks
startticks
0
3000
1000.0
200
1
NIL
HORIZONTAL

SLIDER
584
676
756
709
stopticks
stopticks
startticks + 200
8000
5000.0
200
1
NIL
HORIZONTAL

MONITOR
776
680
878
725
Sample Tick Size
Sample
17
1
11

BUTTON
292
453
364
486
NIL
Default
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.1.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
