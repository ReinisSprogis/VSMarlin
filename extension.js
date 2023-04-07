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
        const g1CommandRegex = /^G1\s+((?:F\d+\s*)?(?:X-?\d+(\.\d+)?\s*)?(?:Y-?\d+(\.\d+)?\s*)?(?:Z-?\d+(\.\d+)?\s*)?)*E$/i;
  
        if (g1CommandRegex.test(lineBeforeCursor)) {
          const extrusionCompletion = new vscode.CompletionItem('Extrusion', vscode.CompletionItemKind.Snippet);
  
          const coordsRegex = /X(-?\d+(\.\d+)?)\s*Y(-?\d+(\.\d+)?)/i;
          const coordsMatch = coordsRegex.exec(line);
  
          if (coordsMatch) {
            const x1 = parseFloat(coordsMatch[1]);
            const y1 = parseFloat(coordsMatch[3]);
  
            // Define x2 and y2 as the previous X and Y coordinates
            // You can update these values based on your requirements
            const x2 = 0;
            const y2 = 0;
  
            // Get the nozzle diameter and filament diameter from the comments
            const nozzleDiameterRegex = /;NOZZLE_DIAMETER:(\d+(\.\d+)?)/i;
            const filamentDiameterRegex = /;FILAMENT_DIAMETER:(\d+(\.\d+)?)/i;
  
            let nozzleDiameter = 0.4; // Default nozzle diameter
            let filamentDiameter = 1.75; // Default filament diameter
  
            // Iterate through the lines before the current line and get the most recent nozzle diameter and filament diameter
            for (let i = 0; i < position.line; i++) {
              const currentLine = document.lineAt(i).text;
  
              const nozzleDiameterMatch = nozzleDiameterRegex.exec(currentLine);
              const filamentDiameterMatch = filamentDiameterRegex.exec(currentLine);
  
              if (nozzleDiameterMatch) {
                nozzleDiameter = parseFloat(nozzleDiameterMatch[1]);
              }
  
              if (filamentDiameterMatch) {
                filamentDiameter = parseFloat(filamentDiameterMatch[1]);
              }
            }
  
            const extrusionValue = calculateExtrusion(x1, y1, x2, y2, nozzleDiameter, filamentDiameter);
            extrusionCompletion.insertText = `E${extrusionValue.toFixed(5)}`;
            return [extrusionCompletion];
          }
        }
      },
    },
    'E'
  );
  

  context.subscriptions.push(provider);
}


function calculateExtrusion(x0, y0, x1, y1, layerHeight, lineWidth, filamentDiameter) {
  if (isNaN(filamentDiameter) || filamentDiameter <= 0) {
    filamentDiameter = 1.75;
  }

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


