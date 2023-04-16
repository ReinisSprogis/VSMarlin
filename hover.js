const vscode = require('vscode');
const fs = require('fs');
const path = require('path');
const MarkdownIt = require('markdown-it');
const md = new MarkdownIt();

//This function provides information on hovering over keywords
function hoverInfoActivate(context) {
   // console.log('hoverInfoActivate is activated!');

    const hoverProvider = vscode.languages.registerHoverProvider('marlin', {
        provideHover(document, position, token) {
            const range = document.getWordRangeAtPosition(position);
            const word = document.getText(range);
           // console.log("Word: " + word);
            

            const getMarkdownFromFile = (filePath) => {
                try {
                    return new Promise((resolve, reject) => {
                        fs.readFile(filePath, 'utf8', (err, data) => {
                            if (err) {
                                reject(err);
                            } else {
                                const markdownString = md.render(data);
                                const hoverMarkdownString = new vscode.MarkdownString(markdownString, true);
                                hoverMarkdownString.supportHtml = true;
                                resolve(new vscode.Hover(hoverMarkdownString));
                            }
                        });
                    });
                } catch (e) {
                     return; // Return early if the word is empty or whitespace
                }
                
            };
           
            if (word.length > 5) {
                return; // Return early if the word is empty or whitespace
            }

            //If the word is G0 or G00 or G1 or G01 or G001
            //Then return the G0/G1 page
            //This is because the G0/G1 page contains information on both G0 and G1
            //This will be the same exclusive for other keywords.
            //For example, the G2/G3 page contains information on both G2 and G3
            //Other commands will be processed as if G4 is the same as G04 G004 and G004.
            //The same for M commands.
            //If no match is found, then no markup and hover info are shown. M29 M34 M665 M666 
            //Need to solve a way for G029 like files where multiple files are needed to be read for the same keyword.
            //G0/G1
            if (word == 'G0' || word == 'G00' || word == 'G1' || word == 'G01' || word == 'G001') {
                const gcodeFile = path.join(__dirname, 'MarlinDocumentation-master', '_gcode', 'G000-G001.md');
              return  getMarkdownFromFile(gcodeFile);
            //G2/G3
            } else if (word == 'G2' || word == 'G3' || word == 'G02' || word == 'G03' || word == 'G002' || word == 'G003') {
                    const gcodeFile = path.join(__dirname, 'MarlinDocumentation-master', '_gcode', 'G002-G003.md');
                    return getMarkdownFromFile(gcodeFile);
            //G17 G18 G19
            } else if (word == 'G17' || word ==  'G18' || word ==  'G19' || word ==  'G017' || word ==   'G018' || word ==  'G019') {
                const gcodeFile = path.join(__dirname, 'MarlinDocumentation-master', '_gcode', 'G017-G019.md');
                return getMarkdownFromFile(gcodeFile);
            }
            //G54 G55 G56 G57 G58 G59
            else if(word == 'G54' || word == 'G55' || word == 'G56' || word == 'G57' || word == 'G58'|| word == 'G59' || word == 'G054' || word == 'G055' || word == 'G056' || word == 'G057' || word == 'G058'|| word == 'G059' || word == 'G59.1' || word == 'G59.2' || word == 'G59.3'){
                const gcodeFile = path.join(__dirname, 'MarlinDocumentation-master', '_gcode', 'G054-G059.md');
                return getMarkdownFromFile(gcodeFile);
            //M0 M1
            }else if(word == 'M0' || word == 'M00' || word == 'M000' || word == 'M1' || word == 'M01' || word == 'M001'){
                const gcodeFile = path.join(__dirname, 'MarlinDocumentation-master', '_gcode', 'M000-M001.md');
                return getMarkdownFromFile(gcodeFile);
            //M7 M8 M9
            }else if(word == 'M7' || word == 'M07' || word == 'M007' || word == 'M8' || word == 'M08' || word == 'M008'|| word == 'M9' || word == 'M09' || word == 'M009'){
                const gcodeFile = path.join(__dirname, 'MarlinDocumentation-master', '_gcode', 'M007-M009.md');
                return getMarkdownFromFile(gcodeFile);
            //M10 M11
            }else if (word == 'M10' || word == 'M010' || word == 'M11' || word == 'M011'){
                const gcodeFile = path.join(__dirname, 'MarlinDocumentation-master', '_gcode', 'M010-M011.md');
                return getMarkdownFromFile(gcodeFile);
            //M810 M811 M812 M813 M814 M815 M816 M817 M818 M819 
            }else if (word == 'M810' || word == 'M811' || word == 'M812' || word == 'M813' || word == 'M814' || word == 'M815' || word == 'M816' || word == 'M817' || word == 'M818' || word == 'M819'){
                const gcodeFile = path.join(__dirname, 'MarlinDocumentation-master', '_gcode', 'M810-M819.md');
                return getMarkdownFromFile(gcodeFile);
            //M860, M861, M862, M863, M864, M865, M866, M867, M868, M869    
            }else if (word == 'M860' || word == 'M861' || word == 'M862' || word == 'M863' || word == 'M864' || word == 'M865' || word == 'M866' || word == 'M867' || word == 'M868' || word == 'M869'){
                const gcodeFile = path.join(__dirname, 'MarlinDocumentation-master', '_gcode', 'M860-M869.md');
                return getMarkdownFromFile(gcodeFile);
            //T1 T2    
            }else if (/T\d+/.test(word)){
                //console.log('T found:' + word);
                const gcodeFile = path.join(__dirname, 'MarlinDocumentation-master', '_gcode', 'T001-T002.md');
                return getMarkdownFromFile(gcodeFile);
            }
            else {
               
                filtered = '';
                if (word[0] == 'G' || word[0] == 'M'  && word.length <= 3) {
                    if (word.length == 2) {
                        filtered = word[0] + '00' + word.substring(1);
                    } else if (word.length == 3) {
                        filtered = word[0] + '0' + word.slice(1);
                    } else {
                        filtered = word;
                    }
                } else {
                    filtered = word;
                }
                const gcodeFile = path.join(__dirname, 'MarlinDocumentation-master', '_gcode', filtered + '.md');
                return getMarkdownFromFile(gcodeFile);
              
            }
        }
    });

    context.subscriptions.push(hoverProvider);
}


exports.hoverInfoActivate = hoverInfoActivate;

