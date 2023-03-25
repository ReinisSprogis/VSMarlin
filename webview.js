window.addEventListener('message', event => {
    const message = event.data; // The JSON data our extension sent
  
    switch (message.command) {
      case 'alert':
        alert(message.text);
        break;
    }
  });
  window.onNodeClick = function(lineNumber) {
    vscode.postMessage({
      command: 'navigateToLine',
      lineNumber: lineNumber
    });
  }
  // Reveal the 'vscode' global variable
  const vscode = acquireVsCodeApi();