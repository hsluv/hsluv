/*
    D3.js Slider
    Inspired by jQuery UI Slider
    Copyright (c) 2013, Bjorn Sandvik - http://blog.thematicmapping.org
    BSD license: http://opensource.org/licenses/BSD-3-Clause
*/

d3.slider = function module() {
  "use strict";

  // Public variables width default settings
  var min = 0,
      max = 100,
      step = 0.01,
      axis = false,
      margin = 50,
      value,
      scale;

  // Private variables
  var axisScale,
      dispatch = d3.dispatch("slide", "slideend"),
      formatPercent = d3.format(".2%"),
      tickFormat = d3.format(".0"),
      sliderLength;

  var redraws = [];

  function slider(selection) {
    selection.each(function() {

      // Create scale if not defined by user
      if (!scale) {
        scale = d3.scale.linear().domain([min, max]);
      }

      // Start value
      value = value || scale.domain()[0];

      var drag = d3.behavior.drag();
      drag.on('dragend', function () {
        dispatch.slideend(d3.event, value);
      })

      var div = d3.select(this)
        .classed("d3-slider", true)
        .call(drag);

      var handle = div.append("a")
        .classed("d3-slider-handle", true)
        .attr("xlink:href", "#")
        .attr('id', "handle-one")
        .on("click", stopPropagation)
        .call(drag);

      redraws.push(function() {
        var newPos = formatPercent(scale(stepValue(value)));
        handle.style('left', newPos);
      });

      div.on("mousedown", onClickHorizontal);
      
      handle.style("left", formatPercent(scale(value)));
      drag.on("drag", onDragHorizontal);
      
      sliderLength = parseInt(div.style("width"), 10);
      
      if (axis) {
        createAxis(div);
      }


      function createAxis(dom) {

        // Create axis if not defined by user
        if (typeof axis === "boolean") {

          axis = d3.svg.axis()
              .ticks(Math.round(sliderLength / 100))
              .tickFormat(tickFormat)
              .orient('bottom');

        }

        // Copy slider scale to move from percentages to pixels
        axisScale = scale.copy().range([0, sliderLength]);
          axis.scale(axisScale);

          // Create SVG axis container
        var svg = dom.append("svg")
            .classed("d3-slider-axis d3-slider-axis-" + axis.orient(), true)
            .on("click", stopPropagation);

        var g = svg.append("g");

        svg.style("margin-left", -margin + "px");

        svg.attr({
          width: sliderLength + margin * 2,
          height: margin
        });

        if (axis.orient() === "top") {
          svg.style("top", -margin + "px");
          g.attr("transform", "translate(" + margin + "," + margin + ")");
        } else { // bottom
          g.attr("transform", "translate(" + margin + ",0)");
        }

        g.call(axis);

      }


      // Move slider handle on click/drag
      function moveHandle(pos) {

        var newValue = stepValue(scale.invert(pos / sliderLength)),
            currentValue = value.length ? value[0]: value;

        if (currentValue !== newValue) {
          var oldPos = formatPercent(scale(stepValue(currentValue))),
              newPos = formatPercent(scale(stepValue(newValue)));

          dispatch.slide(d3.event.sourceEvent || d3.event, value = newValue);

          handle.style("left", newPos);
        }

      }


      // Calculate nearest step value
      function stepValue(val) {

        if (val === scale.domain()[0] || val === scale.domain()[1]) {
          return val;
        }

        var valModStep = (val - scale.domain()[0]) % step,
            alignValue = val - valModStep;

        if (Math.abs(valModStep) * 2 >= step) {
          alignValue += (valModStep > 0) ? step : -step;
        }

        return alignValue;

      }


      function onClickHorizontal() {
        if (!value.length) {
          moveHandle(d3.event.offsetX || d3.event.layerX);
        }
      }

      function onDragHorizontal() {
        moveHandle(Math.max(0, Math.min(sliderLength, d3.event.x)));
      }

      function stopPropagation() {
        d3.event.stopPropagation();
      }

    });

  }

  // Getter/setter functions
  slider.min = function(_) {
    if (!arguments.length) return min;
    min = _;
    return slider;
  };

  slider.max = function(_) {
    if (!arguments.length) return max;
    max = _;
    return slider;
  };

  slider.step = function(_) {
    if (!arguments.length) return step;
    step = _;
    return slider;
  };

  slider.axis = function(_) {
    if (!arguments.length) return axis;
    axis = _;
    return slider;
  };

  slider.margin = function(_) {
    if (!arguments.length) return margin;
    margin = _;
    return slider;
  };

  slider.value = function(_) {
    if (!arguments.length) return value;
    value = _;
    return slider;
  };

  slider.redraw = function() {
    for (var i=0; i<redraws.length; i++) {
      var redraw = redraws[i];
      redraw();
    }
  }

  slider.scale = function(_) {
    if (!arguments.length) return scale;
    scale = _;
    return slider;
  };

  d3.rebind(slider, dispatch, "on");

  return slider;

};


