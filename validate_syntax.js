const vscode = require('vscode');
const marlinGcodeParser = require('./marlin_gcode_parser');

const diagnosticCollection = vscode.languages.createDiagnosticCollection('marlin');

function validateAndProvideDiagnostics(document) {
  // Clear previous diagnostics for the document
  diagnosticCollection.clear();

  const gcode = document.getText();
  const diagnostics = [];
  try {
    console.log('Parsing gcode');
    const ast = marlinGcodeParser.parse(gcode, { collectErrors: true });
    console.log('AST', ast);

    ast.errors.forEach(error => {
      const diagnostic = createDiagnosticFromError(document, error);
      diagnostics.push(diagnostic);
    });
    
    diagnosticCollection.set(document.uri, diagnostics);
   
  } catch (error) {
    console.log('Error in parsing', error);
    const diagnostic = createDiagnosticFromError(document, error);
    diagnostics.push(diagnostic);
   

    
  }
  diagnosticCollection.set(document.uri, diagnostics);
}

function createDiagnosticFromError(document, error) {
  console.log('Creating diagnostic for error');
  const start = document.positionAt(error.location.start.offset);
  const end = document.positionAt(error.location.end.offset);
  const range = new vscode.Range(start, end);
  console.log(error);
  let message = '';

  if (error.type === 'value_missing') {
    message = `ERROR: Value missing for ${error.parameter} parameter in ${error.command} command`;
  } else if (error.type === 'duplicate_parameters') {
    message = `ERROR: Duplicate parameters in ${error.command} command: ${error.duplicates.join(', ')}`;

  } else {
    message = `${error.name}: ${error.message}`;
  }
  console.log(message);
  return new vscode.Diagnostic(range, message, vscode.DiagnosticSeverity.Error);
}


module.exports = {
  validateAndProvideDiagnostics: validateAndProvideDiagnostics,
};

// //Check for duplicate parameters in line by providing line nad regex such as EXAMPLE: /\b(X|Y|Z|E|F|S)/g
// function findDuplicateParameters(line, parameterRegex) {
//   const parameters = {};
//   // Remove comments
//   const lineWithoutComments = line.replace(/;.*$/, '');
//   let match;
//   while ((match = parameterRegex.exec(lineWithoutComments)) !== null) {
//     const parameter = match[1];
//     parameters[parameter] = (parameters[parameter] || 0) + 1;
//   }
//   return Object.keys(parameters).filter(param => parameters[param] > 1);
// }

// // Create a new status bar item
// const validationStatus = vscode.window.createStatusBarItem(vscode.StatusBarAlignment.Left, 100);

// // Show the status bar item
// validationStatus.show();

// // Function to update the status bar item
// function updateStatusBar(message, backgroundColor = null, color = null) {
//   validationStatus.text = message;

//   if (backgroundColor) {
//     validationStatus.backgroundColor = new vscode.ThemeColor(backgroundColor);
//   }

//   if (color) {
//     validationStatus.color = new vscode.ThemeColor(color);
//   }
// }

// //Check for duplicate parameters in line by providing line nad regex such as EXAMPLE: /\b(X|Y|Z|E|F|S)/g
// function checkForMissingValuesInParameters(i, lineWithoutComments, xMissingValueRegex, diagnostics) {
//   let match;
//   while ((match = xMissingValueRegex.exec(lineWithoutComments)) !== null) {
//     if (match[0] != null) {
//       const start = new vscode.Position(i, match.index);
//       const end = new vscode.Position(i, match.index + 1);
//       const range = new vscode.Range(start, end);
//       const diagnostic = new vscode.Diagnostic(range, 'ERROR: Missing ' + match[0] + ' value', vscode.DiagnosticSeverity.Error);
//       diagnostics.push(diagnostic);
//     }
//   }
// }

// //Show warning if no parameters are present.
// function showWarningForMissingParameters(currentLineNumber, lineWithoutComments, missingParameterRegex, diagnostics) {
//   if (missingParameterRegex.test(lineWithoutComments)) {
//     const start = new vscode.Position(currentLineNumber, 0);
//     const end = new vscode.Position(currentLineNumber, currentLineNumber);
//     const range = new vscode.Range(start, end);
//     const diagnostic = new vscode.Diagnostic(range, 'WARNING: Missing parameters for ' + lineWithoutComments.trim(), vscode.DiagnosticSeverity.Warning);
//     diagnostics.push(diagnostic);
//   }
// }

// //Check for duplicate parameters in line by providing line nad regex such as EXAMPLE: /\b(X|Y|Z|E|F|S)/g
// function checkForDuplicateParameters(currentLineNumber, lineWithoutComments, parameterRegex, diagnostics) {
//   const duplicateParameters = findDuplicateParameters(lineWithoutComments, parameterRegex);
//   duplicateParameters.forEach(param => {
//     const index = lineWithoutComments.indexOf(param);
//     const start = new vscode.Position(currentLineNumber, index);
//     const end = new vscode.Position(currentLineNumber, index + 1);
//     const range = new vscode.Range(start, end);
//     const diagnostic = new vscode.Diagnostic(range, 'ERROR: Duplicate ' + param + ' parameter.', vscode.DiagnosticSeverity.Error);
//     diagnostics.push(diagnostic);
//   });
// }

