const vscode = require('vscode');
const fs = require('fs');
const path = require('path');

async function graphics(context) {
  console.log('graphics activated!');
  const panels = [];
  const panelColors = {};
  const lastGcodeContents = {};

  const updateToolpath = () => {
    const editor = vscode.window.activeTextEditor;
    const document = editor.document;
    const uri = document.uri.toString();
    const currentGcodeContent = document.getText();
    const visibleLines = getVisibleLines(editor);

    if (lastGcodeContents[uri] === undefined || currentGcodeContent !== lastGcodeContents[uri]) {
      lastGcodeContents[uri] = currentGcodeContent;
      panels.forEach((panel) => {
        if (panel && panel.webview && panel.uri === uri) {
          panel.webview.postMessage({ type: 'updateToolpath', uri, gcodeContent: currentGcodeContent, visibleLines });
        }
      });
    }
  };


  const sendVisibleLines = () => {
    const editor = vscode.window.activeTextEditor;
    const visibleLines = getVisibleLines(editor);
    const uri = editor.document.uri.toString();
   //console.log("visibleLines: " + visibleLines.start + " - " + visibleLines.end);
    panels.forEach((panel) => {
      if (panel && panel.webview && panel.uri === uri) {
        console.log("send visibleLines to webview");
        panel.webview.postMessage({ type: 'visibleLines', visibleLines });
      }
    });
  }


  let disposable = vscode.commands.registerCommand('marlin.showToolpath', async () => {
    console.log("Command: marlin.showToolpath");
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

    if (panelColors[uri] === undefined) {
      panelColors[uri] = randomColor;
    }

    panel.webview.onDidReceiveMessage(
      console.log("panel.webview.onDidReceiveMessage"),
      (message) => {
        if (message.type === 'ready') {
          panel.webview.postMessage({ type: 'setUri', uri: panel.uri });
          updateToolpath();
        }
      },
      undefined,
      context.subscriptions
    );

    //Sets the color for tab icon.
    //This ir random color squared icon that has the sam color for each panel that is opened from same editor.
    panel.iconPath = getColoredIconUri(panelColors[uri], context);

    //Panel uri is used to check if the panel has been created from the same document.
    //If it is not the same document then the toolpath will not be updated.
    //This is needed otherwise without tracking what panel is associated with what document the toolpath would be updated for all panels when a change is made in one document.
    panel.uri = uri;
    //test: trying to load toolpath wen panel is created
    panel.webview.postMessage({ type: 'panelOpened', uri: panel.uri });
    //Add panel to panels array for tracking.
    panels.push(panel);

    //Creates panel frm the html file.
    //In the toolpath.html graphics are managed with three.js and responds to changes in gcode files.
    //This will further extend to feedback from changes in three.js wil be sent to gcode files. TODO: implement this
    panel.webview.html = getToolpathHtml();

    // called when graphics panel is closed
    // Remove panel from panels array to add new color to panelColors array when new panel is created.
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

  //Updating graphics when a change is made in the active editor.
  vscode.workspace.onDidChangeTextDocument((event) => {
    if (event.document === vscode.window.activeTextEditor.document) {
      console.log('onDidChangeTextDocument');
      updateToolpath();
    }
  });

  vscode.window.onDidChangeTextEditorVisibleRanges((e) => {

    if (e.textEditor === vscode.window.activeTextEditor) {
      console.log('onDidChangeTextEditorVisibleRanges');
      sendVisibleLines();
    }
  });

  //This is needed to update correct panel when the active editor changes.
  //Needed to detect what is current active panel so that when panel focuses to another editor the toolpath is changed in correct panel.
  vscode.window.onDidChangeActiveTextEditor((editor) => {
    console.log('onDidChangeActiveTextEditor');
    if (editor) {
      const uri = editor.document.uri.toString();
      console.log(uri);
      panels.forEach((panel) => {
        if (panel && panel.webview && panel.uri === uri) {
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


function getVisibleLines(editor) {
  const visibleRanges = editor.visibleRanges;
  const firstVisiblePosition = visibleRanges[0].start;
  const lastVisiblePosition = visibleRanges[visibleRanges.length - 1].end;

  const firstVisibleLine = firstVisiblePosition.line;
  const lastVisibleLine = lastVisiblePosition.line;

  return {
    start: firstVisibleLine,
    end: lastVisibleLine,
  };
}





function getToolpathHtml() {
  const toolpathHtml = fs.readFileSync(path.join(__dirname, 'toolpath.html'), 'utf-8');
  return toolpathHtml;
}

exports.graphics = graphics;
