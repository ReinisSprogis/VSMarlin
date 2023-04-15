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

//Check for duplicate parameters in line by providing line nad regex such as EXAMPLE: /\b(X|Y|Z|E|F|S)/g
function checkForMissingValuesInParameters(i, lineWithoutComments, xMissingValueRegex, diagnostics) {
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
}

//Show warning if no parameters are present.
function showWarningForMissingParameters(currentLineNumber, lineWithoutComments, missingParameterRegex, diagnostics) {
  if (missingParameterRegex.test(lineWithoutComments)) {
    const start = new vscode.Position(currentLineNumber, 0);
    const end = new vscode.Position(currentLineNumber, currentLineNumber);
    const range = new vscode.Range(start, end);
    const diagnostic = new vscode.Diagnostic(range, 'WARNING: Missing parameters for ' + lineWithoutComments.trim(), vscode.DiagnosticSeverity.Warning);
    diagnostics.push(diagnostic);
  }
}

//Check for duplicate parameters in line by providing line nad regex such as EXAMPLE: /\b(X|Y|Z|E|F|S)/g
function checkForDuplicateParameters(currentLineNumber, lineWithoutComments, parameterRegex, diagnostics) {
  const duplicateParameters = findDuplicateParameters(lineWithoutComments, parameterRegex);
  duplicateParameters.forEach(param => {
    const index = lineWithoutComments.indexOf(param);
    const start = new vscode.Position(currentLineNumber, index);
    const end = new vscode.Position(currentLineNumber, index + 1);
    const range = new vscode.Range(start, end);
    const diagnostic = new vscode.Diagnostic(range, 'ERROR: Duplicate ' + param + ' value', vscode.DiagnosticSeverity.Error);
    diagnostics.push(diagnostic);
  });
}

//Check dor unknown parameters in line by providing line nad regex such as EXAMPLE: /\b[^\sGMXYZEFS;\.+-]/g
function checkForUnknownParameters(currentLineNumber, lineWithoutComments, unknownParameterRegex, diagnostics) {
  let unknownMatch;
  while ((unknownMatch = unknownParameterRegex.exec(lineWithoutComments)) !== null) {
    console.log("Unknown param: " + unknownMatch);
    const index = unknownMatch.index;
    const start = new vscode.Position(currentLineNumber, index);
    const end = new vscode.Position(currentLineNumber, index + 1);
    const range = new vscode.Range(start, end);
    const diagnostic = new vscode.Diagnostic(range, 'WARNING: Unknown parameter ' + unknownMatch[0], vscode.DiagnosticSeverity.Warning);
    diagnostics.push(diagnostic);
  }
}

