{
  function makeParameter(name, value, location) {
    return {
      name: name,
      value: value,
      location: {
        start: location.start,
        end: location.end,
      }
    };
  }

  //Check for dublicate parameters. Returns an array of dublicate parameters.
  //I dont think gcode allows for dublicate parameters. But if i will come i cross one that does, I will ommit the error.
  function findDuplicateParameters(parameters) {
    const duplicates = [];
    const seen = {};
    parameters.forEach(p => {
      if (seen[p.name]) {
        duplicates.push(p.name);
      } else {
        seen[p.name] = true;
      }
    });
    return duplicates;
  }
}

start
  = lineNumber? ws? commands:(gCommand / mCommand / comment / emptyLine)*  ws?  nl? {
      const errors = []; 
      commands = commands.filter(c => c.type !== 'emptyLine'); 
      commands.forEach(c => {
        if (c.errors) {
          errors.push(...c.errors);
        }
      });
      if (options.collectErrors) {
        return {
          commands: commands,
          errors: errors,
        };
      } else {
        return { commands: commands };
      }
    }



string 'String' 
  = [a-zA-Z0-9_ ]*

emptyLine "Empty Line"
  = ws nl {
      return {
        type: "emptyLine",
        location: {
          start: location().start,
          end: location().end,
        },
      };
    }

ws "whitespace" 
  = [ \t]* / " "*

nl "Newl line"
  = [\r] / [\n] / [\r][\n]? 

//*******************Numbers******************//

//Not sure if this is needed.
//But added just in case some might have line numbers in their gcode.
lineNumber "Line Number"
  = "N" n:[0-9]+ ws {
      return parseInt(n.join(""));
    } 

//Eather integer or float.
number 'Decimal or Integer'
  = sign:("-")? intPart:[0-9]+ fracPart:("." [0-9]+)? ws{
      return parseFloat((sign || "") + intPart.join("") + (fracPart ? fracPart.join("") : ""));
    }


//Digit without decimal point.
integer 'Integer'
  = sign:("-")? intPart:[0-9]+ ws {
      return parseInt((sign || "") + intPart.join(""));
    }

//Only positive integer
positiveInteger 'Positive Integer'
  = intPart:[0-9]+ ws {
      return parseInt(intPart.join(""));
    } 

//Types is described as integer in gcode documentation.
index 'Positive'
  = positiveInteger

temp 'Temperature'
  = integer

linear 'Integer'
  = integer

pos 'Integer' 
  = number

rate 'Integer' 
  = number

slot 'Slot'
  = positiveInteger


ms 'Millisecond'
  = positiveInteger

sec 'Second'
  = positiveInteger

//Two different namings for the same thing. (in Marlin)
seconds 'Second'
  = sec

time 'Time'
  = positiveInteger

pin 'Pin'
  = positiveInteger

state 'State'
  = integer

//Specifically floating point number.
float 'Float'
  = sign:("-")? intPart:[0-9]+ fracPart:("." [0-9]+) ws{
      return parseFloat((sign || "") + intPart.join("") + (fracPart ? fracPart.join("") : ""));
    }


power "0 - 255"
  = value:integer* &{ return parseInt(value, 10) >= 0 && parseInt(value, 10) <= 255; } {
      return parseInt(value, 10);
    }

  
filepos "File Position"
  = integer

//Direction is 0 or 1.
//0 is clockwise.
//1 is counterclockwise.
direction '0 or 1'
  = "0" / "1"

//Boolean is 0 false or 1 true.
bool '0 = false or 1 = true'
  = "0" / "1"

//Takes no parameters
flag 'Flag - No parameters'
  = ""

//Line that start with ; are considered as comments. Comment is allowed at the and of line as well.
comment '; comment' 
  = ws? ";" commentText:[^\n]* {
      return {
        type: "comment",
        text: commentText.join(""),
        location: {
          start: location().start,
          end: location().end,
        },
      };
    }

//All g commands with parameters
gCommand 
  = c:(
    g0Command /
    g1Command /
    g2Command /
    g3Command /
    g4Command /
    g5Command /
    g6Command /
    g10_11Command /
    g12Command /
    g26Command /
    g27Command /
    g28Command /
    g30Command /
    g33Command /
    g34Command /
    g35Command /
    g38_2to38_5Command /
    g42Command /
    g60Command /
    g61Command /
    g76Command /
    g92Command /
    g425Command /
    noParamGCommand
    ) { return c; }

//All gcodes that takes no parameters. So that only comment is allowed.
noParamGCommand 
  = (
    "G17" /
    "G18" /
    "G19" /
    "G20" /
    "G21" / 
    "G31" / 
    "G32" / 
    "G53" / 
    "G54" / 
    "G55" / 
    "G56" / 
    "G57" / 
    "G58" / 
    "G59.1" / 
    "G59.2" / 
    "G59.3" /
    "G59" /
    "G80" /
    "G90" /
    "G91" )!integer ws? {
      return {
        command: text(),
        parameters: [],
        location: {
          start: location().start,
          end: location().end,
        },
      };
    }

//all M commands with parameters
mCommand 
  = c:(
    m0toM1Command / 
    m2Command /
    m3Command /
    m4Command /
    m16Command /
    m17Command /
    m18andM84Command /
    m20Command /
    m23Command /
    m24Command /
    m26Command /
    m27Command /
    m28Command /
    m30Command /
    m32Command /
    m33Command /
    m34Command /
    m42Command /
    m43Command /
    noParamMCommands 
    ) ws? { return c; } 

//All mcodes that takes no parameters. So that only comment is allowed.
noParamMCommands 
  = (
    "M5" /
    "M7" /
    "M8" /
    "M9" /
    "M10" /
    "M11" /
    "M21" /
    "M22" /
    "M25" /
    "M29" /
    "M31" /
    "M76" /
    "M77" /
    "M78" /
    "M81" /
    "M82" /
    "M83" /
    "M108" /
    "M112" /
    "M115" /
    "M119" /
    "M120" /
    "M121" /
    "M123" /
    "M127" /
    "M129" /
    "M360" /
    "M361" /
    "M362" /
    "M363" /
    "M364" /
    "M400" /
    "M402" /
    "M406" /
    "M407" /
    "M410" /
    "M428" /
    "M500" /
    "M501" /
    "M502" /
    "M504" /
    "M510" /
    "M524" /
    "M909" /
    "M910" /
    "M911" /
    "M993" /
    "M994" /
    "M995" /
    "M997" 
    ) !integer ws? {
      return {
        command: text(),
        parameters: [],
        location: {
          start: location().start,
          end: location().end,
        },
      };
    }

//G0-G1 - Linear Move
//G0 and G1 commands are very similar.
// I could have made one rule for both of them, but it is separate because G0 wans about using G1 for print / laser cut moves.
//G0 [E<pos>] [F<rate>] [S<power>] [X<pos>] [Y<pos>] [Z<pos>]
// Parameters
// [E<pos>]	
// An absolute or relative coordinate on the E (extruder) axis (in current units). The E axis describes the position of the filament in terms of input to the extruder feeder.
// [F<rate>]	
// The maximum movement rate of the move between the start and end point. The feedrate set here applies to subsequent moves that omit this parameter.
// [S<power>]  2.1.1 LASER_FEATURE	
// Set the laser power for the move.
// [X<pos>]	
// An absolute or relative coordinate on the X axis (in current units).
// [Y<pos>]	
// An absolute or relative coordinate on the Y axis (in current units).
// [Z<pos>]
g0Command 
  = "G0" !integer ws? params:g0Parameter* {
      const errors = []; 
      const duplicates = findDuplicateParameters(params);
      //If there are any duplicate parameters, push an error to the errors array.
      if (duplicates.length > 0) {
        errors.push({
          type: 'duplicate_parameters',
          command: 'G0',
          duplicates: duplicates,
          location: {
            start: location().start,
            end: location().end,
          },
        });
      }
      //Check if there is E or S parameter. If there is, will show suggestion to use G1 command.
      params.forEach(p => {
        if (p.name === 'E' || p.name === 'S') {
          errors.push({
            type: 'use_G1',
            command: 'G0',
            parameter: p.name,
            location: {
              start: p.location.start,
              end: p.location.end,
            },
          });
        }
      });

      return {
        command: "G0",
        parameters: params,
        errors: errors.length > 0 ? errors : null, 
        location: {
          start: location().start,
          end: location().end,
        },
      };
    }

