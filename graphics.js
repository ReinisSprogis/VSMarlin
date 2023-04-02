const vscode = require('vscode');
const fs = require('fs');
const path = require('path');
const THREE = require('three');


async function graphics(context) {
  const panels = [];

  const updateToolpath = () => {
    const editor = vscode.window.activeTextEditor;
    const document = editor.document;
    const gcodeContent = document.getText();
    const toolpathData = parseGcode(gcodeContent);

    panels.forEach((panel) => {
      if (panel && panel.webview) {
        panel.webview.postMessage({ type: 'updateToolpath', toolpathData });
      }
    });
  };

  let disposable = vscode.commands.registerCommand('marlin.showToolpath', async () => {
    const panel = vscode.window.createWebviewPanel(
      'toolpathView',
      'Toolpath',
      vscode.ViewColumn.Beside,
      {
        enableScripts: true,
      }
    );

    panels.push(panel);

    panel.webview.onDidReceiveMessage(
      (message) => {
        if (message.type === 'ready') {
          updateToolpath();
        }
      },
      undefined,
      context.subscriptions
    );

    panel.webview.html = getToolpathHtml();

    panel.onDidDispose(
      () => {
        const panelIndex = panels.indexOf(panel);
        if (panelIndex !== -1) {
          panels.splice(panelIndex, 1);
        }
      },
      null,
      context.subscriptions
    );
  });

  context.subscriptions.push(disposable);

  vscode.workspace.onDidChangeTextDocument((event) => {
    if (event.document === vscode.window.activeTextEditor.document) {
      updateToolpath();
    }
  });
}




function parseGcode(gcodeContent) {
    const lines = gcodeContent.split('\n');
    const coordinates = [];
    let current = new THREE.Vector3();
  
    for (const line of lines) {
      if (line.startsWith('G1') || line.startsWith('G0')) {
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
  
  function getToolpathHtml() {
    const toolpathHtml = fs.readFileSync(path.join(__dirname, 'toolpath.html'), 'utf-8');
    return toolpathHtml;
  }
  
  

exports.graphics = graphics;