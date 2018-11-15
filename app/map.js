import {select, selectAll, event} from 'd3-selection';
import {geoPath} from 'd3-geo';
import {format} from 'd3-format';
import * as topojson from "topojson";
import {annotation, annotationLabel,annotationCalloutCircle} from "d3-svg-annotation";
import map from '../sources/mn-precincts-topo.json';

var annotation_data = [
  {
    type: annotationLabel,
    note: {
        label: "Duluth anchors the Eighth Congressional District, one of several districts where a competitive primary may have helped drive high Democratic turnout.",
        wrap: 170,
        lineType:'none',
        align: 'left'
    },
    color: "black",
    y: 435,
    x: 430,
    dy: 15,
    dx: 15
  },
  {
    type: annotationCalloutCircle,
    note: {
        label: "The DFL saw its turnout advantage extend to many rural precincts in western Minnesota, including several in Kittson County.",
        wrap: 130,
        lineType:'none',
        align: 'middle'
    },
    color: "black",
    //settings for the subject, in this case the circle radius
    subject: {
      radius: 20
    },
    y: 195,
    x: 40,
    dy: -35,
    dx: 30
  },
  {
    type: annotationCalloutCircle,
    note: {
        label: "DFL voters turned out at higher rates than Republicans throughout a ring of suburban precincts, including these in Dakota County, many of which voted for Donald Trump in 2016.",
        wrap: 150,
        lineType:'vertical'
    },
    color: "black",
    //settings for the subject, in this case the circle radius
    subject: {
      radius: 10
    },
    y: 670,
    x: 360,
    dy: -10,
    dx: 50
  },]

class StribPrecinctMap {

  constructor(target) {
    this.target = target;
    this.svg = select(this.target);
    this.path = geoPath();
    this.m = map;
  }
  
  _renderState() {
    var self = this;
      
    self.svg.append("g")
      .selectAll("path")
      .data(topojson.feature(map, this.m.objects['mn-state-longlat']).features)
      .enter().append("path")
        .attr("d", self.path)
        .attr("class", "map-state-boundary");    
  }
  
  _renderCities(tiers) {
    var self = this;

    self.svg.append("g")
      .selectAll("circle")
        .data(topojson.feature(map, this.m.objects.cities).features.filter(
          d => tiers.includes(d.properties.TIER)
        ))
        .enter().append("circle")
          .attr("cx", function (d) {
            return d.geometry.coordinates[0];
          })
          .attr("cy", function (d) {
            return d.geometry.coordinates[1];
          })
          .attr("r", function (d) {
            if (d.properties.TIER == 1) {
              return '5px';
            } else if (d.properties.TIER == 2) {
              return '3px';
            } else {
              return '2px';
            }
          })
          .attr("class", function (d) {
            var tier = d.properties.TIER;
            if (tier == 1) {
              return 'map-city-point-large';
            } else if (tier == 2) {
              return 'map-city-point-medium';
            } else if (tier == 3 || tier == 4) {
              return 'map-city-point-small';
            }
          });

    this.svg.append("g")
      .selectAll("text")
      .data(topojson.feature(map, this.m.objects.cities).features.filter(
        d => tiers.includes(d.properties.TIER)
      ))
      .enter().append("text")
        .attr("dx", function (d) {
          return d.geometry.coordinates[0] + parseInt(d.properties.DX);
        })
        .attr("dy", function (d) {
          return d.geometry.coordinates[1] + parseInt(d.properties.DY);
        })
        .text(function (d) { return d.properties.NAME; })
        .attr('text-anchor', function (d) {
          return d.properties.ANCHOR;
        })
        .attr("class", function (d) {
          var tier = d.properties.TIER;
          if (tier == 1) {
            return 'map-city-label-large';
          } else if (tier == 2) {
            return 'map-city-label-medium';
          } else if (tier == 3 || tier == 4) {
            return 'map-city-label-small';
          }
        });
  }
  