// //Check if parameters are valid. If they are anything else than allowed parameter, will return error.
// //Example: /(X|Y|Z|E|F|S)/g
// function checkForUnsupportedParameters(currentLineNumber, lineWithoutComments, validParameterRegex, diagnostics) {
//   const unsupportedParameterRegex = new RegExp(`(\\b[^\\sGM0-9${validParameterRegex.source.slice(1, -1)};.+\\-])\\b`, 'g');
//   //console.log(unsupportedParameterRegex);
//   let unsupportedMatch;
//   while ((unsupportedMatch = unsupportedParameterRegex.exec(lineWithoutComments)) !== null) {
//     const index = unsupportedMatch.index;
//     const start = new vscode.Position(currentLineNumber, index);
//     const end = new vscode.Position(currentLineNumber, index + 1);
//     const range = new vscode.Range(start, end);
//     const diagnostic = new vscode.Diagnostic(range, 'ERROR: Unsupported parameter ' + unsupportedMatch[0], vscode.DiagnosticSeverity.Error);
//     diagnostics.push(diagnostic);
//   }
// }


// //Check if parameter is lowercase. If it is, show suggestion to uppercase. 
// function suggestCapitalization(document, currentLineNumber, lineWithoutComments, diagnostics) {
//   const lowercaseMatch = lineWithoutComments.match(/[a-z]/);

//   if (lowercaseMatch) {
//     const range = document.lineAt(currentLineNumber).range;
//     const diagnostic = new vscode.Diagnostic(range, 'Prefer using capital letters for G and M codes and their parameters.', vscode.DiagnosticSeverity.Information);
//     diagnostic.code = 'capitalizeLine';
//     diagnostics.push(diagnostic);
//   }
// }




// //Check Gcode and M code parameters if any and syntax errors.
// function validateEvent(document, diagnosticCollection, affectedRange = null) {
//   updateStatusBar('Validating syntax...');

//   let diagnostics = diagnosticCollection.get(document.uri);
//   if (!diagnostics) {
//     diagnostics = [];
//   }
//   const lines = document.getText().split('\n');
//   if (lines.length === 0) {
//     return;
//   }
//   const startLine = affectedRange ? affectedRange.start.line : 0;
//   const endLine = affectedRange ? affectedRange.end.line : lines.length - 1;
//   // Filter out existing diagnostics for the affected lines
//   diagnostics = diagnostics.filter((diagnostic) => diagnostic.range.start.line < startLine || diagnostic.range.start.line > endLine);

//   ///(\b[^\sGM0-9b(X|Y|Z|E|F|S;.+\-])/g
//   for (let currentLineNumber = startLine; currentLineNumber <= endLine; currentLineNumber++) {
//     const line = lines[currentLineNumber]; // line of text
//     // Remove comments. As Errors and warnings will be ignored if parameter char is present in comments.
//     const lineWithoutComments = line.replace(/;.*/, '');

//     // Validate G0 and G1. Same rules for both.
//     if (/^\s*\b(G(0|1))\b/.test(lineWithoutComments)) {
//       //G0 [E<pos>] [F<rate>] [S<power>] [X<pos>] [Y<pos>] [Z<pos>]
//       //G1 [E<pos>] [F<rate>] [S<power>] [X<pos>] [Y<pos>] [Z<pos>]

//       //Showing warning if G0 or G1 is written without parameters.
//       showWarningForMissingParameters(currentLineNumber, lineWithoutComments, /^\s*G(0|1)\s*$/, diagnostics);

//       //Check for unsupported parameters
//       const validParameterRegexG01 = /(X|Y|Z|E|F|S)/g;
//       checkForUnsupportedParameters(currentLineNumber, lineWithoutComments, validParameterRegexG01, diagnostics);


//       // Check for duplicate parameters
//       const parameterRegex = /\b(X|Y|Z|E|F|S)/g;
//       checkForDuplicateParameters(currentLineNumber, lineWithoutComments, parameterRegex, diagnostics);

//       //If there is no value for parameter, show error. 
//       const xMissingValueRegex = /(X|Y|Z|E|F|S)(?![+-]?\d+(\.\d*)?)/g;
//       checkForMissingValuesInParameters(currentLineNumber, lineWithoutComments, xMissingValueRegex, diagnostics);

//       //Check if S or E parameter is present in G0 line.
//       //If S or E is present in G0 line, show suggestion to replace G0 with G1
//       const G0Regex = /\bG0\s*/g;
//       const SOrERegex = /\b(S|E)\s*/g;
//       let matchG0;
//       let matchSOrE;
//       while ((matchG0 = G0Regex.exec(lineWithoutComments)) !== null && (matchSOrE = SOrERegex.exec(lineWithoutComments)) !== null) {
//         const start = new vscode.Position(currentLineNumber, matchG0.index);
//         const end = new vscode.Position(currentLineNumber, matchG0.index + 2);
//         const range = new vscode.Range(start, end);
//         const diagnostic = new vscode.Diagnostic(range, 'SUGGESTION: Use G0 for non-print / laser-cutting moves. Use G1 instead.', vscode.DiagnosticSeverity.Information);
//         diagnostics.push(diagnostic);
//       }


