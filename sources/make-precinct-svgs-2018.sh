echo "Ray: Trump 2016, Klobuchar 2018 ..."
mapshaper -i mn-precincts-geo.json \
  -quiet \
  -proj +proj=utm +zone=15 +ellps=GRS80 +datum=NAD83 +units=m +no_defs \
  -colorizer name=calcFill colors='#0258A0,#f9eaeb' categories="RDFL,RR" nodata='#dfdfdf' \
  -style fill='calcFill(winner16pres + winner18sen)' target="mn-precincts-geo" \
  -simplify 10% \
  -o ./output/trump2016_klobuchar2018.svg &&

echo "Ray: Trump 2016 ..."
mapshaper -i mn-precincts-geo.json \
  -quiet \
  -proj +proj=utm +zone=15 +ellps=GRS80 +datum=NAD83 +units=m +no_defs \
  -colorizer name=calcFill colors='#c0272d,#dfdfdf' categories="R,DFL" nodata='#dfdfdf' \
  -style fill='calcFill(winner16pres)' target="mn-precincts-geo" \
  -simplify 10% \
  -o ./output/trump2016.svg &&

# echo "R16 ..." &&
# mapshaper -i mn-precincts-geo.json ./layers/mn-roads-longlat.json ./layers/mn-state-longlat.json ./layers/mn-cities-longlat.json snap combine-files \
#   -quiet \
#   -proj webmercator \
#   -colorizer name=calcFill colors='#c0272d,#dfdfdf' categories="R,DFL" nodata='#dfdfdf' \
#   -colorizer name=calcOpacity colors='0.1,0.25,0.5,0.75,1,1' breaks=10,25,100,500,100000 \
#   -style fill='calcFill(winner16pres)' opacity='calcOpacity(votes18_sqmi)' target="mn-precincts-geo" \
#   -style stroke='#dcdcdc' stroke-width=0.5 target="roads" \
#   -style stroke='lightgray' fill="none" stroke-width=1 target="mn-state-longlat" \
#   -filter '"1,2".indexOf(TIER) > -1' target="cities" \
#   -style r=2 label-text='NAME' text-anchor="ANCHOR" dx="DX" dy="DY - 3" font-size="1.4em" font-family="Helvetica" stroke='darkgray' stroke-width=0.3 target="cities" \
#   -style where="TIER==2" font-size="1.1em" target="cities" \
#   -simplify 10% \
#   -o ./output/r16.svg combine-layers &&

# echo "R16, DGov18 ..." &&
# mapshaper -i mn-precincts-geo.json ./layers/mn-roads-longlat.json ./layers/mn-state-longlat.json ./layers/mn-cities-longlat.json snap combine-files \
#   -quiet \
#   -proj webmercator \
#   -colorizer name=calcFill colors='#0258a0,#dfdfdf' categories="y,n" nodata='#dfdfdf' \
#   -colorizer name=calcOpacity colors='0.1,0.25,0.5,0.75,1,1' breaks=10,25,100,500,100000 \
#   -style fill='calcFill(r16_dgov18)' opacity='calcOpacity(votes18_sqmi)' target="mn-precincts-geo" \
#   -style stroke='#dcdcdc' stroke-width=0.5 target="roads" \
#   -style stroke='lightgray' fill="none" stroke-width=1 target="mn-state-longlat" \
#   -filter '"1,2".indexOf(TIER) > -1' target="cities" \
#   -style r=2 label-text='NAME' text-anchor="ANCHOR" dx="DX" dy="DY - 3" font-size="1.4em" font-family="Helvetica" stroke='darkgray' stroke-width=0.3 target="cities" \
#   -style where="TIER==2" font-size="1.1em" target="cities" \
#   -simplify 10% \
#   -o ./output/r16-dgov18.svg combine-layers

# echo "R16, DSen18 ..." &&
# mapshaper -i mn-precincts-geo.json ./layers/mn-roads-longlat.json ./layers/mn-state-longlat.json ./layers/mn-cities-longlat.json snap combine-files \
#   -quiet \
#   -proj webmercator \
#   -colorizer name=calcFill colors='#0258a0,#dfdfdf' categories="y,n" nodata='#dfdfdf' \
#   -colorizer name=calcOpacity colors='0.1,0.25,0.5,0.75,1,1' breaks=10,25,100,500,100000 \
#   -style fill='calcFill(r16_dsen18)' opacity='calcOpacity(votes18_sqmi)' target="mn-precincts-geo" \
#   -style stroke='#dcdcdc' stroke-width=0.5 target="roads" \
#   -style stroke='lightgray' fill="none" stroke-width=1 target="mn-state-longlat" \
#   -filter '"1,2".indexOf(TIER) > -1' target="cities" \
#   -style r=2 label-text='NAME' text-anchor="ANCHOR" dx="DX" dy="DY - 3" font-size="1.4em" font-family="Helvetica" stroke='darkgray' stroke-width=0.3 target="cities" \
#   -style where="TIER==2" font-size="1.1em" target="cities" \
#   -simplify 10% \
#   -o ./output/r16-dsen18.svg combine-layers &&

# echo "R16, DSenSpec18 ..." &&
# mapshaper -i mn-precincts-geo.json ./layers/mn-roads-longlat.json ./layers/mn-state-longlat.json ./layers/mn-cities-longlat.json snap combine-files \
#   -quiet \
#   -proj webmercator \
#   -colorizer name=calcFill colors='#0258a0,#dfdfdf' categories="y,n" nodata='#dfdfdf' \
#   -colorizer name=calcOpacity colors='0.1,0.25,0.5,0.75,1,1' breaks=10,25,100,500,100000 \
#   -style fill='calcFill(r16_dsenspec18)' opacity='calcOpacity(votes18_sqmi)' target="mn-precincts-geo" \
#   -style stroke='#dcdcdc' stroke-width=0.5 target="roads" \
#   -style stroke='lightgray' fill="none" stroke-width=1 target="mn-state-longlat" \
#   -filter '"1,2".indexOf(TIER) > -1' target="cities" \
#   -style r=2 label-text='NAME' text-anchor="ANCHOR" dx="DX" dy="DY - 3" font-size="1.4em" font-family="Helvetica" stroke='darkgray' stroke-width=0.3 target="cities" \
#   -style where="TIER==2" font-size="1.1em" target="cities" \
#   -simplify 10% \
#   -o ./output/r16-dsenspec18.svg combine-layers