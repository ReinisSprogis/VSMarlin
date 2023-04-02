const vscode = require('vscode');
const fs = require('fs');
const path = require('path');
const THREE = require('three');
const diff = require('fast-diff');

async function graphics(context) {
  const panels = [];
  const panelColors = {};

  const lastGcodeContents = {};
  
  const updateToolpath = () => {
    const editor = vscode.window.activeTextEditor;
    const document = editor.document;
    const uri = document.uri.toString();
    const currentGcodeContent = document.getText();
  
    if (lastGcodeContents[uri] === undefined || currentGcodeContent !== lastGcodeContents[uri]) {
      lastGcodeContents[uri] = currentGcodeContent;
      panels.forEach((panel) => {
        if (panel && panel.webview && panel.uri === uri) {
          panel.webview.postMessage({ type: 'updateToolpath', uri, gcodeContent: currentGcodeContent });
        }
      });
    }
  };
  
  

  let disposable = vscode.commands.registerCommand('marlin.showToolpath', async () => {
    const editor = vscode.window.activeTextEditor;
    const document = editor.document;
    const uri = document.uri.toString();
    const fileName = path.basename(document.fileName);
    const randomColor = getRandomColor();


    const panel = vscode.window.createWebviewPanel(
      'toolpathView',
      'Toolpath: ' + fileName,
      vscode.ViewColumn.Beside,
      {
        enableScripts: true,
      }
    );
    
    if(panelColors[uri] === undefined) {
      panelColors[uri] = randomColor;
    }

    panel.iconPath = getColoredIconUri(panelColors[uri], context);
    panel.uri = uri;
    panels.push(panel);

    panel.webview.onDidReceiveMessage(
      (message) => {
        if (message.type === 'ready') {
          panel.webview.postMessage({ type: 'setUri', uri: panel.uri });
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
        //remove color from panelColors
        delete panelColors[uri];
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

  vscode.window.onDidChangeActiveTextEditor((editor) => {
    if (editor) {
      const uri = editor.document.uri.toString();
      console.log(uri);
      panels.forEach((panel) => {
        if (panel && panel.webview &&  panel.uri === uri) {
          panel.uri = uri;
          panel.webview.postMessage({ type: 'setUri', uri: panel.uri });
          updateToolpath();
        }
      });
    }
  });

}




 

function getRandomColor() {
  const letters = '0123456789ABCDEF';
  let color = '#';
  for (let i = 0; i < 6; i++) {
    color += letters[Math.floor(Math.random() * 16)];
  }
  return color;
}

function getColoredIconUri(color, context) {
  const svg = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100">
    <rect width="100" height="100" fill="${color}" />
  </svg>`;
  const iconUri = vscode.Uri.parse('data:image/svg+xml;base64,' + Buffer.from(svg).toString('base64'));
  return iconUri;
}




function getToolpathHtml() {
  const toolpathHtml = fs.readFileSync(path.join(__dirname, 'toolpath.html'), 'utf-8');
  return toolpathHtml;
}

exports.graphics = graphics;
