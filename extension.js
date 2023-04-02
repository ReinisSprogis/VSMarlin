const { hoverInfoActivate } = require('./hover');
const { graphics } = require('./graphics');
const { nodes } = require('./nodes.js');
//const { registerSnippets } = require('./snippets/gcode.js');
//Bundle file
function activate(context) {
  console.log('Extension activated!');
  hoverInfoActivate(context);
  graphics(context);
 // registerSnippets(context);
 // nodes(context);
}


function deactivate() {
}

module.exports = {
  activate,
  deactivate
};