g0Parameter 
  = p:("X" / "Y" / "Z" / "E" / "F" / "S") v:number {
      return makeParameter(p, v, location());
    }

//G0-G1 - Linear Move
//G1 almos the same as G0, but it does not show suggestion to use G1 command.
//G1 [E<pos>] [F<rate>] [S<power>] [X<pos>] [Y<pos>] [Z<pos>]
//Parameters
// [E<pos>]	
// An absolute or relative coordinate on the E (extruder) axis (in current units). The E axis describes the position of the filament in terms of input to the extruder feeder.
// [F<rate>]	
// The maximum movement rate of the move between the start and end point. The feedrate set here applies to subsequent moves that omit this parameter.
// [S<power>]  2.1.1 LASER_FEATURE	
// Set the laser power for the move.
// [X<pos>]	
// An absolute or relative coordinate on the X axis (in current units).
// [Y<pos>]	
// An absolute or relative coordinate on the Y axis (in current units).
// [Z<pos>]
g1Command 
  = "G1" !integer ws? params:g1Parameter* {
      const errors = []; 
      const duplicates = findDuplicateParameters(params);
      //If there are any duplicate parameters, push an error to the errors array.
      if (duplicates.length > 0) {
        errors.push({
          type: 'duplicate_parameters',
          command: 'G1',
          duplicates: duplicates,
          location: {
            start: location().start,
            end: location().end,
          },
        });
      }
      return {
        command: "G1",
        parameters: params,
        errors: errors.length > 0 ? errors : null, 
        location: {
          start: location().start,
          end: location().end,
        },
      };
    }

g1Parameter
  = p:("X" / "Y" / "Z" / "E" / "F" / "S") v:number {
      return makeParameter(p, v, location());
    }

//G2 - Arc or Circle Move
//G2 [E<pos>] [F<rate>] I<offset> J<offset> [P<count>] R<radius> [S<power>] [X<pos>] [Y<pos>] [Z<pos>]
//There are two type of forms available for G2 and G3 commands.
// I and J or R. 
//I J and R cannot be used together.
// Parameters
// [E<pos>]	
// The amount to extrude between the start point and end point
// [F<rate>]	
// The maximum rate of the move between the start and end point
// I<offset>	
// An offset from the current X position to use as the arc center
// J<offset>	
// An offset from the current Y position to use as the arc center
// [P<count>]	
// Specify complete circles. (Requires ARC_P_CIRCLES)
// R<radius>	
// A radius from the current XY position to use as the arc center
// [S<power>]  2.0.8	
// Set the Laser power for the move.
// [X<pos>]	
// A coordinate on the X axis
// [Y<pos>]	
// A coordinate on the Y axis
// [Z<pos>]	
// A coordinate on the Z axis
g2Command 
  = "G2" !integer ws params:g2Parameter* {
      const errors = []; 
      const duplicates = findDuplicateParameters(params);
      //If there are any duplicate parameters, push an error to the errors array.
      if (duplicates.length > 0) {
        errors.push({
          type: 'duplicate_parameters',
          command: 'G2',
          duplicates: duplicates,
          location: {
            start: location().start,
            end: location().end,
          },
        });
      }
      //Check if there is I J and R parameters together. Use R form or I J form.
      let i = false;
      let j = false;
      let r = false;
      let x = false;
      let y = false;
      params.forEach(p => {
        if (p.name === 'I') {
          i = true;
        }
        if (p.name === 'J') {
          j = true;
        }
        if (p.name === 'R') {
          r = true;
        }
        if (p.name === 'X') {
          x = true;
        }
        if (p.name === 'Y') {
          y = true;
        }
      });

      if ((i || j) && r) {
        errors.push({
          type: 'unallowed_parameter_combination_R_I_J',
          command: 'G2',
          location: {
            start: location().start,
            end: location().end,
          },
        });
      }
    
    //Check if X or Y are present in same line as R.
    //If not throw error: Omitting both X and Y will not allowed in R form.
    if(!x && !y && r){
      errors.push({
        type: 'unallowed_parameter_combination_R_X_Y',
        command: 'G2',
        location: {
          start: location().start,
          end: location().end,
        },
      });
    }
      return {
        command: "G2",
        parameters: params,
        errors: errors.length > 0 ? errors : null, 
        location: {
          start: location().start,
          end: location().end,
        },
      };
    }

g2Parameter
  = p:("X" / "Y" / "Z" / "E" / "F" / "S" / "I" / "J" / "R" / "P") v:number {
      return makeParameter(p, v, location());
    }
//G3 - Arc or Circle Move
//G3 [E<pos>] [F<rate>] I<offset> J<offset> [P<count>] R<radius> [S<power>] [X<pos>] [Y<pos>] [Z<pos>]
//There are two type of forms available for G2 and G3 commands.
// I and J or R.
//I J and R cannot be used together.
// Parameters
// [E<pos>]	
// The amount to extrude between the start point and end point
// [F<rate>]	
// The maximum rate of the move between the start and end point
// I<offset>	
// An offset from the current X position to use as the arc center
// J<offset>	
// An offset from the current Y position to use as the arc center
// [P<count>]	
// Specify complete circles. (Requires ARC_P_CIRCLES)
// R<radius>	
// A radius from the current XY position to use as the arc center
// [S<power>]  2.0.8	
// Set the Laser power for the move.
// [X<pos>]	
// A coordinate on the X axis
// [Y<pos>]	
// A coordinate on the Y axis
// [Z<pos>]	
// A coordinate on the Z axis
g3Command 
  = "G3" !integer ws? params:g3Parameter* {
      const errors = []; 
      const duplicates = findDuplicateParameters(params);
      //If there are any duplicate parameters, push an error to the errors array.
      if (duplicates.length > 0) {
        errors.push({
          type: 'duplicate_parameters',
          command: 'G3',
          duplicates: duplicates,
          location: {
            start: location().start,
            end: location().end,
          },
        });
      }
      //Check if there is I J and R parameters together. Use R form or I J form.
      let i = false;
      let j = false;
      let r = false;
      let x = false;
      let y = false;
      params.forEach(p => {
        if (p.name === 'I') {
          i = true;
        }
        if (p.name === 'J') {
          j = true;
        }
        if (p.name === 'R') {
          r = true;
        }
        if (p.name === 'X') {
          x = true;
        }
        if (p.name === 'Y') {
          y = true;
        }
      });

      if ((i || j) && r) {
        errors.push({
          type: 'unallowed_parameter_combination_R_I_J',
          command: 'G3',
          location: {
            start: location().start,
            end: location().end,
          },
        });
      }
    
    //Check if X or Y are present in same line as R.
    //If not throw error: Omitting both X and Y will not allowed in R form.
    if(!x && !y && r){
      errors.push({
        type: 'unallowed_parameter_combination_R_X_Y',
        command: 'G3',
        location: {
          start: location().start,
          end: location().end,
        },
      });
    }
      return {
        command: "G3",
        parameters: params,
        errors: errors.length > 0 ? errors : null, 
        location: {
          start: location().start,
          end: location().end,
        },
      };
    }
  

g3Parameter
  = p:("X" / "Y" / "Z" / "E" / "F" / "S" / "I" / "J" / "R" / "P") v:number {
      return makeParameter(p, v, location());
    }

//G4 - Dwell
//G4 [P<time (ms)>] [S<time (sec)>]
//If both S and P are included, S takes precedence.
//G4 with no arguments is effectively the same as M400.
// Parameters
// [P<time(ms)>]	
// Amount of time to dwell
// [S<time(sec)>]
g4Command 
  = "G4" !integer ws? params:g4Parameter* {
      const errors = []; 
      const duplicates = findDuplicateParameters(params);
      //If there are any duplicate parameters, push an error to the errors array.
      if (duplicates.length > 0) {
        errors.push({
          type: 'duplicate_parameters',
          command: 'G4',
          duplicates: duplicates,
          location: {
            start: location().start,
            end: location().end,
          },
        });
      }
      return {
        command: "G4",
        parameters: params,
        errors: errors.length > 0 ? errors : null, 
        location: {
          start: location().start,
          end: location().end,
        },
      };
    }

g4Parameter
  = p:"P" v:ms ws?{ return makeParameter(p, v, location()); }
  / p:"S" v:sec ws?{ return makeParameter(p, v, location()); }

