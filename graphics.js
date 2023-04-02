const vscode = require('vscode');
const fs = require('fs');
const path = require('path');
const THREE = require('three');
const diff = require('fast-diff');

async function graphics(context) {
  const panels = [];

  const lastGcodeContents = {};
  
  const updateToolpath = () => {
    const editor = vscode.window.activeTextEditor;
    const document = editor.document;
    const uri = document.uri.toString();
    const currentGcodeContent = document.getText();
  
    if (lastGcodeContents[uri] === undefined || currentGcodeContent !== lastGcodeContents[uri]) {
      lastGcodeContents[uri] = currentGcodeContent;
      panels.forEach((panel) => {
        if (panel && panel.webview) {
          panel.webview.postMessage({ type: 'updateToolpath', uri, gcodeContent: currentGcodeContent });
        }
      });
    }
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

    panel.uri = getActiveEditorUri();
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

function getActiveEditorUri() {
  const editor = vscode.window.activeTextEditor;
  return editor.document.uri.toString();
}

function getToolpathHtml() {
  const toolpathHtml = fs.readFileSync(path.join(__dirname, 'toolpath.html'), 'utf-8');
  return toolpathHtml;
}

exports.graphics = graphics;