//     } else if (/^\s*\bG(2|3)\b/.test(lineWithoutComments)) {
//       // G2 [E<pos>] [F<rate>] I<offset> J<offset> [P<count>] R<radius> [S<power>] [X<pos>] [Y<pos>] [Z<pos>]
//       //G3 [E<pos>] [F<rate>] I<offset> J<offset> [P<count>] R<radius> [S<power>] [X<pos>] [Y<pos>] [Z<pos>]

//       //Showing warning if G2 or G3 is written without parameters.
//       showWarningForMissingParameters(currentLineNumber, lineWithoutComments, /^\s*G(2|3)\s*$/, diagnostics);

//       //Check for unsupported parameters
//       const validParameterRegexG23 = /(X|Y|Z|E|F|S|I|J|R|P)/g;
//       checkForUnsupportedParameters(currentLineNumber, lineWithoutComments, validParameterRegexG23, diagnostics);

//       //Check if all parameters have values.
//       const xMissingValueRegex = /(\b(X|Y|Z|E|F|S|I|J|R|P))(?![+-]?\d+(\.\d*)?)/g;
//       checkForMissingValuesInParameters(currentLineNumber, lineWithoutComments, xMissingValueRegex, diagnostics);

//       // Check for duplicate parameters
//       const parameterRegex = /\b(X|Y|Z|E|F|S|I|J|R|P)/g;
//       checkForDuplicateParameters(currentLineNumber, lineWithoutComments, parameterRegex, diagnostics);

//       //Check if I J and R are present in same line,
//       //then show error as IJ or R can be used in G2/G3, but not both at the same time.
//       const IJRegex = /\b(I|J)\s*/g;
//       const RRegex = /\bR\s*/g;
//       let matchR;
//       while (IJRegex.exec(lineWithoutComments) !== null && (matchR = RRegex.exec(lineWithoutComments)) !== null) {
//         const start = new vscode.Position(currentLineNumber, matchR.index);
//         const end = new vscode.Position(currentLineNumber, matchR.index + 1);
//         const range = new vscode.Range(start, end);
//         const diagnostic = new vscode.Diagnostic(range, 'ERROR: I J and R can not be used in same line.', vscode.DiagnosticSeverity.Error);
//         diagnostics.push(diagnostic);
//       }
//     } else if (/^\s*G4/.test(lineWithoutComments)) {
//       //G4 [P<time (ms)>] [S<time (sec)>]

//       //Check unsupported parameters
//       const validParameterRegexG4 = /(P|S)/g;
//       checkForUnsupportedParameters(currentLineNumber, lineWithoutComments, validParameterRegexG4, diagnostics);

//       //Check if parameters are missing values.
//       const xMissingValueRegex = /(\b(P|S))(?![+-]?\d+(\.\d*)?)/g;
//       checkForMissingValuesInParameters(currentLineNumber, lineWithoutComments, xMissingValueRegex, diagnostics);

//       // Check for duplicate parameters
//       const parameterRegex = /\b(P|S)/g;
//       checkForDuplicateParameters(currentLineNumber, lineWithoutComments, parameterRegex, diagnostics);

//     } else if (/^\s*G5/.test(lineWithoutComments)) {
//       //G5 [E<pos>] [F<rate>] I<pos> J<pos> P<pos> Q<pos> [S<power>] X<pos> Y<pos>

//       //Check unsupported parameters
//       const validParameterRegexG5 = /(E|F|I|J|P|Q|S|X|Y)/g;
//       checkForUnsupportedParameters(currentLineNumber, lineWithoutComments, validParameterRegexG5, diagnostics);

//       //Check if parameters are missing values.
//       const xMissingValueRegex = /(\b(E|F|I|J|P|Q|S|X|Y))(?![+-]?\d+(\.\d*)?)/g;
//       checkForMissingValuesInParameters(currentLineNumber, lineWithoutComments, xMissingValueRegex, diagnostics);

//       // Check for duplicate parameters
//       const parameterRegex = /\b(E|F|I|J|P|Q|S|X|Y)/g;
//       checkForDuplicateParameters(currentLineNumber, lineWithoutComments, parameterRegex, diagnostics);
//       //Check if Z is specified and return error if it is.
//       //Only X Y axis are supported.


//       const ZRegex = /\bZ\s*/g;
//       let matchZ;
//       while ((matchZ = ZRegex.exec(lineWithoutComments)) !== null) {
//         const start = new vscode.Position(currentLineNumber, matchZ.index);
//         const end = new vscode.Position(currentLineNumber, matchZ.index + 1);
//         const range = new vscode.Range(start, end);
//         const diagnostic = new vscode.Diagnostic(range, 'ERROR: Z axis is not supported in G5.', vscode.DiagnosticSeverity.Error);
//         diagnostics.push(diagnostic);
//       }
//     }
//     else if (/^\s*G6/.test(lineWithoutComments)) {
//       //G6 [E<direction>] [I<index>] [R<rate>] [S<rate>] [X<direction>] [Y<direction>] [Z<direction>]