  _renderPrecincts() {
    var self = this;

    self.svg.append("g")
      .selectAll("path")
      .data(topojson.feature(map, this.m.objects['mn-precincts-geo']).features)
      .enter().append("path")
        .attr("d", self.path)
        .attr("class", function(d) {
          var c = 'map-precinct-boundary';
 
          // Set flipper categories
          if (d.properties.winner16pres == 'R') {
            c += ' r16';
          }
          if (d.properties.r16_dgov18 == 'y') {
            c += ' dgov18';
          }
          if (d.properties.r16_dsen18 == 'y') {
            c += ' dsen18';
          }
          if (d.properties.r16_dsenspec18 == 'y') {
            c += ' dsenspec18';
          }
          if (d.properties.split18 == 'y') {
            c += ' split18';
          }
          if (d.properties.winner18sen == 'DFL') {
            c += ' klobuchar18';
          }
          if (d.properties.winner18sen == 'R') {
            c += ' newberger18';
          }
          if (d.properties.winner18sen == 'even') {
            c += ' even18';
          }

          // Set opacity groupings
          let votes_sqmi = d.properties.votes18_sqmi;

          // Opacity based on density
          if (votes_sqmi >= 500) {
            c += ' o5';
          } else if (votes_sqmi < 500  && votes_sqmi >= 100) {
            c += ' o4';
          } else if (votes_sqmi < 100 && votes_sqmi >= 25) {
            c += ' o3';
          } else if (votes_sqmi < 25 && votes_sqmi >= 10) {
            c += ' o2';
          } else {
            c += ' o1';
          }

          return c;
        })
  }

  _renderRoads() {
    var self = this;
      
    self.svg.append("g")
      .selectAll("path")
      .data(topojson.feature(map, this.m.objects.roads).features)
      .enter().append("path")
        .attr("d", self.path)
        .attr("class",  function(d) {
          if (d.properties.RTTYP == 'I') {
            return "map-interstate-boundary";
          } else {
            return "map-road-boundary";
          }
        });
  } 

  _renderAnnotations() {
    const makeAnnotations = annotation()
      .type(annotationLabel)
      .annotations(annotation_data);

    this.svg.append("g")
      .attr("class", "annotation-group")
      .call(makeAnnotations);
  } 

  transition(state) {
    var self = this; 

    if (state == 'default') {
      selectAll(".map-precinct-boundary")
        .attr('style', "fill:#f8f8f8;");
    }

    if (state == 'r16') {
      selectAll(".map-precinct-boundary")
        .attr('style', "fill:#f8f8f8;");
      selectAll('.map-precinct-boundary.r16')
        .attr("style", "fill:#C0272D");
    }

    if (state == 'dsen18') {
      selectAll('.map-precinct-boundary.r16')
        .attr("style", "fill:#f9eaeb;");
      selectAll('.map-precinct-boundary.r16.dsen18')
        .attr("style", "fill:#0258A0");
    }

    if (state == 'dgov18') {
      selectAll('.map-precinct-boundary.r16')
        .attr("style", "fill:#f9eaeb;");
      selectAll('.map-precinct-boundary.r16.dsen18')
        .attr("style", "fill:#f9eaeb");
      selectAll('.map-precinct-boundary.r16.dgov18')
        .attr("style", "fill:#0258A0");
    }

    if (state == 'dsenspec18') {
      selectAll('.map-precinct-boundary.r16')
        .attr("style", "fill:#f9eaeb;");
      selectAll('.map-precinct-boundary.r16.dsen18')
        .attr("style", "fill:#f9eaeb");
      selectAll('.map-precinct-boundary.r16.dgov18')
        .attr("style", "fill:#f9eaeb");
      selectAll('.map-precinct-boundary.r16.dsenspec18')
        .attr("style", "fill:#0258A0");
    }

    if (state == 'split') {
      selectAll(".map-precinct-boundary")
        .attr('style', "fill:#f8f8f8;");
      selectAll('.map-precinct-boundary.r16')
        .attr("style", "fill:#f9eaeb;");
      selectAll('.map-precinct-boundary.split18')
        .attr("style", "fill:#0258A0");
    }  

    if (state == 'fullresults') {
      selectAll(".map-precinct-boundary")
        .attr('style', "fill:#f8f8f8;");
      selectAll('.map-precinct-boundary.klobuchar18')
        .attr("style", "fill:#0258A0");
      selectAll('.map-precinct-boundary.newberger18')
        .attr("style", "fill:#C0272D");
      selectAll('.map-precinct-boundary.even18')
        .attr("style", "fill:#874e8e");
    }

  }

  render(cities=[1, 2, 3, 4]) {
    var self = this;
          
    self._renderState();
    self._renderPrecincts();
    self._renderRoads();
    self._renderCities(cities);
    // self._renderAnnotations();
  }
}

export { StribPrecinctMap as default }