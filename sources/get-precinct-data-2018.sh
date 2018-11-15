PRES16=https://electionresults.sos.state.mn.us/Results/MediaResult/100?mediafileid=52 \
GOV18=https://electionresults.sos.state.mn.us/Results/MediaResult/115?mediafileid=39 \
SEN18=https://electionresults.sos.state.mn.us/Results/MediaResult/115?mediafileid=28 \

echo "Downloading 2018 precincts ..." &&
wget ftp://ftp.gisdata.mn.gov/pub/gdrs/data/pub/us_mn_state_sos/bdry_votingdistricts/shp_bdry_votingdistricts.zip && \
  unzip shp_bdry_votingdistricts.zip  && \
  shp2json bdry_votingdistricts.shp | \
  mapshaper - -quiet -proj longlat from=bdry_votingdistricts.prj -o ./bdry_votingdistricts.json format=geojson && \
  cat bdry_votingdistricts.json | \
  geo2topo precincts=- > ./mn-precincts-longlat.tmp.json && \
  rm bdry_votingdistricts.* && \
  rm -rf ./metadata && \
  rm shp_bdry_votingdistricts.* &&

########## GET PRECINCT RESULTS ##########

echo "Downloading precinct results ..." &&

echo "2016 president ..." &&
echo "state;county_id;precinct_id;office_id;office_name;district;\
cand_order;cand_name;suffix;incumbent;party;precincts_reporting;\
precincts_voting;votes;votes_pct;votes_office" | \
  cat - <(wget -O - -o /dev/null $PRES16) > mn-pres-16.tmp.csv &&

echo "2018 governor ..." &&
echo "state;county_id;precinct_id;office_id;office_name;district;\
cand_order;cand_name;suffix;incumbent;party;precincts_reporting;\
precincts_voting;votes;votes_pct;votes_office" | \
  cat - <(wget -O - -o /dev/null $GOV18) > mn-gov-18.tmp.csv &&

echo "2018 senate ..." &&
echo "state;county_id;precinct_id;office_id;office_name;district;\
cand_order;cand_name;suffix;incumbent;party;precincts_reporting;\
precincts_voting;votes;votes_pct;votes_office" | \
  cat - <(wget -O - -o /dev/null $SEN18) | \
  csv2json -r ";" | \
  ndjson-split | \
  ndjson-filter 'd.office_id == "0102"' | \
  ndjson-reduce | \
  json2csv -w ";" > mn-sen-18.tmp.csv

echo "2018 senate special ..." &&
echo "state;county_id;precinct_id;office_id;office_name;district;\
cand_order;cand_name;suffix;incumbent;party;precincts_reporting;\
precincts_voting;votes;votes_pct;votes_office" | \
  cat - <(wget -O - -o /dev/null $SEN18) | \
  csv2json -r ";" | \
  ndjson-split | \
  ndjson-filter 'd.office_id == "0103"' | \
  ndjson-reduce | \
  json2csv -w ";" > mn-senspec-18.tmp.csv

######### PROCESS RESULTS ##########

echo "Calculating winners ..."

echo "2016 president ..." &&
cat mn-pres-16.tmp.csv | \
  csv2json -r ";" | \
  ndjson-split | \
  ndjson-map '{"id":  d.county_id + d.precinct_id, "county_id": d.county_id, "precinct_id": d.precinct_id, "party": d.party, "votes": parseInt(d.votes), "votes_pct": parseFloat(d.votes_pct)}' | \
  ndjson-reduce '(p[d.id] = p[d.id] || []).push({party: d.party, votes: d.votes, votes_pct: d.votes_pct}), p' '{}' | \
  ndjson-split 'Object.keys(d).map(key => ({id: key, votes: d[key]}))' | \
  ndjson-map '{"id": d.id, "votes": d.votes.filter(obj => obj.party != "").sort((a, b) => b.votes - a.votes)}' | \
  ndjson-map '{"id": d.id, "votes": d.votes, "winner": d.votes[0].votes > 0 ? d.votes[0].votes != d.votes[1].votes ? ["DFL", "R"].includes(d.votes[0].party) ? d.votes[0].party : "OTH" : "even" : "none", "winner_margin": (d.votes[0].votes_pct - d.votes[1].votes_pct).toFixed(2)}' | \
  ndjson-map '{"id": d.id, "winner": d.winner, "winner_margin": d.winner_margin, "total_votes": d.votes.reduce((a, b) => a + b.votes, 0), "votes_obj": d.votes}' > joined-pres-16.tmp.ndjson &&