// G5 - Bézier cubic spline
//G5 [E<pos>] [F<rate>] I<pos> J<pos> P<pos> Q<pos> [S<power>] X<pos> Y<pos>
//P and Q are required 
// [E<pos>]	
// The length of filament to feed into the extruder between the start and end point
// [F<rate>]	
// The maximum feedrate of the move between the start and end point (in current units per second). This value applies to all subsequent moves.
// I<pos>	
// Offset from the X start point to first control point
// J<pos>	
// Offset from the Y start point to first control point
// P<pos>	
// Offset from the X end point to second control point
// Q<pos>	
// Offset from the Y end point to the second control point
// [S<power>]  2.0.8	
// Set the Laser power for the move.
// X<pos>	
// A destination coordinate on the X axis
// Y<pos>	
// A destination coordinate on the Y axis
g5Command 
  = "G5" !integer ws? params:g5Parameter* {
      const errors = []; 
      const duplicates = findDuplicateParameters(params);
      //If there are any duplicate parameters, push an error to the errors array.
      if (duplicates.length > 0) {
        errors.push({
          type: 'duplicate_parameters',
          command: 'G5',
          duplicates: duplicates,
          location: {
            start: location().start,
            end: location().end,
          },
        });
      }

      return {
        command: "G5",
        parameters: params,
        errors: errors.length > 0 ? errors : null, 
        location: {
          start: location().start,
          end: location().end,
        },
      };
    }

g5Parameter 
  = p:("X" / "Y" / "E" / "F" / "S" / "I" / "J" / "P" / "Q") v:number {
      return makeParameter(p, v, location());
    }

//G6 - Direct Stepper Move
//G6 [E<direction>] [I<index>] [R<rate>] [S<rate>] [X<direction>] [Y<direction>] [Z<direction>]
// Parameters
// [E<direction>]	
// 1 for positive, 0 for negative. Last value is cached for future invocations. Not used for directional formats.
// [I<index>]	
// Set page index
// [R<rate>]	
// Step rate per second. Last value is cached for future invocations.
// [S<rate>]	
// Number of steps to take. Defaults to max steps.
// [X<direction>]	
// 1 for positive, 0 for negative. Last value is cached for future invocations. Not used for directional formats.
// [Y<direction>]	
// 1 for positive, 0 for negative. Last value is cached for future invocations. Not used for directional formats.
// [Z<direction>]	
// 1 for positive, 0 for negative. Last value is cached for future invocations. Not used for directional formats.
g6Command 
  = "G6" !integer ws? params:g6Parameter* {
      const errors = []; 
      const duplicates = findDuplicateParameters(params);
      //If there are any duplicate parameters, push an error to the errors array.
      if (duplicates.length > 0) {
        errors.push({
          type: 'duplicate_parameters',
          command: 'G6',
          duplicates: duplicates,
          location: {
            start: location().start,
            end: location().end,
          },
        });
      }
      return {
        command: "G6",
        parameters: params,
        errors: errors.length > 0 ? errors : null, 
        location: {
          start: location().start,
          end: location().end,
        },
      };
    }

g6Parameter 
  = p:"X" v:direction ws?{ return makeParameter(p, v, location()); }
  / p:"Y" v:direction ws? { return makeParameter(p, v, location()); }
  / p:"Z" v:direction ws?{ return makeParameter(p, v, location()); }
  / p:"E" v:direction ws?{ return makeParameter(p, v, location()); }
  / p:"S" v:number ws?{ return makeParameter(p, v, location()); }
  / p:"I" v:integer ws?{ return makeParameter(p, v, location()); }
  / p:"R" v:number ws?{ return makeParameter(p, v, location()); }


//G10 - Retract
//G10 [S<bool>]
//G11 [S<bool>]
//Parameters
// [S<bool>]	
// Use G10 S1 to do a swap retraction, before changing extruders. The subsequent G11 (after tool change) will do a swap recover. (Requires EXTRUDERS > 1)
 g10_11Command 
  = c:("G10" / "G11") !integer ws? params:g10_11Parameter* {
      const errors = []; 
      const duplicates = findDuplicateParameters(params);
      //If there are any duplicate parameters, push an error to the errors array.
      if (duplicates.length > 0) {
        errors.push({
          type: 'duplicate_parameters',
          command: c,
          duplicates: duplicates,
          location: {
            start: location().start,
            end: location().end,
          },
        });
      }
      return {
        command: c,
        parameters: params,
        errors: errors.length > 0 ? errors : null, 
        location: {
          start: location().start,
          end: location().end,
        },
      };
    }

g10_11Parameter
  = p:("S") v:bool {
      return makeParameter(p, v, location());
    }

//G12 - Clean the Nozzle
//G12 [P<0|1|2>] [R<radius>] [S<count>] [T<count>] [X] [Y] [Z]
// Parameters
// [P<0|1|2>]	
// Pattern style selection
// P0: Linear move back and forth
// P1: Move in a zigzag pattern
// P2: Move in a circular pattern
// [R<radius>]	
// Radius of nozzle cleaning circle
// [S<count>]	
// Number of repetitions of the pattern
// [T<count>]	
// Number of triangles in the zigzag pattern
// [X]	
// Include X motion when cleaning with limited axes. (Leave out X, Y, and Z for non-limited cleaning.)
// [Y]	
// Include Y motion when cleaning with limited axes. (Leave out X, Y, and Z for non-limited cleaning.)
// [Z]	
// Include Z motion when cleaning with limited axes. (Leave out X, Y, and Z for non-limited cleaning.) 
g12Command 
  = "G12" !integer ws? params:g12Parameter* {
      const errors = []; 
      const duplicates = findDuplicateParameters(params);
      //If there are any duplicate parameters, push an error to the errors array.
      if (duplicates.length > 0) {
        errors.push({
          type: 'duplicate_parameters',
          command: 'G12',
          duplicates: duplicates,
          location: {
            start: location().start,
            end: location().end,
          },
        });
      }
      return {
        command: "G12",
        parameters: params,
        errors: errors.length > 0 ? errors : null, 
        location: {
          start: location().start,
          end: location().end,
        },
      };
    }

g12Parameter
  = p:"P" v:("1"/ "2" / "3") ws?{ return makeParameter(p, v, location()); }
  / p:"R" v:number  ws?{ return makeParameter(p, v, location()); }
  / p:"S" v:integer  ws?{ return makeParameter(p, v, location()); } 
  / p:"T" v:integer  ws?{ return makeParameter(p, v, location()); }
  / p:"X" v:flag  ws?{ return makeParameter(p, v, location()); }
  / p:"Y" v:flag  ws?{ return makeParameter(p, v, location()); }
  / p:"Z" v:flag  ws?{ return makeParameter(p, v, location()); }


//G26 - Mesh Validation Pattern
//G26 [B<temp>] [C<bool>] [D] [F<linear>] [H<linear>] [I<index>] [K<bool>] [L<linear>] [O<linear>] [P<linear>] [Q<float>] [R<int>] [S<float>] [U<linear>] [X<linear>] [Y<linear>]
// Parameters
// [B<temp>]	
// Bed temperature (otherwise 60°C) to use for the test print.
// [C<bool>]	
// Continue with the closest point (otherwise, don’t)
// [D]	
// Disable leveling compensation (otherwise, enable)
// [F<linear>]	
// Filament diameter (otherwise 1.75mm)
// [H<linear>]	
// Hot end temperature (otherwise 205°C) to use for the test print.
// [I<index>]  2.0.6	
// Material preset to use for the test print. Overrides S.
// [K<bool>]	
// Keep heaters on when done
// [L<linear>]	
// Layer height to use for the test
// [O<linear>]	
// Ooze amount (otherwise 0.3mm). Emitted at the start of the test.
// [P<linear>]	
// Prime Length
// [Q<float>]	
// Retraction multiplier. G26 retract and recover are 1.0mm and 1.2mm respectively. Both retract and recover are multiplied by this value.
// [R<int>]	
// Number of G26 Repetitions (otherwise 999)
// [S<float>]	
// Nozzle size (otherwise 0.4mm)
// [U<linear>]	
// Random deviation. (U with no value, 50).
// [X<linear>]	
// X position (otherwise, current X position)
// [Y<linear>]	
// Y position (otherwise, current Y position)
g26Command 
  = "G26" !integer ws? params:g26Parameter* {
      const errors = []; 
      const duplicates = findDuplicateParameters(params);
      //If there are any duplicate parameters, push an error to the errors array.
      if (duplicates.length > 0) {
        errors.push({
          type: 'duplicate_parameters',
          command: 'G26',
          duplicates: duplicates,
          location: {
            start: location().start,
            end: location().end,
          },
        });
      }
      return {
        command: "G26",
        parameters: params,
        errors: errors.length > 0 ? errors : null, 
        location: {
          start: location().start,
          end: location().end,
        },
      };
    }
  