//       //Check unsupported parameters
//       const validParameterRegexG6 = /(E|I|R|S|X|Y|Z)/g;
//       checkForUnsupportedParameters(currentLineNumber, lineWithoutComments, validParameterRegexG6, diagnostics);

//       //Check missing values
//       const xMissingValueRegex = /(\b(E|I|R|S|X|Y|Z))(?!\s*[+-]?\d+(\.\d*)?)/g;
//       checkForMissingValuesInParameters(currentLineNumber, lineWithoutComments, xMissingValueRegex, diagnostics);

//       // Check for duplicate parameters
//       const parameterRegex = /\b(E|I|R|S|X|Y|Z)/g;
//       checkForDuplicateParameters(currentLineNumber, lineWithoutComments, parameterRegex, diagnostics);


//     }
//     else if (/^\s*G(10|11)/.test(lineWithoutComments)) {
//       //G10 [S<bool>]
//       //G11
//       const xMissingValueRegex = /(\bS(?!\d*))/g;
//       checkForMissingValuesInParameters(currentLineNumber, lineWithoutComments, xMissingValueRegex, diagnostics);
//       const parameterRegex = /\b(S)/g;
//       checkForDuplicateParameters(currentLineNumber, lineWithoutComments, parameterRegex, diagnostics);
//     } else if (/^\s*G12/.test(lineWithoutComments)) {
//       //G12 [P<0|1|2>] [R<radius>] [S<count>] [T<count>] [X] [Y] [Z]

//       //Check unsupported parameters
//       const validParameterRegexG12 = /(P|R|S|T|X|Y|Z)/g;
//       checkForUnsupportedParameters(currentLineNumber, lineWithoutComments, validParameterRegexG12, diagnostics);

//       //Check missing values
//       const xMissingValueRegex = /(\b(P|R|S|T|X|Y|Z))(?!\s*[+-]?\d+(\.\d*)?)/g;
//       checkForMissingValuesInParameters(currentLineNumber, lineWithoutComments, xMissingValueRegex, diagnostics);

//       // Check for duplicate parameters
//       const parameterRegex = /\b(P|R|S|T|X|Y|Z)/g;
//       checkForDuplicateParameters(currentLineNumber, lineWithoutComments, parameterRegex, diagnostics);

//     } else if (/^\s*G26/.test(lineWithoutComments)) {
//       //G26 [B<temp>] [C<bool>] [D] [F<linear>] [H<linear>] [I<index>] [K<bool>] [L<linear>] [O<linear>] [P<linear>] [Q<float>] [R<int>] [S<float>] [U<linear>] [X<linear>] [Y<linear>]

//       //Check unsupported parameters
//       const validParameterRegexG26 = /(B|C|D|F|H|I|K|L|O|P|Q|R|S|U|X|Y)/g;
//       checkForUnsupportedParameters(currentLineNumber, lineWithoutComments, validParameterRegexG26, diagnostics);

//       //Check missing values
//       const xMissingValueRegex = /(\b(B|C|D|F|H|I|K|L|O|P|Q|R|S|U|X|Y))(?!\s*[+-]?\d+(\.\d*)?)/g;
//       checkForMissingValuesInParameters(currentLineNumber, lineWithoutComments, xMissingValueRegex, diagnostics);

//       // Check for duplicate parameters
//       const parameterRegex = /\b(B|C|D|F|H|I|K|L|O|P|Q|R|S|U|X|Y)/g;
//       checkForDuplicateParameters(currentLineNumber, lineWithoutComments, parameterRegex, diagnostics);

//     } else if (/^\s*G27/.test(lineWithoutComments)) {
//       //G27 [P<0|1|2>]

//       //Check unsupported parameters
//       const validParameterRegexG27 = /(P)/g;
//       checkForUnsupportedParameters(currentLineNumber, lineWithoutComments, validParameterRegexG27, diagnostics);

//       //Check missing values
//       const xMissingValueRegex = /(\b(P))(?!\s*[+-]?\d+(\.\d*)?)/g;
//       checkForMissingValuesInParameters(currentLineNumber, lineWithoutComments, xMissingValueRegex, diagnostics);

//       // Check for duplicate parameters
//       const parameterRegex = /\b(P)/g;
//       checkForDuplicateParameters(currentLineNumber, lineWithoutComments, parameterRegex, diagnostics);

//     } else if (/^\s*G28/.test(lineWithoutComments)) {
//       //G28 [L] [O] [R] [X] [Y] [Z]

//       //Check unsupported parameters
//       const validParameterRegexG28 = /(L|O|R|X|Y|Z)/g;
//       checkForUnsupportedParameters(currentLineNumber, lineWithoutComments, validParameterRegexG28, diagnostics);

//       //TODO: Only flags allowed, no values.

//       // Check for duplicate parameters
//       const parameterRegex = /\b(L|O|R|X|Y|Z)/g;
//       checkForDuplicateParameters(currentLineNumber, lineWithoutComments, parameterRegex, diagnostics);

//     } else if (/^\s*G29/.test(lineWithoutComments)) {
//       //TODO: Bed leveling
//     }
//     else if (/^\s*G30/.test(lineWithoutComments)) {
//       //G30 [C<bool>] [E<bool>] [X<pos>] [Y<pos>]

