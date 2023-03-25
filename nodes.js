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

    const nodesData = parseGcodeToNodes(gcodeContent);

    panel.webview.html = getNodesHtml(nodesData);
  });
  panel.webview.onDidReceiveMessage(
    (message) => {
      switch (message.command) {
        case 'navigateToLine':
          navigateToLine(message.lineNumber);
          return;
      }
    },
    undefined,
    context.subscriptions
  );
  

  
  context.subscriptions.push(disposable);
}

function navigateToLine(lineNumber) {
    const editor = vscode.window.activeTextEditor;
    const position = new vscode.Position(lineNumber, 0);
  
    editor.selection = new vscode.Selection(position, position);
    editor.revealRange(new vscode.Range(position, position));
  }
  
  function parseGcodeToNodes(gcodeContent) {
    const lines = gcodeContent.split('\n');
    const nodes = [];
  
    lines.forEach((line, index) => {
      if (line.startsWith(';')) {
        const matchParam = line.match(/;(.+):(.+)/);
        if (matchParam) {
          nodes.push({
            type: 'parameter',
            name: matchParam[1].trim(),
            value: matchParam[2].trim(),
            lineNumber: index,
            x: 0,
            y: nodes.length * 30 + 20
          });
        } else {
          nodes.push({
            type: 'comment',
            value: line.substr(1).trim(),
            lineNumber: index,
            x: 0,
            y: nodes.length * 30 + 20
          });
        }
      }
    });
  
    return nodes;
  }


  function getNodesHtml(nodesData) {
    // Read the content of the nodes.html file
    const nodesHtml = fs.readFileSync(
      path.join(__dirname, 'nodes.html'),
      'utf-8'
    );
  
    // Replace the NODES_DATA_PLACEHOLDER with the actual nodesData
    const filledNodesHtml = nodesHtml.replace(
      'NODES_DATA_PLACEHOLDER',
      JSON.stringify(nodesData)
    );
  
    // Include the webview.js script in the nodes.html content
    const scriptTag =
      '<script src="vscode-resource:' +
      path.join(__dirname, 'webview.js') +
      '"></script>';
  
    const nodesHtmlWithClickEvent = filledNodesHtml.replace(
      '</head>',
      `${scriptTag}</head>`
    );
  
    // Add the click event to the nodes using the onNodeClick() function
    const clickEventCode = `
      <script>
        const nodes = d3.selectAll('.node');
        nodes.on('click', function(event, d) {
          window.onNodeClick(d.lineNumber);
        });
      </script>`;
  
    const finalNodesHtml = nodesHtmlWithClickEvent.replace(
      '</body>',
      `${clickEventCode}</body>`
    );
  
    return finalNodesHtml;
  }
  

module.exports = {
  nodes
};