g26Parameter
  = p:"B" v:integer ws?{ return makeParameter(p, v, location()); }
  / p:"C" v:bool ws?{ return makeParameter(p, v, location()); }
  / p:"D" v:flag ws?{ return makeParameter(p, v, location()); }
  / p:"F" v:integer ws?{ return makeParameter(p, v, location()); }
  / p:"H" v:integer ws?{ return makeParameter(p, v, location()); }
  / p:"I" v:integer ws?{ return makeParameter(p, v, location()); }
  / p:"K" v:bool ws?{ return makeParameter(p, v, location()); }

//G27 - Park toolhead
//G27 [P<0|1|2>]
//Parameters
// [P<0|1|2>]	
// Z axis action
// P0: If current Z-pos is lower than Z-park then the nozzle will be raised to reach Z-park height
// P1: No matter the current Z-pos, the nozzle will be raised/lowered to reach Z-park height
// P2: The nozzle height will be raised by Z-park amount but never going over the machine’s limit of Z_MAX_POS
  g27Command 
    = "G27" !integer ws? params:g27Parameter* {
        const errors = []; 
        const duplicates = findDuplicateParameters(params);
        //If there are any duplicate parameters, push an error to the errors array.
        if (duplicates.length > 0) {
          errors.push({
            type: 'duplicate_parameters',
            command: 'G27',
            duplicates: duplicates,
            location: {
              start: location().start,
              end: location().end,
            },
          });
        }
        return {
          command: "G27",
          parameters: params,
          errors: errors.length > 0 ? errors : null, 
          location: {
            start: location().start,
            end: location().end,
          },
        };
      }

  g27Parameter
    = p:"P" v:("1"/ "2" / "3") ws?{ return makeParameter(p, v, location()); }

//G28 - Auto Home
//G28 [L] [O] [R] [X] [Y] [Z]
// Parameters
// [L]	
// Flag to restore bed leveling state after homing. (default true)

// [O]  1.1.9	
// Flag to skip homing if the position is already trusted

// [R]  1.1.9	
// The distance to raise the nozzle before homing

// [X]	
// Flag to home the X axis

// [Y]	
// Flag to home the Y axis

// [Z]	
// Flag to home the Z axis
g28Command 
  = "G28" !integer ws? params:g28Parameter* {
      const errors = []; 
      const duplicates = findDuplicateParameters(params);
      //If there are any duplicate parameters, push an error to the errors array.
      if (duplicates.length > 0) {
        errors.push({
          type: 'duplicate_parameters',
          command: 'G28',
          duplicates: duplicates,
          location: {
            start: location().start,
            end: location().end,
          },
        });
      }
      return {
        command: "G28",
        parameters: params,
        errors: errors.length > 0 ? errors : null, 
        location: {
          start: location().start,
          end: location().end,
        },
      };
    }

g28Parameter
  = p:"L" v:flag ws?{ return makeParameter(p, v, location()); }
  / p:"O" v:flag ws?{ return makeParameter(p, v, location()); }
  / p:"R" v:flag ws?{ return makeParameter(p, v, location()); }
  / p:"X" v:flag ws?{ return makeParameter(p, v, location()); }
  / p:"Y" v:flag ws?{ return makeParameter(p, v, location()); }
  / p:"Z" v:flag ws?{ return makeParameter(p, v, location()); }

  //G29 [A<bool>] [C<bool>] [D<bool>] [E<bool>] [J<bool>] [O] [Q<bool>] [V<0-4>]
  //G29 [A<bool>] [B<linear>] [C<bool>] [D<bool>] [E<bool>] [F<linear>] [H<linear>] [J<bool>] [L<linear>] [O] [P<int>] [Q<bool>] [R<linear>] [S<rate>] [T<bool>] [V<0-4>] [X<int>] [Y<int>]
  //G29 [I<index>] [J<index>] S<0|1|2|3|4|5> [X<count>] [Y<count>] [Z<linear>]
  //G29 [A<bool>] [B<linear>] [C<bool>] [D<bool>] [E<bool>] [F<linear>] [H<linear>] [J<bool>] [L<linear>] [O] [Q<bool>] [R<linear>] [S<rate>] [V<0-4>] [W<bool>] [X<int/float>] [Y<int/float>] [Z<float>]
  //G29 [A] [B<mm/flag>] [C<bool/float>] [D] [E] [F<linear>] [H<linear>] [I<int>] [J<int>] [K<index>] [L<index>] [P<0|1|2|3|4|5|6>] [Q<index>] [R<int>] [S<slot>] [T<0|1>] [U] [V<0|1|2|3|4>] [W] [X<linear>] [Y<linear>]
  //Todo: Implement. Too complecated for now.

//G30 - Single Z-Probe
//G30 [C<bool>] [E<bool>] [X<pos>] [Y<pos>]
// Parameters
// [C<bool>]	
// Probe with temperature compensation enabled (PTC_PROBE, PTC_BED, PTC_HOTEND)

// [E<bool>]	
// Engage the probe for each point

// [X<pos>]	
// X probe position

// [Y<pos>]	
// Y probe position
  g30Command 
    = "G30" !integer ws? params:g30Parameter* {
        const errors = []; 
        const duplicates = findDuplicateParameters(params);
        //If there are any duplicate parameters, push an error to the errors array.
        if (duplicates.length > 0) {
          errors.push({
            type: 'duplicate_parameters',
            command: 'G30',
            duplicates: duplicates,
            location: {
              start: location().start,
              end: location().end,
            },
          });
        }
        return {
          command: "G30",
          parameters: params,
          errors: errors.length > 0 ? errors : null, 
          location: {
            start: location().start,
            end: location().end,
          },
        };
      }

  g30Parameter
    = p:"C" v:bool ws?{ return makeParameter(p, v, location()); }
    / p:"E" v:bool ws?{ return makeParameter(p, v, location()); }
    / p:"X" v:number ws?{ return makeParameter(p, v, location()); }
    / p:"Y" v:number ws?{ return makeParameter(p, v, location()); }


//G33 - Delta Auto Calibration
//G33 [C<float>] [E<bool>] [F<1-30>] [O<bool>] [P<|0|1|2|3|4-10>] [R<float>] [T<bool>] [V<|0|1|2|3|>]
//Parameters
// [C<float>]	
// If omitted iterations stop at best achievable precision. If set iterations will stop at the set precision.

// [E<bool>]	
// Engage the probe for each point.

// [F<1-30>]	
// Run (“force”) this number of iterations and take the best result.

// [O<bool>]  2.0.9.2	
// Probe at probe-offset-relative positions instead of the required kinematic points.

// [P<|0|1|2|3|4-10>]	
// Number of probe points. If not specified, uses DELTA_CALIBRATION_DEFAULT_POINTS

// P0: Normalize end-stops and tower angle corrections only (no probing).
// P1: Probe center and set height only.
// P2: Probe center and towers. Set height, endstops, and delta radius.
// P3: Probe all positions - center, towers and opposite towers. Set all.
// P4-10: Probe all positions with intermediate locations, averaging them.
// [R<float>]  2.0.9.2	
// Temporarily reduce the size of the probe grid by the specified amount.

// [T<bool>]	
// Disable tower angle corrections calibration (P3-P7)

// [V<|0|1|2|3|>]	
// Set the verbose level

// V0: Dry run, no calibration
// V1: Report settings
// V2: Report settings and probe results
// V3: Report settings, probe results, and calibration results
g33Command 
  = "G33" !integer ws? params:g33Parameter* {
      const errors = []; 
      const duplicates = findDuplicateParameters(params);
      //If there are any duplicate parameters, push an error to the errors array.
      if (duplicates.length > 0) {
        errors.push({
          type: 'duplicate_parameters',
          command: 'G33',
          duplicates: duplicates,
          location: {
            start: location().start,
            end: location().end,
          },
        });
      }
      return {
        command: "G33",
        parameters: params,
        errors: errors.length > 0 ? errors : null, 
        location: {
          start: location().start,
          end: location().end,
        },
      };
    }

  g33Parameter
    = p:"C" v:number ws?{ return makeParameter(p, v, location()); }
    / p:"E" v:bool ws?{ return makeParameter(p, v, location()); }
    / p:"F" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"O" v:bool ws?{ return makeParameter(p, v, location()); }
    / p:"P" v:("0"/ "1" / "2" / "3" / "4" / "5" / "6" / "7" / "8" / "9" / "10") ws?{ return makeParameter(p, v, location()); }
    / p:"R" v:number ws?{ return makeParameter(p, v, location()); }
    / p:"T" v:bool ws?{ return makeParameter(p, v, location()); }
    / p:"V" v:("0"/ "1" / "2" / "3") ws?{ return makeParameter(p, v, location()); }

