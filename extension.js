const vscode = require('vscode');
const fs = require('fs');
const path = require('path');
const THREE = require('three');

const { hoverInfoActivate } = require('./hover');

async function activate(context) {
  console.log('Congratulations, your extension "extension" is now active!');
  hoverInfoActivate(context);

  let disposable = vscode.commands.registerCommand('marlin.showToolpath', async () => {
    // Create and show a new WebView panel
    const panel = vscode.window.createWebviewPanel(
      'toolpathView',
      'Toolpath',
      vscode.ViewColumn.Beside,
      {
        enableScripts: true
        
      }
    );

    // Get the current file G-code content
    const editor = vscode.window.activeTextEditor;
    const document = editor.document;
    const gcodeContent = document.getText();

    // Parse G-code and generate 3D toolpath data
    const toolpathData = parseGcode(gcodeContent);

    // Render the 3D toolpath in the WebView
    panel.webview.html = getToolpathHtml(toolpathData);
  });

  context.subscriptions.push(disposable);
}

exports.activate = activate;

function parseGcode(gcodeContent) {
  const lines = gcodeContent.split('\n');
  const coordinates = [];
  let current = new THREE.Vector3();

  for (const line of lines) {
    if (line.startsWith('G1')) {
      const matchX = line.match(/X(-?\d+(\.\d+)?)/);
      const matchY = line.match(/Y(-?\d+(\.\d+)?)/);
      const matchZ = line.match(/Z(-?\d+(\.\d+)?)/);

      const newX = matchX ? parseFloat(matchX[1]) : current.x;
      const newY = matchY ? parseFloat(matchY[1]) : current.y;
      const newZ = matchZ ? parseFloat(matchZ[1]) : current.z;

      const next = new THREE.Vector3(newX, newY, newZ);
      coordinates.push(current, next);
      current = next;
    }
  }

  return coordinates;
}

function getToolpathHtml(toolpathData) {
  // Read the content of the toolpath.html file
  const toolpathHtml = fs.readFileSync(path.join(__dirname, 'toolpath.html'), 'utf-8');

  // Replace the TOOLPATH_DATA_PLACEHOLDER with the actual toolpathData
  const filledToolpathHtml = toolpathHtml.replace('TOOLPATH_DATA_PLACEHOLDER', JSON.stringify(toolpathData));

  return filledToolpathHtml;
}
