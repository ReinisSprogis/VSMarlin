const vscode = require('vscode');
const axios = require('axios');
const cheerio = require('cheerio');
const path = require('path');

//This function provides information on hovering over keywords
function hoverInfoActivate(context) {
    console.log('hoverInfoActivate is activated!');
    const keywords = [
        'G01', 'G1', 'G001'
    ];

    const hoverProvider = vscode.languages.registerHoverProvider('marlin', {
        provideHover(document, position, token) {
            const range = document.getWordRangeAtPosition(position);
            const word = document.getText(range);
            const baseURL = "https://marlinfw.org";
            const relativeUrlRegex = /<a href="(\/.*?)">/g;
            console.log("Word: " + word);

            //If the word is G0 or G00 or G1 or G01 or G001
            //Then return the G0/G1 page
            //This is because the G0/G1 page contains information on both G0 and G1
            //Linear movement commands
            if (word == 'G0' || word == 'G00' || word == 'G1' || word == 'G01' || word == 'G001') {
                console.log("G0/G1")
                return axios.get('https://marlinfw.org/docs/gcode/G000-G001.html')
                    .then(response => {
                        const data = cheerio.load(response.data);
                        const content = data('div.col-lg-12.row.long').html();

                        console.log("Content g1: " + content);
                        const updatedMarkdownContent = content.toString().replace(relativeUrlRegex, `<a href="${baseURL}$1">`);
                        const markdownString = new vscode.MarkdownString('' + updatedMarkdownContent, true);
                        markdownString.supportHtml = true;
                        return new vscode.Hover(markdownString);
                    })
                    .catch(error => {
                        console.error(error);
                    });

            } else if (word == 'G2' || word == 'G3' || word == 'G02' || word == 'G03' || word == 'G002' || word == 'G003') {
                //If the word is G2 or G3 or G02 or G03 or G002 or G003
                //Then return the G2/G3 page
                //This is because the G2/G3 page contains information on both G2 and G3
                //Circular movement commands


                return axios.get('https://marlinfw.org/docs/gcode/G002-G003.html')
                    .then(response => {
                        const data = cheerio.load(response.data);
                        const content = data('div.col-lg-12.row.long').html();

                        console.log("Content g2: " + content);
                        const markdownString = new vscode.MarkdownString('' + content.toString(), true);
                        markdownString.supportHtml = true;
                        return new vscode.Hover(markdownString);
                    })
                    .catch(error => {
                        console.error(error);
                    });
            } else if (word == 'G17' || word ==  'G18' || word ==  'G19' || word ==  'G017' || word ==   'G018' || word ==  'G019') {
                //If the word is G17, G18, G19, G017, G018, G019
                //Then return the G17/G19 page
                //This is because the G17/G19 page contains information on both G17 and G19
                //Plane selection commands
                return axios.get('https://marlinfw.org/docs/gcode/G017-G019.html')
                    .then(response => {
                        const data = cheerio.load(response.data);
                        const content = data('div.col-lg-12.row.long').html();
                        console.log("Content g17: " + content);
                        const markdownString = new vscode.MarkdownString('' + content.toString(), true);
                        markdownString.supportHtml = true;
                        return new vscode.Hover(markdownString);
                    })
            }
            else if(word == 'G54' || word == 'G55' || word == 'G56' || word == 'G57' || word == 'G58'|| word == 'G59' || word == 'G054' || word == 'G055' || word == 'G056' || word == 'G057' || word == 'G058'|| word == 'G059'){
                //If the word is G54, G55, G56, G57, G58, G59, G054, G055, G056, G057, G058, G059
                //Then return the G54/G59 page
                //This is because the G54/G59 page contains information on both G54 and G59
                //Coordinate system selection commands
                return axios.get('https://marlinfw.org/docs/gcode/G054-G059.html')
                    .then(response => {
                        const data = cheerio.load(response.data);
                        const content = data('div.col-lg-12.row.long').html();
                        console.log("Content g54: " + content);
                        const markdownString = new vscode.MarkdownString('' + content.toString(), true);
                        markdownString.supportHtml = true;
                        return new vscode.Hover(markdownString);
                    })
            
                
            }
            else {

                //If G or M value contains 1 or 2 digits, add the 0 at the beginning to match 3 digit format.
                //G1 -> G001
                //G01 -> G001
                //G001 -> G001
                //M1 -> M001
                //M01 -> M001
                //M001 -> M001
                filtered = '';
                if (word[0] == 'G' || word[0] == 'M' && word.length <= 3) {
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

                console.log("Filtered: " + filtered);
                return axios.get('https://marlinfw.org/docs/gcode/' + filtered + '.html')
                    .then(response => {
                        const data = cheerio.load(response.data);
                        const content = data('div.col-lg-12.row.long').html();

                        console.log("Content: " + content);
                        const markdownString = new vscode.MarkdownString('' + content.toString(), true);
                        markdownString.supportHtml = true;
                        return new vscode.Hover(markdownString);
                    })
                    .catch(error => {
                        console.error(error);
                    });
            }
        }
    });

    context.subscriptions.push(hoverProvider);
}


exports.hoverInfoActivate = hoverInfoActivate;