//G34 - Z Steppers Auto-Alignment
//G34 [A] [E] [I] [T]
// Parameters
// [A]	
// Amplification - must be between 0.5 - 2.0
// [E]	
// Stow probe after probing each point.
// [I]	
// Iterations - must be between 1 - 30
// [T]	
// Target accuracy - must be between 0.01 - 1.0
//G34 [S<mA>] [Z<linear>]
// Parameters
// [S<mA>]	
// Current value to use for the raise move. (Default: GANTRY_CALIBRATION_CURRENT)
// [Z<linear>]	
// Extra distance past Z_MAX_POS to move the Z axis. (Default: GANTRY_CALIBRATION_EXTRA_HEIGHT)
g34Command 
  = "G34" !integer ws? params:g34Parameter* {
      const errors = []; 
      const duplicates = findDuplicateParameters(params);
      //If there are any duplicate parameters, push an error to the errors array.
      if (duplicates.length > 0) {
        errors.push({
          type: 'duplicate_parameters',
          command: 'G34',
          duplicates: duplicates,
          location: {
            start: location().start,
            end: location().end,
          },
        });
      }
      
      return {
        command: "G34",
        parameters: params,
        errors: errors.length > 0 ? errors : null, 
        location: {
          start: location().start,
          end: location().end,
        },
      };
    }

g34Parameter
  = p:"A" v:flag ws?{ return makeParameter(p, v, location()); }
  / p:"E" v:flag ws?{ return makeParameter(p, v, location()); }
  / p:"I" v:flag ws?{ return makeParameter(p, v, location()); }
  / p:"T" v:flag ws?{ return makeParameter(p, v, location()); }
  / p:"S" v:number ws?{ return makeParameter(p, v, location()); }
  / p:"Z" v:number ws?{ return makeParameter(p, v, location()); }

//G35 - Tramming Assistant
//G35 [S<30|31|40|41|50|51>]
// Parameters
// [S<30|31|40|41|50|51>]	
// Screw thread type

// S30: M3 clockwise
// S31: M3 counter-clockwise
// S40: M4 clockwise
// S41: M4 counter-clockwise
// S50: M5 clockwise
// S51: M5 counter-clockwise
g35Command 
  = "G35" !integer ws? params:g35Parameter* {
      const errors = []; 
      const duplicates = findDuplicateParameters(params);
      //If there are any duplicate parameters, push an error to the errors array.
      if (duplicates.length > 0) {
        errors.push({
          type: 'duplicate_parameters',
          command: 'G35',
          duplicates: duplicates,
          location: {
            start: location().start,
            end: location().end,
          },
        });
      }
      
      return {
        command: "G35",
        parameters: params,
        errors: errors.length > 0 ? errors : null, 
        location: {
          start: location().start,
          end: location().end,
        },
      };
    }

g35Parameter
  = p:"S" v:("30"/ "31" / "40" / "41" / "50" / "51") ws?{ return makeParameter(p, v, location()); }

//G38.2-G38.5 - Probe target
// G38.2 [F<rate>] [X<pos>] [Y<pos>] [Z<pos>]
// G38.3 [F<rate>] [X<pos>] [Y<pos>] [Z<pos>]
// G38.4 [F<rate>] [X<pos>] [Y<pos>] [Z<pos>]
// G38.5 [F<rate>] [X<pos>] [Y<pos>] [Z<pos>]
// Parameters
// [F<rate>]	
// Feedrate for the move
// [X<pos>]	
// Target X
// [Y<pos>]	
// Target Y
// [Z<pos>]	
// Target Z
g38_2to38_5Command 
  = c:("G38.2" / "G38.3" / "G38.4" / "G38.5") !integer ws? params:g38_2to38_5Parameter* {
      const errors = []; 
      const duplicates = findDuplicateParameters(params);
      //If there are any duplicate parameters, push an error to the errors array.
      if (duplicates.length > 0) {
        errors.push({
          type: 'duplicate_parameters',
          command: c,
          duplicates: duplicates,
          location: {
            start: location().start,
            end: location().end,
          },
        });
      }
      return {
        command: c,
        parameters: params,
        errors: errors.length > 0 ? errors : null, 
        location: {
          start: location().start,
          end: location().end,
        },
      };
    }

g38_2to38_5Parameter
  = p:"F" v:rate ws?{ return makeParameter(p, v, location()); }
  / p:"X" v:pos ws?{ return makeParameter(p, v, location()); }
  / p:"Y" v:pos ws?{ return makeParameter(p, v, location()); }
  / p:"Z" v:pos ws?{ return makeParameter(p, v, location()); }

// G42 - Move to mesh coordinate
// G42 [F<rate>] [I<pos>] [J<pos>]
// Parameters
// [F<rate>]	
// The maximum movement rate of the move between the start and end point. The feedrate set here applies to subsequent moves that omit this parameter.
// [I<pos>]	
// The column of the mesh coordinate
// [J<pos>]	
// The row of the mesh coordinate
g42Command 
  = "G42" !integer ws? params:g42Parameter* {
      const errors = []; 
      const duplicates = findDuplicateParameters(params);
      //If there are any duplicate parameters, push an error to the errors array.
      if (duplicates.length > 0) {
        errors.push({
          type: 'duplicate_parameters',
          command: 'G42',
          duplicates: duplicates,
          location: {
            start: location().start,
            end: location().end,
          },
        });
      }
      return {
        command: "G42",
        parameters: params,
        errors: errors.length > 0 ? errors : null, 
        location: {
          start: location().start,
          end: location().end,
        },
      }; 
    }

g42Parameter
  = p:"F" v:rate ws?{ return makeParameter(p, v, location()); } 
  / p:"I" v:pos ws?{ return makeParameter(p, v, location()); } 
  / p:"J" v:pos ws?{ return makeParameter(p, v, location()); }

//G60 - Save Current Position
//G60 [S<slot>]
//Parameters
// [S<slot>]	
// Memory slot. If omitted, the first slot (0) is used.
g60Command 
  = "G60" !integer ws? params:g60Parameter* {
      const errors = []; 
      const duplicates = findDuplicateParameters(params);
      //If there are any duplicate parameters, push an error to the errors array.
      if (duplicates.length > 0) {
        errors.push({
          type: 'duplicate_parameters',
          command: 'G60',
          duplicates: duplicates,
          location: {
            start: location().start,
            end: location().end,
          },
        });
      }
      return {
        command: "G60",
        parameters: params,
        errors: errors.length > 0 ? errors : null, 
        location: {
          start: location().start,
          end: location().end,
        }, 
      }; 
    }

  g60Parameter
    = p:"S" v:slot ws?{ return makeParameter(p, v, location()); } 

//G61 - Return to Saved Position
// G61 [E] [F<rate>] [S<slot>] [X] [Y] [Z]
//Parameters
// [E]	
// Flag to restore the E axis
// [F<rate>]	
// Move feedrate
// [S<slot>]	
// Memory slot (0 if omitted)
// [X]	
// Flag to restore the X axis
// [Y]	
// Flag to restore the Y axis
// [Z]	
// Flag to restore the Z axis
g61Command 
  = "G61" !integer ws? params:g61Parameter* {
      const errors = []; 
      const duplicates = findDuplicateParameters(params);
      //If there are any duplicate parameters, push an error to the errors array.
      if (duplicates.length > 0) {
        errors.push({
          type: 'duplicate_parameters',
          command: 'G61',
          duplicates: duplicates,
          location: {
            start: location().start,
            end: location().end,
          },
        });
      }
      return {
        command: "G61",
        parameters: params,
        errors: errors.length > 0 ? errors : null, 
        location: {
          start: location().start,
          end: location().end, 
        },
      }; 
    }

  g61Parameter
    = p:"E" v:flag ws?{ return makeParameter(p, v, location()); }
    / p:"F" v:rate ws?{ return makeParameter(p, v, location()); }
    / p:"S" v:slot ws?{ return makeParameter(p, v, location()); }
    / p:"X" v:flag ws?{ return makeParameter(p, v, location()); }
    / p:"Y" v:flag ws?{ return makeParameter(p, v, location()); }
    / p:"Z" v:flag ws?{ return makeParameter(p, v, location()); }


