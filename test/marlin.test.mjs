// npm install --save-dev mocha 
//this it the test file for the marlin_gcode_parser.js
//It will contains all Gcode and Mcode tests valid and invalid.
import { strict as assert } from 'assert';
import marlinGcodeParser from '../marlin_gcode_parser.js';
const options = { collectErrors: true , marlinVersion: "2.0" }; 
describe('Gcode and Mcode Parser Tests', () => {
    it('Valid G-code', () => {
        assert.doesNotThrow(() => {
            marlinGcodeParser.parse('G0 X10 Y10 Z10 F100 ;Comment', options);
            marlinGcodeParser.parse('G0 X10 Y10 Z10 F100 ', options);
            marlinGcodeParser.parse('G1 X10 Y10 Z10 F100 E400 S300 ;Comment', options);
            marlinGcodeParser.parse('G1 X10 Y10 Z10 F100 E400 S300 ', options);
            marlinGcodeParser.parse('G2 X10 Y10 Z10 F100 E400 S300 I10 J10 ;Comment', options);
            marlinGcodeParser.parse('G2 X10 Y10 Z10 R30 F100 E400 S300 ', options);
            marlinGcodeParser.parse('G3 X10 Y10 Z10 F100 E400 S300 I10 J10 ;Comment', options);
            marlinGcodeParser.parse('G3 X10 Y10 Z10 R30 F100 E400 S300 ', options);
            marlinGcodeParser.parse('G4 P1000 ;Comment', options);
            marlinGcodeParser.parse('G4 P1000 ', options);
            marlinGcodeParser.parse('G4 S1000 ;Comment', options);
            marlinGcodeParser.parse('G4 S1000 ', options);
            marlinGcodeParser.parse('G4 P1000 S1000;Comment', options);
            marlinGcodeParser.parse('G4 P1000 S1000', options);
        }, 'Valid G-code should not throw an error');
    });

    it('Valid M-code', () => {
        assert.doesNotThrow(() => {
            marlinGcodeParser.parse('M0 P20', options);
        }, 'Valid M-code should not throw an error');
    });

    it('Invalid G-code', () => {
        assert.throws(() => {
            marlinGcodeParser.parse('G0 X Y5 Z5',options); //Missing X value
        }, 'Invalid G-code should throw an error');
    });

    it('Invalid M-code', () => {
        assert.throws(() => {
            marlinGcodeParser.parse('M0 P',options); //Missing S value
            marlinGcodeParser.parse(invalidMcode, options);
        }, 'Invalid M-code should throw an error');
    });
});