//       //Check unsupported parameters
//       const validParameterRegexG30 = /(C|E|X|Y)/g;
//       checkForUnsupportedParameters(currentLineNumber, lineWithoutComments, validParameterRegexG30, diagnostics);

//       //Check missing values
//       const xMissingValueRegex = /(\b(C|E|X|Y))(?!\s*[+-]?\d+(\.\d*)?)/g;
//       checkForMissingValuesInParameters(currentLineNumber, lineWithoutComments, xMissingValueRegex, diagnostics);

//       // Check for duplicate parameters
//       const parameterRegex = /\b(C|E|X|Y)/g;
//       checkForDuplicateParameters(currentLineNumber, lineWithoutComments, parameterRegex, diagnostics);

//     } else if (/^\s*G33/.test(lineWithoutComments)) {
//       //G33 [C<float>] [E<bool>] [F<1-30>] [O<bool>] [P<|0|1|2|3|4-10>] [R<float>] [T<bool>] [V<|0|1|2|3|>]

//       //Check unsupported parameters
//       const validParameterRegexG33 = /(C|E|F|O|P|R|T|V)/g;
//       checkForUnsupportedParameters(currentLineNumber, lineWithoutComments, validParameterRegexG33, diagnostics);

//       //Check missing values
//       const xMissingValueRegex = /(\b(C|E|F|O|P|R|T|V))(?!\s*[+-]?\d+(\.\d*)?)/g;
//       checkForMissingValuesInParameters(currentLineNumber, lineWithoutComments, xMissingValueRegex, diagnostics);

//       // Check for duplicate parameters
//       const parameterRegex = /\b(C|E|F|O|P|R|T|V)/g;
//       checkForDuplicateParameters(currentLineNumber, lineWithoutComments, parameterRegex, diagnostics);

//       //TODO: Only allowed values
//     } else if (/^\s*G34/.test(lineWithoutComments)) {
//       //G34 [A] [E] [I] [T]

//       //Check unsupported parameters
//       const validParameterRegexG34 = /(A|E|I|T)/g;
//       checkForUnsupportedParameters(currentLineNumber, lineWithoutComments, validParameterRegexG34, diagnostics);

//       //Check for duplicate parameters
//       const parameterRegex = /\b(A|E|I|T)/g;
//       checkForDuplicateParameters(currentLineNumber, lineWithoutComments, parameterRegex, diagnostics);

//       //TODO: Flags take no parameters

//       //TODO: implement secondary parameters G34 [S<mA>] [Z<linear>]
//     } else if (/^\s*G35/.test(lineWithoutComments)) {
//       //G35 [S<30|31|40|41|50|51>]

//       //Check unsupported parameters
//       const validParameterRegexG35 = /(S)/g;
//       checkForUnsupportedParameters(currentLineNumber, lineWithoutComments, validParameterRegexG35, diagnostics);

//       //Check for duplicate parameters
//       const parameterRegex = /\b(S)/g;
//       checkForDuplicateParameters(currentLineNumber, lineWithoutComments, parameterRegex, diagnostics);

//       //TODO: Check missing values only allowed ones.
//     } else if (/^\s*G(38.2|38.3|38.4|38.5)/.test(lineWithoutComments)) {
//       //G38.2 [F<rate>] [X<pos>] [Y<pos>] [Z<pos>]
//       // G38.3 [F<rate>] [X<pos>] [Y<pos>] [Z<pos>]
//       // G38.4 [F<rate>] [X<pos>] [Y<pos>] [Z<pos>]
//       // G38.5 [F<rate>] [X<pos>] [Y<pos>] [Z<pos>]

//       //Check unsupported parameters
//       const validParameterRegexG382 = /(F|X|Y|Z)/g;
//       checkForUnsupportedParameters(currentLineNumber, lineWithoutComments, validParameterRegexG382, diagnostics);

//       //Check for duplicate parameters
//       const parameterRegex = /\b(F|X|Y|Z)/g;
//       checkForDuplicateParameters(currentLineNumber, lineWithoutComments, parameterRegex, diagnostics);

//       //check for missing values
//       const xMissingValueRegex = /(\b(F|X|Y|Z))(?!\s*[+-]?\d+(\.\d*)?)/g;
//       checkForMissingValuesInParameters(currentLineNumber, lineWithoutComments, xMissingValueRegex, diagnostics);

//     } else if (/^\s*G42/.test(lineWithoutComments)) {
//       //G42 [F<rate>] [I<pos>] [J<pos>]

//       //Check unsupported parameters
//       const validParameterRegexG42 = /(F|I|J)/g;
//       checkForUnsupportedParameters(currentLineNumber, lineWithoutComments, validParameterRegexG42, diagnostics);

//       //Check for duplicate parameters
//       const parameterRegex = /\b(F|I|J)/g;
//       checkForDuplicateParameters(currentLineNumber, lineWithoutComments, parameterRegex, diagnostics);

//       //check for missing values
//       const xMissingValueRegex = /(\b(F|I|J))(?!\s*[+-]?\d+(\.\d*)?)/g;
//       checkForMissingValuesInParameters(currentLineNumber, lineWithoutComments, xMissingValueRegex, diagnostics);