// G76 - Probe temperature calibration
//G76 [B] [P]
// Parameters
// [B]	
// Calibrate bed only
// [P]
g76Command 
  = "G76" !integer ws? params:g76Parameter* {
      const errors = []; 
      const duplicates = findDuplicateParameters(params);
      //If there are any duplicate parameters, push an error to the errors array.
      if (duplicates.length > 0) {
        errors.push({
          type: 'duplicate_parameters',
          command: 'G76',
          duplicates: duplicates,
          location: {
            start: location().start,
            end: location().end,
          },
        });
      }
      return {
        command: "G76",
        parameters: params,
        errors: errors.length > 0 ? errors : null, 
        location: {
          start: location().start, 
          end: location().end,
        },
      }; 
    }

  g76Parameter
    = p:"B" v:flag ws?{ return makeParameter(p, v, location()); }
    / p:"P" v:flag ws?{ return makeParameter(p, v, location()); }


//G92 - Set Position
//G92 [E<pos>] [X<pos>] [Y<pos>] [Z<pos>]
// Parameters
// [E<pos>]	
// New extruder position
// [X<pos>]	
// New X axis position
// [Y<pos>]	
// New Y axis position
// [Z<pos>]	
// New Z axis position
g92Command 
  = "G92" !integer ws? params:g92Parameter* {
     const errors = []; 
      const duplicates = findDuplicateParameters(params);
      //If there are any duplicate parameters, push an error to the errors array.
      if (duplicates.length > 0) {
        errors.push({
          type: 'duplicate_parameters',
          command: 'G92',
          duplicates: duplicates,
          location: {
            start: location().start,
            end: location().end,
          },
        });
      }
      return {
        command: "G92",
        parameters: params,
        errors: errors.length > 0 ? errors : null, 
        location: {
          start: location().start,
          end: location().end, 
        },
      }; 
    }

  g92Parameter
    = p:"E" v:pos ws?{ return makeParameter(p, v, location()); }
    / p:"X" v:pos ws?{ return makeParameter(p, v, location()); }
    / p:"Y" v:pos ws?{ return makeParameter(p, v, location()); }
    / p:"Z" v:pos ws?{ return makeParameter(p, v, location()); }


//G425 - Backlash Calibration
//G425 [B] [T<index>] [U<linear>] [V]
// Parameters
// [B]	
// Perform calibration of backlash only.
// [T<index>]	
// Perform calibration of one toolhead only.
// [U<linear>]	
// Uncertainty: how far to start probe away from the cube (mm)
// [V]	
// Probe cube and print position, error, backlash and hotend offset. (Requires CALIBRATION_REPORTING)
g425Command 
  = "G425" !integer ws? params:g425Parameter* {
      const errors = []; 
      const duplicates = findDuplicateParameters(params);
      //If there are any duplicate parameters, push an error to the errors array.
      if (duplicates.length > 0) {
        errors.push({
          type: 'duplicate_parameters',
          command: 'G425',
          duplicates: duplicates,
          location: {
            start: location().start,
            end: location().end,
          },
        });
      }
      return {
        command: "G425",
        parameters: params,
        errors: errors.length > 0 ? errors : null, 
        location: {
          start: location().start,
          end: location().end, 
        },
      }; 
    }

  g425Parameter
    = p:"B" v:flag ws?{ return makeParameter(p, v, location()); }
    / p:"T" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"U" v:number ws?{ return makeParameter(p, v, location()); }
    / p:"V" v:flag ws?{ return makeParameter(p, v, location()); }


    //************M Codes************//

// M0 - M1 - Unconditional stop
//M0 [P<ms>] [S<sec>] [string]
// M1 [P<ms>] [S<sec>] [string]
// Parameters
// [P<ms>]	
// Expire time, in milliseconds
// [S<sec>]	
// Expire time, in seconds
// [string]	
// An optional message to display on the LCD
m0toM1Command 
  = c:("M0" / "M1") !integer ws? params:m0toM1Parameter* string?{
      const errors = []; 
      const duplicates = findDuplicateParameters(params);
      //If there are any duplicate parameters, push an error to the errors array.
      if (duplicates.length > 0) {
        errors.push({
          type: 'duplicate_parameters',
          command: c,
          duplicates: duplicates,
          location: {
            start: location().start,
            end: location().end,
          },
        });
      }
      return {
        command: c,
        parameters: params,
        errors: errors.length > 0 ? errors : null, 
        location: {
          start: location().start, 
          end: location().end,
        },
      }; 
    }

  m0toM1Parameter
    = p:"P" v:ms ws?{ return makeParameter(p, v, location()); }
    / p:"S" v:sec ws?{ return makeParameter(p, v, location()); }
    
//M2 - Spindle CW / Laser On
//   M3 [I<mode>] [O<power>] [S<power>]
// Parameters
// [I<mode>]	
// Inline mode ON / OFF.
// [O<power>]	
// Spindle speed or laser power in PWM 0-255 value range
// [S<power>]	
// Spindle speed or laser power in the configured value range (see CUTTER_POWER_DISPLAY). (PWM 0-255 by default)
m2Command 
  = "M2" !integer ws? params:m2Parameter* {
      const errors = []; 
      const duplicates = findDuplicateParameters(params);
      //If there are any duplicate parameters, push an error to the errors array.
      if (duplicates.length > 0) {
        errors.push({
          type: 'duplicate_parameters',
          command: 'M2',
          duplicates: duplicates,
          location: {
            start: location().start,
            end: location().end,
          },
        });
      }
      return {
        command: "M2",
        parameters: params,
        errors: errors.length > 0 ? errors : null, 
        location: {
          start: location().start, 
          end: location().end,
        },
      }; 
    }

  m2Parameter
    = p:"I" v:bool ws?{ return makeParameter(p, v, location()); }
    / p:"O" v:power ws?{ return makeParameter(p, v, location()); }
    / p:"S" v:power ws?{ return makeParameter(p, v, location()); }


//M3 - Spindle CW / Laser On
//   M3 [I<mode>] [O<power>] [S<power>]
// Parameters
// [I<mode>]	
// Inline mode ON / OFF.
// [O<power>]	
// Spindle speed or laser power in PWM 0-255 value range
// [S<power>]	
// Spindle speed or laser power in the configured value range (see CUTTER_POWER_DISPLAY). (PWM 0-255 by default)
m3Command 
    = "M3" !integer ws? params:m3Parameter* {
        const errors = []; 
      const duplicates = findDuplicateParameters(params);
      //If there are any duplicate parameters, push an error to the errors array.
      if (duplicates.length > 0) {
        errors.push({
          type: 'duplicate_parameters',
          command: 'M3',
          duplicates: duplicates,
          location: {
            start: location().start,
            end: location().end,
          },
        });
      }
        return {
          command: "M3",
          parameters: params,
          errors: errors.length > 0 ? errors : null, 
          location: {
            start: location().start,
            end: location().end, 
          },
        }; 
      }

  m3Parameter
    = p:"I" v:bool ws?{ return makeParameter(p, v, location()); }
    / p:"O" v:power ws?{ return makeParameter(p, v, location()); }
    / p:"S" v:power ws?{ return makeParameter(p, v, location()); }

//M4 - Spindle CCW / Laser On
//   M4 [I<mode>] [O<power>] [S<power>]
// Parameters
// [I<mode>]
// Inline mode ON / OFF.
// [O<power>]
// Spindle speed or laser power in PWM 0-255 value range
// [S<power>]
// Spindle speed or laser power in the configured value range (see CUTTER_POWER_UNIT). (PWM 0-255 by default)
m4Command 
  = "M4" !integer ws? params:m4Parameter* {
      const errors = []; 
      const duplicates = findDuplicateParameters(params);
      //If there are any duplicate parameters, push an error to the errors array.
      if (duplicates.length > 0) {
        errors.push({
          type: 'duplicate_parameters',
          command: 'M4',
          duplicates: duplicates,
          location: {
            start: location().start,
            end: location().end,
          },
        });
      }
      return {
        command: "M4",
        parameters: params,
        errors: errors.length > 0 ? errors : null, 
        location: {
          start: location().start, 
          end: location().end,
        },
      }; 
    }

  m4Parameter
    = p:"I" v:bool ws?{ return makeParameter(p, v, location()); }
    / p:"O" v:power ws?{ return makeParameter(p, v, location()); }
    / p:"S" v:power ws?{ return makeParameter(p, v, location()); }

