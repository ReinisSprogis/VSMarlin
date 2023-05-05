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
  = commands:(command / comment / emptyLine)* {
      const errors = []; // Define errors variable here
      commands = commands.filter(c => c.type !== 'emptyLine'); // Move this line up
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

number
  = sign:("+" / "-")? intPart:[0-9]+ fracPart:("." [0-9]+)? ws{
      return parseFloat((sign || "") + intPart.join("") + (fracPart ? fracPart.join("") : ""));
    }

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


command
  = c:(g0Command) ws { return c; }

anyCommand
  = c:([A-Z] [0-9]+) ws {
      return {
        command: c,
        location: {
          start: location().start,
          end: location().end,
        },
      };
    }

  


g0Command
  = "G0" ws params:g0Parameter* {
      const errors = []; // Add this line
      const duplicates = findDuplicateParameters(params);
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
      return {
        command: "G0",
        parameters: params,
        errors: errors.length > 0 ? errors : null, // Add this line
        location: {
          start: location().start,
          end: location().end,
        },
      };
    }






g0Parameter
  = p:("X" / "Y" / "Z" / "E" / "F" / "S") v:number {
      if (!v) {
        errors.push({
          type: 'value_missing',
          command: 'G0',
          parameter: p,
          location: {
            start: location().start,
            end: location().end,
          },
        });
        return makeParameter(p, null, location());
      }
      return makeParameter(p, v, location());
    }