//     } else if (/^\s*G60/.test(lineWithoutComments)) {
//       //G60 [S<slot>]

//       //Check unsupported parameters
//       const validParameterRegexG60 = /(S)/g;
//       checkForUnsupportedParameters(currentLineNumber, lineWithoutComments, validParameterRegexG60, diagnostics);

//       //Check for duplicate parameters
//       const parameterRegex = /\b(S)/g;
//       checkForDuplicateParameters(currentLineNumber, lineWithoutComments, parameterRegex, diagnostics);

//       //check for missing values
//       const xMissingValueRegex = /(\b(S))(?!\s*[+-]?\d+(\.\d*)?)/g;
//       checkForMissingValuesInParameters(currentLineNumber, lineWithoutComments, xMissingValueRegex, diagnostics);

//     } else if (/^\s*G61/.test(lineWithoutComments)) {
//       //G61 [E] [F<rate>] [S<slot>] [X] [Y] [Z]

//       //Check unsupported parameters
//       const validParameterRegexG61 = /(E|F|S|X|Y|Z)/g;
//       checkForUnsupportedParameters(currentLineNumber, lineWithoutComments, validParameterRegexG61, diagnostics);

//       //Check for duplicate parameters
//       const parameterRegex = /\b(E|F|S|X|Y|Z)/g;
//       checkForDuplicateParameters(currentLineNumber, lineWithoutComments, parameterRegex, diagnostics);

//       //check for missing values
//       const xMissingValueRegex = /(\b(E|F|S|X|Y|Z))(?!\s*[+-]?\d+(\.\d*)?)/g;
//       checkForMissingValuesInParameters(currentLineNumber, lineWithoutComments, xMissingValueRegex, diagnostics);
//       //TODO: Flags take no parameters
//     } else if (/^\s*G76/.test(lineWithoutComments)) {
//       //G76 [B] [P]

//       //Check unsupported parameters
//       const validParameterRegexG76 = /(B|P)/g;
//       checkForUnsupportedParameters(currentLineNumber, lineWithoutComments, validParameterRegexG76, diagnostics);

//       //Check for duplicate parameters
//       const parameterRegex = /\b(B|P)/g;
//       checkForDuplicateParameters(currentLineNumber, lineWithoutComments, parameterRegex, diagnostics);

//       //TODO: Flags take no parameters
//     } else if (/^\s*G92/.test(lineWithoutComments)) {
//       //G92 [E<pos>] [X<pos>] [Y<pos>] [Z<pos>]

//       //Check unsupported parameters
//       const validParameterRegexG92 = /(E|X|Y|Z)/g;
//       checkForUnsupportedParameters(currentLineNumber, lineWithoutComments, validParameterRegexG92, diagnostics);

//       //Check for duplicate parameters
//       const parameterRegex = /\b(E|X|Y|Z)/g;
//       checkForDuplicateParameters(currentLineNumber, lineWithoutComments, parameterRegex, diagnostics);

//       //check for missing values
//       const xMissingValueRegex = /(\b(E|X|Y|Z))(?!\s*[+-]?\d+(\.\d*)?)/g;
//       checkForMissingValuesInParameters(currentLineNumber, lineWithoutComments, xMissingValueRegex, diagnostics);

//     } else if (/^\s*G452/.test(lineWithoutComments)) {
//       //G425 [B] [T<index>] [U<linear>] [V]

//       //Check unsupported parameters
//       const validParameterRegexG452 = /(B|T|U|V)/g;
//       checkForUnsupportedParameters(currentLineNumber, lineWithoutComments, validParameterRegexG452, diagnostics);

//       //Check for duplicate parameters
//       const parameterRegex = /\b(B|T|U|V)/g;
//       checkForDuplicateParameters(currentLineNumber, lineWithoutComments, parameterRegex, diagnostics);

//       //check for missing values
//       const xMissingValueRegex = /(\b(B|T|U|V))(?!\s*[+-]?\d+(\.\d*)?)/g;
//       checkForMissingValuesInParameters(currentLineNumber, lineWithoutComments, xMissingValueRegex, diagnostics);

//       //TODO: Flags take no parameters
//     }
//     else if (/^\s*G(20|21|17|18|19|20|21|31|32|53|54|55|56|57|58|59|59.1|59.2|59.3|80|90|91)(?!\d)\s*(\S+)/.test(lineWithoutComments)) {
//       //All Gcodes that don't take any parameters. 
//       const start = new vscode.Position(currentLineNumber, lineWithoutComments.search(/\S/));
//       const end = new vscode.Position(currentLineNumber, lineWithoutComments.search(/\S/) + lineWithoutComments.trim().length);
//       const range = new vscode.Range(start, end);
//       const diagnostic = new vscode.Diagnostic(range, 'ERROR: No parameters for: G' + lineWithoutComments.trim().substring(1, 3), vscode.DiagnosticSeverity.Error);
//       diagnostics.push(diagnostic);
//     }
//     else if (/^\s*M(0|1)/.test(lineWithoutComments)) {
//       // M0 [P<ms>] [S<sec>] [string]
//       // M1 [P<ms>] [S<sec>] [string]