//M16 - Expected Printer Check
// M16 string
// Parameters
// string	
// The string to compare to MACHINE_NAME.
m16Command 
  = "M16" !integer ws? params:m16Parameter{
      const errors = []; 
      const duplicates = findDuplicateParameters(params);
      //If there are any duplicate parameters, push an error to the errors array.
      if (duplicates.length > 0) {
        errors.push({
          type: 'duplicate_parameters',
          command: 'M16',
          duplicates: duplicates,
          location: {
            start: location().start,
            end: location().end,
          },
        });
      }
      return {
        command: "M16",
        parameters: params,
        errors: errors.length > 0 ? errors : null, 
        location: {
          start: location().start, 
          end: location().end,
        },
      }; 
    }
  
m16Parameter 
  = string:string { return string; }

//M17 - Enable Steppers
// M17 [E<flag>] [X<flag>] [Y<flag>] [Z<flag>]
// Parameters
// [E<flag>]	
// E Enable
// [X<flag>]	
// X Enable
// [Y<flag>]	
// Y Enable
// [Z<flag>]	
// Z Enable
m17Command 
  = "M17" !integer ws? params:m17Parameter* {
      const errors = []; 
      const duplicates = findDuplicateParameters(params);
      //If there are any duplicate parameters, push an error to the errors array.
      if (duplicates.length > 0) {
        errors.push({
          type: 'duplicate_parameters',
          command: 'M17',
          duplicates: duplicates,
          location: {
            start: location().start,
            end: location().end,
          },
        });
      }
      return {
        command: "M17",
        parameters: params,
        errors: errors.length > 0 ? errors : null, 
        location: {
          start: location().start, 
          end: location().end,
        },
      }; 
    }

  m17Parameter
    = p:"E" v:flag ws?{ return makeParameter(p, v, location()); }
    / p:"X" v:flag ws?{ return makeParameter(p, v, location()); }
    / p:"Y" v:flag ws?{ return makeParameter(p, v, location()); }
    / p:"Z" v:flag ws?{ return makeParameter(p, v, location()); }

// M18, M84 - Disable steppers
// M18 [E<flag>] [S<seconds>] [X<flag>] [Y<flag>] [Z<flag>]
// M84 [E<flag>] [S<seconds>] [X<flag>] [Y<flag>] [Z<flag>]
// Parameters
// [E<flag>]	
// E Disable
// [S<seconds>]	
// Inactivity Timeout. If none specified, disable now.
// [X<flag>]	
// X Disable
// [Y<flag>]	
// Y Disable
// [Z<flag>]	
// Z Disable
m18andM84Command 
  = c:("M18" / "M84") !integer ws? params:m18andM84Parameter* {
      const errors = []; 
      const duplicates = findDuplicateParameters(params);
      //If there are any duplicate parameters, push an error to the errors array.
      if (duplicates.length > 0) {
        errors.push({
          type: 'duplicate_parameters',
          command: c,
          duplicates: duplicates,
          location: {
            start: location().start,
            end: location().end,
          },
        });
      }
      return {
        command: c,
        parameters: params,
        errors: errors.length > 0 ? errors : null, 
        location: {
          start: location().start, 
          end: location().end,
        },
      }; 
    }

  m18andM84Parameter
    = p:"E" v:flag ws?{ return makeParameter(p, v, location()); }
    / p:"S" v:seconds ws?{ return makeParameter(p, v, location()); }
    / p:"X" v:flag ws?{ return makeParameter(p, v, location()); }
    / p:"Y" v:flag ws?{ return makeParameter(p, v, location()); }
    / p:"Z" v:flag ws?{ return makeParameter(p, v, location()); }

//M20 - List SD Card
//M20 [F] [L] [T]
// Parameters
// [F]  2.0.9.4 CUSTOM_FIRMWARE_UPLOAD	
// Only list BIN files. Used by host plugins to facilitate firmware upload.
// [L]  2.0.9 LONG_FILENAME_HOST_SUPPORT 	
// Include the long filename in the listing.
// [T]  2.1.2 M20_TIMESTAMP_SUPPORT	
// Include the file timestamp in the listing.
m20Command 
  = "M20" !integer ws? params:m20Parameter* {
      const errors = []; 
      const duplicates = findDuplicateParameters(params);
      //If there are any duplicate parameters, push an error to the errors array.
      if (duplicates.length > 0) {
        errors.push({
          type: 'duplicate_parameters',
          command: 'M20',
          duplicates: duplicates,
          location: {
            start: location().start,
            end: location().end,
          },
        });
      }
      return {
        command: "M20",
        parameters: params,
        errors: errors.length > 0 ? errors : null, 
        location: {
          start: location().start, 
          end: location().end,
        },
      }; 
    }

  m20Parameter
    = p:"F" v:flag ws?{ return makeParameter(p, v, location()); }
    / p:"L" v:flag ws?{ return makeParameter(p, v, location()); }
    / p:"T" v:flag ws?{ return makeParameter(p, v, location()); }

//M23 - Select SD file
// M23 filename
// Parameters
// filename	
// The filename of the file to open.
m23Command
  = "M23" !integer ws? params:m23Parameter {
      const errors = []; 
      return {
        command: "M23",
        parameters: params,
        errors: errors.length > 0 ? errors : null, 
        location: {
          start: location().start, 
          end: location().end,
        },
      }; 
    }

m23Parameter
  = filename:string { return filename; }    


//M24 - Start or Resume SD print
// M24 [S<pos>] [T<time>]
// Parameters
// [S<pos>]	
// Position in file to resume from (requires POWER_LOSS_RECOVERY)
// [T<time>]	
// Elapsed time since start of print (requires POWER_LOSS_RECOVERY)
m24Command 
  = "M24" !integer ws? params:m24Parameter* {
      const errors = []; 
      const duplicates = findDuplicateParameters(params);
      //If there are any duplicate parameters, push an error to the errors array.
      if (duplicates.length > 0) {
        errors.push({
          type: 'duplicate_parameters',
          command: 'M24',
          duplicates: duplicates,
          location: {
            start: location().start,
            end: location().end,
          },
        });
      }
      return {
        command: "M24",
        parameters: params,
        errors: errors.length > 0 ? errors : null, 
        location: {
          start: location().start, 
          end: location().end,
        },
      }; 
    }

  m24Parameter
    = p:"S" v:pos ws?{ return makeParameter(p, v, location()); }
    / p:"T" v:time ws?{ return makeParameter(p, v, location()); }

//M26 - Set SD position
// M26 [S<pos>]
// Parameters
// [S<pos>]	
// Next file read position to set
m26Command 
  = "M26" !integer ws? params:m26Parameter* {
     const errors = []; 
      const duplicates = findDuplicateParameters(params);
      //If there are any duplicate parameters, push an error to the errors array.
      if (duplicates.length > 0) {
        errors.push({
          type: 'duplicate_parameters',
          command: 'M26',
          duplicates: duplicates,
          location: {
            start: location().start,
            end: location().end,
          },
        });
      }
      return {
        command: "M26",
        parameters: params,
        errors: errors.length > 0 ? errors : null, 
        location: {
          start: location().start, 
          end: location().end,
        },
      }; 
    }

  m26Parameter
    = p:"S" v:pos ws?{ return makeParameter(p, v, location()); }

//M27 - Report SD print status
// M27 [C] [S<seconds>]
// Parameters
// [C]	
// Report the filename and long filename of the current file
// [S<seconds>]	
// Interval between auto-reports. S0 to disable (requires AUTO_REPORT_SD_STATUS)
m27Command 
  = "M27" !integer ws? params:m27Parameter* {
   const errors = []; 
      const duplicates = findDuplicateParameters(params);
      //If there are any duplicate parameters, push an error to the errors array.
      if (duplicates.length > 0) {
        errors.push({
          type: 'duplicate_parameters',
          command: 'M27',
          duplicates: duplicates,
          location: {
            start: location().start,
            end: location().end,
          },
        });
      }
      return {
        command: "M27",
        parameters: params,
        errors: errors.length > 0 ? errors : null, 
        location: {
          start: location().start, 
          end: location().end,
        },
      }; 
    }

  m27Parameter
    = p:"C" v:flag ws?{ return makeParameter(p, v, location()); }
    / p:"S" v:seconds ws?{ return makeParameter(p, v, location()); }


