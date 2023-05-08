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
    console.log("Marlin version: " + marlinVersion);
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
  console.log("Error type: " + error );
  const start = document.positionAt(error.location.start.offset);
  const end = document.positionAt(error.location.end.offset);
  const range = new vscode.Range(start, end);

  let message = '';

if (error.type === 'duplicate_parameters') {
    message = `ERROR: Duplicate parameters in ${error.command} command: ${error.duplicates.join(', ')}`;
    return new vscode.Diagnostic(range, message, vscode.DiagnosticSeverity.Error);
  }else if(error.type === 'use_G1') {
    message = `SUGGESTION: Use G1 for print / laser-cutting moves.`;
    console.log(message);
    return new vscode.Diagnostic(range, message, vscode.DiagnosticSeverity.Information);
  }else if(error.type === 'unallowed_parameter_combination_R_I_J') {
    message = `ERROR: R, I, J parameters cannot be used together.`;
    console.log(message);
    return new vscode.Diagnostic(range, message, vscode.DiagnosticSeverity.Error);
  }else if(error.type === 'unallowed_parameter_combination_R_X_Y') {
    message = `ERROR: Omitting both X and Y will not allowed in R form.`;
    console.log(message);
    return new vscode.Diagnostic(range, message, vscode.DiagnosticSeverity.Error);
  }else if (error.type === 'unsupported_version' || error.type === 'unsupported_parameter_version') {
    console.log("Unsupported version:" + error.name + " " + error.requiredVersion + " " + error.currentVersion );
    message = `ERROR: ${error.parameter}  is only supported in Marlin ${error.requiredVersion} or higher. Current version: ${error.currentVersion}.`;
    return new vscode.Diagnostic(range, message, vscode.DiagnosticSeverity.Error);
  }
  else {
    message = `${error.name}: ${error.message}`;
    return new vscode.Diagnostic(range, message, vscode.DiagnosticSeverity.Error);
  }
}

//Find marlin version
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