//       //Check unsupported parameters
//       const validParameterRegexM01 = /(P|S)/g;
//       checkForUnsupportedParameters(currentLineNumber, lineWithoutComments, validParameterRegexM01, diagnostics);

//       //Check for duplicate parameters
//       const parameterRegex = /\b(P|S)/g;
//       checkForDuplicateParameters(currentLineNumber, lineWithoutComments, parameterRegex, diagnostics);

//       //check for missing values
//       const xMissingValueRegex = /(\b(P|S))(?!\s*[+-]?\d+(\.\d*)?)/g;
//       checkForMissingValuesInParameters(currentLineNumber, lineWithoutComments, xMissingValueRegex, diagnostics);

//     } else if (/^\s*M(3|4)/.test(lineWithoutComments)){
//       //M3 [I<mode>] [O<power>] [S<power>]

//       //Check unsupported parameters
//       const validParameterRegexM3 = /(I|O|S)/g;
//       checkForUnsupportedParameters(currentLineNumber, lineWithoutComments, validParameterRegexM3, diagnostics);

//       //Check for duplicate parameters
//       const parameterRegex = /\b(I|O|S)/g;
//       checkForDuplicateParameters(currentLineNumber, lineWithoutComments, parameterRegex, diagnostics);

//       //check for missing values
//       const xMissingValueRegex = /(\b(I|O|S))(?!\s*[+-]?\d+(\.\d*)?)/g;
//       checkForMissingValuesInParameters(currentLineNumber, lineWithoutComments, xMissingValueRegex, diagnostics);

//     } else if  (/^\s*M16/.test(lineWithoutComments)) {
//       //TODO: String parameter
//     }
//     else if  (/^\s*M17/.test(lineWithoutComments)) {
//       //M17 [E<flag>] [X<flag>] [Y<flag>] [Z<flag>]

//       //Check unsupported parameters
//       const validParameterRegexM17 = /(E|X|Y|Z)/g;
//       checkForUnsupportedParameters(currentLineNumber, lineWithoutComments, validParameterRegexM17, diagnostics);

//       //Check for duplicate parameters
//       const parameterRegex = /\b(E|X|Y|Z)/g;
//       checkForDuplicateParameters(currentLineNumber, lineWithoutComments, parameterRegex, diagnostics);

//       //TODO: Flags take no parameters
//     }else if  (/^\s*M(18|84)/.test(lineWithoutComments)) {
//       //M18 [E<flag>] [S<seconds>] [X<flag>] [Y<flag>] [Z<flag>]
//       //M84 [E<flag>] [S<seconds>] [X<flag>] [Y<flag>] [Z<flag>]

//       //Check unsupported parameters
//       const validParameterRegexM18 = /(E|S|X|Y|Z)/g;
//       checkForUnsupportedParameters(currentLineNumber, lineWithoutComments, validParameterRegexM18, diagnostics);

//       //Check for duplicate parameters
//       const parameterRegex = /\b(E|S|X|Y|Z)/g;
//       checkForDuplicateParameters(currentLineNumber, lineWithoutComments, parameterRegex, diagnostics);

//       //check for missing values
//       const xMissingValueRegex = /(\b(E|S|X|Y|Z))(?!\s*[+-]?\d+(\.\d*)?)/g;
//       checkForMissingValuesInParameters(currentLineNumber, lineWithoutComments, xMissingValueRegex, diagnostics);

//       //TODO: Flags take no parameters
//     }
//     else if  (/^\s*M20/.test(lineWithoutComments)) {
//       //M20 [F] [L] [T]

//       //Check unsupported parameters
//       const validParameterRegexM20 = /(F|L|T)/g;
//       checkForUnsupportedParameters(currentLineNumber, lineWithoutComments, validParameterRegexM20, diagnostics);

//       //Check for duplicate parameters
//       const parameterRegex = /\b(F|L|T)/g;
//       checkForDuplicateParameters(currentLineNumber, lineWithoutComments, parameterRegex, diagnostics);

//       //TODO: Flags take no parameters
//     }else if  (/^\s*M23/.test(lineWithoutComments)) {
//       //M23 filename

//       //TODO: String parameter
//     }else if  (/^\s*M24/.test(lineWithoutComments)) {
//       //M24 [S<pos>] [T<time>]

//       //Check unsupported parameters
//       const validParameterRegexM24 = /(S|T)/g;
//       checkForUnsupportedParameters(currentLineNumber, lineWithoutComments, validParameterRegexM24, diagnostics);

//       //Check for duplicate parameters
//       const parameterRegex = /\b(S|T)/g;
//       checkForDuplicateParameters(currentLineNumber, lineWithoutComments, parameterRegex, diagnostics);

//       //check for missing values
//       const xMissingValueRegex = /(\b(S|T))(?!\s*[+-]?\d+(\.\d*)?)/g;
//       checkForMissingValuesInParameters(currentLineNumber, lineWithoutComments, xMissingValueRegex, diagnostics);
//     }else if  (/^\s*M26/.test(lineWithoutComments)) {
//       //M26 [S<pos>]

