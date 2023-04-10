const vscode = require('vscode');
function extrusionCalculations(context){
  //Previous extrusion position is used to calculate how much filament needs to be extruded.
  //This is relevant when using absolute extrusion mode, because previous extrusion position must be known to calculate total distance extruded.
  let prevExtrusion = 0;

  //Previous position is used to calculate distance travelled by the nozzle.
  //This is relevant when using relative extrusion mode, because previous position must be known to calculate total distance travelled.
  //This can usually most recent line before current line that have X and Y Z coordinates using G0 G1 later implement G2 G3.
  let prevX = 0;
  let prevY = 0;
  let prevZ = 0;

  //This can be changed any time in program by using M82,M83,G90,G91.
  //M82 - Absolute extrusion mode.
  //M83 - Relative extrusion mode.
  //G90 - Absolute coordinates mode.
  //G91 - Relative coordinates mode.
  //Recommended to use relative extrusion and absolute coordinates for travel.
  //Because inserted line using absolute extrusion mode will have to recalculate extrusion for all following lines.
  //while inserted line using relative extrusion mode will only have to recalculate extrusion for current and the following line.
  //User must manually recalculate following lines if the line that was inserted was using relative extrusion mode.
  //This could be changed later to automatically recalculate following line.
  let extrusionMode = 'absolute';

  //Default values for nozzle and filament diameters.
  //This can be override by user using comments in program.
  //Format: ;NOZZLE_DIAMETER:0.4
  //Format: ;FILAMENT_DIAMETER:1.75
  let nozzleDiameter = 0.4;
  let filamentDiameter = 1.75;

  //This is used to keep track of the position of the filament.
  //In absolute extrusion mode this is usually the value of the last E coordinate.
  //This can be set by user using G92 command.
  //Format: G92 E0
  let currentFilamentPosition = 0;

  //Retracting is done by setting the E coordinate to a negative value.
  //If previous E coordinate is a negative value then retracting is set too its current value.
  // Otherwise its set to 0.
  //This is used to compensate for retraction when calculating extrusion.
  //Retracted value will be added to calculated value.
  let retractingDistance = 0;

  //Layer height is used to calculate extrusion.
  //This can be changed by user using comments in program.
  //Format: ;LAYER_HEIGHT:0.2
  let layerHeight = 0.2;

  // Check for extrusion mode commands regex
  const m82Regex = /^M82/;
  const m83Regex = /^M83/;
  const g92Regex = /^G92/;
  const g90Regex = /^G90/;
  const g91Regex = /^G91/;

  //Provides auto calculations for extrusion when user is typing G1 G0 and activated by typing E.
  //When E is typed the user is prompted with a dropdown for accepting "Calculate extrusion".
  //This will calculate the extrusion needed for the current line and insert it as E value.
  const provider = vscode.languages.registerCompletionItemProvider('marlin', {
    provideCompletionItems(document, position, token, context) {
      // Current line where cursor is located
      const line = document.lineAt(position).text;

      //Shows 'Calculate Extrusion' extrusion option to user when E is typed.
      const extrusionCompletion = new vscode.CompletionItem('Calculate Extrusion', vscode.CompletionItemKind.Snippet);


      //Scan all lines up to the current line.
      //Last line processed is the line before current line. However line before current line might not have X Y Z coordinates.
      //That is why is why we re-scanning the file from the beginning to find the last line that has X Y Z coordinates every time we need to calculate extrusion.
      //This is not ideal and might be changed later.
      //However still fast and works tested with files 700K+ lines long.
      //While loop will not process current line since i is less than position.line.
      for (let i = 0; i < position.line; i++) {
        const iterLine = document.lineAt(i).text; // Line being iterated over

        //Looking for nozzle diameter and filament diameter settings.
        //If not found then use default values 0.4 and 1.75 as most common.
        if (iterLine.includes(";NOZZLE_DIAMETER:")) {
          nozzleDiameter = parseFloat(iterLine.replace(";NOZZLE_DIAMETER:", ""));
        }
        if (iterLine.includes(";FILAMENT_DIAMETER:")) {
          filamentDiameter = parseFloat(iterLine.replace(";FILAMENT_DIAMETER:", ""));
        }
        //Looking for Layer height
        if (iterLine.includes(";LAYER_HEIGHT:")) {
          layerHeight = parseFloat(iterLine.replace(";LAYER_HEIGHT:", ""));
          console.log('CURRENT LAYER HEIGHT:' +layerHeight);
        }


        // Check for extrusion mode commands.
        // M82 and M83 sets extrusion mode to absolute or relative.
        // G90 and G91 sets extrusion mode to absolute or relative.
        // G90 and G91 will override M82 and M83.
        //M82 and M83 will override G90 and G91 for Extrusion mode while G90 and G91 will override position mode for XYZ and E.
        //Default mode is relative.
        if (m82Regex.test(iterLine)) {
          extrusionMode = 'absolute';
        }

        if (m83Regex.test(iterLine)) {
          extrusionMode = 'relative';
        }

        if (g90Regex.test(iterLine)) {
          extrusionMode = 'absolute';
        }

        if (g91Regex.test(iterLine)) {
          extrusionMode = 'relative';
        }

        //Resets currentFilamentPosition to value set by user using G92 command.
        //XYZ can also be set using G92 command. This has not been implemented yet.
        //Need to check in case user resets X Y Z using G92 command. If so then reset prevX to X and prevY to Y and prevZ to Z values set by G92 command.
        //This usually is value of 0. To reset filament position to 0 and continue extruding from there.
        if (g92Regex.test(iterLine)) {
          currentFilamentPosition = parseFloat(iterLine.replace("G92 E", ""));
          prevExtrusion = currentFilamentPosition;
        }

      }

      //Calculates extrusion using absolute extrusion mode.
      //Absolute extrusion is when E coordinate is absolute position of filament.
      //Meaning the value is the total distance traveled by the filament since program started or since last G92 command reset the filament position.
      if (extrusionMode === 'absolute') {
        console.log('Extrusion mode: ' + extrusionMode);
        // const coordsRegex = /X(-?\d+(\.\d+)?)\s*Y(-?\d+(\.\d+)?)(?:\s*Z(-?\d+(\.\d+)?))?/i;
        //  const coordsMatch = coordsRegex.exec(line);

        //Setting current position to last position in case user did not specify X Y or Z coordinates.
        //This will update current position to last position if user did not specify any of the X Y or Z.
        //Unspecified coordinates will be set to last position value.
        var x1 = prevX;
        var y1 = prevY;
        var z1 = prevZ;

        //Scanning current line to see if user specified X Y or Z coordinates.
        //If user specified X Y or Z coordinates then update current position to those coordinates.
        if (/X(\d+(?:\.\d+)?)/.test(line)) {
          x1 = /X(\d+(\.\d+)?)/.exec(line)[1];
        }
        if (/Y(\d+(?:\.\d+)?)/.test(line)) {
          y1 = /Y(\d+(\.\d+)?)/.exec(line)[1];
        }
        if (/Z(\d+(?:\.\d+)?)/.test(line)) {

          z1 = /Z(\d+(\.\d+)?)/.exec(line)[1];
        }

        //Temporarily used fixed value 0.2 for layer height.
        const tempLayerHeight = 0.2;

        //Calculate extrusion.
        const extrusionValue = calculateExtrusion(prevX, prevY, prevZ, x1, y1, z1, nozzleDiameter, filamentDiameter, extrusionMode, prevExtrusion, tempLayerHeight);

        //Replace E with calculated extrusion value.
        extrusionCompletion.insertText = `E${extrusionValue}`;

        //Sets previous extrusion value to current extrusion value calculated. Might not be needed.
        prevExtrusion = extrusionValue;

        //Display the option to user.
        return [extrusionCompletion];
      } else if (extrusionMode === 'relative') {
        const extrusionCompletion = new vscode.CompletionItem('Extrusion', vscode.CompletionItemKind.Snippet);
        console.log('Extrusion mode: ' + extrusionMode);
        //Display the option to user.
        return [extrusionCompletion];
      }
    }
  },
    'E' //Activated when E is typed in G0 G1 G2 G3 command
  );

  context.subscriptions.push(provider);
}

