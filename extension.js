const vscode = require('vscode');
const {hoverInfoActivate} = require('./hover');
function activate(context) {
    console.log('Congratulations, your extension "extension" is now active!');
   hoverInfoActivate(context);
  
    
}

exports.activate = activate;