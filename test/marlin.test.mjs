// npm install --save-dev mocha 
//Test file for the marlin_gcode_parser.js
//It will contains all Gcode and Mcode tests valid and invalid.
import { strict as assert } from 'assert';
import marlinGcodeParser from '../marlin_gcode_parser.js';
const options = { collectErrors: true , marlinVersion: "2.0.0" }; 
describe('Gcode and Mcode Parser Tests', () => {
    it('Valid G-code', () => {
        assert.doesNotThrow(() => {
            //G0 [E<pos>] [F<rate>] [S<power>] [X<pos>] [Y<pos>] [Z<pos>]
            marlinGcodeParser.parse('G0 X10', options);
            marlinGcodeParser.parse('G0 X10 Y10', options);
            marlinGcodeParser.parse('G0 X10 Y10 Z10', options);
            marlinGcodeParser.parse('G0 X10 Y10 Z10 F100 ', options); 
            marlinGcodeParser.parse('G0 X10 Y10 Z10 F100 E400', options);
            marlinGcodeParser.parse('G0 X10 Y10 Z10 F100 E400 S300', options);
            marlinGcodeParser.parse('G0 X10 Y10 Z10 F100 E400 S300 ;Comment', options);

            //G1 [E<pos>] [F<rate>] [S<power>] [X<pos>] [Y<pos>] [Z<pos>]
            marlinGcodeParser.parse('G1 X10', options);
            marlinGcodeParser.parse('G1 X10 Y10', options);
            marlinGcodeParser.parse('G1 X10 Y10 Z10', options);
            marlinGcodeParser.parse('G1 X10 Y10 Z10 F100 ', options);
            marlinGcodeParser.parse('G1 X10 Y10 Z10 F100 E400', options);
            marlinGcodeParser.parse('G1 X10 Y10 Z10 F100 E400 S300', options);
            marlinGcodeParser.parse('G1 X10 Y10 Z10 F100 E400 S300 ;Comment', options);

            //G2 [E<pos>] [F<rate>] I<offset> J<offset> [P<count>] R<radius> [S<power>] [X<pos>] [Y<pos>] [Z<pos>]
            marlinGcodeParser.parse('G2 X10 Y10 I10 J10', options);
            marlinGcodeParser.parse('G2 X10 Y10 I10 J10 P10', options);
            marlinGcodeParser.parse('G2 X10 Y10 R10', options);
            marlinGcodeParser.parse('G2 X10 Y10 R10 S10', options);
            marlinGcodeParser.parse('G2 X10 Y10 R10 S10 E10', options);
            marlinGcodeParser.parse('G2 X10 Y10 R10 S10 E10 F10', options);
            marlinGcodeParser.parse('G2 X10 Y10 Z10 R10 S10 E10 F10', options);
            marlinGcodeParser.parse('G2 X10 Y10 Z10 R10 S10 E10 F10 ;Comment', options);

            //G3 [E<pos>] [F<rate>] I<offset> J<offset> [P<count>] R<radius> [S<power>] [X<pos>] [Y<pos>] [Z<pos>]
            marlinGcodeParser.parse('G3 X10 Y10 I10 J10', options);
            marlinGcodeParser.parse('G3 X10 Y10 I10 J10 P10', options);
            marlinGcodeParser.parse('G3 X10 Y10 R10', options);
            marlinGcodeParser.parse('G3 X10 Y10 R10 S10', options);
            marlinGcodeParser.parse('G3 X10 Y10 R10 S10 E10', options);
            marlinGcodeParser.parse('G3 X10 Y10 R10 S10 E10 F10', options);
            marlinGcodeParser.parse('G3 X10 Y10 Z10 R10 S10 E10 F10', options);
            marlinGcodeParser.parse('G3 X10 Y10 Z10 R10 S10 E10 F10 ;Comment', options);

            //G4 [P<time (ms)>] [S<time (sec)>]
            marlinGcodeParser.parse('G4 P10', options);
            marlinGcodeParser.parse('G4 S10', options);
            marlinGcodeParser.parse('G4 P10 S10', options);
            marlinGcodeParser.parse('G4 P10 S10 ;Comment', options);

            ////G5 [E<pos>] [F<rate>] I<pos> J<pos> P<pos> Q<pos> [S<power>] X<pos> Y<pos>
            marlinGcodeParser.parse('G5 X10 Y10 I10 J10 P10 Q10', options);
            marlinGcodeParser.parse('G5 X10 Y10 I10 J10 P10 Q10 S10', options);
            marlinGcodeParser.parse('G5 X10 Y10 I10 J10 P10 Q10 S10 E10', options);
            marlinGcodeParser.parse('G5 X10 Y10 I10 J10 P10 Q10 S10 E10 F10', options);
            marlinGcodeParser.parse('G5 X10 Y10 I10 J10 P10 Q10 S10 E10 F10 ;Comment', options);

            ////G6 [E<direction>] [I<index>] [R<rate>] [S<rate>] [X<direction>] [Y<direction>] [Z<direction>]
            marlinGcodeParser.parse('G6 X1 Y1 Z1 E1', options);
            marlinGcodeParser.parse('G6 X1 Y1 Z1 E1 I10', options);
            marlinGcodeParser.parse('G6 X1 Y1 Z1 E1 I10', options);
            marlinGcodeParser.parse('G6 X1 Y1 Z1 E1 R10 S10', options);
            marlinGcodeParser.parse('G6 X1 Y1 Z1 E1 R10 S10 ;Comment', options);

            //G10 [S<bool>]
            marlinGcodeParser.parse('G10 S1', options);
            marlinGcodeParser.parse('G10 S0 ;Comment', options);

            //G11 [S<bool>]
            marlinGcodeParser.parse('G11 S1', options);
            marlinGcodeParser.parse('G11 S0 ;Comment', options);

            //G12 [P<0|1|2>] [R<radius>] [S<count>] [T<count>] [X] [Y] [Z]
            marlinGcodeParser.parse('G12 P0 R10 S10 T10 X Y Z', options);
            marlinGcodeParser.parse('G12 P1 R10 S10 T10 X Y Z', options);
            marlinGcodeParser.parse('G12 P2 R10 S10 T10 X Y Z', options);
            marlinGcodeParser.parse('G12 P0 R10 S10 T10 X Y Z ;Comment', options);

            //G26 [B<temp>] [C<bool>] [D] [F<linear>] [H<linear>] [I<index>] [K<bool>] [L<linear>] [O<linear>] [P<linear>] [Q<float>] [R<int>] [S<float>] [U<linear>] [X<linear>] [Y<linear>]
            marlinGcodeParser.parse('G26 B10 C1 D F10 H10 I10 K1 L10 O10 P10 Q10 R10 S10 U10 X10 Y10', options);
            marlinGcodeParser.parse('G26 B10 C1 D F10 H10 I10 K1 L10 O10 P10 Q10 R10 S10 U10 X10 Y10 ;Comment', options);

            //G27 [P<0|1|2>]
            marlinGcodeParser.parse('G27 P0', options);
            marlinGcodeParser.parse('G27 P1', options);
            marlinGcodeParser.parse('G27 P2', options);
            marlinGcodeParser.parse('G27 P0 ;Comment', options);

            ////G28 [L] [O] [R] [X] [Y] [Z]
            marlinGcodeParser.parse('G28 L', options);
            marlinGcodeParser.parse('G28 O', options);
            marlinGcodeParser.parse('G28 R', options);
            marlinGcodeParser.parse('G28 X', options);
            marlinGcodeParser.parse('G28 Y', options);
            marlinGcodeParser.parse('G28 Z', options);
            marlinGcodeParser.parse('G28 L O R X Y Z', options);
            marlinGcodeParser.parse('G28 L O R X Y Z ;Comment', options);

            //G30 [C<bool>] [E<bool>] [X<pos>] [Y<pos>]
            marlinGcodeParser.parse('G30 C1 E1 X10 Y10', options);
            marlinGcodeParser.parse('G30 C1 E1 X10 Y10 ;Comment', options);

            //G33 [C<float>] [E<bool>] [F<1-30>] [O<bool>] [P<|0|1|2|3|4-10>] [R<float>] [T<bool>] [V<|0|1|2|3|>]
            marlinGcodeParser.parse('G33 C10 E1 F10 O1 P10 R10 T1 V1', options);
            marlinGcodeParser.parse('G33 C10 E1 F10 O1 P10 R10 T1 V1 ;Comment', options);

            ////G34 [A] [E] [I] [T]
            marlinGcodeParser.parse('G34 A', options);
            marlinGcodeParser.parse('G34 E', options);
            marlinGcodeParser.parse('G34 I', options);
            marlinGcodeParser.parse('G34 T', options);
            marlinGcodeParser.parse('G34 A E I T', options);
            marlinGcodeParser.parse('G34 A E I T ;Comment', options);

            //G34 [S<mA>] [Z<linear>]
            marlinGcodeParser.parse('G34 S10 Z10', options);
            marlinGcodeParser.parse('G34 S10 Z10 ;Comment', options);

            //G35 [S<30|31|40|41|50|51>]
            marlinGcodeParser.parse('G35 S30', options);
            marlinGcodeParser.parse('G35 S31', options);
            marlinGcodeParser.parse('G35 S40', options);
            marlinGcodeParser.parse('G35 S41', options);
            marlinGcodeParser.parse('G35 S50', options);
            marlinGcodeParser.parse('G35 S51', options);
            marlinGcodeParser.parse('G35 S30 ;Comment', options);

            // G38.2 [F<rate>] [X<pos>] [Y<pos>] [Z<pos>]
            marlinGcodeParser.parse('G38.2 X10 Y10 Z10', options);
            marlinGcodeParser.parse('G38.2 X10 Y10 Z10 F10', options);
            marlinGcodeParser.parse('G38.2 X10 Y10 Z10 F10 ;Comment', options);

            // G38.3 [F<rate>] [X<pos>] [Y<pos>] [Z<pos>]
            marlinGcodeParser.parse('G38.3 X10 Y10 Z10', options);
            marlinGcodeParser.parse('G38.3 X10 Y10 Z10 F10', options);
            marlinGcodeParser.parse('G38.3 X10 Y10 Z10 F10 ;Comment', options);

            // G38.4 [F<rate>] [X<pos>] [Y<pos>] [Z<pos>]
            marlinGcodeParser.parse('G38.4 X10 Y10 Z10', options);
            marlinGcodeParser.parse('G38.4 X10 Y10 Z10 F10', options);
            marlinGcodeParser.parse('G38.4 X10 Y10 Z10 F10 ;Comment', options);

            // G38.5 [F<rate>] [X<pos>] [Y<pos>] [Z<pos>]
            marlinGcodeParser.parse('G38.5 X10 Y10 Z10', options);
            marlinGcodeParser.parse('G38.5 X10 Y10 Z10 F10', options);
            marlinGcodeParser.parse('G38.5 X10 Y10 Z10 F10 ;Comment', options);

            // G42 [F<rate>] [I<pos>] [J<pos>]
            marlinGcodeParser.parse('G42 F10 I10 J10', options);
            marlinGcodeParser.parse('G42 F10 I10 J10 ;Comment', options);

            //G60 [S<slot>]
            marlinGcodeParser.parse('G60 S10', options);
            marlinGcodeParser.parse('G60 S10 ;Comment', options);

            // G61 [E] [F<rate>] [S<slot>] [X] [Y] [Z]
            marlinGcodeParser.parse('G61 E F10 S10 X Y Z', options);
            marlinGcodeParser.parse('G61 E F10 S10 X Y Z ;Comment', options);

            //G76 [B] [P]
            marlinGcodeParser.parse('G76 B P', options);
            marlinGcodeParser.parse('G76 B P ;Comment', options);

            //G92 [E<pos>] [X<pos>] [Y<pos>] [Z<pos>]
            marlinGcodeParser.parse('G92 E10 X10 Y10 Z10', options);
            marlinGcodeParser.parse('G92 E10 X10 Y10 Z10 ;Comment', options);

            //G425 [B] [T<index>] [U<linear>] [V]
            marlinGcodeParser.parse('G425 B T10 U10 V', options);
            marlinGcodeParser.parse('G425 B T10 U10 V ;Comment', options);

            //Non parameter commands  "G91" /"G90" /"G80" /"G59.3" /"G59.2" /"G59.1" / "G59" /"G58" / "G57" / "G56" / "G55" / "G54" / "G53" / "G32" / "G31" / "G21" /"G20" /"G19" /"G18" /"G17"
            marlinGcodeParser.parse('G91', options);
            marlinGcodeParser.parse('G91 ;comment', options);
            marlinGcodeParser.parse('G90', options);
            marlinGcodeParser.parse('G90 ;comment', options);
            marlinGcodeParser.parse('G80', options);
            marlinGcodeParser.parse('G80 ;comment', options);
            marlinGcodeParser.parse('G59.3', options);
            marlinGcodeParser.parse('G59.3 ;comment', options);
            marlinGcodeParser.parse('G59.2', options);
            marlinGcodeParser.parse('G59.2 ;comment', options);
            marlinGcodeParser.parse('G59.1', options);
            marlinGcodeParser.parse('G59.1 ;comment', options);
            marlinGcodeParser.parse('G59', options);
            marlinGcodeParser.parse('G59 ;comment', options);
            marlinGcodeParser.parse('G58', options);
            marlinGcodeParser.parse('G58 ;comment', options);
            marlinGcodeParser.parse('G57', options);
            marlinGcodeParser.parse('G57 ;comment', options);
            marlinGcodeParser.parse('G56', options);
            marlinGcodeParser.parse('G56 ;comment', options);
            marlinGcodeParser.parse('G55', options);
            marlinGcodeParser.parse('G55 ;comment', options);
            marlinGcodeParser.parse('G54', options);
            marlinGcodeParser.parse('G54 ;comment', options);
            marlinGcodeParser.parse('G53', options);
            marlinGcodeParser.parse('G53 ;comment', options);
            marlinGcodeParser.parse('G32', options);
            marlinGcodeParser.parse('G32 ;comment', options);
            marlinGcodeParser.parse('G31', options);
            marlinGcodeParser.parse('G31 ;comment', options);
            marlinGcodeParser.parse('G21', options);
            marlinGcodeParser.parse('G21 ;comment', options);
            marlinGcodeParser.parse('G20', options);
            marlinGcodeParser.parse('G20 ;comment', options);
            marlinGcodeParser.parse('G19', options);
            marlinGcodeParser.parse('G19 ;comment', options);
            marlinGcodeParser.parse('G18', options);
            marlinGcodeParser.parse('G18 ;comment', options);
            marlinGcodeParser.parse('G17', options);
            marlinGcodeParser.parse('G17 ;comment', options);


        }, 'Valid G-code should not throw an error');
    });

    it('Valid M-code', () => {
        assert.doesNotThrow(() => {
            marlinGcodeParser.parse('M0 P20', options);
        }, 'Valid M-code should not throw an error');
    });

    it('Invalid G-code', () => {
       
            //G0 [E<pos>] [F<rate>] [S<power>] [X<pos>] [Y<pos>] [Z<pos>]
            assert.throws(() => {
                marlinGcodeParser.parse('G0 X2 Y5 Z5',options); //Missing X value
            });
            marlinGcodeParser.parse('G0 X4 Y5 Z5 F ',options); //Missing F value
            marlinGcodeParser.parse('G0 X4 Y5 Z ',options); //Missing Z value
            marlinGcodeParser.parse('G0 X4 Y5 Z5 F',options); //Missing F value
            marlinGcodeParser.parse('G0 X4 Y5 Z5 F32 S',options); //Missing S value
            marlinGcodeParser.parse('G0 X4 Y5 Z5 F4 S24 E',options); //Missing E value
            marlinGcodeParser.parse('G0 X Y Z F S E',options); //Missing X,Y,Z,F,S,E values
            marlinGcodeParser.parse('G0 X3 Y5 Z5 7',options); //Invalid parameter end - 7
            marlinGcodeParser.parse('G0 X4 h Y5 Z5',options); //Invalid parameter middle - h
            marlinGcodeParser.parse('G0h X4 Y5 Z5',options); // Invalid parameter beginning - h
            marlinGcodeParser.parse('G0 X4 Y5 Z5 Comment without semicolon',options); //Comment without semicolon
           
            //G1 [E<pos>] [F<rate>] [S<power>] [X<pos>] [Y<pos>] [Z<pos>]
            marlinGcodeParser.parse('G1 X Y5 Z5',options); //Missing X value
            marlinGcodeParser.parse('G1 X4 Y5 Z5 F ',options); //Missing F value
            marlinGcodeParser.parse('G1 X4 Y5 Z ',options); //Missing Z value
            marlinGcodeParser.parse('G1 X4 Y5 Z5 F',options); //Missing F value
            marlinGcodeParser.parse('G1 X4 Y5 Z5 F32 S',options); //Missing S value
            marlinGcodeParser.parse('G1 X4 Y5 Z5 F4 S24 E',options); //Missing E value
            marlinGcodeParser.parse('G1 X Y Z F S E',options); //Missing X,Y,Z,F,S,E values
            marlinGcodeParser.parse('G1 X3 Y5 Z5 7',options); //Invalid parameter end - 7
            marlinGcodeParser.parse('G1 X4 h Y5 Z5',options); //Invalid parameter middle - h
            marlinGcodeParser.parse('G1h X4 Y5 Z5',options); // Invalid parameter beginning - h
            marlinGcodeParser.parse('G1 X4 Y5 Z5 Comment without semicolon',options); //Comment without semicolon
           
            //G2 [E<pos>] [F<rate>] I<offset> J<offset> [P<count>] R<radius> [S<power>] [X<pos>] [Y<pos>] [Z<pos>]
            marlinGcodeParser.parse('G2 X Y5 Z5',options); //Missing X value
            marlinGcodeParser.parse('G2 X4 Y5 Z5 F ',options); //Missing F value
            marlinGcodeParser.parse('G2 X4 Y5 Z ',options); //Missing Z value
            marlinGcodeParser.parse('G2 X4 Y5 Z5 F',options); //Missing F value
            marlinGcodeParser.parse('G2 X4 Y5 Z5 F32 S',options); //Missing S value
            marlinGcodeParser.parse('G2 X4 Y5 Z5 F4 S24 E',options); //Missing E value
            marlinGcodeParser.parse('G2 X Y Z F S E',options); //Missing X,Y,Z,F,S,E values
            marlinGcodeParser.parse('G2 X3 Y5 Z5 7',options); //Invalid parameter end - 7
            marlinGcodeParser.parse('G2 X4 h Y5 Z5',options); //Invalid parameter middle - h
            marlinGcodeParser.parse('G2h X4 Y5 Z5',options); // Invalid parameter beginning - h
            marlinGcodeParser.parse('G2 X4 Y5 Z5 Comment without semicolon',options); //Comment without semicolon

            //G3 [E<pos>] [F<rate>] I<offset> J<offset> [P<count>] R<radius> [S<power>] [X<pos>] [Y<pos>] [Z<pos>]
            marlinGcodeParser.parse('G3 X Y5 Z5',options); //Missing X value
            marlinGcodeParser.parse('G3 X4 Y5 Z5 F ',options); //Missing F value
            marlinGcodeParser.parse('G3 X4 Y5 Z ',options); //Missing Z value
            marlinGcodeParser.parse('G3 X4 Y5 Z5 F',options); //Missing F value
            marlinGcodeParser.parse('G3 X4 Y5 Z5 F32 S',options); //Missing S value
            marlinGcodeParser.parse('G3 X4 Y5 Z5 F4 S24 E',options); //Missing E value
            marlinGcodeParser.parse('G3 X Y Z F S E',options); //Missing X,Y,Z,F,S,E values
            marlinGcodeParser.parse('G3 X3 Y5 Z5 7',options); //Invalid parameter end - 7
            marlinGcodeParser.parse('G3 X4 h Y5 Z5',options); //Invalid parameter middle - h
            marlinGcodeParser.parse('G3h X4 Y5 Z5',options); // Invalid parameter beginning - h
            marlinGcodeParser.parse('G3 X4 Y5 Z5 Comment without semicolon',options); //Comment without semicolon

            //G4 [P<time (ms)>] [S<time (sec)>]
            marlinGcodeParser.parse('G4 P',options); //Missing P value
            marlinGcodeParser.parse('G4 S',options); //Missing S value
            marlinGcodeParser.parse('G4 P S',options); //Missing P and S values
            marlinGcodeParser.parse('G4 P S Comment',options); //Missing P and S values and comment without semicolon
            marlinGcodeParser.parse('G4 P10 S10 A',options); //Invalid parameter end - A

            ////G5 [E<pos>] [F<rate>] I<pos> J<pos> P<pos> Q<pos> [S<power>] X<pos> Y<pos>
            marlinGcodeParser.parse('G5 X Y5 Z5',options); //Missing X value
            marlinGcodeParser.parse('G5 X4 Y5 Z5 F ',options); //Missing F value
            marlinGcodeParser.parse('G5 X4 Y5 Z ',options); //Missing Z value
            marlinGcodeParser.parse('G5 X4 Y Z5 F10',options); //Missing Y value
            marlinGcodeParser.parse('G5 X4 Y5 Z5 F32 S',options); //Missing S value
            marlinGcodeParser.parse('G5 X4 Y5 Z5 F4 S24 E',options); //Missing E value
            marlinGcodeParser.parse('G5 X Y Z F S E',options); //Missing X,Y,Z,F,S,E values
            marlinGcodeParser.parse('G5 X3 Y5 Z5 7',options); //Invalid parameter end - 7
            marlinGcodeParser.parse('G5 X4 h Y5 Z5',options); //Invalid parameter middle - h
            marlinGcodeParser.parse('G5h X4 Y5 Z5',options); // Invalid parameter beginning - h
            marlinGcodeParser.parse('G5 X4 Y5 Z5 Comment without semicolon',options); //Comment without semicolon

            ////G6 [E<direction>] [I<index>] [R<rate>] [S<rate>] [X<direction>] [Y<direction>] [Z<direction>]
            marlinGcodeParser.parse('G6 X Y5 Z5',options); //Missing X value
            marlinGcodeParser.parse('G6 X4 Y5 Z5 F ',options); //Missing F value
            marlinGcodeParser.parse('G6 X4 Y5 Z ',options); //Missing Z value
            marlinGcodeParser.parse('G6 X4 Y Z5 F10',options); //Missing Y value
            marlinGcodeParser.parse('G6 X4 Y5 Z5 F32 S',options); //Missing S value
            marlinGcodeParser.parse('G6 X4 Y5 Z5 F4 S24 E',options); //Missing E value
            marlinGcodeParser.parse('G6 X Y Z F S E',options); //Missing X,Y,Z,F,S,E values
            marlinGcodeParser.parse('G6 X3 Y5 Z5 7',options); //Invalid parameter end - 7
            marlinGcodeParser.parse('G6 X4 h Y5 Z5',options); //Invalid parameter middle - h
            marlinGcodeParser.parse('G6h X4 Y5 Z5',options); // Invalid parameter beginning - h
            marlinGcodeParser.parse('G6 X4 Y5 Z5 Comment without semicolon',options); //Comment without semicolon

            //G10 [S<bool>]
            marlinGcodeParser.parse('G10 S',options); //Missing S value
            marlinGcodeParser.parse('G10 S Comment',options); //Missing S value and comment without semicolon
            marlinGcodeParser.parse('G10 S10 A',options); //Invalid parameter end - A

            //G11 [S<bool>]
            marlinGcodeParser.parse('G11 S',options); //Missing S value
            marlinGcodeParser.parse('G11 S Comment',options); //Missing S value and comment without semicolon
            marlinGcodeParser.parse('G11 S10 A',options); //Invalid parameter end - A

            //G12 [P<0|1|2>] [R<radius>] [S<count>] [T<count>] [X] [Y] [Z]
            marlinGcodeParser.parse('G12 P3',options); //Invalid P value
            marlinGcodeParser.parse('G12 P1 R',options); //Missing R value
            marlinGcodeParser.parse('G12 P1 R10 S',options); //Missing S value
            marlinGcodeParser.parse('G12 P1 R10 S10 T',options); //Missing T value
            marlinGcodeParser.parse('G12 P1 R10 S10 T10 X10',options); //Flag X with value
            marlinGcodeParser.parse('G12 P1 R10 S10 T10 X Y10',options); //Flag Y with value
            marlinGcodeParser.parse('G12 P1 R10 S10 T10 X Y Z10',options); //Flag Z with value
            marlinGcodeParser.parse('G12 P1 R10 S10 T10 X Y Z10 A',options); //Invalid parameter end - A
            marlinGcodeParser.parse('G12 P1 R10 S10 T10 X Y Z10 Comment',options); //Comment without semicolon

            //G26 [B<temp>] [C<bool>] [D] [F<linear>] [H<linear>] [I<index>] [K<bool>] [L<linear>] [O<linear>] [P<linear>] [Q<float>] [R<int>] [S<float>] [U<linear>] [X<linear>] [Y<linear>]
            marlinGcodeParser.parse('G26 B',options); //Missing B value
            marlinGcodeParser.parse('G26 B10 C',options); //Missing C value
            marlinGcodeParser.parse('G26 B10 C1 D1',options); //Flag D with value
            marlinGcodeParser.parse('G26 B10 C1 D F',options); //Missing F value
            marlinGcodeParser.parse('G26 B10 C1 D F10 H',options); //Missing H value
            marlinGcodeParser.parse('G26 B10 C1 D F10 H10 I',options); //Missing I value
            marlinGcodeParser.parse('G26 B10 C1 D F10 H10 I10 K',options); //Missing K value
            marlinGcodeParser.parse('G26 B10 C1 D F10 H10 I10 K1 L',options); //Missing L value
            marlinGcodeParser.parse('G26 B10 C1 D F10 H10 I10 K1 L10 O',options); //Missing O value
            marlinGcodeParser.parse('G26 B10 C1 D F10 H10 I10 K1 L10 O10 P',options); //Missing P value
            marlinGcodeParser.parse('G26 B10 C1 D F10 H10 I10 K1 L10 O10 P10 Q',options); //Missing Q value
            marlinGcodeParser.parse('G26 B10 C1 D F10 H10 I10 K1 L10 O10 P10 Q10 R',options); //Missing R value
            marlinGcodeParser.parse('G26 B10 C1 D F10 H10 I10 K1 L10 O10 P10 Q10 R10 S',options); //Missing S value
            marlinGcodeParser.parse('G26 B10 C1 D F10 H10 I10 K1 L10 O10 P10 Q10 R10 S10 U',options); //Missing U value
            marlinGcodeParser.parse('G26 B10 C1 D F10 H10 I10 K1 L10 O10 P10 Q10 R10 S10 U10 X',options); //Missing X value
            marlinGcodeParser.parse('G26 B10 C1 D F10 H10 I10 K1 L10 O10 P10 Q10 R10 S10 U10 X10 Y',options); //Missing Y value
            marlinGcodeParser.parse('G26 B10 C1 D F10 H10 I10 K1 L10 O10 P10 Q10 R10 S10 U10 X10 Y10 A',options); //Invalid parameter end - A
            marlinGcodeParser.parse('G26 B10 C1 D F10 H10 I10 K1 L10 O10 P10 Q10 R10 S10 U10 X10 Y10 Comment',options); //Comment without semicolon

            //G27 [P<0|1|2>]
            marlinGcodeParser.parse('G27 P',options); //Missing P value
            marlinGcodeParser.parse('G27 P3',options); //Invalid P value
            marlinGcodeParser.parse('G27 P0 A',options); //Invalid parameter end - A
            marlinGcodeParser.parse('G27 P0 Comment',options); //Comment without semicolon

            ////G28 [L] [O] [R] [X] [Y] [Z]
            marlinGcodeParser.parse('G28 L1 O R X Y Z',options); //Flag L with value
            marlinGcodeParser.parse('G28 L O1 R X Y Z',options); //Flag O with value
            marlinGcodeParser.parse('G28 L O R1 X Y Z',options); //Flag R with value
            marlinGcodeParser.parse('G28 L O R X1 Y Z',options); //Flag X with value
            marlinGcodeParser.parse('G28 L O R X Y1 Z',options); //Flag Y with value
            marlinGcodeParser.parse('G28 L O R X Y Z1',options); //Flag Z with value
            marlinGcodeParser.parse('G28 L O R X Y Z A',options); //Invalid parameter end - A
            marlinGcodeParser.parse('G28 L O R X Y Z Comment',options); //Comment without semicolon

            //G30 [C<bool>] [E<bool>] [X<pos>] [Y<pos>]
            marlinGcodeParser.parse('G30 C',options); //Missing C value
            marlinGcodeParser.parse('G30 C1 E',options); //Missing E value
            marlinGcodeParser.parse('G30 C1 E1 X',options); //Missing X value
            marlinGcodeParser.parse('G30 C1 E1 X10 Y',options); //Missing Y value
            marlinGcodeParser.parse('G30 C1 E1 X10 Y10 A',options); //Invalid parameter end - A
            marlinGcodeParser.parse('G30 C1 E1 X10 Y10 Comment',options); //Comment without semicolon

            //G33 [C<float>] [E<bool>] [F<1-30>] [O<bool>] [P<|0|1|2|3|4-10>] [R<float>] [T<bool>] [V<|0|1|2|3|>]
            marlinGcodeParser.parse('G33 C',options); //Missing C value
            marlinGcodeParser.parse('G33 C1 E',options); //Missing E value
            marlinGcodeParser.parse('G33 C1 E2',options); //invalid E value
            marlinGcodeParser.parse('G33 C1 E1 F',options); //Missing F value
            marlinGcodeParser.parse('G33 C1 E1 F33',options); //Invalid F value
            marlinGcodeParser.parse('G33 C1 E1 F10 O',options); //Missing O value
            marlinGcodeParser.parse('G33 C1 E1 F10 O1 P',options); //Missing P value
            marlinGcodeParser.parse('G33 C1 E1 F10 O1 P11',options); //Invalid P value
            marlinGcodeParser.parse('G33 C1 E1 F10 O1 P10 R',options); //Missing R value
            marlinGcodeParser.parse('G33 C1 E1 F10 O1 P10 R10 T',options); //Missing T value
            marlinGcodeParser.parse('G33 C1 E1 F10 O1 P10 R10 T1 V',options); //Missing V value
            marlinGcodeParser.parse('G33 C1 E1 F10 O1 P10 R10 T1 V4',options); //Invalid V value
            marlinGcodeParser.parse('G33 C1 E1 F10 O1 P10 R10 T1 V1 A',options); //Invalid parameter end - A
            marlinGcodeParser.parse('G33 C1 E1 F10 O1 P10 R10 T1 V1 Comment',options); //Comment without semicolon

            ////G34 [A] [E] [I] [T]
            marlinGcodeParser.parse('G34 A1 E I T',options); //Flag A with value
            marlinGcodeParser.parse('G34 A E1 I T',options); //Flag E with value
            marlinGcodeParser.parse('G34 A E I1 T',options); //Flag I with value
            marlinGcodeParser.parse('G34 A E I T1',options); //Flag T with value
            marlinGcodeParser.parse('G34 A E I T L',options); //Invalid parameter end - L
            marlinGcodeParser.parse('G34 A E I T Comment',options); //Comment without semicolon

            //G34 [S<mA>] [Z<linear>]
            marlinGcodeParser.parse('G34 S',options); //Missing S value
            marlinGcodeParser.parse('G34 S10 Z',options); //Missing Z value
            marlinGcodeParser.parse('G34 S10 Z10 L',options); //Invalid parameter end - A
            marlinGcodeParser.parse('G34 S10 Z10 Comment',options); //Comment without semicolon

            //G35 [S<30|31|40|41|50|51>]
            marlinGcodeParser.parse('G35 S',options); //Missing S value
            marlinGcodeParser.parse('G35 S29',options); //Invalid S value
            marlinGcodeParser.parse('G35 S30 A',options); //Invalid parameter end - A
            marlinGcodeParser.parse('G35 S30 Comment',options); //Comment without semicolon

            // G38.2 [F<rate>] [X<pos>] [Y<pos>] [Z<pos>]
            marlinGcodeParser.parse('G38.2 X',options); //Missing X value
            marlinGcodeParser.parse('G38.2 X10 Y',options); //Missing Y value
            marlinGcodeParser.parse('G38.2 X10 Y10 Z',options); //Missing Z value
            marlinGcodeParser.parse('G38.2 X10 Y10 Z10 F',options); //Missing F value
            marlinGcodeParser.parse('G38.2 X10 Y10 Z10 F10 A',options); //Invalid parameter end - A
            marlinGcodeParser.parse('G38.2 X10 Y10 Z10 F10 Comment',options); //Comment without semicolon
            
            // G38.3 [F<rate>] [X<pos>] [Y<pos>] [Z<pos>]
            marlinGcodeParser.parse('G38.3 X',options); //Missing X value
            marlinGcodeParser.parse('G38.3 X10 Y',options); //Missing Y value
            marlinGcodeParser.parse('G38.3 X10 Y10 Z',options); //Missing Z value
            marlinGcodeParser.parse('G38.3 X10 Y10 Z10 F',options); //Missing F value
            marlinGcodeParser.parse('G38.3 X10 Y10 Z10 F10 A',options); //Invalid parameter end - A
            marlinGcodeParser.parse('G38.3 X10 Y10 Z10 F10 Comment',options); //Comment without semicolon

            // G38.4 [F<rate>] [X<pos>] [Y<pos>] [Z<pos>]
            marlinGcodeParser.parse('G38.4 X',options); //Missing X value
            marlinGcodeParser.parse('G38.4 X10 Y',options); //Missing Y value
            marlinGcodeParser.parse('G38.4 X10 Y10 Z',options); //Missing Z value
            marlinGcodeParser.parse('G38.4 X10 Y10 Z10 F',options); //Missing F value
            marlinGcodeParser.parse('G38.4 X10 Y10 Z10 F10 A',options); //Invalid parameter end - A
            marlinGcodeParser.parse('G38.4 X10 Y10 Z10 F10 Comment',options); //Comment without semicolon

            // G38.5 [F<rate>] [X<pos>] [Y<pos>] [Z<pos>]
            marlinGcodeParser.parse('G38.5 X',options); //Missing X value
            marlinGcodeParser.parse('G38.5 X10 Y',options); //Missing Y value
            marlinGcodeParser.parse('G38.5 X10 Y10 Z',options); //Missing Z value
            marlinGcodeParser.parse('G38.5 X10 Y10 Z10 F',options); //Missing F value
            marlinGcodeParser.parse('G38.5 X10 Y10 Z10 F10 A',options); //Invalid parameter end - A
            marlinGcodeParser.parse('G38.5 X10 Y10 Z10 F10 Comment',options); //Comment without semicolon

            // G42 [F<rate>] [I<pos>] [J<pos>]
            marlinGcodeParser.parse('G42 F',options); //Missing F value
            marlinGcodeParser.parse('G42 F10 I',options); //Missing I value
            marlinGcodeParser.parse('G42 F10 I10 J',options); //Missing J value
            marlinGcodeParser.parse('G42 F10 I10 J10 A',options); //Invalid parameter end - A
            marlinGcodeParser.parse('G42 F10 I10 J10 Comment',options); //Comment without semicolon

            //G60 [S<slot>]
            marlinGcodeParser.parse('G60 S',options); //Missing S value
            marlinGcodeParser.parse('G60 S10 A',options); //Invalid parameter end - A
            marlinGcodeParser.parse('G60 S10 Comment',options); //Comment without semicolon
            
            // G61 [E] [F<rate>] [S<slot>] [X] [Y] [Z]
            marlinGcodeParser.parse('G61 E10',options); //Flag E with value
            marlinGcodeParser.parse('G61 E F',options); //Missing F value
            marlinGcodeParser.parse('G61 E F10 S',options); //Missing S value
            marlinGcodeParser.parse('G61 E F10 S10 X10',options); //Flag X with value
            marlinGcodeParser.parse('G61 E F10 S10 X Y',options); //Flag Y with value
            marlinGcodeParser.parse('G61 E F10 S10 X Y Z10',options); //Flag Z with value
            marlinGcodeParser.parse('G61 E F10 S10 X10 Y10 Z10 A',options); //Invalid parameter end - A
            marlinGcodeParser.parse('G61 E F10 S10 X10 Y10 Z10 Comment',options); //Comment without semicolon


       
    });

    it('Invalid M-code', () => {
        assert.throws(() => {
            marlinGcodeParser.parse('M0 P',options); //Missing S value
            marlinGcodeParser.parse(invalidMcode, options);
        }, 'Invalid M-code should throw an error');
    });
});