echo "2018 governor ..." &&
cat mn-gov-18.tmp.csv | \
  csv2json -r ";" | \
  ndjson-split | \
  ndjson-map '{"id":  d.county_id + d.precinct_id, "county_id": d.county_id, "precinct_id": d.precinct_id, "party": d.party, "votes": parseInt(d.votes), "votes_pct": parseFloat(d.votes_pct)}' | \
  ndjson-reduce '(p[d.id] = p[d.id] || []).push({party: d.party, votes: d.votes, votes_pct: d.votes_pct}), p' '{}' | \
  ndjson-split 'Object.keys(d).map(key => ({id: key, votes: d[key]}))' | \
  ndjson-map '{"id": d.id, "votes": d.votes.filter(obj => obj.party != "").sort((a, b) => b.votes - a.votes)}' | \
  ndjson-map '{"id": d.id, "votes": d.votes, "winner": d.votes[0].votes > 0 ? d.votes[0].votes != d.votes[1].votes ? ["DFL", "R"].includes(d.votes[0].party) ? d.votes[0].party : "OTH" : "even" : "none", "winner_margin": (d.votes[0].votes_pct - d.votes[1].votes_pct).toFixed(2)}' | \
  ndjson-map '{"id": d.id, "winner": d.winner, "winner_margin": d.winner_margin, "total_votes": d.votes.reduce((a, b) => a + b.votes, 0), "votes_obj": d.votes}' > joined-gov-18.tmp.ndjson &&

echo "2018 senate ..." &&
cat mn-sen-18.tmp.csv | \
  csv2json -r ";" | \
  ndjson-split | \
  ndjson-filter 'd.office_id == "0102"' | \
  ndjson-map '{"id":  d.county_id + d.precinct_id, "county_id": d.county_id, "precinct_id": d.precinct_id, "party": d.party, "votes": parseInt(d.votes), "votes_pct": parseFloat(d.votes_pct)}' | \
  ndjson-reduce '(p[d.id] = p[d.id] || []).push({party: d.party, votes: d.votes, votes_pct: d.votes_pct}), p' '{}' | \
  ndjson-split 'Object.keys(d).map(key => ({id: key, votes: d[key]}))' | \
  ndjson-map '{"id": d.id, "votes": d.votes.filter(obj => obj.party != "").sort((a, b) => b.votes - a.votes)}' | \
  ndjson-map '{"id": d.id, "votes": d.votes, "winner": d.votes[0].votes > 0 ? d.votes[0].votes != d.votes[1].votes ? ["DFL", "R"].includes(d.votes[0].party) ? d.votes[0].party : "OTH" : "even" : "none", "winner_margin": (d.votes[0].votes_pct - d.votes[1].votes_pct).toFixed(2)}' | \
  ndjson-map '{"id": d.id, "winner": d.winner, "winner_margin": d.winner_margin, "total_votes": d.votes.reduce((a, b) => a + b.votes, 0), "votes_obj": d.votes}' > joined-sen-18.tmp.ndjson &&

echo "2018 senate special ..." &&
cat mn-senspec-18.tmp.csv | \
  csv2json -r ";" | \
  ndjson-split | \
  ndjson-filter 'd.office_id == "0103"' | \
  ndjson-map '{"id":  d.county_id + d.precinct_id, "county_id": d.county_id, "precinct_id": d.precinct_id, "party": d.party, "votes": parseInt(d.votes), "votes_pct": parseFloat(d.votes_pct)}' | \
  ndjson-reduce '(p[d.id] = p[d.id] || []).push({party: d.party, votes: d.votes, votes_pct: d.votes_pct}), p' '{}' | \
  ndjson-split 'Object.keys(d).map(key => ({id: key, votes: d[key]}))' | \
  ndjson-map '{"id": d.id, "votes": d.votes.filter(obj => obj.party != "").sort((a, b) => b.votes - a.votes)}' | \
  ndjson-map '{"id": d.id, "votes": d.votes, "winner": d.votes[0].votes > 0 ? d.votes[0].votes != d.votes[1].votes ? ["DFL", "R"].includes(d.votes[0].party) ? d.votes[0].party : "OTH" : "even" : "none", "winner_margin": (d.votes[0].votes_pct - d.votes[1].votes_pct).toFixed(2)}' | \
  ndjson-map '{"id": d.id, "winner": d.winner, "winner_margin": d.winner_margin, "total_votes": d.votes.reduce((a, b) => a + b.votes, 0), "votes_obj": d.votes}' > joined-senspec-18.tmp.ndjson &&

