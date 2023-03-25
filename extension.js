const { hoverInfoActivate } = require('./hover');
const { graphics } = require('./graphics');
const { nodes } = require('./nodes.js');

//Bundle file
function activate(context) {
  console.log('Extension activated!');
  hoverInfoActivate(context);
  graphics(context);
 // nodes(context);
}


function deactivate() {
}

module.exports = {
  activate,
  deactivate
};


