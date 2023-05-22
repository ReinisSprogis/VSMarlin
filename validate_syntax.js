const vscode = require('vscode');

//Marlin Gcode parser. Parses the gcode and finds errors and warnings.
const marlinGcodeParser = require('./marlin_gcode_parser');

//For showing syntax errors, warnings, suggestions and information in the editor.
const diagnosticCollection = vscode.languages.createDiagnosticCollection('marlin');

function validateAndProvideDiagnostics(document) {
  // Clear previous diagnostics for the document
  diagnosticCollection.clear();
  const diagnostics = [];

  const gcode = document.getText();
  const marlinVersion = getMarlinVersion(gcode);
  //Iterate thru all lines and pares each line to find errors and show them in correct lines
  for(let i = 0; i < document.lineCount; i++) {
    const line = document.lineAt(i);
    const lineText = line.text;
  //  console.log(i + " " + lineText);
    try {
      
      const ast = marlinGcodeParser.parse(lineText, { collectErrors: true , marlinVersion: marlinVersion});
      ast.errors.forEach(error => {
        const diagnostic = createDiagnosticFromError(document, error,i);
        diagnostics.push(diagnostic);
      });
    } catch (error) {
      const diagnostic = createDiagnosticFromError(document, error,i);
      diagnostics.push(diagnostic);
    }
  }
  diagnosticCollection.set(document.uri, diagnostics);
}


function createDiagnosticFromError(document, error,lineNumber) {
  const start = new vscode.Position(lineNumber, error.location.start.column - 1);
  const end = new vscode.Position(lineNumber, error.location.end.column - 1);
  const range = new vscode.Range(start, end);

  let message = '';

if (error.type === 'duplicate_parameters') {
    //Showing if parameter is entered twice in command. And it's not supported.
    message = `ERROR: Duplicate parameters in ${error.command} command: ${error.duplicates.join(', ')}`;
    return new vscode.Diagnostic(range, message, vscode.DiagnosticSeverity.Error);
  }else if(error.type === 'use_G1') {
    //Suggestion to use G1 instead of G0 for print / laser-cutting moves.
    //This is by documentation.
    message = `SUGGESTION: Use G1 for print / laser-cutting moves.`;
    return new vscode.Diagnostic(range, message, vscode.DiagnosticSeverity.Information);
  }else if(error.type === 'unallowed_parameter_combination_R_I_J') {
    //Specific to G2/G3 commands. R, I, J parameters cannot be used together.
    message = `ERROR: R, I, J parameters cannot be used together.`;
    return new vscode.Diagnostic(range, message, vscode.DiagnosticSeverity.Error);
  }else if(error.type === 'unallowed_parameter_combination_R_X_Y') {
    //Specific to G2/G3 commands. Must be at least one of X or Y using R form.
    message = `ERROR: Omitting both X and Y is not allowed in R form.`;
    return new vscode.Diagnostic(range, message, vscode.DiagnosticSeverity.Error);
  }else if (error.type === 'unsupported_version' ) {
    //Version control when command example G10 is supported or M73 in given version.
    message = `ERROR: ${error.command}  is only supported in Marlin ${error.requiredVersion} or higher. Current version: ${error.currentVersion}.`;
    return new vscode.Diagnostic(range, message, vscode.DiagnosticSeverity.Error);
  }else if ( error.type === 'unsupported_parameter_version') {
    //Version control when parameter example P is supported in given version.
    message = `ERROR: ${error.parameter}  is only supported in Marlin ${error.requiredVersion} or higher. Current version: ${error.currentVersion}.`;
    return new vscode.Diagnostic(range, message, vscode.DiagnosticSeverity.Error);
  }else if ( error.type === 'missing_required_parameter') {
    //Missing required parameter in command.
    message = `ERROR: ${error.parameter}  is required in ${error.command}.`;
    return new vscode.Diagnostic(range, message, vscode.DiagnosticSeverity.Error);
  } else if (error.type === 'deprecated_command') {
    //Currently not implemented.
    message = `WARNING: Command ${error.command} is deprecated since Marlin ${error.deprecated}.`;
    return new vscode.Diagnostic(range, message, vscode.DiagnosticSeverity.Warning);
  } else if (error.type === 'deprecated_parameter') {
    //Currently not implemented.
    message = `WARNING: Parameter ${error.parameter} is deprecated since Marlin ${error.deprecated} in command ${error.command}.`;
    return new vscode.Diagnostic(range, message, vscode.DiagnosticSeverity.Warning);
  }
  else {
    //Mostly syntax error. Such as missing parameter or incorrect value type. 
    message = `${error.name}: ${error.message}`;
    return new vscode.Diagnostic(range, message, vscode.DiagnosticSeverity.Error);
  }
}

//Find marlin version
//TODO: Optimize so that it does not search the whole document if match found, and every time text changes.
function getMarlinVersion(gcode) {
  const regex = /;FLAVOR:Marlin\s+(\d+\.\d+\.\d+)/;
  const match = gcode.match(regex);
  if (match) {
    return match[1];
  }
  return "2.0.0";
}


function deactivate() {
  if (statusBar) {
    statusBar.dispose();
  }
}

module.exports = {
  deactivate,
  validateAndProvideDiagnostics
};
