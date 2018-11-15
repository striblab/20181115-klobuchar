import 'intersection-observer';
import scrollama from "scrollama";
import {select, selectAll, event} from 'd3-selection';
import StribPrecinctMap from './map.js';

// Doing these as constants for now because confusing ES6 "this" scoping + laziness
const map = new StribPrecinctMap('#map-zoomer');
const scroller = scrollama();

class ScrollyGraphic {

  constructor() {
    this.container = select('#scroll');
    this.graphic = this.container.select('.scroll__graphic');
    this.chart = this.graphic.select('#map-container');
    this.t = this.container.select('.scroll__text');
    this.step = this.t.selectAll('.step');
    this.map = new StribPrecinctMap('#precinct-map');
  }

  /********** PRIVATE METHODS **********/

  // generic window resize listener event
  _handleResize() {
    var self = this;

    // 1. update height of step elements
    var stepHeight = Math.floor(window.innerHeight * 0.75);
    this.step.style('height', stepHeight + 'px');

    // 2. update width/height of graphic element
    var bodyWidth = select('body').node().offsetWidth;
    var textWidth = this.t.node().offsetWidth;

    // 3. tell scrollama to update new element dimensions
    scroller.resize();
  }

  // scrollama event handlers
  _handleStepEnter(response) {
    // add color to current step only
    this.step.classed('is-active', function (d, i) {
      return i === response.index;
    })

    if (response.index == 1) {
      this.map.transition('r16');
    }

    if (response.index == 2) {
      this.map.transition('dsen18');
    }

    if (response.index == 3) {
      this.map.transition('dgov18');
    }

    if (response.index == 4) {
      this.map.transition('dsenspec18');
    }

    if (response.index == 5) {
      this.map.transition('split');
    }

    if (response.index == 6) {
      this.map.transition('fullresults');
    }

  }

  _handleStepExit(response) {
  }

  _handleStepProgress(response) {
  }

  _handleContainerEnter(response) {
    // if (response.direction == 'down') {
    //   this.map.transition('r16');
    // }

    // sticky the graphic
    this.graphic.classed('is-fixed', true);
    this.graphic.classed('is-bottom', false);
  }

  _handleContainerExit(response) {
    if (response.direction == 'up') {
      this.map.transition('default');
    }

    // un-sticky the graphic, and pin to top/bottom of container
    this.graphic.classed('is-fixed', false);
    this.graphic.classed('is-bottom', response.direction === 'down');
  }

  /********** PUBLIC METHODS **********/

  init() {
    var self = this;
    // setupStickyfill();

    this.map.render();

    // 1. force a resize on load to ensure proper dimensions are sent to scrollama
    this._handleResize();

    // 2. setup the scroller passing options
    // this will also initialize trigger observations
    // 3. bind scrollama event handlers (this can be chained like below)
    scroller.setup({
      container: '#scroll',
      graphic: '.scroll__graphic',
      text: '.scroll__text',
      step: '.scroll__text .step',
      debug: false,
    })
      .onStepEnter((response) => this._handleStepEnter(response))
      .onContainerEnter((response) => this._handleContainerEnter(response))
      .onContainerExit((response) => this._handleContainerExit(response));

    // setup resize event
    window.addEventListener('resize', () => this._handleResize());
  }

}

export { ScrollyGraphic as default }