function validateEvent(document, diagnosticCollection) {
  const diagnostics = [];

  const lines = document.getText().split('\n');
  if (lines.length === 0) {
    return;
  }

  for (let currentLineNumber = 0; currentLineNumber < lines.length; currentLineNumber++) {
    const line = lines[currentLineNumber]; // line of text
    // Remove comments. As Error and warning will be ignored if parameter char is present in comments.
    const lineWithoutComments = line.replace(/;.*/, '');

    // Validate G0 and G1. Same rules for both.
    if (/^\s*G(0|1)/.test(lineWithoutComments)) {
      const xMissingValueRegex = /(\b(X|Y|Z|E|F|S))(?!\s*[+-]?\d+(\.\d*)?)/g;


      //If there is no value for parameter, show error. 
      // EXAMPLE: G0 X2 Y 
      //will show error for Y are missing value.
      checkForMissingValuesInParameters(currentLineNumber, lineWithoutComments, xMissingValueRegex, diagnostics);

      //Showing warning if G0 or G1 is written without parameters.
      showWarningForMissingParameters(currentLineNumber, lineWithoutComments, /^\s*G(0|1)\s*$/, diagnostics);

      // Check for duplicate parameters
      const parameterRegex = /\b(X|Y|Z|E|F|S)/g;
      checkForDuplicateParameters(currentLineNumber, lineWithoutComments, parameterRegex, diagnostics);

      ////Check for unknown parameters in line. Only X,Y,Z,E,F,S are valid parameters in G0 and G1
      const unknownParameterRegex = /(\b[^\sGMXYZEFS;\.+-]\d)/g;
      checkForUnknownParameters(currentLineNumber, lineWithoutComments, unknownParameterRegex, diagnostics);


      //Check if S or E parameter is present in G0 line.
      //If S or E is present in G0 line, show suggestion to replace G0 with G1
      const G0Regex = /\bG0\s*/g;
      const SOrERegex = /\b(S|E)\s*/g;
      let matchG0;
      let matchSOrE;
      while ((matchG0 = G0Regex.exec(lineWithoutComments)) !== null && (matchSOrE = SOrERegex.exec(lineWithoutComments)) !== null) {
        const start = new vscode.Position(currentLineNumber, matchG0.index);
        const end = new vscode.Position(currentLineNumber, matchG0.index + 2);
        const range = new vscode.Range(start, end);
        const diagnostic = new vscode.Diagnostic(range, 'SUGGESTION: Use G0 for non-print / laser-cutting moves. Use G1 instead.', vscode.DiagnosticSeverity.Information);
        diagnostics.push(diagnostic);
      }

    } else if (/^\s*G(2|3)\s*$/.test(lineWithoutComments)) {
      //Registers G2 and G3 without parameters as Error.
      //Check if the line starts with G2 or G3:
      // Regular expression: /^\s*G(2|3)\b/
      // Check if any unknown parameters are present in the line:
      // Regular expression: /\b([^\sGMXYZEFS\d;\.-])/
      // Check if the I and J parameters are both present in the line:
      // Regular expression: /\bI[+-]?\d+(\.\d*)?\s+J[+-]?\d+(\.\d*)?\b/
      // Check if the I and J parameters are both missing in the line:
      // Regular expression: /\bG[23]\b(?!.*\bI\b)(?!.*\bJ\b)(?!.*\bR\b)/
      // Check if the R parameter is present in the line:
      // Regular expression: /\bR[+-]?\d+(\.\d*)?\b/
      // Check if the X and Y parameters are both present in the line:
      // Regular expression: /\bX[+-]?\d+(\.\d*)?\s+Y[+-]?\d+(\.\d*)?\b/
      // Check if the X and Y parameters are both missing in the line:
      // Regular expression: /\bG[23]\b(?!.*\bX\b)(?!.*\bY\b)/
      // Check if the P parameter is present in the line:
      // Regular expression: /\bP\d+\b/
      // Please note that some of these regular expressions include negative lookaheads to exclude certain patterns, such as checking if the I parameter is missing but the R parameter is present. You may also need to adjust these regular expressions to match the specific syntax and formatting used in your code.
      const missingParametersRegex = /\b(G2|G3)(?!\s+I)(?!\s+J)(?!\s+R)(?!\s+X)(?!\s+Y)(?!\s+P)/g;

    } else if (/^\s*G(20|21)(?!\d)\s*(\S+)/.test(lineWithoutComments)) {
      //All Gcodes that don't take any parameters. 
      const start = new vscode.Position(currentLineNumber, lineWithoutComments.search(/\S/));
      const end = new vscode.Position(currentLineNumber, lineWithoutComments.search(/\S/) + lineWithoutComments.trim().length);
      const range = new vscode.Range(start, end);
      const diagnostic = new vscode.Diagnostic(range, 'ERROR: No parameters for: G' + lineWithoutComments.trim().substring(1, 3), vscode.DiagnosticSeverity.Error);
      diagnostics.push(diagnostic);
    } else if (/^\s*M/.test(lineWithoutComments)) {
      //Registers single M codes without number as Error M without number
      const missingMCodeRegex = /\bM(?!\d)/g;
      let matchM;
      while ((matchM = missingMCodeRegex.exec(lineWithoutComments)) !== null) {
        if (matchM[0] != null) {
          const start = new vscode.Position(currentLineNumber, matchM.index);
          const end = new vscode.Position(currentLineNumber, matchM.index + 1);
          const range = new vscode.Range(start, end);
          const diagnostic = new vscode.Diagnostic(range, 'ERROR: Missing M code number', vscode.DiagnosticSeverity.Error);
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

