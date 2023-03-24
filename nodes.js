const vscode = require('vscode');
const fs = require('fs');
const path = require('path');

async function nodes(context) {
  let disposable = vscode.commands.registerCommand('marlin.showNodes', async () => {
    const panel = vscode.window.createWebviewPanel(
      'nodesView',
      'Nodes',
      vscode.ViewColumn.Beside,
      {
        enableScripts: true
      }
    );

    const editor = vscode.window.activeTextEditor;
    const document = editor.document;
    const gcodeContent = document.getText();

    const nodesData = parseGcode(gcodeContent);

    panel.webview.html = getNodesHtml(nodesData);
  });

  context.subscriptions.push(disposable);
}

function parseGcode(gcodeContent) {
  const lines = gcodeContent.split('\n');
  const nodes = [];

  for (const line of lines) {
    if (line.startsWith(';')) {
      const comment = line.substring(1).trim();
      const matchParam = comment.match(/([A-Z]+):(-?\d+(\.\d+)?)/);
      if (matchParam) {
        nodes.push({
          type: 'parameter',
          name: matchParam[1],
          value: parseFloat(matchParam[2])
        });
      } else {
        nodes.push({
          type: 'comment',
          value: comment
        });
      }
    }
  }

  return nodes;
}

function getNodesHtml(nodesData) {
  const nodesHtml = fs.readFileSync(path.join(__dirname, 'nodes.html'), 'utf-8');
  const filledNodesHtml = nodesHtml.replace('NODES_DATA_PLACEHOLDER', JSON.stringify(nodesData));
  return filledNodesHtml;
}

module.exports = {
  nodes
};
