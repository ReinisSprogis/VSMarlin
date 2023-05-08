const vscode = require('vscode');
const marlinGcodeParser = require('./marlin_gcode_parser');

const diagnosticCollection = vscode.languages.createDiagnosticCollection('marlin');

function validateAndProvideDiagnostics(document) {
  // Clear previous diagnostics for the document
  diagnosticCollection.clear();
  const diagnostics = [];

  const gcode = document.getText();
  
  try {
    const marlinVersion = getMarlinVersion(gcode);
    const ast = marlinGcodeParser.parse(gcode, { collectErrors: true , marlinVersion: marlinVersion});
    
    ast.errors.forEach(error => {
      const diagnostic = createDiagnosticFromError(document, error);
      diagnostics.push(diagnostic);
    });
   
  } catch (error) {
    const diagnostic = createDiagnosticFromError(document, error);
    diagnostics.push(diagnostic);
    
  }
  diagnosticCollection.set(document.uri, diagnostics);
}


function createDiagnosticFromError(document, error) {
  const start = document.positionAt(error.location.start.offset);
  const end = document.positionAt(error.location.end.offset);
  const range = new vscode.Range(start, end);

  let message = '';

if (error.type === 'duplicate_parameters') {
    //Showing if parameter is entered twice in command. And its not supported.
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


module.exports = {
  validateAndProvideDiagnostics: validateAndProvideDiagnostics,
};
