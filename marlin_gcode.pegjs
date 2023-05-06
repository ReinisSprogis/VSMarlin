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
  = lineNumber? ws? commands:(command / comment / emptyLine)* ws? nl? {
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





emptyLine
  = ws nl {
      return {
        type: "emptyLine",
        location: {
          start: location().start,
          end: location().end,
        },
      };
    }

ws "whitespace" = [ \t]*

nl "newline"
  = [\n] / [\r][\n]?

//Not sure if this is needed.
//But added just in case some might have line numbers in their gcode.
lineNumber
  = "N" n:[0-9]+ ws {
      return parseInt(n.join(""));
    } 

//Eather integer or float.
number
  = sign:("-")? intPart:[0-9]+ fracPart:("." [0-9]+)? ws{
      return parseFloat((sign || "") + intPart.join("") + (fracPart ? fracPart.join("") : ""));
    }

//*******************Integer types******************//
//Digit without decimal point.
integer
  = sign:("-")? intPart:[0-9]+ ws {
      return parseInt((sign || "") + intPart.join(""));
    }

//Types is described as integer in gcode documentation.
index = integer

temp = integer

linear = integer



//Specifically floating point number.
float
  = sign:("-")? intPart:[0-9]+ fracPart:("." [0-9]+) ws{
      return parseFloat((sign || "") + intPart.join("") + (fracPart ? fracPart.join("") : ""));
    }



//Direction is 0 or 1.
//0 is clockwise.
//1 is counterclockwise.
direction 
  = "0" / "1"

//Boolean is 0 false or 1 true.
bool 
  = "0" / "1"

//Takes no parameters
flag
= ""

//Line that start with ; are considered as comments. Comment is allowed at the and of line as well.
comment
  = ";" commentText:[^\n]* ws "\n" {
      return {
        type: "comment",
        text: commentText.join(""),
        location: {
          start: location().start,
          end: location().end,
        },
      };
    }

//All commands with parameters
command
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
    noParamGCommand
    ) ws? { return c; }

//All gcodes that takes no parameters. So that only comment is allowed.
noParamGCommand
  = ("G17" !integer /
    "G18" !integer /
    "G19" !integer /
    "G20" !integer /
    "G21" !integer / 
    "G31" !integer / 
    "G32" !integer / 
    "G53" !integer / 
    "G54" !integer / 
    "G55" !integer / 
    "G56" !integer / 
    "G57" !integer / 
    "G58" !integer / 
    "G59" !integer / 
    "G59.1"  !integer / 
    "G59.2"  !integer / 
    "G59.3" !integer /
    "G80"  !integer /
    "G90"  !integer /
    "G91" !integer ) ws? {
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
  = p:("P" / "S") v:integer {
      return makeParameter(p, v, location());
    }

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