function calculateExtrusion(x1, y1, z1, x2, y2, z2, nozzleDiameter, filamentDiameter, extrusionMode, prevExtrusion, layerHeight) {
    // Calculate the Euclidean distance between two points (x1, y1, z1) and (x2, y2, z2)
    const distance = Math.sqrt(Math.pow(x2 - x1, 2) + Math.pow(y2 - y1, 2) + Math.pow(z2 - z1, 2));
  
    // Calculate the cross-sectional area of the nozzle
    const nozzleArea = Math.PI * Math.pow(nozzleDiameter / 2, 2);
  
    // Calculate the cross-sectional area of the filament
    const filamentArea = Math.PI * Math.pow(filamentDiameter / 2, 2);
  
    // Calculate the extrusion volume
    const extrusionVolume = distance * nozzleArea * layerHeight;
  
    // Calculate the required filament length for the extrusion volume
    const filamentLength = extrusionVolume / filamentArea;
  
    // Calculate the total extrusion length based on the extrusion mode
    let totalExtrusionLength;
    if (extrusionMode === 'relative') {
      totalExtrusionLength = filamentLength;
    } else {
      totalExtrusionLength = prevExtrusion + filamentLength;
    }
    console.log('totalExtrusionLength: ' + totalExtrusionLength);
    return totalExtrusionLength;
  }
  
  
exports.extrusionCalculations = extrusionCalculations;