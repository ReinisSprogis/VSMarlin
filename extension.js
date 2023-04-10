const { hoverInfoActivate } = require('./hover');
const { graphics } = require('./graphics');
const { nodes } = require('./nodes.js');
const { timeline } = require('./timeline.js');
const { extrusionCalculations } = require('./extrusion_calculations.js');

//const { registerSnippets } = require('./snippets/gcode.js');
//Bundle file

function activate(context) {
  console.log('Extension activated!');
  //Hover info on commands G and M codes.
  hoverInfoActivate(context);
  //Toolpath graphics ctrl+shift+r
  graphics(context);
  //Shows timeline of G and M codes ctrl+shift+t
  timeline(context);
  //Calculates node number and time for each G and M code when E is type autocomplete is offered to calculate values for E.
  extrusionCalculations(context);
}

function deactivate() {
}

module.exports = {
  activate,
  deactivate
};


