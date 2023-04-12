const vscode = require('vscode');

//This function checks for syntax errors in code and provides diagnostics,
// autofixes and code actions for them. Also provides warnings. 
function validateAndProvideDiagnostics(context) {
  const diagnosticCollection = vscode.languages.createDiagnosticCollection('marlin');

  vscode.workspace.onDidChangeTextDocument(event => {
    const document = event.document;
    const diagnostics = [];

    const lines = document.getText().split('\n');
    if (lines.length === 0) {
      return;
    }

    for (let i = 0; i < lines.length; i++) {
      const line = lines[i]; // line of text

      // Validate G0
      // Check for missing values
      if (/^\s*G0/.test(line)) {
        //console.log("G0 missing values: " + line);
        const xMissingValueRegex = /(\b(X|Y|Z|E|F|S))(?!\d)[+-]?/g;
        let match;
        while ((match = xMissingValueRegex.exec(line)) !== null) {
          if (match[0] != null) {
            const start = new vscode.Position(i, match.index);
            const end = new vscode.Position(i, match.index + 1);
            const range = new vscode.Range(start, end);
            const diagnostic = new vscode.Diagnostic(range, 'ERROR: Missing ' + match[0] + ' value', vscode.DiagnosticSeverity.Error);
            diagnostics.push(diagnostic);
          }
        }

        if (/^\s*G0\s*$/.test(line)) {
          const start = new vscode.Position(i, line.indexOf("G0"));
          const end = new vscode.Position(i, line.indexOf("G0") + 2);
          const range = new vscode.Range(start, end);
          const diagnostic = new vscode.Diagnostic(range, 'WARNING: Missing parameters for G0', vscode.DiagnosticSeverity.Warning);
          diagnostics.push(diagnostic);
        }
    

        // Check for duplicate parameters
        const parameterRegex = /\b(X|Y|Z|E|F|S)/g;
        const duplicateParameters = findDuplicateParameters(line, parameterRegex);
        duplicateParameters.forEach(param => {
          const index = line.indexOf(param);
          const start = new vscode.Position(i, index);
          const end = new vscode.Position(i, index + 1);
          const range = new vscode.Range(start, end);
          const diagnostic = new vscode.Diagnostic(range, 'ERROR: Duplicate ' + param + ' value', vscode.DiagnosticSeverity.Error);
          diagnostics.push(diagnostic);
        });
      }

      //

      //****Validate M code */
      // check for missing M code value any where in the line
      // Validate M code
      // Check for missing M code value anywhere in the line
      if (/^\s*M/.test(line)) {
        const missingMCodeRegex = /\bM(?!\d)/g;
        let matchM;
        while ((matchM = missingMCodeRegex.exec(line)) !== null) {
          if (matchM[0] != null) {
            const start = new vscode.Position(i, matchM.index);
            const end = new vscode.Position(i, matchM.index + 1);
            const range = new vscode.Range(start, end);
            const diagnostic = new vscode.Diagnostic(range, 'ERROR: Missing M code value', vscode.DiagnosticSeverity.Error);
            diagnostics.push(diagnostic);
          }
        }
      }

    }

    diagnosticCollection.set(document.uri, diagnostics);
  });
  context.subscriptions.push(diagnosticCollection);

}

//Check for duplicate parameters in line by providing line nad regex such as EXAMPLE: /\b(X|Y|Z|E|F|S)/g
function findDuplicateParameters(line, parameterRegex) {
  const parameters = {};
  let match;
  while ((match = parameterRegex.exec(line)) !== null) {
    const parameter = match[1];
    parameters[parameter] = (parameters[parameter] || 0) + 1;
  }
  return Object.keys(parameters).filter(param => parameters[param] > 1);
}


module.exports = {
  validateAndProvideDiagnostics
};