//M28 - Start SD write
// M28 [B1] filename
// Parameters
// [B1]	
// Set an optimized binary file transfer mode. (Requires BINARY_FILE_TRANSFER)
// filename	
// File name to write
m28Command 
  = "M28" !integer ws? params:m28Parameter ws string?{
      const errors = []; 

      return {
        command: "M28",
        parameters: params,
        errors: errors.length > 0 ? errors : null, 
        location: {
          start: location().start, 
          end: location().end,
        },
      }; 
    } 

  m28Parameter
    = p:"B1" v:flag ws?{ return makeParameter(p, v, location()); }
    
//M30 - Delete SD file
// M30 filename
// Parameters
// filename	
// The filename of the file to delete.
m30Command 
  = "M30" !integer ws? params:m30Parameter {
      const errors = []; 
      return {
        command: "M30",
        parameters: params,
        errors: errors.length > 0 ? errors : null, 
        location: {
          start: location().start, 
          end: location().end, 
        },
      }; 
    }

  m30Parameter
    = filename:string { return filename; }

//M32 - Select and Start
//M32 [P<flag>] [S<filepos>]
// Parameters
// [P<flag>]	
// Sub-Program flag
// [S<filepos>]	
// Starting file offset
m32Command 
  = "M32" !integer ws? params:m32Parameter* {
      const errors = []; 

      return {
        command: "M32",
        parameters: params,
        errors: errors.length > 0 ? errors : null, 
        location: {
          start: location().start, 
          end: location().end, 
        },
      }; 
    }

  m32Parameter
    = p:"P" v:flag ws?{ return makeParameter(p, v, location()); }
    / p:"S" v:filepos ws?{ return makeParameter(p, v, location()); }

//M33 - Get Long Path
// M33 path
// Parameters
// path	
// DOS 8.3 path to a file or folder
m33Command 
  = "M33" !integer ws? path:m33Parameter {
            const errors = []; 

      return {
        command: "M33",
        parameters: path,
        errors: errors.length > 0 ? errors : null, 
        location: {
          start: location().start, 
          end: location().end, 
        },
      }; 
    }

  m33Parameter
    = path:string { return path; }

//M34 - SDCard Sorting
// M34 [F<-1|0|1>] [S<bool>]
// Parameters
// [F<-1|0|1>]	
// Folder Sorting
// F-1: Folders before files
// F0: No folder sorting
// F1: Folders after files
// [S<bool>]	
// Sorting on/off
m34Command 
  = "M34" !integer ws? params:m34Parameter* {
      const errors = []; 
      const duplicates = findDuplicateParameters(params);
      //If there are any duplicate parameters, push an error to the errors array.
      if (duplicates.length > 0) {
        errors.push({
          type: 'duplicate_parameters',
          command: 'M34',
          duplicates: duplicates,
          location: {
            start: location().start,
            end: location().end,
          },
        });
      }
      return {
        command: "M34",
        parameters: params,
        errors: errors.length > 0 ? errors : null, 
        location: {
          start: location().start, 
          end: location().end, 
        },
      }; 
    }

  m34Parameter
    = p:"F" v:("-1" / "0" / "1") ws?{ return makeParameter(p, v, location()); }
    / p:"S" v:bool ws?{ return makeParameter(p, v, location()); }

//M42 - Set Pin State
// M42 [I<bool>] [P<pin>] S<state> [T<0|1|2|3>]
// Parameters
// [I<bool>]  1.1.9.1	
// Ignore protection on pins that Marlin is using.
// [P<pin>]	
// A digital pin number (even for analog pins) to write to. (LED_PIN if omitted)
// S<state>	
// The state to set. PWM pins may be set from 0-255.
// [T<0|1|2|3>]  2.0.5.2	
// Set the pin mode. Prior to Marlin 2.0.9.4 this is set with the M parameter.
// T0: INPUT
// T1: OUTPUT
// T2: INPUT_PULLUP
// T3: INPUT_PULLDOWN
m42Command 
  = c:"M42" !integer ws? params:m42Parameter* {
      const errors = []; 
      const duplicates = findDuplicateParameters(params);
      //If there are any duplicate parameters, push an error to the errors array.
      if (duplicates.length > 0) {
        errors.push({
          type: 'duplicate_parameters',
          command: c,
          duplicates: duplicates,
          location: {
            start: location().start,
            end: location().end,
          },
        });
      }
      return {
        command: c,
        parameters: params,
        errors: errors.length > 0 ? errors : null, 
        location: {
          start: location().start, 
          end: location().end, 
        },
      }; 
    }

  m42Parameter
    = p:"I" v:bool ws?{ return makeParameter(p, v, location()); }
    / p:"P" v:pin ws?{ return makeParameter(p, v, location()); }
    / p:"S" v:state ws?{ return makeParameter(p, v, location()); }
    / p:"T" v:("0" / "1" / "2" / "3") ws?{ return makeParameter(p, v, location()); }

//M43 - Debug Pins
// M43 [E<bool>] [I] [P<pin>] [S] [T] [W]
// Parameters
// [E<bool>]	
// Watch endstops
// [I]	
// Ignore protection when reporting values
// [P<pin>]	
// Digital Pin Number
// [S]	
// Test BLTouch type servo probes. Use P to specify servo index (0-3). Defaults to 0 if P omitted
// [T]	
// Toggle pins - see M43 T for options
// [W]	
// Watch pins
m43Command 
  = "M43" !integer ws? params:m43Parameter* {
      const errors = []; 
      const duplicates = findDuplicateParameters(params);
      //If there are any duplicate parameters, push an error to the errors array.
      if (duplicates.length > 0) {
        errors.push({
          type: 'duplicate_parameters',
          command: 'M43',
          duplicates: duplicates,
          location: {
            start: location().start,
            end: location().end,
          },
        });
      }
      return {
        command: "M43",
        parameters: params,
        errors: errors.length > 0 ? errors : null, 
        location: {
          start: location().start, 
          end: location().end, 
        },
      }; 
    }

  m43Parameter
    = p:"E" v:bool ws?{ return makeParameter(p, v, location()); }
    / "I" ws?{ return makeParameter("I", true, location()); }
    / p:"P" v:pin ws?{ return makeParameter(p, v, location()); }
    / "S" ws?{ return makeParameter("S", true, location()); }
    / "T" ws?{ return makeParameter("T", true, location()); }
    / "W" ws?{ return makeParameter("W", true, location()); }

//M43 T - Toggle Pins
// M43 T [I<bool>] [L<pin>] [R<count>] [S<pin>] [W<time>]
// Parameters
// [I<bool>]	
// Flag to ignore Marlin’s pin protection. Use with caution!!!!
// [L<pin>]	
// End Pin number. If not given, will default to last pin defined for this board
// [R<count>]	
// Repeat pulses on each pin this number of times before continuing to next pin. If not given will default to 1.
// [S<pin>]	
// Start Pin number. If not given, will default to 0
// [W<time>]	
// Wait time (in milliseconds) transitions. If not given will default to 500.
m43tCommand
  = "M43" ws "T" !integer ws? params:m43tParameter* {
      const errors = []; 
      const duplicates = findDuplicateParameters(params);
      //If there are any duplicate parameters, push an error to the errors array.
      if (duplicates.length > 0) {
        errors.push({
          type: 'duplicate_parameters',
          command: 'M43 T',
          duplicates: duplicates,
          location: {
            start: location().start,
            end: location().end,
          },
        });
      }
      return {
        command: "M43 T",
        parameters: params,
        errors: errors.length > 0 ? errors : null, 
        location: {
          start: location().start,
          end: location().end, 
        },
      }; 
    }

  m43tParameter
    = p:"I" v:bool ws?{ return makeParameter(p, v, location()); }
    / p:"L" v:pin ws?{ return makeParameter(p, v, location()); }
    / p:"R" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"S" v:pin ws?{ return makeParameter(p, v, location()); }
    / p:"W" v:integer ws?{ return makeParameter(p, v, location()); }

  