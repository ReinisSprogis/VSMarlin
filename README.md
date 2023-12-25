# marlin README

This is an attempt of an VSCode extension for Marlin firmware G-Codes.
Let me be honest and say that it is far from complete and it is my first attempt at an extension. I created this as experiment some time ago and now decided to release it to the public to show concept and see if community is interested, rather than leave it on the dusty shelf forever. I will try to improve it over time but I can't promise anything. If you want to contribute, feel free to do so. If there is interest to take this to next level by community and make this a real extension, probably should discuss with contributors how to proceed. Currently it is more of a proof of concept. It is also not up to date with latest Marlin firmware. 

## Features
*Syntax highlighting
*Snippets for Marlin G-Codes and M-Codes
*Hover over G-Code and M-code to see description
*Tool path graphics 
*G-Code and Mcode Error checking
*Marlin Version checking
*Extrusion calculation - No working properly
*Program timeline chart 


\!\[Screenshot\]\(media\screenshot.png\)

> Tip: Select panel of code and press ctrl+Alt+R to see tool path graphics
> Tip: Select panel of code and press ctrl+Alt+T to see program timeline chart

## Requirements

VSCode

## Known Issues

*Extrusion calculation is not working properly and give wrong results.
*Parser checking full file on every change, slowing down editor. Need to find a way to check only changed lines.
*Graphics not supporting all G-Codes and M-Codes.
*Scrolling through code doesn't show correct tool path graphics. Need to account fro non G-Code lines.
*Potentially many more...

## Release Notes

Initial release.

### 1.0.0


**Enjoy!**