//       //Check unsupported parameters
//       const validParameterRegexM26 = /(S)/g;
//       checkForUnsupportedParameters(currentLineNumber, lineWithoutComments, validParameterRegexM26, diagnostics);

//       //Check for duplicate parameters
//       const parameterRegex = /\b(S)/g;
//       checkForDuplicateParameters(currentLineNumber, lineWithoutComments, parameterRegex, diagnostics);

//       //check for missing values
//       const xMissingValueRegex = /(\b(S))(?!\s*[+-]?\d+(\.\d*)?)/g;
//       checkForMissingValuesInParameters(currentLineNumber, lineWithoutComments, xMissingValueRegex, diagnostics);
//     }else if  (/^\s*M27/.test(lineWithoutComments)) {
//       //M27 [C] [S<seconds>]
      
//       //Check unsupported parameters
//       const validParameterRegexM27 = /(C|S)/g;
//       checkForUnsupportedParameters(currentLineNumber, lineWithoutComments, validParameterRegexM27, diagnostics);

//       //Check for duplicate parameters
//       const parameterRegex = /\b(C|S)/g;
//       checkForDuplicateParameters(currentLineNumber, lineWithoutComments, parameterRegex, diagnostics);

//       //check for missing values
//       const xMissingValueRegex = /(\b(C|S))(?!\s*[+-]?\d+(\.\d*)?)/g;
//       checkForMissingValuesInParameters(currentLineNumber, lineWithoutComments, xMissingValueRegex, diagnostics);

//       //TODO: Flags take no parameters
//     }else if  (/^\s*M28/.test(lineWithoutComments)) {
//       //M28 [B1] filename

//       //TODO: String parameter
//       //TODO: Flags take no parameters
//     }else if  (/^\s*M30/.test(lineWithoutComments)) {
//       //TODO: String parameter
//     }else if  (/^\s*M16/.test(lineWithoutComments)) {
//       //TODO: String parameter
//     }else if  (/^\s*M16/.test(lineWithoutComments)) {
//       //TODO: String parameter
//     }else if  (/^\s*M16/.test(lineWithoutComments)) {
//       //TODO: String parameter
//     }else if  (/^\s*M16/.test(lineWithoutComments)) {
//       //TODO: String parameter
//     }else if  (/^\s*M16/.test(lineWithoutComments)) {
//       //TODO: String parameter
//     }else if  (/^\s*M16/.test(lineWithoutComments)) {
//       //TODO: String parameter
//     }else if  (/^\s*M16/.test(lineWithoutComments)) {
//       //TODO: String parameter
//     }else if  (/^\s*M16/.test(lineWithoutComments)) {
//       //TODO: String parameter
//     }else if  (/^\s*M16/.test(lineWithoutComments)) {
//       //TODO: String parameter
//     }else if  (/^\s*M16/.test(lineWithoutComments)) {
//       //TODO: String parameter
//     }else if  (/^\s*M16/.test(lineWithoutComments)) {
//       //TODO: String parameter
//     }
//     else if (/^\s*M(5|7|8|9|10|11|21|22|25|29)(?!\d)\s*(\S+)/.test(lineWithoutComments)) {
//       //All Gcodes that don't take any parameters. 
//       const start = new vscode.Position(currentLineNumber, lineWithoutComments.search(/\S/));
//       const end = new vscode.Position(currentLineNumber, lineWithoutComments.search(/\S/) + lineWithoutComments.trim().length);
//       const range = new vscode.Range(start, end);
//       const diagnostic = new vscode.Diagnostic(range, 'ERROR: No parameters for: M' + lineWithoutComments.trim().substring(1, 3), vscode.DiagnosticSeverity.Error);
//       diagnostics.push(diagnostic);
//     }
//     else if (/^\s*M/.test(lineWithoutComments)) {
//       //Registers single M codes without number as Error M without number
//       const missingMCodeRegex = /\bM(?!\d)/g;
//       let matchM;
//       while ((matchM = missingMCodeRegex.exec(lineWithoutComments)) !== null) {
//         if (matchM[0] != null) {
//           const start = new vscode.Position(currentLineNumber, matchM.index);
//           const end = new vscode.Position(currentLineNumber, matchM.index + 1);
//           const range = new vscode.Range(start, end);
//           const diagnostic = new vscode.Diagnostic(range, 'ERROR: Missing M code number', vscode.DiagnosticSeverity.Error);
//           diagnostics.push(diagnostic);
//         }
//       }
//     }
//     //This currently prioritizes over errors. Need to fix this.
//     suggestCapitalization(document, currentLineNumber, lineWithoutComments, diagnostics);
//   }

//   diagnosticCollection.set(document.uri, diagnostics);
//   updateStatusBar('Validation completed', 'statusBar.background', 'statusBar.foreground');
// }


// function getChangedLines(contentChanges) {
//   const changedLines = new Set();
//   for (const change of contentChanges) {
//     for (let i = change.range.start.line; i <= change.range.end.line; i++) {
//       changedLines.add(i);
//     }
//   }
//   return changedLines;
// }

// function deactivate() {
//   validationStatus.dispose();
// }

// module.exports = {
//   validateAndProvideDiagnostics,
//   deactivate,
// };