######## JOIN RESULTS TOGETHER ##########

echo "Joining results together ..."
ndjson-join 'd.id' <(cat joined-pres-16.tmp.ndjson) <(cat joined-gov-18.tmp.ndjson) | \
  ndjson-map '{"id": d[0].id, "winner16pres": d[0].winner, "winner18gov": d[1].winner, "votes16pres": d[0].total_votes, "votes18gov": d[1].total_votes}' | \
ndjson-join 'd.id' - <(cat joined-sen-18.tmp.ndjson) | \
  ndjson-map '{"id": d[0].id, "winner16pres": d[0].winner16pres, "winner18gov": d[0].winner18gov, "winner18sen": d[1].winner, "votes16pres": d[0].votes16pres, "votes18gov": d[0].votes18gov, "votes18sen": d[1].total_votes}' | \
ndjson-join 'd.id' - <(cat joined-senspec-18.tmp.ndjson) | \
  ndjson-map '{"id": d[0].id, "winner16pres": d[0].winner16pres, "winner18gov": d[0].winner18gov, "winner18sen": d[0].winner18sen, "winner18senspec": d[1].winner, "votes16pres": d[0].votes16pres, "votes18gov": d[0].votes18gov, "votes18sen": d[0].votes18sen, "votes18senspec": d[1].total_votes}' > joined-all.tmp.ndjson &&

######### JOIN RESULTS TO MAPS ##########

echo "Joining results to maps ..."
ndjson-split 'd.objects.precincts.geometries' < mn-precincts-longlat.tmp.json | \
  ndjson-map -r d3 '{"type": d.type, "arcs": d.arcs, "properties": {"id": d3.format("02")(d.properties.COUNTYCODE) + d.properties.PCTCODE, "county": d.properties.COUNTYNAME, "precinct": d.properties.PCTNAME, "area_sqmi": d.properties.Shape_Area * 0.00000038610}}' > mn-precincts-longlat.tmp.ndjson &&
  ndjson-join 'd.properties.id' 'd.id' <(cat mn-precincts-longlat.tmp.ndjson) <(cat joined-all.tmp.ndjson) | \
   ndjson-map '{"type": d[0].type, "arcs": d[0].arcs, "properties": {"id": d[0].properties.id, "county": d[0].properties.county, "precinct": d[0].properties.precinct, "area_sqmi": d[0].properties.area_sqmi, "winner16pres": d[1].winner16pres, "winner18gov": d[1].winner18gov, "winner18sen": d[1].winner18sen, "winner18senspec": d[1].winner18senspec, "votes18_sqmi": d[1].votes18gov / d[0].properties.area_sqmi, "r16_dgov18": d[1].winner16pres == "R" && d[1].winner18gov == "DFL" ? "y" : "n", "r16_dsen18": d[1].winner16pres == "R" && d[1].winner18sen == "DFL" ? "y" : "n", "r16_dsenspec18": d[1].winner16pres == "R" && d[1].winner18senspec == "DFL" ? "y" : "n", "split18": (d[1].winner18gov == "R" && d[1].winner18senspec == "R") && d[1].winner18sen == "DFL"? "y" : "n"}}' | \
ndjson-reduce 'p.geometries.push(d), p' '{"type": "GeometryCollection", "geometries":[]}' > mn-precincts.geometries.tmp.ndjson &&

ndjson-join '1' '1' <(ndjson-cat mn-precincts-longlat.tmp.json) <(cat mn-precincts.geometries.tmp.ndjson) |
  ndjson-map '{"type": d[0].type, "bbox": d[0].bbox, "transform": d[0].transform, "objects": {"precincts": {"type": "GeometryCollection", "geometries": d[1].geometries}}, "arcs": d[0].arcs}' > mn-precincts-final.json &&
topo2geo precincts=mn-precincts-geo.json < mn-precincts-final.json &&

######### MAKE TOPOJSON ##########

echo "Making topojson ..."
mapshaper -i mn-precincts-geo.json ./layers/mn-roads-longlat.json ./layers/mn-state-longlat.json ./layers/mn-cities-longlat.json snap combine-files \
  -proj webmercator \
  -quiet \
  -simplify 10% \
  -o format=topojson ./mn-precincts-topo.json combine-layers width=640 height=960 force

######### CLEANUP ##########

echo "Cleaning up" &&
rm *.tmp.* &&
rm mn-precincts-final.json