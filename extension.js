const { hoverInfoActivate } = require('./hover');
const { graphics } = require('./graphics');
const { nodes } = require('./nodes.js');
const vscode = require('vscode');
//const { registerSnippets } = require('./snippets/gcode.js');
//Bundle file
function activate(context) {
  console.log('Extension activated!');
  hoverInfoActivate(context);
  graphics(context);

  const provider = vscode.languages.registerCompletionItemProvider(
    'marlin',
    {
      provideCompletionItems(document, position, token, context) {
        const line = document.lineAt(position).text;
        const lineBeforeCursor = line.substr(0, position.character);
        console.log('providing completion');
        const g1CommandRegex = /^G1\s+((?:F\d+\s*)?(?:X-?\d+(\.\d+)?\s*)?(?:Y-?\d+(\.\d+)?\s*)?(?:Z-?\d+(\.\d+)?\s*)?)*E$/i;

        if (g1CommandRegex.test(lineBeforeCursor)) {
          const extrusionCompletion = new vscode.CompletionItem('Extrusion', vscode.CompletionItemKind.Snippet);

          const coordsRegex = /X(-?\d+(\.\d+)?)\s*Y(-?\d+(\.\d+)?)/i;
          const coordsMatch = coordsRegex.exec(line);

          if (coordsMatch) {
            const x1 = parseFloat(coordsMatch[1]);
            const y1 = parseFloat(coordsMatch[3]);
            console.log('Extrusion');
            // Calculate extrusion (E) here based on the coordinates
            // ...
            const extrusionValue = 0; // Replace with the actual calculated value

            extrusionCompletion.insertText = `E${extrusionValue.toFixed(5)}`;
          }

          return [extrusionCompletion];
        }
      },
    },
    'E' // Add this line to register 'E' as a trigger character
  );

  context.subscriptions.push(provider);
}


function calculateExtrusion(x0, y0, x1, y1, layerHeight, lineWidth, filamentDiameter) {
  const distance = Math.sqrt(Math.pow(x1 - x0, 2) + Math.pow(y1 - y0, 2));
  const area = layerHeight * lineWidth;
  const filamentArea = Math.PI * Math.pow(filamentDiameter / 2, 2);

  return (area * distance) / filamentArea;
}

function deactivate() {
}

module.exports = {
  activate,
  deactivate
};


