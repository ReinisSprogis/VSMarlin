const vscode = require('vscode');


const { hoverInfoActivate } = require('./hover');
const { graphics } = require('./graphics');

function activate(context) {
  console.log('Congratulations, your extension "extension" is now active!');
  hoverInfoActivate(context);
  graphics(context);

}

exports.activate = activate;
