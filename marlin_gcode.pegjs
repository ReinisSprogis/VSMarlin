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

//G0 and G1 commands are very similar.
// I could have made one rule for both of them, but it is separate because G0 wans about using G1 for print / laser cut moves.
//G0 [E<pos>] [F<rate>] [S<power>] [X<pos>] [Y<pos>] [Z<pos>]
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

//G1 almos the same as G0, but it does not show suggestion to use G1 command.
//G1 [E<pos>] [F<rate>] [S<power>] [X<pos>] [Y<pos>] [Z<pos>]
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

//G2 [E<pos>] [F<rate>] I<offset> J<offset> [P<count>] R<radius> [S<power>] [X<pos>] [Y<pos>] [Z<pos>]
//There are two type of forms available for G2 and G3 commands.
// I and J or R. 
//I J and R cannot be used together.
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

//G3 [E<pos>] [F<rate>] I<offset> J<offset> [P<count>] R<radius> [S<power>] [X<pos>] [Y<pos>] [Z<pos>]
//There are two type of forms available for G2 and G3 commands.
// I and J or R.
//I J and R cannot be used together.
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

//G4 [P<time (ms)>] [S<time (sec)>]
//If both S and P are included, S takes precedence.
//G4 with no arguments is effectively the same as M400.
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

//G5 [E<pos>] [F<rate>] I<pos> J<pos> P<pos> Q<pos> [S<power>] X<pos> Y<pos>
//P and Q are required 
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

//G6 [E<direction>] [I<index>] [R<rate>] [S<rate>] [X<direction>] [Y<direction>] [Z<direction>]
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

//G6 [E<direction>] [I<index>] [R<rate>] [S<rate>] [X<direction>] [Y<direction>] [Z<direction>]
g6Parameter 
  = p:"X" v:direction ws?{ return makeParameter(p, v, location()); }
  / p:"Y" v:direction ws? { return makeParameter(p, v, location()); }
  / p:"Z" v:direction ws?{ return makeParameter(p, v, location()); }
  / p:"E" v:direction ws?{ return makeParameter(p, v, location()); }
  / p:"S" v:number ws?{ return makeParameter(p, v, location()); }
  / p:"I" v:integer ws?{ return makeParameter(p, v, location()); }
  / p:"R" v:number ws?{ return makeParameter(p, v, location()); }



//G10 [S<bool>]
//G11 [S<bool>]
//S parameter is optional.
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


 //G12 [P<0|1|2>] [R<radius>] [S<count>] [T<count>] [X] [Y] [Z] 
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

//G26 [B<temp>] [C<bool>] [D] [F<linear>] [H<linear>] [I<index>] [K<bool>] [L<linear>] [O<linear>] [P<linear>] [Q<float>] [R<int>] [S<float>] [U<linear>] [X<linear>] [Y<linear>]
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

  //G27 [P<0|1|2>]
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

//G28 [L] [O] [R] [X] [Y] [Z]
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
  