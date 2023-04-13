const vscode = require('vscode');


//This function checks for syntax errors as user types in code and provides diagnostics,
//Autofixes and code actions for them. Also provides warnings. 
function validateAndProvideDiagnostics(context) {
  const diagnosticCollection = vscode.languages.createDiagnosticCollection('marlin');
  //Scanning document for errors when document is opened
  vscode.workspace.onDidOpenTextDocument((document) => {
    validateEvent(document, diagnosticCollection);
  });

  vscode.workspace.onDidChangeTextDocument((event) => {
    validateEvent(event.document, diagnosticCollection);
  });
}

//Check for duplicate parameters in line by providing line nad regex such as EXAMPLE: /\b(X|Y|Z|E|F|S)/g
function findDuplicateParameters(line, parameterRegex) {
  const parameters = {};
  // Remove comments
  const lineWithoutComments = line.replace(/;.*$/, '');
  let match;
  while ((match = parameterRegex.exec(lineWithoutComments)) !== null) {
    const parameter = match[1];
    parameters[parameter] = (parameters[parameter] || 0) + 1;
  }
  return Object.keys(parameters).filter(param => parameters[param] > 1);
}


function validateEvent(document, diagnosticCollection) {
  const diagnostics = [];

  const lines = document.getText().split('\n');
  if (lines.length === 0) {
    return;
  }

  for (let i = 0; i < lines.length; i++) {
    const line = lines[i]; // line of text
    // Remove comments
    const lineWithoutComments = line.replace(/;.*/, '');
    // Validate G0 and G1
    // Check for missing values
    if (/^\s*G(0|1)/.test(lineWithoutComments)) {
      const xMissingValueRegex = /(\b(X|Y|Z|E|F|S))(?!\s*[+-]?\d+(\.\d*)?)/g;

      let match;
      while ((match = xMissingValueRegex.exec(lineWithoutComments)) !== null) {
        if (match[0] != null) {
          const start = new vscode.Position(i, match.index);
          const end = new vscode.Position(i, match.index + 1);
          const range = new vscode.Range(start, end);
          const diagnostic = new vscode.Diagnostic(range, 'ERROR: Missing ' + match[0] + ' value', vscode.DiagnosticSeverity.Error);
          diagnostics.push(diagnostic);
        }
      }

      if (/^\s*G(0|1)\s*$/.test(lineWithoutComments)) {
        const start = new vscode.Position(i, lineWithoutComments.indexOf("G"));
        const end = new vscode.Position(i, lineWithoutComments.indexOf("G") + 2);
        const range = new vscode.Range(start, end);
        const diagnostic = new vscode.Diagnostic(range, 'WARNING: Missing parameters for ' + lineWithoutComments.trim(), vscode.DiagnosticSeverity.Warning);
        diagnostics.push(diagnostic);
      }

      // Check for duplicate parameters
      const parameterRegex = /\b(X|Y|Z|E|F|S)/g;
      const duplicateParameters = findDuplicateParameters(lineWithoutComments, parameterRegex);
      duplicateParameters.forEach(param => {
        const index = lineWithoutComments.indexOf(param);
        const start = new vscode.Position(i, index);
        const end = new vscode.Position(i, index + 1);
        const range = new vscode.Range(start, end);
        const diagnostic = new vscode.Diagnostic(range, 'ERROR: Duplicate ' + param + ' value', vscode.DiagnosticSeverity.Error);
        diagnostics.push(diagnostic);
      });

      const unknownParameterRegex = /(\b[^\sGMXYZEFS\d;\.+-])/g;


      let unknownMatch;
      while ((unknownMatch = unknownParameterRegex.exec(lineWithoutComments)) !== null ) {
        console.log("Unknown param: "+unknownMatch);
        const index = unknownMatch.index;
        const start = new vscode.Position(i, index);
        const end = new vscode.Position(i, index + 1);
        const range = new vscode.Range(start, end);
        const diagnostic = new vscode.Diagnostic(range, 'WARNING: Unknown parameter ' + unknownMatch[0], vscode.DiagnosticSeverity.Warning);
        diagnostics.push(diagnostic);
      }
    }

    
    


    // Validate M code
    if (/^\s*M/.test(lineWithoutComments)) {
      const missingMCodeRegex = /\bM(?!\d)/g;
      let matchM;
      while ((matchM = missingMCodeRegex.exec(lineWithoutComments)) !== null) {
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
}


function getChangedLines(contentChanges) {
  const changedLines = new Set();
  for (const change of contentChanges) {
    for (let i = change.range.start.line; i <= change.range.end.line; i++) {
      changedLines.add(i);
    }
  }
  return changedLines;
}

module.exports = {
  validateAndProvideDiagnostics
};

