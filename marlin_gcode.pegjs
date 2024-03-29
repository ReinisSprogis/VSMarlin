//This is a parser for Marlin. //Here can be set different rules for grammar. 
//It is not a part of the project, but it is used to generate marling_gcode_parser.js.


//Functions to use in the parser goes here.
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


  
  function compareVersions(v1, v2) {
    const [major1, minor1, patch1] = v1.split('.').map(Number);
    const [major2, minor2, patch2] = v2.split('.').map(Number);
  
    if (major1 > major2) return 1;
    if (major1 < major2) return -1;
    if (minor1 > minor2) return 1;
    if (minor1 < minor2) return -1;
    if (patch1 > patch2) return 1;
    if (patch1 < patch2) return -1;
    return 0;
  }
  

  //Version controll
  function createCommand(c, params, duplicates, commandVersion, paramVersions, requiredParams, error, location) {
  const errors = [];

  if (duplicates.length > 0) {
    errors.push({
      type: 'duplicate_parameters',
      command: c,
      duplicates: duplicates,
      location: {
        start: location.start,
        end: location.end,
      },
    });
  }

if(error != null && error.length > 0){
  errors.push(...error);
}

if(requiredParams !== null){
 requiredParams.forEach(paramName => {
    if (!params.some(param => param.name === paramName)) {
      errors.push({
        type: 'missing_required_parameter',
        command: c,
        parameter: paramName,
        location: {
          start: location.start,
          end: location.end,
        },
      });
    }
  });
}

  if (commandVersion) {
    if (compareVersions(options.marlinVersion, commandVersion.required) < 0) {
      errors.push({
        type: 'unsupported_version',
        command: c,
        requiredVersion: commandVersion.required,
        currentVersion: options.marlinVersion,
        location: {
          start: location.start,
          end: location.end,
        },
      });
    }
  }
  


  params.forEach(param => {
    const paramVersion = paramVersions.find(pv => pv.name === param.name);
    if (paramVersion && compareVersions(options.marlinVersion, paramVersion.required) < 0) {
      errors.push({
        type: 'unsupported_parameter_version',
        command: c,
        parameter: param.name,
        requiredVersion: paramVersion.required,
        currentVersion: options.marlinVersion,
        location: {
          start: location.start,
          end: location.end,
        },
      });
    }
  });

  return {
    command: c,
    parameters: params,
    errors: errors.length > 0 ? errors : null,
    location: {
      start: location.start,
      end: location.end,
    },
  };
}

//This is versions for all non-parameter commands.
function getRequiredVersionForCommand(command) {
    switch (command) {
      //G-codes
      case "G17": return "1.0.0";
      case "G18": return "1.0.0";
      case "G19": return "1.0.0";
      case "G20": return "1.1.0";
      case "G21": return "1.1.0";
      case "G31": return "1.0.0";
      case "G32": return "1.0.0";
      case "G53": return "1.0.0";
      case "G54": return "1.0.0";
      case "G55": return "1.0.0";
      case "G56": return "1.0.0";
      case "G57": return "1.0.0";
      case "G58": return "1.0.0";
      case "G59.1": return "1.0.0";
      case "G59.2": return "1.0.0";
      case "G59.3": return "1.0.0";
      case "G59": return "1.0.0";
      case "G80": return "1.0.0";
      case "G90": return "1.0.0";
      case "G91": return "1.0.0";
      //M-codes
      case "M5": return "1.1.2";
      case "M7": return "1.0.0";
      case "M8": return "1.0.0";
      case "M9": return "1.0.0";
      case "M10": return "2.0.8";
      case "M11": return "2.0.8";
      case "M21": return "1.0.0";
      case "M22": return "1.0.0";
      case "M25": return "1.0.0";
      case "M29": return "1.0.0";
      case "M31": return "1.0.0";
      case "M76": return "1.0.0";
      case "M77": return "1.0.0";
      case "M78": return "1.0.0";
      case "M81": return "1.0.0";
      case "M82": return "1.0.0";
      case "M83": return "1.0.0";
      case "M108": return "1.0.0";
      case "M112": return "1.0.0";
      case "M115": return "1.0.0";
      case "M119": return "1.0.0";
      case "M120": return "1.0.0";
      case "M121": return "1.0.0";
      case "M123": return "1.0.0";
      case "M127": return "1.0.0";
      case "M129": return "1.0.0";
      case "M360": return "1.0.0";
      case "M361": return "1.0.0";
      case "M362": return "1.0.0";
      case "M363": return "1.0.0";
      case "M364": return "1.0.0";
      case "M400": return "1.0.0";
      case "M402": return "1.0.0";
      case "M406": return "1.0.0";
      case "M407": return "1.0.0";
      case "M410": return "1.0.0";
      case "M428": return "1.0.0";
      case "M500": return "1.0.0";
      case "M501": return "1.0.0";
      case "M502": return "1.0.0";
      case "M504": return "1.0.0";
      case "M510": return "1.0.0";
      case "M524": return "2.0.0";
      case "M909": return "1.0.0";
      case "M910": return "1.0.0";
      case "M911": return "1.0.0";
      case "M993": return "1.0.0";
      case "M994": return "1.0.0";
      case "M995": return "1.0.0";
      case "M997": return "2.0.0";
      default: return "1.0.0";
    }
  }
}


//Start rule for the parser.
//Line is expeted to start with one of the start rules.
//Not sure if Marlin supports Line numbers, but i added, just in case.
start
  = lineNumber? ws? command:(gCommand / mCommand / comment / emptyLine)  ws?  nl? comment? {
      const errors = []; 
      if (command.errors) {
          errors.push(...command.errors);
      }
      if (options.collectErrors) {
        return {
          command: command,
          errors: errors,
        };
      } else {
        return { command: command };
      }
    }




string 'String' 
  = [a-zA-Z0-9_!"£$%^&?><,./#';=-`¬ ]*

passcode 'Passcode'
  = [a-zA-Z0-9_!"£$%^&?><,./#';=-`¬\\|]*

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

nl "New line"
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

degrees 'Degrees'
  = integer

beeps 'Beeps'
  = integer

response 'Response'
  = integer
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

minutes 'Minutes'
  = positiveInteger

mst 
  = integer

contrast 'Contrast'
  = integer

pin 'Pin'
  = positiveInteger

state 'State'
  = integer

legs 'Legs: int'
  = positiveInteger

ohm 
  = integer

beta 
  = integer
//Specifically floating point number.
float 'Float'
  = number

factor 'Factor'
  = float

accel 
  = float

jerk 
  = float

hertz 
  = float

zeta 
  = float

kfactor 
  = float

deviation
  = float

adj 
  = float

offset 
  = float

length 
  = float

feedrate
  = float

coeff 
  = float

steps 'Steps'
  = float

unit_s 'Units\\s'
  = float

diameter 'Diameter'
  = float

volume 'Volume'
  = float

cm 
  = float

percent 'Percent'
  = float

distance 'Distance'
  = float

power "0 - 255"
  = value:integer* &{ return parseInt(value, 10) >= 0 && parseInt(value, 10) <= 255; } {
      return parseInt(value, 10);
    }

byte 'byte'
  = power
addr
  = byte
Hz 
  = byte

pressure 'Pressure'
  = byte

speed 'Speed'
  = byte

intensity 'Intensity'
  = byte

pixel 'Pixel'
  = integer

sensitivity 'Sensitivity'
  = byte

strip 'Strip'
  = integer 
  
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


enable 
  = bool

engage '0 = false or 1 = true'
  =  bool
//Takes no parameters
flag 'Flag - No parameters'
  = ""

axis 
  = [A-Z]

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

//All G commands with parameters
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

//All G-codes that takes no parameters. So that only comment is allowed.
//List is in reverse order to avoid prefix ambiguity.
//Any added commands must be added in getRequiredVersionForCommand function.
noParamGCommand 
  = c:(
    "G91" /
    "G90" /
    "G80" /
    "G59.3" /
    "G59.2" /
    "G59.1" / 
    "G59" /
    "G58" / 
    "G57" / 
    "G56" / 
    "G55" / 
    "G54" / 
    "G53" / 
    "G32" / 
    "G31" / 
    "G21" /
    "G20" /
    "G19" /
    "G18" /
    "G17"
    )!integer ws? {
      const commandVersion = {
        required: getRequiredVersionForCommand(c),
      };
      return createCommand(c, [], [], commandVersion, [], [] , [], location());
    }


//all M commands with parameters
mCommand 
  = c:(
    m0toM1Command / 
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
    m48Command /
    m73Command /
    m75Command /
    m80Command /
    m85Command /
    m92Command /
    m100Command /
    m102Command /
    m104Command /
    m105Command /
    m106Command /
    m107Command /
    m109Command /
    m110Command /
    m113Command /
    m114Command /
    m117Command /
    m118Command /
    m122Command /
    m125Command /
    m126Command /
    m128Command /
    m140Command /
    m141Command /
    m143Command /
    m145Command /
    m149Command /
    m150Command /
    m154Command /
    m155Command /
    m163Command /
    m164Command /
    m165Command /
    m166Command /
    m190Command /
    m191Command /
    m192Command /
    m193Command /
    m200Command /
    m201Command /
    m203Command /
    m204Command /
    m205Command /
    m206Command /
    m207Command /
    m208Command /
    m209Command /
    m211Command /
    m217Command /
    m218Command /
    m220Command /
    m221Command /
    m226Command /
    m240Command /
    m250Command /
    m255Command /
    m256Command /
    m260Command /
    m261Command /
    m280Command /
    m281Command /
    m282Command /
    m290Command /
    m300Command /
    m301Command /
    m302Command /
    m303Command /
    m304Command /
    m305Command /
    m306Command /
    m350Command /
    m351Command /
    m355Command /
    m380Command /
    m381Command /
    m401Command /
    m403Command /
    m404Command /
    m405Command /
    m412Command /
    m413Command /
    m420Command /
    m421Command /
    m422Command /
    m423Command /
    m425Command /
    m430Command /
    m486Command /
    m503Command /
    m511Command /
    m512Command /
    m540Command /
    m569Command /
    m575Command /
    m593Command /
    m600Command /
    m603Command /
    m605Command /
    m666Command /
    m672Command /
    m701Command /
    m702Command /
    m710Command /
    m808Command /
    m810Command /
    m851Command /
    m852Command /
    m860Command /
    m876Command /
    m900Command /
    m906Command /
    m907Command /
    m908Command /
    m912Command /
    m913Command /
    m914Command /
    m915Command /
    m916Command /
    m917Command /
    m918Command /
    m928Command /
    m951Command /
    m999Command /
    m7219Command /
    noParamMCommands 
    ) { return c; } 

//All mcodes that takes no parameters. So that only comment is allowed.
//List must be in reverse order to avoid prefix ambiguity.
//Any added commands must be added in getRequiredVersionForCommand function.
noParamMCommands 
  = c:(
    "M997" /
    "M995" /
    "M994" /
    "M993" /
    "M911" /
    "M910" /
    "M909" /
    "M524" /
    "M510" /
    "M504" /
    "M502" /
    "M501" /
    "M500" /
    "M428" /
    "M410" /
    "M407" /
    "M406" /
    "M402" /
    "M400" /
    "M364" /
    "M363" /
    "M362" /
    "M361" /
    "M360" /
    "M129" /
    "M127" /
    "M123" /
    "M121" /
    "M120" /
    "M119" /
    "M115" /
    "M112" /
    "M108" /
    "M83" /
    "M82" /
    "M81" /
    "M78" /
    "M77" /
    "M76" /   
    "M31" /
    "M29" /
    "M25" /
    "M22" /
    "M21" /
    "M11" /
    "M10" /
    "M9" /
    "M8" /
    "M7" /     
    "M5" 
    ) !integer ws? {
      const commandVersion = {
        required: getRequiredVersionForCommand(c),
      };
      return createCommand(c, [], [], commandVersion, [], [] , [], location());
    }


//G0-G1 - Linear Move
//G0 and G1 commands are very similar.
// I could have made one rule for both of them, but it is separate because G0 warns about using G1 for print / laser cut moves.
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
  = c:"G0" !integer ws? params:g0Parameter* {
    var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        { name: "X", required: "1.0.0" },
        { name: "Y", required: "1.0.0" },
        { name: "Z", required: "1.0.0" },
        { name: "E", required: "1.0.0" },
        { name: "F", required: "1.0.0" },
        { name: "S", required: "2.1.1" },
      ];
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

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
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
  = c:"G1" !integer ws? params:g1Parameter* {
      var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        { name: "X", required: "1.0.0" },
        { name: "Y", required: "1.0.0" },
        { name: "Z", required: "1.0.0" },
        { name: "E", required: "1.0.0" },
        { name: "F", required: "1.0.0" },
        { name: "S", required: "2.1.1" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, [] , errors, location());
    
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
  = c:"G2" !integer ws params:g2Parameter* {
       var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        { name: "X", required: "1.0.0" },
        { name: "Y", required: "1.0.0" },
        { name: "Z", required: "1.0.0" },
        { name: "E", required: "1.0.0" },
        { name: "F", required: "1.0.0" },
        { name: "S", required: "2.0.8" },
        { name: "I", required: "1.0.0" },
        { name: "J", required: "1.0.0" },
        { name: "R", required: "1.0.0" },
        { name: "P", required: "1.0.0" },
      ];
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
return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
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
  = c:"G3" !integer ws? params:g3Parameter* {
       var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        { name: "X", required: "1.0.0" },
        { name: "Y", required: "1.0.0" },
        { name: "Z", required: "1.0.0" },
        { name: "E", required: "1.0.0" },
        { name: "F", required: "1.0.0" },
        { name: "S", required: "2.0.8" },
        { name: "I", required: "1.0.0" },
        { name: "J", required: "1.0.0" },
        { name: "R", required: "1.0.0" },
        { name: "P", required: "1.0.0" },
      ];
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
      return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
  
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
  = c:"G4" !integer ws? params:g4Parameter* {
      var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        { name: "P", required: "1.0.0" },
        { name: "S", required: "1.0.0" },
      ];
      return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
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
  = c:"G5" !integer ws? params:g5Parameter* {
     var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.1.0" };
      const paramVersions = [
        { name: "X", required: "1.1.0" },
        { name: "Y", required: "1.1.0" },
        { name: "Z", required: "1.1.0" },
        { name: "E", required: "1.1.0" },
        { name: "F", required: "1.1.0" },
        { name: "S", required: "2.0.8" },
        { name: "I", required: "1.1.0" },
        { name: "J", required: "1.1.0" },
        { name: "P", required: "1.1.0" },
        { name: "Q", required: "1.1.0" }
      ];

 return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
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
  = c:"G6" !integer ws? params:g6Parameter* {
      var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" }; //undefined version
      const paramVersions = [
        { name: "X", required: "1.0.0" },
        { name: "Y", required: "1.0.0" },
        { name: "Z", required: "1.0.0" },
        { name: "E", required: "1.0.0" },
        { name: "I", required: "1.0.0" },
        { name: "R", required: "1.0.0" },
        { name: "S", required: "1.0.0" },
        ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
    
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
          var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        { name: "S", required: "1.0.0" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
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
  = c:"G12" !integer ws? params:g12Parameter* {
         var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.1.0" };
      const paramVersions = [
        { name: "P", required: "1.1.0" },
        { name: "R", required: "1.1.0" },
        { name: "S", required: "1.1.0" },
        { name: "T", required: "1.1.0" },
        { name: "X", required: "1.1.0" },
        { name: "Y", required: "1.1.0" },
        { name: "Z", required: "1.1.0" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
    }

g12Parameter
  = p:"P" v:("0"/ "1" / "2") ws?{ return makeParameter(p, v, location()); }
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
  = c:"G26" !integer ws? params:g26Parameter* {
         var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.1.0" };
      const paramVersions = [
        { name: "B", required: "1.1.0" },
        { name: "C", required: "1.1.0" },
        { name: "D", required: "1.1.0" },
        { name: "F", required: "1.1.0" },
        { name: "H", required: "1.1.0" },
        { name: "I", required: "2.0.6" },
        { name: "K", required: "1.1.0" },
        { name: "L", required: "1.1.0" },
        { name: "O", required: "1.1.0" },
        { name: "P", required: "1.1.0" },
        { name: "Q", required: "1.1.0" },
        { name: "R", required: "1.1.0" },
        { name: "S", required: "1.1.0" },
        { name: "U", required: "1.1.0" },
        { name: "X", required: "1.1.0" },
        { name: "Y", required: "1.1.0" },
      ];

    return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());   
    }
  
g26Parameter
  =   p:"B" v:integer ws?{ return makeParameter(p, v, location()); }
  / p:"C" v:bool ws?{ return makeParameter(p, v, location()); }
  / p:"D" v:flag ws?{ return makeParameter(p, v, location()); }
  / p:"F" v:number ws?{ return makeParameter(p, v, location()); }
  / p:"H" v:integer ws?{ return makeParameter(p, v, location()); }
  / p:"I" v:integer ws?{ return makeParameter(p, v, location()); }
  / p:"K" v:bool ws?{ return makeParameter(p, v, location()); }
  / p:"L" v:number ws?{ return makeParameter(p, v, location()); }
  / p:"O" v:number ws?{ return makeParameter(p, v, location()); }
  / p:"P" v:number ws?{ return makeParameter(p, v, location()); }
  / p:"Q" v:number ws?{ return makeParameter(p, v, location()); }
  / p:"R" v:integer ws?{ return makeParameter(p, v, location()); }
  / p:"S" v:number ws?{ return makeParameter(p, v, location()); }
  / p:"U" v:number ws?{ return makeParameter(p, v, location()); }
  / p:"X" v:number ws?{ return makeParameter(p, v, location()); }
  / p:"Y" v:number ws?{ return makeParameter(p, v, location()); }
  

//G27 - Park toolhead
//G27 [P<0|1|2>]
//Parameters
// [P<0|1|2>]	
// Z axis action
// P0: If current Z-pos is lower than Z-park then the nozzle will be raised to reach Z-park height
// P1: No matter the current Z-pos, the nozzle will be raised/lowered to reach Z-park height
// P2: The nozzle height will be raised by Z-park amount but never going over the machine’s limit of Z_MAX_POS
  g27Command 
    = c:"G27" !integer ws? params:g27Parameter* {
     var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.1.0" }; //undefined version
      const paramVersions = [
        { name: "P", required: "1.1.0" },
        ];
  
  return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
      }

  g27Parameter
    = p:"P" v:("0"/ "1" / "2") ws?{ return makeParameter(p, v, location()); }

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
  = c:"G28" !integer ws? params:g28Parameter* {
      var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" }; //undefined version
      const paramVersions = [
        { name: "L", required: "1.0.0" },
        { name: "O", required: "1.1.9" },
        { name: "R", required: "1.1.9" },
        { name: "X", required: "1.0.0" },
        { name: "Y", required: "1.0.0" },
        { name: "Z", required: "1.0.0" },
        ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
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
    = c:"G30" !integer ws? params:g30Parameter* {
       var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" }; //undefined version
      const paramVersions = [
        { name: "C", required: "1.0.0" },
        { name: "E", required: "1.0.0" },
        { name: "X", required: "1.0.0" },
        { name: "Y", required: "1.0.0" },
        ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());    
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
  = c:"G33" !integer ws? params:g33Parameter* {
     var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.1.0" }; //undefined version
      const paramVersions = [
        { name: "C", required: "1.1.0" },
        { name: "E", required: "1.1.0" },
        { name: "F", required: "1.1.0" },
        { name: "O", required: "2.0.9.2" },
        { name: "P", required: "1.1.0" },
        { name: "R", required: "2.0.9.2" },
        { name: "T", required: "1.1.0" },
        { name: "V", required: "1.1.0" },
        ];
  return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());         
    }

  g33Parameter
    = p:"C" v:number ws?{ return makeParameter(p, v, location()); }
    / p:"E" v:bool ws?{ return makeParameter(p, v, location()); }
    / p:"F" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"O" v:bool ws?{ return makeParameter(p, v, location()); }
    / p:"P" v:("10"/ "9" / "8" / "7" / "6" / "5" / "4" / "3" / "2" / "1" / "0") ws?{ return makeParameter(p, v, location()); }
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
  = c:"G34" !integer ws? params:g34Parameter* {
      var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "2.0.4" }; //undefined version
      const paramVersions = [
        { name: "A", required: "2.0.4" },
        { name: "E", required: "2.0.4" },
        { name: "I", required: "2.0.4" },
        { name: "T", required: "2.0.4" },
        { name: "S", required: "2.0.4" },
        { name: "Z", required: "2.0.4" },
        ];
  return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location()); 
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
  = c:"G35" !integer ws? params:g35Parameter* {
      var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" }; //undefined version
      const paramVersions = [
        { name: "S", required: "1.0.0" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());

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
     var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.1.0" }; //undefined version
      const paramVersions = [
        { name: "F", required: "1.1.0" },
        { name: "X", required: "1.1.0" },
        { name: "Y", required: "1.1.0" },
        { name: "Z", required: "1.1.0" },
        ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
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
  = c:"G42" !integer ws? params:g42Parameter* {
      var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.1.2" }; //undefined version
      const paramVersions = [
        { name: "F", required: "1.1.2" },
        { name: "I", required: "1.1.2" },
        { name: "J", required: "1.1.2" },
        ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
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
  = c:"G60" !integer ws? params:g60Parameter* {
      var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" }; //undefined version
      const paramVersions = [
        { name: "S", required: "1.0.0" },
        ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
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
  = c:"G61" !integer ws? params:g61Parameter* {
     var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" }; //undefined version
      const paramVersions = [
        { name: "E", required: "1.0.0" },
        { name: "F", required: "1.0.0" },
        { name: "S", required: "1.0.0" },
        { name: "X", required: "1.0.0" },
        { name: "Y", required: "1.0.0" },
        { name: "Z", required: "1.0.0" },
        ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
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
  = c:"G76" !integer ws? params:g76Parameter* {
      var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" }; //undefined version
      const paramVersions = [
        { name: "B", required: "1.0.0" },
        { name: "P", required: "1.0.0" },
        ];
  return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());       
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
  = c:"G92" !integer ws? params:g92Parameter* {
    var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" }; //undefined version
      const paramVersions = [
        { name: "X", required: "1.0.0" },
        { name: "Y", required: "1.0.0" },
        { name: "Z", required: "1.0.0" },
        { name: "E", required: "1.0.0" },
        ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
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
  = c:"G425" !integer ws? params:g425Parameter* {
      const errors = []; 
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" }; //undefined version
      const paramVersions = [
        { name: "B", required: "1.0.0" },
        { name: "T", required: "1.0.0" },
        { name: "U", required: "1.0.0" },
        { name: "V", required: "1.0.0" },
        ];

    return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());     
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
  = c:("M0" / "M1") !integer ws? params:m0toM1Parameter* string? {
     var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        { name: "P", required: "1.0.0" },
        { name: "S", required: "1.0.0" },
        { name: "string", required: "1.0.0" }
      ];

      return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    }

  m0toM1Parameter
    = p:"P" v:ms ws?{ return makeParameter(p, v, location()); }
    / p:"S" v:sec ws?{ return makeParameter(p, v, location()); }
    


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
    = c:"M3" !integer ws? params:m3Parameter* {
       var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.1.2" };
      const paramVersions = [
        { name: "I", required: "1.1.2" },
        { name: "O", required: "1.1.2" },
        { name: "S", required: "1.1.2" },
      ];

      return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
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
  = c:"M4" !integer ws? params:m4Parameter* {
      var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.1.2" };
      const paramVersions = [
        { name: "I", required: "1.1.2" },
        { name: "O", required: "1.1.2" },
        { name: "S", required: "1.1.2" },
      ];

      return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
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
  = c:"M16" !integer ws? params:m16Parameter{
      var errors = [];
      const duplicates = [];
      const commandVersion = { required: "2.0.0" };
      const paramVersions = [
      ];

      return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
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
  = c:"M17" !integer ws? params:m17Parameter* {
     var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        { name: "E", required: "1.0.0" },
        { name: "X", required: "1.0.0" },
        { name: "Y", required: "1.0.0" },
        { name: "Z", required: "1.0.0" },


      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
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
     var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        { name: "E", required: "1.0.0" },
        { name: "S", required: "2.1.1" },
        { name: "X", required: "1.0.0" },
        { name: "Y", required: "1.0.0" },
        { name: "Z", required: "1.0.0" },
       
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
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
  = c:"M20" !integer ws? params:m20Parameter* {
      const errors = []; 
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" }; //undefined version
      const paramVersions = [
        { name: "F", required: "2.0.9.4" },
        { name: "L", required: "2.0.9" },
        { name: "T", required: "2.1.2" },
        ];

      return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
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
  = c:"M23" !integer ws? params:m23Parameter {
      var errors = [];
      const duplicates = [];
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
      ];

      return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
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
  = c:"M24" !integer ws? params:m24Parameter* {
      const errors = []; 
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" }; //undefined version
      const paramVersions = [
        { name: "S", required: "1.0.0" },
        { name: "T", required: "1.0.0" },
        ];

      return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
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
  = c:"M26" !integer ws? params:m26Parameter* {
     var errors = [];
      const duplicates = [];
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        { name: "S", required: "1.0.0" },
      ];

      return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
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
  = c:"M27" !integer ws? params:m27Parameter* {
    var errors = [];
      const duplicates = [];
      const commandVersion = { required: "1.0.0" }; //undefined version
      const paramVersions = [
        { name: "C", required: "1.0.0" },
        { name: "S", required: "1.0.0" },
      ];

      return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
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
  = c:"M28" !integer ws? params:m28Parameter ws string?{
       var errors = [];
      const duplicates = [];
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        { name: "B1", required: "1.0.0" },
      ];

      return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
    } 

  m28Parameter
    = p:"B1" v:flag ws?{ return makeParameter(p, v, location()); }
    
//M30 - Delete SD file
// M30 filename
// Parameters
// filename	
// The filename of the file to delete.
m30Command 
  = c:"M30" !integer ws? params:m30Parameter {
      var errors = [];
      const duplicates = [];
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
      ];

      return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
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
  = c:"M32" !integer ws? params:m32Parameter* {
       var errors = [];
      const duplicates = [];
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        { name: "P", required: "1.0.0" },
        { name: "S", required: "1.0.0" },
      ];

      return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
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
  = c:"M33" !integer ws? path:m33Parameter {
       var errors = [];
      const duplicates = [];
      const commandVersion = { required: "1.0.2" };
      const paramVersions = [
      ];

      return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
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
  = c:"M34" !integer ws? params:m34Parameter* {
      var errors = [];
      const duplicates = [];
      const commandVersion = { required: "1.1.0" };
      const paramVersions = [
        { name: "F", required: "1.1.0" },
        { name: "S", required: "1.1.0" },
      ];


      return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
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
       var errors = [];
      const duplicates = [];
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        { name: "I", required: "1.1.9.1" },
        { name: "P", required: "1.0.0" },
        { name: "S", required: "1.0.0" },
        { name: "T", required: "2.0.5.2" },
      ];

      return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
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
  = c:"M43" !integer ws? params:m43Parameter* {
     var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        { name: "E", required: "1.0.0" },
        { name: "I", required: "1.0.0" },
        { name: "P", required: "1.0.0" },
        { name: "S", required: "1.0.0" },
        { name: "T", required: "1.0.0" },
        { name: "W", required: "1.0.0" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
    }

  m43Parameter
    = p:"E" v:bool ws?{ return makeParameter(p, v, location()); }
    / p:"I" ws?{ return makeParameter("I", true, location()); }
    / p:"P" v:pin ws?{ return makeParameter(p, v, location()); }
    / p:"S" ws?{ return makeParameter("S", true, location()); }
    / p:"T" ws?{ return makeParameter("T", true, location()); }
    / p:"W" ws?{ return makeParameter("W", true, location()); }

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
  = c:("M43" ws "T") !integer ws? params:m43tParameter* {
     var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        { name: "I", required: "1.0.0" },
        { name: "L", required: "1.0.0" },
        { name: "R", required: "1.0.0" },
        { name: "S", required: "1.0.0" },
        { name: "W", required: "1.0.0" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
    }

  m43tParameter
    = p:"I" v:bool ws?{ return makeParameter(p, v, location()); }
    / p:"L" v:pin ws?{ return makeParameter(p, v, location()); }
    / p:"R" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"S" v:pin ws?{ return makeParameter(p, v, location()); }
    / p:"W" v:integer ws?{ return makeParameter(p, v, location()); }

  //M48 - Probe Repeatability Test
//   M48 [C<bool>] [E<engage>] [L<legs>] [P<count>] [S<0|1>] [V<level>] [X<pos>] [Y<pos>]
// Parameters
// [C<bool>]	
// Probe with temperature compensation enabled (PTC_PROBE, PTC_BED, PTC_HOTEND)
// [E<engage>]	
// Engage for each probe
// [L<legs>]	
// Number of legs to probe
// [P<count>]	
// Number of probes to do
// [S<0|1>]	
// Star/Schizoid probe. By default this will do 7 points. Override with L.
// S0: Circular pattern
// S1: Star-like pattern
// [V<level>]	
// Verbose Level (0-4, default=1)
// [X<pos>]	
// X Position
// [Y<pos>]	
// Y Position
m48Command 
  = c:"M48" !integer ws? params:m48Parameter* {
      var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        { name: "C", required: "1.0.0" },
        { name: "E", required: "1.0.0" },
        { name: "L", required: "1.0.0" },
        { name: "P", required: "1.0.0" },
        { name: "S", required: "1.0.0" },
        { name: "V", required: "1.0.0" },
        { name: "X", required: "1.0.0" },
        { name: "Y", required: "1.0.0" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
    }

  m48Parameter
    = p:"C" v:bool ws?{ return makeParameter(p, v, location()); }
    / p:"E" v:engage ws?{ return makeParameter(p, v, location()); }
    / p:"L" v:legs ws?{ return makeParameter(p, v, location()); }
    / p:"P" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"S" v:("0" / "1") ws?{ return makeParameter(p, v, location()); }
    / p:"V" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"X" v:pos ws?{ return makeParameter(p, v, location()); }
    / p:"Y" v:pos ws?{ return makeParameter(p, v, location()); }

//M73 - Set Print Progress
// M73 P<percent> [R<minutes>]
// Parameters
// P<percent>	
// Current print progress percentage
// [R<minutes>]  2.0.0 USE_M73_REMAINING_TIME	
// Set remaining time.
m73Command
  = c:"M73" !integer ws? params:m73Parameter* {
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.1.7" };
      const paramVersions = [
        { name: "P", required: "1.1.7" },
        { name: "R", required: "2.0.0" }
      ];
      const requiredParams = ["P"];
      return createCommand(c, params, duplicates, commandVersion, paramVersions, requiredParams,null, location());
    }


  m73Parameter
    = p:"P" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"R" v:minutes ws?{ return makeParameter(p, v, location()); }

//M75 - Start Print Job Timer
//M75 [string]
// Parameters
// [string]	
// A string to display in the LCD heading. (Requires DWIN_CREALITY_LCD_ENHANCED)
m75Command 
  = c:"M75" !integer ws? params:m75Parameter{
var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [

      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
    }

  m75Parameter
    = string:string { return string; }


//M80 - Power On
// M80 [S]
// Parameters
// [S]	
// Report Power Supply state
m80Command 
  = c:"M80" !integer ws? params:m80Parameter* {
      var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        { name: "S", required: "2.1.1" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
    }

  m80Parameter
    = p:"S" ws?{ return makeParameter(p, true, location()); }
  
//M85 - Inactivity Shutdown
// M85 S<seconds>
// Parameters
// S<seconds>	
// Max inactive seconds
m85Command 
  = c:"M85" !integer ws? params:m85Parameter* {
     var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        { name: "S", required: "1.0.0" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
    }

  m85Parameter
    = p:"S" v:seconds ws?{ return makeParameter(p, v, location()); }

//M92 - Set Axis Steps-per-unit
// M92 [E<steps>] [T<index>] [X<steps>] [Y<steps>] [Z<steps>]
// Parameters
// [E<steps>]	
// E steps per unit
// [T<index>]	
// Target extruder (Requires DISTINCT_E_FACTORS)
// [X<steps>]	
// X steps per unit
// [Y<steps>]	
// Y steps per unit
// [Z<steps>]	
// Z steps per unit
m92Command 
  = c:"M92" !integer ws? params:m92Parameter* {
      var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        { name: "E", required: "1.0.0" },
        { name: "T", required: "1.0.0" },
        { name: "X", required: "1.0.0" },
        { name: "Y", required: "1.0.0" },
        { name: "Z", required: "1.0.0" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
    }

  m92Parameter
    = p:"E" v:steps ws?{ return makeParameter(p, v, location()); }
    / p:"T" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"X" v:steps ws?{ return makeParameter(p, v, location()); }
    / p:"Y" v:steps ws?{ return makeParameter(p, v, location()); }
    / p:"Z" v:steps ws?{ return makeParameter(p, v, location()); }

//M100 - Free Memory
// M100 [C<n>] [D] [F] [I]
// Parameters
// [C<n>]	
// Corrupt ‘n’ locations in the free memory pool and report the locations of the corruption. This is useful to check the correctness of the M100 D and M100 F commands
// [D]	
// Dump the free memory block from __brkval to the stack pointer
// [F]	
// Return the number of free bytes in the memory pool along with other vital statistics that define the memory pool
// [I]	
// Initialize the free memory pool so it can be watched and print vital statistics that define the free memory pool
m100Command 
  = c:"M100" !integer ws? params:m100Parameter* {
var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
          { name: "C", required: "1.0.0" },
          { name: "D", required: "1.0.0" },
          { name: "F", required: "1.0.0" },
          { name: "I", required: "1.0.0" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
    }

  m100Parameter
    = p:"C" v:integer ws?{ return makeParameter(p, v, location()); }
    / "D" ws?{ return makeParameter("D", true, location()); }
    / "F" ws?{ return makeParameter("F", true, location()); }
    / "I" ws?{ return makeParameter("I", true, location()); }

//M102 - Configure Bed Distance Sensor
// M102 S<-6|-5|-1|0|>0>
// Parameters
// S<-6|-5|-1|0|>0>	
// Set the Bed Distance Sensor state and trigger distance.

// S-6: Start Calibration
// S-5: Read raw Calibration data
// S-1: Read sensor information
// S0: Disable Adjustable Z Height
// S>0: Set Adjustable Z Height in 0.1mm units (e.g., M102 S4 enables adjusting for Z <= 0.4mm.)
m102Command 
  = c:"M102" !integer ws? params:m102Parameter* {
      var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "2.1.1" };
      const paramVersions = [
        { name: "S", required: "2.1.1" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
    }

  m102Parameter
    = p:"S" v:("-6" / "-5" / "-1" / "0" / ">0") ws?{ return makeParameter(p, v, location()); }

//M104 - Set Hotend Temperature
// M104 [B<temp>] [F<flag>] [I<index>] [S<temp>] [T<index>]
// Parameters
// [B<temp>]	
// AUTOTEMP: The max auto-temperature.
// [F<flag>]	
// AUTOTEMP: Autotemp flag. Omit to disable autotemp.
// [I<index>]  2.0.6	
// Material preset index. Overrides S.
// [S<temp>]	
// Target temperature.
// AUTOTEMP: the min auto-temperature.
// [T<index>]	
// Hotend index. If omitted, the currently active hotend will be used.
m104Command 
  = c:"M104" !integer ws? params:m104Parameter* {
     var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        { name: "B", required: "1.0.0" },
        { name: "F", required: "1.0.0" },
        { name: "I", required: "2.0.6" },
        { name: "S", required: "1.0.0" },
        { name: "T", required: "1.0.0" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
    }

  m104Parameter
    = p:"B" v:temp ws?{ return makeParameter(p, v, location()); }
    / p:"F" v:flag ws?{ return makeParameter(p, v, location()); }
    / p:"I" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"S" v:temp ws?{ return makeParameter(p, v, location()); }
    / p:"T" v:integer ws?{ return makeParameter(p, v, location()); }

//M105 - Report Temperatures
// M105 [R] [T<index>]
// Parameters
// [R]	
// Include the Redundant temperature sensor (if any)
// [T<index>]	
// Hotend index
m105Command 
  = c:"M105" !integer ws? params:m105Parameter* {
      var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        { name: "R", required: "1.0.0" },
        { name: "T", required: "1.0.0" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
    }

  m105Parameter
    = "R" ws?{ return makeParameter("R", true, location()); }
    / p:"T" v:integer ws?{ return makeParameter(p, v, location()); }

//M106 - Set Fan Speed
// M106 [I<index>] [P<index>] [S<speed>] [T<secondary>]
// Parameters
// [I<index>]  2.0.6	
// Material preset index. Overrides S.
// [P<index>]	
// Fan index
// [S<speed>]	
// Speed, from 0 to 255. S255 provides 100% duty cycle; S128 produces 50%.
// [T<secondary>]	
// Secondary speed. Added in Marlin 1.1.7. (Requires EXTRA_FAN_SPEED)
// M106 P<fan> T3-255 sets a secondary speed for <fan>.
// M106 P<fan> T2 uses the set secondary speed.
// M106 P<fan> T1 restores the previous fan speed.
m106Command 
  = c:"M106" !integer ws? params:m106Parameter* {
      var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        { name: "I", required: "2.0.6" },
        { name: "P", required: "1.0.0" },
        { name: "S", required: "1.0.0" },
        { name: "T", required: "1.1.7" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
    }

  m106Parameter
    = p:"I" v:index ws?{ return makeParameter(p, v, location()); }
    / p:"P" v:byte ws?{ return makeParameter(p, v, location()); }
    / p:"S" v:index ws?{ return makeParameter(p, v, location()); }
    / p:"T" v:integer ws?{ return makeParameter(p, v, location()); }

//M107 - Fan Off
//M107 [P<index>]
// Parameters
// [P<index>]	
// Fan index
m107Command 
  = c:"M107" !integer ws? params:m107Parameter* {
      var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        { name: "P", required: "1.0.0" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
    }

  m107Parameter
    = p:"P" v:index ws?{ return makeParameter(p, v, location()); }

//M109 - Wait for Hotend Temperature
// M109 [B<temp>] [F<flag>] [I<index>] [R<temp>] [S<temp>] [T<index>]
// Parameters
// [B<temp>]	
// With AUTOTEMP, the max auto-temperature.
// [F<flag>]	
// Autotemp flag. Omit to disable autotemp.
// [I<index>]  2.0.6	
// Material preset index. Overrides S.
// [R<temp>]	
// Target temperature (wait for cooling or heating).
// [S<temp>]	
// Target temperature (wait only when heating). Also AUTOTEMP: The min auto-temperature.
// [T<index>]	
// Hotend index. If omitted, the currently active hotend will be used.
m109Command 
  = c:"M109" !integer ws? params:m109Parameter* {
      var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        { name: "B", required: "1.0.0" },
        { name: "F", required: "1.0.0" },
        { name: "I", required: "2.0.6" },
        { name: "R", required: "1.0.0" },
        { name: "S", required: "1.0.0" },
        { name: "T", required: "1.0.0" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
    }

  m109Parameter
    = p:"B" v:temp ws?{ return makeParameter(p, v, location()); }
    / p:"F" v:flag ws?{ return makeParameter(p, v, location()); }
    / p:"I" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"R" v:temp ws?{ return makeParameter(p, v, location()); }
    / p:"S" v:temp ws?{ return makeParameter(p, v, location()); }
    / p:"T" v:integer ws?{ return makeParameter(p, v, location()); }

//M110 - Set Line Number
// M110 N<line>
// Parameters
// N<line>	
// Line number
m110Command 
  = c:"M110" !integer ws? params:m110Parameter* {
      var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        { name: "N", required: "1.0.0" },
      ];
      const requiredParams = ["N"];
return createCommand(c, params, duplicates, commandVersion, paramVersions, requiredParams , errors, location());
    
    }

  m110Parameter
    = p:"N" v:integer ws?{ return makeParameter(p, v, location()); }

  //TODO:
  //M111 - Debug Level


//M113 - Host Keepalive
// M113 [S<seconds>]
// Parameters
// [S<seconds>]	
// Keepalive interval (0-60).
m113Command 
  = c:"M113" !integer ws? params:m113Parameter* {
     var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        { name: "S", required: "1.0.0" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
    }
  
  m113Parameter
    = p:"S" v:seconds ws?{ return makeParameter(p, v, location()); } 

//M114 - Get Current Position
//  M114 [D] [E] [R]
// Parameters
// [D]	
// Detailed information (requires M114_DETAIL)
// [E]	
// Report E stepper position (requires M114_DETAIL)
// [R]	
// Real position information (requires M114_REALTIME)
m114Command 
  = c:"M114" !integer ws? params:m114Parameter* {
      var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        { name: "D", required: "1.0.0" },
        { name: "E", required: "1.0.0" },
        { name: "R", required: "1.0.0" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
    }
  
  m114Parameter
    = "D" ws?{ return makeParameter("D", true, location()); }
    / "E" ws?{ return makeParameter("E", true, location()); }
    / "R" ws?{ return makeParameter("R", true, location()); }

//M117 - Set LCD Message
// M117 [string]
// Parameters
// [string]	
// LCD status message
m117Command 
  = c:"M117" !integer ws? params:m117Parameter {
     var errors = [];
      const duplicates = [];
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
    }
  
  m117Parameter
    = string:string { return string; }

//M118 - Serial print
// M118 [A1] [E1] [Pn<0|1|2>] [string]
// Parameters
// [A1]	
// Prepend // to denote a comment or action command. Hosts like OctoPrint can interpret such commands to perform special actions. See your host’s documentation.
// [E1]	
// Prepend echo: to the message. Some hosts will display echo messages differently when preceded by echo:.
// [Pn<0|1|2>]	
// Send message to host serial port (1-9).
// Pn0: Send message to all ports.
// Pn1: Send message to main host serial port.
// Pn2: Send message to secondary host serial port. Requires SERIAL_PORT_2.
// [string]	
// Message string. If omitted, a blank line will be sent.
m118Command 
  = c:"M118" !integer ws? params:m118Parameter {
      var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        { name: "A1", required: "1.0.0" },
        { name: "E1", required: "1.0.0" },
        { name: "Pn", required: "1.0.0" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
    }
  
  m118Parameter
    = "A1" ws?{ return makeParameter("A1", true, location()); }
    / "E1" ws?{ return makeParameter("E1", true, location()); }
    / p:"Pn" v:integer ws?{ return makeParameter(p, v, location()); }
    / string:string { return string; }

// M122 - TMC Debugging
//M122 [E] [I] [P<ms>] [S] [V] [X] [Y] [Z]
// Parameters
// [E]	
// Target E driver(s) only.
// [I]  2.0.6	
// Flag to re-initialize stepper drivers with current settings.
// [P<ms>] TMC_DEBUG MONITOR_DRIVER_STATUS	
// Interval between continuous debug reports, in milliseconds.
// [S] TMC_DEBUG MONITOR_DRIVER_STATUS	
// Flag to enable/disable continuous debug reporting.
// [V] TMC_DEBUG	
// Report raw register data. Refer to the datasheet to decypher.
// [X]	
// Target X driver(s) only.
// [Y]	
// Target Y driver(s) only.
// [Z]	
// Target Z driver(s) only.
m122Command 
  = c:"M122" !integer ws? params:m122Parameter* {
      var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.1.7" };
      const paramVersions = [
        { name: "E", required: "1.0.0" },
        { name: "I", required: "2.0.6" },
        { name: "P", required: "1.0.0" },
        { name: "S", required: "1.0.0" },
        { name: "V", required: "1.0.0" },
        { name: "X", required: "1.0.0" },
        { name: "Y", required: "1.0.0" },
        { name: "Z", required: "1.0.0" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
    }
  
  m122Parameter
    = "E" ws?{ return makeParameter("E", true, location()); }
    / "I" ws?{ return makeParameter("I", true, location()); }
    / p:"P" v:integer ws?{ return makeParameter(p, v, location()); }
    / "S" ws?{ return makeParameter("S", true, location()); }
    / "V" ws?{ return makeParameter("V", true, location()); }
    / "X" ws?{ return makeParameter("X", true, location()); }
    / "Y" ws?{ return makeParameter("Y", true, location()); }
    / "Z" ws?{ return makeParameter("Z", true, location()); }

//M125 - Park Head
//M125 [L<linear>] [P<bool>] [X<linear>] [Y<linear>] [Z<linear>]
// Parameters
// [L<linear>]	
// Retract length (otherwise FILAMENT_CHANGE_RETRACT_LENGTH)
// [P<bool>]	
// Always show a prompt and await a response (With an LCD menu)
// [X<linear>]	
// X position to park at (otherwise FILAMENT_CHANGE_X_POS)
// [Y<linear>]	
// Y position to park at (otherwise FILAMENT_CHANGE_Y_POS)
// [Z<linear>]	
// Z raise before park (otherwise FILAMENT_CHANGE_Z_ADD)
m125Command 
  = c:"M125" !integer ws? params:m125Parameter* {
     var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        { name: "L", required: "1.0.0" },
        { name: "P", required: "1.0.0" },
        { name: "X", required: "1.0.0" },
        { name: "Y", required: "1.0.0" },
        { name: "Z", required: "1.0.0" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
    }
  
  m125Parameter
    = p:"L" v:linear ws?{ return makeParameter(p, v, location()); }
    / p:"P" v:bool ws?{ return makeParameter(p, v, location()); }
    / p:"X" v:linear ws?{ return makeParameter(p, v, location()); }
    / p:"Y" v:linear ws?{ return makeParameter(p, v, location()); }
    / p:"Z" v:linear ws?{ return makeParameter(p, v, location()); }


//M126 - Baricuda 1 Open
// M126 [S<pressure>]
// Parameters
// [S<pressure>]	
// Valve pressure
m126Command 
  = c:"M126" !integer ws? params:m126Parameter* {
      var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        { name: "S", required: "1.0.0" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
    }
  
  m126Parameter
    = p:"S" v:pressure ws?{ return makeParameter(p, v, location()); }

//M128 - Baricuda 2 Open
// M128 [S<pressure>]
// Parameters
// [S<pressure>]	
// Valve pressure
m128Command 
  = c:"M128" !integer ws? params:m128Parameter* {
   var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        { name: "S", required: "1.0.0" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
    }
  
  m128Parameter
    = p:"S" v:pressure ws?{ return makeParameter(p, v, location()); }

//M140 - Set Bed Temperature
// M140 [I<index>] [S<temp>]
// Parameters
// [I<index>]  2.0.6	
// Material preset index. Overrides S.
// [S<temp>]	
// Target temperature
m140Command 
  = c:"M140" !integer ws? params:m140Parameter* {
     var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        { name: "I", required: "2.0.6" },
        { name: "S", required: "1.0.0" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
    }
  
  m140Parameter
    = p:"I" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"S" v:temp ws?{ return makeParameter(p, v, location()); }

//M141 - Set Chamber Temperature
//M141 [S<temp>]
// Parameters
// [S<temp>]	
// Target temperature.
// AUTOTEMP: the min auto-temperature.
m141Command 
  = c:"M141" !integer ws? params:m141Parameter* {
     var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        { name: "S", required: "1.0.0" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
    }
  
  m141Parameter
    = p:"S" v:temp ws?{ return makeParameter(p, v, location()); }


//M143 - Set Laser Cooler Temperature
// M143 [S<temp>]
// Parameters
// [S<temp>]	
// Target laser coolant temperature.
m143Command 
  = c:"M143" !integer ws? params:m143Parameter* {
     var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "2.0.8" };
      const paramVersions = [
        { name: "S", required: "2.0.8" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
    }
  
  m143Parameter
    = p:"S" v:temp ws?{ return makeParameter(p, v, location()); }

//M145 - Set Material Preset
// M145 [B<temp>] [F<speed>] [H<temp>] [S<index>]
// Parameters
// [B<temp>]	
// Bed temperature
// [F<speed>]	
// Fan speed
// [H<temp>]	
// Hotend temperature
// [S<index>]	
// Material index
m145Command 
  = c:"M145" !integer ws? params:m145Parameter* {
      var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        { name: "B", required: "1.0.0" },
        { name: "F", required: "1.0.0" },
        { name: "H", required: "1.0.0" },
        { name: "S", required: "1.0.0" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
    }
  
  m145Parameter
    = p:"B" v:temp ws?{ return makeParameter(p, v, location()); }
    / p:"F" v:speed ws?{ return makeParameter(p, v, location()); }
    / p:"H" v:temp ws?{ return makeParameter(p, v, location()); }
    / p:"S" v:integer ws?{ return makeParameter(p, v, location()); }

//M149 - Set Temperature Units
// M149 [C] [F] [K]
// Parameters
// [C]	
// Celsius
// [F]	
// Fahrenheit
// [K]	
// Kelvin
m149Command 
  = c:"M149" !integer ws? params:m149Parameter* {
      var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        { name: "C", required: "1.0.0" },
        { name: "F", required: "1.0.0" },
        { name: "K", required: "1.0.0" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
    }
  
  m149Parameter
    = "C" ws?{ return makeParameter("C", true, location()); }
    / "F" ws?{ return makeParameter("F", true, location()); }
    / "K" ws?{ return makeParameter("K", true, location()); }

//M150 - Set RGB(W) Color
// M150 [B<intensity>] [I<pixel>] [K] [P<intensity>] [R<intensity>] [S<strip>] [U<intensity>] [W<intensity>]
// Parameters
// [B<intensity>]	
// Blue component from 0 to 255
// [I<pixel>]  2.0.6 NEOPIXEL_LED	
// NeoPixel pixel index (0 .. pixels-1) (Requires NEOPIXEL_LED)
// [K] NEOPIXEL_LED	
// Keep all unspecified values unchanged (Requires NEOPIXEL_LED)
// [P<intensity>] NEOPIXEL_LED	
// Brightness from 0 to 255 (Requires NEOPIXEL_LED)
// [R<intensity>]	
// Red component from 0 to 255
// [S<strip>]  2.0.6.1 NEOPIXEL2_SEPARATE	
// NeoPixel strip index (0 or 1) (Requires NEOPIXEL2_SEPARATE)
// [U<intensity>]	
// Green component from 0 to 255
// [W<intensity>]	
// White component from 0 to 255 (RGBW_LED or NEOPIXEL_LED only)
m150Command 
  = c:"M150" !integer ws? params:m150Parameter* {
      var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        { name: "B", required: "1.0.0" },
        { name: "I", required: "2.0.6" },
        { name: "K", required: "1.0.0" },
        { name: "P", required: "1.0.0" },
        { name: "R", required: "1.0.0" },
        { name: "S", required: "2.0.6.1" },
        { name: "U", required: "1.0.0" },
        { name: "W", required: "1.0.0" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
    }
  
  m150Parameter
    = p:"B" v:intensity ws?{ return makeParameter(p, v, location()); }
    / p:"I" v:pixel ws?{ return makeParameter(p, v, location()); }
    / "K" ws?{ return makeParameter("K", true, location()); }
    / p:"P" v:intensity ws?{ return makeParameter(p, v, location()); }
    / p:"R" v:intensity ws?{ return makeParameter(p, v, location()); }
    / p:"S" v:strip ws?{ return makeParameter(p, v, location()); }
    / p:"U" v:intensity ws?{ return makeParameter(p, v, location()); }
    / p:"W" v:intensity ws?{ return makeParameter(p, v, location()); }

//M154 - Position Auto-Report
//M154 [S<seconds>]
// Parameters
// [S<seconds>]	
// Interval in seconds between auto-reports. S0 to disable.
m154Command 
  = c:"M154" !integer ws? params:m154Parameter* {
      var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "2.0.8.1" };
      const paramVersions = [
        { name: "S", required: "2.0.8.1" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
    }
  
  m154Parameter
    = p:"S" v:seconds ws?{ return makeParameter(p, v, location()); }

//M155 - Temperature Auto-Report
// M155 [S<seconds>]
// Parameters
// [S<seconds>]	
// Interval in seconds between auto-reports. S0 to disable.
m155Command 
  = c:"M155" !integer ws? params:m155Parameter* {
      var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        { name: "S", required: "1.0.0" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
    }
  
  m155Parameter
    = p:"S" v:seconds ws?{ return makeParameter(p, v, location()); }

//M163 - Set Mix Factor
// M163 [P<factor>] [S<index>]
// Parameters
// [P<factor>]	
// Mix factor
// [S<index>]	
// Component index
m163Command 
  = c:"M163" !integer ws? params:m163Parameter* {
     var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        { name: "P", required: "1.0.0" },
        { name: "S", required: "1.0.0" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
    }
  
  m163Parameter
    = p:"P" v:factor ws?{ return makeParameter(p, v, location()); }
    / p:"S" v:integer ws?{ return makeParameter(p, v, location()); }

//M164 - Save Mix
// M164 S<index>
// Parameters
// S<index>	
// Tool index (active virtual tool if omitted)
m164Command 
  = c:"M164" !integer ws? params:m164Parameter* {
      var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        { name: "S", required: "1.0.0" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
    }
  
  m164Parameter
    = p:"S" v:integer ws?{ return makeParameter(p, v, location()); }

//M165 - Set Mix
// M165 [A<factor>] [B<factor>] [C<factor>] [D<factor>] [H<factor>] [I<factor>]
// Parameters
// [A<factor>]	
// Mix factor 1
// [B<factor>]	
// Mix factor 2
// [C<factor>]	
// Mix factor 3
// [D<factor>]	
// Mix factor 4
// [H<factor>]	
// Mix factor 5
// [I<factor>]	
// Mix factor 6
  m165Command
    = c:"M165" !integer ws? params:m165Parameter* {
       var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        { name: "A", required: "1.0.0" },
        { name: "B", required: "1.0.0" },
        { name: "C", required: "1.0.0" },
        { name: "D", required: "1.0.0" },
        { name: "H", required: "1.0.0" },
        { name: "I", required: "1.0.0" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
      }
    
    m165Parameter
      = p:"A" v:factor ws?{ return makeParameter(p, v, location()); }
      / p:"B" v:factor ws?{ return makeParameter(p, v, location()); }
      / p:"C" v:factor ws?{ return makeParameter(p, v, location()); }
      / p:"D" v:factor ws?{ return makeParameter(p, v, location()); }
      / p:"H" v:factor ws?{ return makeParameter(p, v, location()); }
      / p:"I" v:factor ws?{ return makeParameter(p, v, location()); }

//M166 - Gradient Mix
// M166 A<linear> I<index> J<index> [S<enable>] [T<index>] Z<linear>
// Parameters
// A<linear>	
// Starting Z Height. (Use Z to set the Ending Z Height.)
// I<index>	
// Starting Virtual Tool. The Gradient begins with this tool-mix. Below the Starting Z Height the Starting Virtual Tool fully applies.
// J<index>	
// Ending Virtual Tool. The Gradient transitions to this tool-mix as Z approaches the Ending Z Height. Above the Ending Z Height the Ending Virtual Tool fully applies.
// [S<enable>]	
// Enable / disable the gradient in manual mode. When using the tool index alias, tool-change commands determine whether or not the gradient is enabled.
// [T<index>]	
// A tool index to reassign to the gradient. If no index is given, cancel the tool assignment.
// Z<linear>	
// Ending Z Height. (Use A to set the Starting Z Height.)
m166Command 
  = c:"M166" !integer ws? params:m166Parameter* {
      var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "2.0.0" };
      const paramVersions = [
        { name: "A", required: "2.0.0" },
        { name: "I", required: "2.0.0" },
        { name: "J", required: "2.0.0" },
        { name: "S", required: "2.0.0" },
        { name: "T", required: "2.0.0" },
        { name: "Z", required: "2.0.0" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
    }
  
  m166Parameter
    = p:"A" v:linear ws?{ return makeParameter(p, v, location()); }
    / p:"I" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"J" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"S" v:enable ws?{ return makeParameter(p, v, location()); }
    / p:"T" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"Z" v:linear ws?{ return makeParameter(p, v, location()); }

//M190 - Wait for Bed Temperature
// M190 [I<index>] [R<temp>] [S<temp>]
// Parameters
// [I<index>]  2.0.6	
// Material preset index. Overrides S.
// [R<temp>]	
// Target temperature (wait for cooling or heating).
// [S<temp>]	
// Target temperature (wait only when heating).
m190Command 
  = c:"M190" !integer ws? params:m190Parameter* {
     var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        { name: "I", required: "2.0.6" },
        { name: "R", required: "1.0.0" },
        { name: "S", required: "1.0.0" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
    }
  
  m190Parameter
    = p:"I" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"R" v:temp ws?{ return makeParameter(p, v, location()); }
    / p:"S" v:temp ws?{ return makeParameter(p, v, location()); }

//M191 - Wait for Chamber Temperature
// M191 [R<temp>] [S<temp>]
// Parameters
// [R<temp>]	
// Target temperature (wait for cooling or heating).
// [S<temp>]	
// Target temperature (wait only when heating).
m191Command 
  = c:"M191" !integer ws? params:m191Parameter* {
     var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        { name: "R", required: "1.0.0" },
        { name: "S", required: "1.0.0" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
    }
  
  m191Parameter
    = p:"R" v:temp ws?{ return makeParameter(p, v, location()); }
    / p:"S" v:temp ws?{ return makeParameter(p, v, location()); }

//M192 - Wait for Probe temperature
// M192 [R<temp>] [S<temp>]
// Parameters
// [R<temp>]	
// Temperature to wait for, whether heating or cooling.
// [S<temp>]	
// A minimum temperature to wait for. No wait if already higher.
m192Command 
  = c:"M192" !integer ws? params:m192Parameter* {
     var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "2.0.6.2" };
      const paramVersions = [
        { name: "R", required: "2.0.6.2" },
        { name: "S", required: "2.0.6.2" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
    }
  
  m192Parameter
    = p:"R" v:temp ws?{ return makeParameter(p, v, location()); }
    / p:"S" v:temp ws?{ return makeParameter(p, v, location()); }

//M193 - Set Laser Cooler Temperature
// M193 [S<temp>]
// Parameters
// [S<temp>]	
// Target laser coolant temperature.
m193Command 
  = c:"M193" !integer ws? params:m193Parameter* {
      var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "2.0.8" };
      const paramVersions = [
        { name: "S", required: "2.0.8" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
    }
  
  m193Parameter
    = p:"S" v:temp ws?{ return makeParameter(p, v, location()); }

//M200 - Set Filament Diameter
// M200 [D<diameter>] [L<volume>] [S<flag>] [T<index>]
// Parameters
// [D<diameter>]	
// Filament diameter
// [L<volume>]	
// Set volumetric extruder limit (in mm3/sec). L0 disables the limit. (Requires VOLUMETRIC_EXTRUDER_LIMIT.)
// [S<flag>]	
// 0 to disable volumetric extrusion mode, otherwise volumetric is enabled.
// [T<index>]	
// Extruder index. If omitted, the currently active extruder will be used.
m200Command 
  = c:"M200" !integer ws? params:m200Parameter* {
      var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        { name: "D", required: "1.0.0" },
        { name: "L", required: "1.0.0" },
        { name: "S", required: "1.0.0" },
        { name: "T", required: "1.0.0" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
    }
  
  m200Parameter
    = p:"D" v:diameter ws?{ return makeParameter(p, v, location()); }
    / p:"L" v:volume ws?{ return makeParameter(p, v, location()); }
    / p:"S" v:flag ws?{ return makeParameter(p, v, location()); }
    / p:"T" v:integer ws?{ return makeParameter(p, v, location()); }

//M201 - Print Move Limits
//M201 [E<accel>] [F<Hz>] [S<percent>] [T<index>] [X<accel>] [Y<accel>] [Z<accel>]
// Parameters
// [E<accel>]	
// E axis max acceleration
// [F<Hz>]	
// Planner frequency limit (Requires XY_FREQUENCY_LIMIT)
// [S<percent>]	
// Planner XY frequency minimum speed percentage (Requires XY_FREQUENCY_LIMIT)
// [T<index>]	
// Target extruder (Requires DISTINCT_E_FACTORS)
// [X<accel>]	
// X axis max acceleration
// [Y<accel>]	
// Y axis max acceleration
// [Z<accel>]	
// Z axis max acceleration
m201Command 
  = c:"M201" !integer ws? params:m201Parameter* {
     var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        { name: "E", required: "1.0.0" },
        { name: "F", required: "1.0.0" },
        { name: "S", required: "1.0.0" },
        { name: "T", required: "1.0.0" },
        { name: "X", required: "1.0.0" },
        { name: "Y", required: "1.0.0" },
        { name: "Z", required: "1.0.0" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
    }
  
  m201Parameter
    = p:"E" v:accel ws?{ return makeParameter(p, v, location()); }
    / p:"F" v:Hz ws?{ return makeParameter(p, v, location()); }
    / p:"S" v:percent ws?{ return makeParameter(p, v, location()); }
    / p:"T" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"X" v:accel ws?{ return makeParameter(p, v, location()); }
    / p:"Y" v:accel ws?{ return makeParameter(p, v, location()); }
    / p:"Z" v:accel ws?{ return makeParameter(p, v, location()); }

//M203 - Set Max Feedrate
//M203 [E<units/s>] [T<index>] [X<units/s>] [Y<units/s>] [Z<units/s>]
// Parameters
// [E<units/s>]	
// E axis max feedrate
// [T<index>]	
// Target extruder (Requires DISTINCT_E_FACTORS)
// [X<units/s>]	
// X axis max feedrate
// [Y<units/s>]	
// Y axis max feedrate
// [Z<units/s>]	
// Z axis max feedrate
m203Command 
  = c:"M203" !integer ws? params:m203Parameter* {
var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        { name: "E", required: "1.0.0" },
        { name: "T", required: "1.0.0" },
        { name: "X", required: "1.0.0" },
        { name: "Y", required: "1.0.0" },
        { name: "Z", required: "1.0.0" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
    }
  
  m203Parameter
    = p:"E" v:unit_s ws?{ return makeParameter(p, v, location()); }
    / p:"T" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"X" v:unit_s ws?{ return makeParameter(p, v, location()); }
    / p:"Y" v:unit_s ws?{ return makeParameter(p, v, location()); }
    / p:"Z" v:unit_s ws?{ return makeParameter(p, v, location()); }

//M204 - Set Starting Acceleration
// /M204 [P<accel>] [R<accel>] [S<accel>] [T<accel>]
// Parameters
// [P<accel>]	
// Printing acceleration. Used for moves that include extrusion (i.e., which employ the current tool).
// [R<accel>]	
// Retract acceleration. Used for extruder retraction moves.
// [S<accel>]	
// Legacy parameter for move acceleration. Set both printing and travel acceleration.
// [T<accel>]	
// Travel acceleration. Used for moves that include no extrusion.
m204Command 
  = c:"M204" !integer ws? params:m204Parameter* {
     var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        { name: "P", required: "1.0.0" },
        { name: "R", required: "1.0.0" },
        { name: "S", required: "1.0.0" },
        { name: "T", required: "1.0.0" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
    }

  m204Parameter
    = p:"P" v:accel ws?{ return makeParameter(p, v, location()); }
    / p:"R" v:accel ws?{ return makeParameter(p, v, location()); }
    / p:"S" v:accel ws?{ return makeParameter(p, v, location()); }
    / p:"T" v:accel ws?{ return makeParameter(p, v, location()); }

// M205 - Set Advanced Settings
// M205 [B<µs>] [E<jerk>] [J<deviation>] [S<units/s>] [T<units/s>] [X<jerk>] [Y<jerk>] [Z<jerk>]
// Parameters
// [B<µs>]	
// Minimum segment time (µs)
// [E<jerk>]	
// E max jerk (units/s)
// [J<deviation>]	
// Junction deviation (requires JUNCTION_DEVIATION)
// [S<units/s>]	
// Minimum feedrate for print moves (units/s)
// [T<units/s>]	
// Minimum feedrate for travel moves (units/s)
// [X<jerk>]	
// X max jerk (units/s)
// [Y<jerk>]	
// Y max jerk (units/s)
// [Z<jerk>]	
// Z max jerk (units/s)
m205Command 
  = c:"M205" !integer ws? params:m205Parameter* {
     var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        { name: "B", required: "1.0.0" },
        { name: "E", required: "1.0.0" },
        { name: "J", required: "1.0.0" },
        { name: "S", required: "1.0.0" },
        { name: "T", required: "1.0.0" },
        { name: "X", required: "1.0.0" },
        { name: "Y", required: "1.0.0" },
        { name: "Z", required: "1.0.0" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
    }
  
  m205Parameter
    = p:"B" v:mst ws?{ return makeParameter(p, v, location()); }
    / p:"E" v:jerk ws?{ return makeParameter(p, v, location()); }
    / p:"J" v:deviation ws?{ return makeParameter(p, v, location()); }
    / p:"S" v:unit_s ws?{ return makeParameter(p, v, location()); }
    / p:"T" v:unit_s ws?{ return makeParameter(p, v, location()); }
    / p:"X" v:jerk ws?{ return makeParameter(p, v, location()); }
    / p:"Y" v:jerk ws?{ return makeParameter(p, v, location()); }
    / p:"Z" v:jerk ws?{ return makeParameter(p, v, location()); }

//M206 - Set Home Offsets
// M206 [P<offset>] [T<offset>] [X<offset>] [Y<offset>] [Z<offset>]
// Parameters
// [P<offset>]	
// SCARA Psi offset (Requires MORGAN_SCARA)
// [T<offset>]	
// SCARA Theta offset (Requires MORGAN_SCARA)
// [X<offset>]	
// X home offset
// [Y<offset>]	
// Y home offset
// [Z<offset>]	
// Z home offset
m206Command 
  = c:"M206" !integer ws? params:m206Parameter* {
      var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        {  name: "P", required: "1.0.0" },
        {  name: "T", required: "1.0.0" },
        {  name: "X", required: "1.0.0" },
        {  name: "Y", required: "1.0.0" },
        {  name: "Z", required: "1.0.0" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
    }
  
  m206Parameter
    = p:"P" v:offset ws?{ return makeParameter(p, v, location()); }
    / p:"T" v:offset ws?{ return makeParameter(p, v, location()); }
    / p:"X" v:offset ws?{ return makeParameter(p, v, location()); }
    / p:"Y" v:offset ws?{ return makeParameter(p, v, location()); }
    / p:"Z" v:offset ws?{ return makeParameter(p, v, location()); }

//M207 - Set Firmware Retraction
// M207 [F<feedrate>] [S<length>] [W<length>] [Z<length>]
// Parameters
// [F<feedrate>]	
// Retract feedrate (units/min)
// [S<length>]	
// Retract length
// [W<length>]	
// Retract swap length (multi-extruder)
// [Z<length>]	
// Z lift on retraction
m207Command 
  = c:"M207" !integer ws? params:m207Parameter* {
     var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        { name: "F", required: "1.0.0" },
        {  name: "S", required: "1.0.0" },
        {  name: "W", required: "1.0.0" },
        {  name: "Z", required: "1.0.0" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
    }
  
  m207Parameter
    = p:"F" v:feedrate ws?{ return makeParameter(p, v, location()); }
    / p:"S" v:length ws?{ return makeParameter(p, v, location()); }
    / p:"W" v:length ws?{ return makeParameter(p, v, location()); }
    / p:"Z" v:length ws?{ return makeParameter(p, v, location()); }

//M208 - Firmware Recover
// M208 [F<feedrate>] [R<feedrate>] [S<length>] [W<length>]
// Parameters
// [F<feedrate>]	
// Recover feedrate (units/min)
// [R<feedrate>]	
// Swap recover feedrate (units/min)
// [S<length>]	
// Additional recover length. Can be negative to reduce recover length.
// [W<length>]	
// Additional recover swap length. Can be negative to reduce the length.
m208Command 
  = c:"M208" !integer ws? params:m208Parameter* {
     var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        { name: "F", required: "1.0.0" },
        {  name: "R", required: "1.0.0" },
        {  name: "S", required: "1.0.0" },
        {  name: "W", required: "1.0.0" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
    }
  
  m208Parameter
    = p:"F" v:feedrate ws?{ return makeParameter(p, v, location()); }
    / p:"R" v:feedrate ws?{ return makeParameter(p, v, location()); }
    / p:"S" v:length ws?{ return makeParameter(p, v, location()); }
    / p:"W" v:length ws?{ return makeParameter(p, v, location()); }

//M209 - Set Auto Retract
// M209 S<flag>
// Parameters
// S<flag>	
// Set Auto-Retract on/off
m209Command 
  = c:"M209" !integer ws? params:m209Parameter* {
     var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        { name: "S", required: "1.0.0" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
    }
  
  m209Parameter
    = p:"S" v:flag ws?{ return makeParameter(p, v, location()); }


//M211 - Software Endstops
// M211 [S<flag>]
// Parameters
// [S<flag>]	
// Software endstops state (S1=enable S0=disable)
m211Command 
  = c:"M211" !integer ws? params:m211Parameter* {
     var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        { name: "S", required: "1.0.0" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
    }
  
  m211Parameter
    = p:"S" v:bool ws?{ return makeParameter(p, v, location()); }

//M217 - Filament swap parameters
// M217 [A<linear>] [B<linear>] [E<linear>] [F<linear>] [G<linear>] [L<linear>] [P<feedrate>] [Q] [R<feedrate>] [S<linear>] [U<linear>] [V<linear>] [W<linear>] [X<linear>] [Y<linear>] [Z<feedrate>]
// Parameters
// [A<linear>]	
// Migration Auto Mode. Requires TOOLCHANGE_MIGRATION_FEATURE.
// [B<linear>]	
// Extra resume
// [E<linear>]	
// Extra Prime Length
// [F<linear>]	
// Fan speed (0-255)
// [G<linear>]	
// Fan Time (seconds)
// [L<linear>]	
// Last Migration. Requires TOOLCHANGE_MIGRATION_FEATURE.
// [P<feedrate>]	
// Prime feedrate
// [Q]	
// Prime active tool using TOOLCHANGE_FILAMENT_SWAP settings
// [R<feedrate>]	
// Retract feedrate
// [S<linear>]	
// Swap length
// [U<linear>]	
// Unretract feedrate
// [V<linear>]	
// Enable First Prime on uninitialized Nozzles. Requires TOOLCHANGE_FS_PRIME_FIRST_USED.
// [W<linear>]	
// Enable Park Feature. Requires TOOLCHANGE_PARK - was SINGLENOZZLE_SWAP_PARK.
// [X<linear>]	
// Park X position. Requires TOOLCHANGE_PARK - was SINGLENOZZLE_SWAP_PARK.
// [Y<linear>]	
// Park Y position. Requires TOOLCHANGE_PARK - was SINGLENOZZLE_SWAP_PARK.
// [Z<feedrate>]	
// Z Raise.
  m217Command 
  = c:"M217" !integer ws? params:m217Parameter* {
     var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "2.0.0" };
      const paramVersions = [
        { name: "A", required: "2.0.0" },
        { name: "B", required: "2.0.0" },
        { name: "E", required: "2.0.0" },
        { name: "F", required: "2.0.0" },
        { name: "G", required: "2.0.0" },
        { name: "L", required: "2.0.0" },
        { name: "P", required: "2.0.0" },
        { name: "Q", required: "2.0.0" },
        { name: "R", required: "2.0.0" },
        { name: "S", required: "2.0.0" },
        { name: "U", required: "2.0.0" },
        { name: "V", required: "2.0.0" },
        { name: "W", required: "2.0.0" },
        { name: "X", required: "2.0.0" },
        { name: "Y", required: "2.0.0" },
        { name: "Z", required: "2.0.0" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
    }
  
  m217Parameter
    = p:"A" v:linear ws?{ return makeParameter(p, v, location()); }
    / p:"B" v:linear ws?{ return makeParameter(p, v, location()); }
    / p:"E" v:linear ws?{ return makeParameter(p, v, location()); }
    / p:"F" v:linear ws?{ return makeParameter(p, v, location()); }
    / p:"G" v:linear ws?{ return makeParameter(p, v, location()); }
    / p:"L" v:linear ws?{ return makeParameter(p, v, location()); }
    / p:"P" v:feedrate ws?{ return makeParameter(p, v, location()); }
    / p:"Q" v:flag ws?{ return makeParameter(p, v, location()); }
    / p:"R" v:feedrate ws?{ return makeParameter(p, v, location()); }
    / p:"S" v:linear ws?{ return makeParameter(p, v, location()); }
    / p:"U" v:linear ws?{ return makeParameter(p, v, location()); }
    / p:"V" v:linear ws?{ return makeParameter(p, v, location()); }
    / p:"W" v:linear ws?{ return makeParameter(p, v, location()); }
    / p:"X" v:linear ws?{ return makeParameter(p, v, location()); }
    / p:"Y" v:linear ws?{ return makeParameter(p, v, location()); }
    / p:"Z" v:feedrate ws? { return makeParameter(p, v, location()); }

//M218 - Set Hotend Offset
// M218 [T<index>] [X<offset>] [Y<offset>] [Z<offset>]
// Parameters
// [T<index>]	
// Hotend index. Active extruder by default.
// [X<offset>]	
// Hotend X offset
// [Y<offset>]	
// Hotend Y offset
// [Z<offset>]	
// Hotend Z offset. Requires DUAL_X_CARRIAGE or SWITCHING_NOZZLE.
m218Command 
  = c:"M218" !integer ws? params:m218Parameter* {
     var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        { name: "T", required: "1.0.0" },
        {  name: "X", required: "1.0.0" },
        {  name: "Y", required: "1.0.0" },
        {  name: "Z", required: "1.0.0" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
    }
  
  m218Parameter
    = p:"T" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"X" v:offset ws?{ return makeParameter(p, v, location()); }
    / p:"Y" v:offset ws?{ return makeParameter(p, v, location()); }
    / p:"Z" v:offset ws?{ return makeParameter(p, v, location()); }

//M220 - Set Feedrate Percentage
// M220 [B<flag>] [R<flag>] [S<percent>]
// Parameters
// [B<flag>]	
// Back up current factor
// [R<flag>]	
// Restore the last-saved factor
// [S<percent>]	
// Feedrate percentage
m220Command 
  = c:"M220" !integer ws? params:m220Parameter* {
      var errors = [];
        const duplicates = findDuplicateParameters(params);
        const commandVersion = { required: "1.0.0" };
        const paramVersions = [
          {  name: "B", required: "1.0.0" },
          {  name: "R", required: "1.0.0" },
          {  name: "S", required: "1.0.0" },
        ];
    }
  
  m220Parameter
    = p:"B" v:flag ws?{ return makeParameter(p, v, location()); }
    / p:"R" v:flag ws?{ return makeParameter(p, v, location()); }
    / p:"S" v:percent ws?{ return makeParameter(p, v, location()); }

//M221 - Set Flow Percentage
// M221 S<percent> [T<index>]
// Parameters
// S<percent>	
// Feedrate percentage
// [T<index>]	
// Target extruder (requires multi-extruder). Default is the active extruder.
m221Command 
  = c:"M221" !integer ws? params:m221Parameter* {
      var errors = [];
        const duplicates = findDuplicateParameters(params);
        const commandVersion = { required: "1.0.0" };
        const paramVersions = [
          {  name: "S", required: "1.0.0" },
          {  name: "T", required: "1.0.0" },
        ];
    }

  m221Parameter
    = p:"S" v:percent ws?{ return makeParameter(p, v, location()); }
    / p:"T" v:integer ws?{ return makeParameter(p, v, location()); }

//M226 - Wait for Pin State
// M226 P<pin> [S<state>]
// Parameters
// P<pin>	
// Pin number
// [S<state>]	
// State 0 or 1. Default -1 for inverted.
m226Command 
  = c:"M226" !integer ws? params:m226Parameter* {
      var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        {  name: "P", required: "1.0.0" },
        {  name: "S", required: "1.0.0" },
      ];
return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
    }

  m226Parameter
    = p:"P" v:pin ws?{ return makeParameter(p, v, location()); }
    / p:"S" v:("-1" / "0" / "1") ws?{ return makeParameter(p, v, location()); }

//M240 - Trigger Camera
// M240 [A<offset>] [B<offset>] [D<ms>] [F<feedrate>] [I<pos>] [J<pos>] [P<ms>] [R<length>] [S<feedrate>] [X<pos>] [Y<pos>] [Z<length>]
// Parameters
// [A<offset>]	
// Offset to the X return position. (Requires PHOTO_POSITION)
// [B<offset>]	
// Offset to the Y return position. (Requires PHOTO_POSITION)
// [D<ms>]	
// Duration to hold down the shutter switch. (Requires PHOTO_SWITCH_POSITION and PHOTO_SWITCH_MS)
// [F<feedrate>]	
// Feedrate for the main photo moves. If omitted, the homing feedrate will be used. (Requires PHOTO_POSITION)
// [I<pos>]	
// Shutter switch X position. If omitted, the photo move X position applies. (Requires PHOTO_SWITCH_POSITION)
// [J<pos>]	
// Shutter switch Y position. If omitted, the photo move Y position applies. (Requires PHOTO_SWITCH_POSITION)
// [P<ms>]	
// Delay after pressing the shutter switch. (Requires PHOTO_SWITCH_POSITION and PHOTO_SWITCH_MS)
// [R<length>]	
// Retract/recover length. (Requires PHOTO_POSITION)
// [S<feedrate>]	
// Retract/recover feedrate. (Requires PHOTO_POSITION)
// [X<pos>]	
// Main photo move X position. (Requires PHOTO_POSITION)
// [Y<pos>]	
// Main photo move Y position. (Requires PHOTO_POSITION)
// [Z<length>]	
// Main photo move Z raise. (Requires PHOTO_POSITION)
  m240Command 
  = c:"M240" !integer ws? params:m240Parameter* {
     var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        { name: "A", required: "1.0.0" },
        {  name: "B", required: "1.0.0" },
        {  name: "D", required: "1.0.0" },
        {  name: "F", required: "1.0.0" },
        {  name: "I", required: "1.0.0" },
        {  name: "J", required: "1.0.0" },
        {  name: "P", required: "1.0.0" },
        {  name: "R", required: "1.0.0" },
        {  name: "S", required: "1.0.0" },
        {  name: "X", required: "1.0.0" },
        {  name: "Y", required: "1.0.0" },
        {  name: "Z", required: "1.0.0" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
    }
  
  m240Parameter
    = p:"A" v:offset ws?{ return makeParameter(p, v, location()); }
    / p:"B" v:offset ws?{ return makeParameter(p, v, location()); }
    / p:"D" v:ms ws?{ return makeParameter(p, v, location()); }
    / p:"F" v:feedrate ws?{ return makeParameter(p, v, location()); }
    / p:"I" v:pos ws?{ return makeParameter(p, v, location()); }
    / p:"J" v:pos ws?{ return makeParameter(p, v, location()); }
    / p:"P" v:ms ws?{ return makeParameter(p, v, location()); }
    / p:"R" v:length ws?{ return makeParameter(p, v, location()); }
    / p:"S" v:feedrate ws?{ return makeParameter(p, v, location()); }
    / p:"X" v:pos ws?{ return makeParameter(p, v, location()); }
    / p:"Y" v:pos ws?{ return makeParameter(p, v, location()); }
    / p:"Z" v:length ws?{ return makeParameter(p, v, location()); }

//M250 - LCD Contrast
// M250 [C<contrast>]
// Parameters
// [C<contrast>]	
// Contrast value
m250Command 
  = c:"M250" !integer ws? params:m250Parameter* {
      var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        { name: "C", required: "1.0.0" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
    }
  
  m250Parameter
    = p:"C" v:contrast ws?{ return makeParameter(p, v, location()); }

//M255 - LCD Sleep/Backlight Timeout
// M255 S<minutes>
// Parameters
// S<minutes>	
// Timeout delay in minutes.
m255Command 
  = c:"M255" !integer ws? params:m255Parameter* {
      var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "2.0.9.4" };
      const paramVersions = [
        { name: "S", required: "2.0.9.4" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
    }
  
  m255Parameter
    = p:"S" v:minutes ws?{ return makeParameter(p, v, location()); }

//M256 - LCD Brightness
// M256 [B<brightness>]
// Parameters
// [B<brightness>]	
// Brightness value (0 - 255)
m256Command 
  = c:"M256" !integer ws? params:m256Parameter* {
        var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "2.0.9.2" };
      const paramVersions = [
        { name: "B", required: "2.0.9.2" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
    }
  
  m256Parameter
    = p:"B" v:byte ws?{ return makeParameter(p, v, location()); }

//M260 - I2C Send
// M260 [A<addr>] [B<byte>] [R<flag>] [S<flag>]
// Parameters
// [A<addr>]	
// The bus address to send to
// [B<byte>]	
// The byte to add to the buffer
// [R<flag>]	
// Reset and rewind the I2C buffer
// [S<flag>]	
// Send flag. Flush the buffer to the bus.
m260Command 
  = c:"M260" !integer ws? params:m260Parameter* {
     var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        { name: "A", required: "1.0.0" },
        {  name: "B", required: "1.0.0" },
        {  name: "R", required: "1.0.0" },
        {  name: "S", required: "1.0.0" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
    }
  
  m260Parameter
    = p:"A" v:addr ws?{ return makeParameter(p, v, location()); }
    / p:"B" v:byte ws?{ return makeParameter(p, v, location()); }
    / p:"R" v:flag ws?{ return makeParameter(p, v, location()); }
    / p:"S" v:flag ws?{ return makeParameter(p, v, location()); }

  
//M261 - I2C Request
//M261 A<addr> B<count> [S<0|1|2|3>]
// Parameters
// A<addr>	
// The bus address to request bytes from
// B<count>	
// The number of bytes to request
// [S<0|1|2|3>]  2.0.9.3	
// Output style. Default is 0 (raw echo) if nothing else is given.
// S0: Raw echo
// S1: Bytes (hex)
// S2: 1 or 2 byte value (decimal)
// S3: Bytes (decimal)
m261Command 
  = c:"M261" !integer ws? params:m261Parameter* {
     var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        {  name: "A", required: "1.0.0" },
        {  name: "B", required: "1.0.0" },
        {  name: "S", required: "2.0.9.3" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
    }
  
  m261Parameter
    = p:"A" v:addr ws?{ return makeParameter(p, v, location()); }
    / p:"B" v:byte ws?{ return makeParameter(p, v, location()); }
    / p:"S" v:("0" / "1" / "2" / "3" ) ws?{ return makeParameter(p, v, location()); }

//M280 - Servo Position
// M280 P<index> S<pos>
// Parameters
// P<index>	
// Servo index to set or get
// S<pos>	
// Servo position to set. Omit to read the current position.
m280Command 
  = c:"M280" !integer ws? params:m280Parameter* {
     var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        { name: "P", required: "1.0.0" },
        {  name: "S", required: "1.0.0" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
    }
  
  m280Parameter
    = p:"P" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"S" v:pos ws?{ return makeParameter(p, v, location()); }

//M281 - Edit Servo Angles
// M281 [L<degrees>] P<index> [U<degrees>]
// Parameters
// [L<degrees>]	
// Deploy angle in degrees.
// P<index>	
// Servo index to update / report.
// [U<degrees>]	
// Stow angle in degrees.
m281Command 
  = c:"M281" !integer ws? params:m281Parameter* {
     var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "2.0.0" };
      const paramVersions = [
        { name: "L", required: "2.0.0" },
        { name: "P", required: "2.0.0" },
        {  name: "U", required: "2.0.0" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
    }
  
  m281Parameter
    = p:"L" v:degrees ws?{ return makeParameter(p, v, location()); }
    / p:"P" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"U" v:degrees ws?{ return makeParameter(p, v, location()); }

//M282 - Detach Servo
// M282 P<index>
// Parameters
// P<index>	
// Index of the servo to detach.
m282Command 
  = c:"M282" !integer ws? params:m282Parameter* {
     var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "2.0.9.2" };
      const paramVersions = [
        {  name: "P", required: "2.0.9.2" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
    }
  
  m282Parameter
    = p:"P" v:integer ws?{ return makeParameter(p, v, location()); }

//M290 - Babystep
// M290 [P<bool>] [S<pos>] [X<pos>] [Y<pos>] [Z<pos>]
// Parameters
// [P<bool>]	
// Use P0 to leave the Probe Z Offset unaffected. (Requires BABYSTEP_ZPROBE_OFFSET)
// [S<pos>]	
// Alias for Z
// [X<pos>]	
// A distance on the X axis
// [Y<pos>]	
// A distance on the Y axis
// [Z<pos>]	
// A distance on the Z axis
m290Command 
  = c:"M290" !integer ws? params:m290Parameter* {
      var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.1.7" };
      const paramVersions = [
        { name: "P", required: "1.1.7" },
        {  name: "S", required: "1.1.7" },
        {  name: "X", required: "1.1.7" },
        {  name: "Y", required: "1.1.7" },
        {  name: "Z", required: "1.1.7" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
    }
  
  m290Parameter
    = p:"P" v:bool ws?{ return makeParameter(p, v, location()); }
    / p:"S" v:pos ws?{ return makeParameter(p, v, location()); }
    / p:"X" v:pos ws?{ return makeParameter(p, v, location()); }
    / p:"Y" v:pos ws?{ return makeParameter(p, v, location()); }
    / p:"Z" v:pos ws?{ return makeParameter(p, v, location()); }


//M300 - Play Tone
// M300 [P<ms>] [S<Hz>]
// Parameters
// [P<ms>]	
// Duration (1ms)
// [S<Hz>]	
// Frequency (260Hz)
m300Command 
  = c:"M300" !integer ws? params:m300Parameter* {
      var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        { name: "P", required: "1.0.0" },
        {  name: "S", required: "1.0.0" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
    }
  
  m300Parameter
    = p:"P" v:ms ws?{ return makeParameter(p, v, location()); }
    / p:"S" v:integer ws?{ return makeParameter(p, v, location()); }

  
//M301 - Set Hotend PID
// M301 [C<value>] [D<value>] [E<index>] [F<value>] [I<value>] [L<value>] [P<value>]
// Parameters
// [C<value>]	
// C term (requires PID_EXTRUSION_SCALING)
// [D<value>]	
// Derivative value
// [E<index>]	
// Extruder index to set. Default 0.
// [F<value>]	
// F term (requires PID_FAN_SCALING)
// [I<value>]	
// Integral value
// [L<value>]	
// Extrusion scaling queue length (requires PID_EXTRUSION_SCALING)
// [P<value>]	
// Proportional value
m301Command 
  = c:"M301" !integer ws? params:m301Parameter* {
     var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        { name: "C", required: "1.0.0" },
        {  name: "D", required: "1.0.0" },
        {  name: "E", required: "1.0.0" },
        {  name: "F", required: "1.0.0" },
        {  name: "I", required: "1.0.0" },
        {  name: "L", required: "1.0.0" },
        {  name: "P", required: "1.0.0" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
    }
  
  m301Parameter
    = p:"C" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"D" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"E" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"F" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"I" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"L" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"P" v:integer ws?{ return makeParameter(p, v, location()); }

//M302 - Cold Extrude
// M302 [P<flag>] [S<temp>]
// Parameters
// [P<flag>]	
// Flag to allow extrusion at any temperature
// [S<temp>]	
// Minimum temperature for safe extrusion
m302Command 
  = c:"M302" !integer ws? params:m302Parameter* {
      var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        { name: "P", required: "1.0.0" },
        {  name: "S", required: "1.0.0" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
    }

  m302Parameter
    = p:"P" v:flag ws?{ return makeParameter(p, v, location()); }
    / p:"S" v:temp ws?{ return makeParameter(p, v, location()); }

//M303 - PID autotune
// M303 C<count> D<action> D<flag> [E<index>] S<temp> U<flag>
// Parameters
// C<count>	
// Cycles. At least 3 cycles are required. Default 5.
// D<action>	
// Toggle PID debug output on / off (and take no further action). (Requires PID_DEBUG)
// D<flag>	
// Toggle activation of PID_DEBUG output.
// [E<index>]	
// Hotend index (-1 for heated bed). Default 0.
// S<temp>	
// Target temperature
// U<flag>	
// Use PID result. (Otherwise just print it out.)
m303Command 
  = c:"M303" !integer ws? params:m303Parameter* {
      var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        { name: "C", required: "1.0.0" },
        {  name: "D", required: "1.0.0" },
        {  name: "E", required: "1.0.0" },
        {  name: "S", required: "1.0.0" },
        {  name: "U", required: "1.0.0" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
    }
  
  m303Parameter
    = p:"C" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"D" v:bool ws?{ return makeParameter(p, v, location()); }
    / p:"D" v:flag ws?{ return makeParameter(p, v, location()); }
    / p:"E" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"S" v:temp ws?{ return makeParameter(p, v, location()); }
    / p:"U" v:flag ws?{ return makeParameter(p, v, location()); }

//M304 - Set Bed PID
// M304 [D<value>] [I<value>] [P<value>]
// Parameters
// [D<value>]	
// Derivative value
// [I<value>]	
// Integral value
// [P<value>]	
// Proportional value
m304Command 
  = c:"M304" !integer ws? params:m304Parameter* {
     var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        { name: "X", required: "1.0.0" },
        { name: "Y", required: "1.0.0" },
        { name: "Z", required: "1.0.0" },
        { name: "E", required: "1.0.0" },
        { name: "F", required: "1.0.0" },
        { name: "S", required: "1.0.0" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
    }
  
  m304Parameter
    = p:"D" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"I" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"P" v:integer ws?{ return makeParameter(p, v, location()); }

//M305 - User Thermistor Parameters
// M305 [B<beta>] [C<coeff>] [P<index>] [R<ohm>] [T<ohms>]
// Parameters
// [B<beta>]	
// Thermistor “beta” value
// [C<coeff>]	
// Steinhart-Hart Coefficient ‘C’
// [P<index>]	
// Thermistor table index
// [R<ohm>]	
// Pullup resistor value
// [T<ohms>]	
// Resistance at 25C
m305Command 
  = c:"M305" !integer ws? params:m305Parameter* {
      var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        { name: "B", required: "1.0.0" },
        {  name: "C", required: "1.0.0" },
        {  name: "P", required: "1.0.0" },
        {  name: "R", required: "1.0.0" },
        {  name: "T", required: "1.0.0" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
    }
  
  m305Parameter
    = p:"B" v:beta ws?{ return makeParameter(p, v, location()); }
    / p:"C" v:coeff ws?{ return makeParameter(p, v, location()); }
    / p:"P" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"R" v:ohm ws?{ return makeParameter(p, v, location()); }
    / p:"T" v:ohm ws?{ return makeParameter(p, v, location()); }


//M306 - Model predictive temperature control
// M306 [A<value>] [C<value>] [E<index>] [F<value>] [H<value>] [P<value>] [R<value>] [T]
// Parameters
// [A<value>]	
// Ambient heat transfer coefficient (no fan).
// [C<value>]	
// Heatblock Capacity (joules/kelvin)
// [E<index>]	
// Extruder index. If omitted, the command applies to the active extruder.
// [F<value>]	
// Ambient heat transfer coefficient (fan on full).
// [H<value>]	
// Filament Heat Capacity (joules/kelvin/mm)
// [P<value>]	
// Heater power in watts
// [R<value>]	
// Sensor responsiveness (= transfer coefficient / heat capacity).
// [T]	
// Autotune the selected extruder.
m306Command 
  = c:"M306" !integer ws? params:m306Parameter* {
      var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "2.0.9.4" };
      const paramVersions = [
        { name: "A", required: "2.0.9.4" },
        {  name: "C", required: "2.0.9.4" },
        {  name: "E", required: "2.0.9.4" },
        {  name: "F", required: "2.0.9.4" },
        {  name: "H", required: "2.0.9.4" },
        {  name: "P", required: "2.0.9.4" },
        {  name: "R", required: "2.0.9.4" },
        {  name: "T", required: "2.0.9.4" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
    }
  
  m306Parameter
    = p:"A" v:float ws?{ return makeParameter(p, v, location()); }
    / p:"C" v:float ws?{ return makeParameter(p, v, location()); }
    / p:"E" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"F" v:float ws?{ return makeParameter(p, v, location()); }
    / p:"H" v:float ws?{ return makeParameter(p, v, location()); }
    / p:"P" v:float ws?{ return makeParameter(p, v, location()); }
    / p:"R" v:float ws?{ return makeParameter(p, v, location()); }
    / "T" ws?{ return makeParameter("T", true, location()); }


//M350 - Set micro-stepping
// M350 [B<1|2|4|8|16>] [E<1|2|4|8|16>] [S<1|2|4|8|16>] [X<1|2|4|8|16>] [Y<1|2|4|8|16>] [Z<1|2|4|8|16>]
// Parameters
// [B<1|2|4|8|16>]	
// Set micro-stepping for the 5th stepper driver.
// [E<1|2|4|8|16>]	
// Set micro-stepping for the E0 stepper driver.
// [S<1|2|4|8|16>]	
// Set micro-stepping for all 5 stepper drivers.
// [X<1|2|4|8|16>]	
// Set micro-stepping for the X stepper driver.
// [Y<1|2|4|8|16>]	
// Set micro-stepping for the Y stepper driver.
// [Z<1|2|4|8|16>]	
// Set micro-stepping for the Z stepper driver.
  m350Command 
  = c:"M350" !integer ws? params:m350Parameter* {
     var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        { name: "B", required: "1.0.0" },
        {  name: "E", required: "1.0.0" },
        {  name: "S", required: "1.0.0" },
        {  name: "X", required: "1.0.0" },
        {  name: "Y", required: "1.0.0" },
        {  name: "Z", required: "1.0.0" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
    }
  
  m350Parameter
    = p:"B" v:("1" / "2" / "4" / "8" / "16") ws?{ return makeParameter(p, v, location()); }
    / p:"E" v:("1" / "2" / "4" / "8" / "16") ws?{ return makeParameter(p, v, location()); }
    / p:"S" v:("1" / "2" / "4" / "8" / "16") ws?{ return makeParameter(p, v, location()); }
    / p:"X" v:("1" / "2" / "4" / "8" / "16") ws?{ return makeParameter(p, v, location()); }
    / p:"Y" v:("1" / "2" / "4" / "8" / "16") ws?{ return makeParameter(p, v, location()); }
    / p:"Z" v:("1" / "2 " / "4" / "8" / "16") ws?{ return makeParameter(p, v, location()); }

//M351 - Set Microstep Pins
// M351 [B<0|1>] [E<0|1>] S<1|2> [X<0|1>] [Y<0|1>] [Z<0|1>]
// Parameters
// [B<0|1>]	
// Set the MS1/2 pin for the 5th stepper driver.
// [E<0|1>]	
// Set the MS1/2 pin for the E stepper driver.
// S<1|2>	
// Select the pin to set for all specified axes.
// S1: Select pin MS1 for all axes being set.
// S2: Select pin MS2 for all axes being set.
// [X<0|1>]	
// Set the MS1/2 pin for the X stepper driver.
// [Y<0|1>]	
// Set the MS1/2 pin for the Y stepper driver.
// [Z<0|1>]	
// Set the MS1/2 pin for the Z stepper driver.
m351Command 
  = c:"M351" !integer ws? params:m351Parameter* {
     var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        { name: "B", required: "1.0.0" },
        {  name: "E", required: "1.0.0" },
        {  name: "S", required: "1.0.0" },
        {  name: "X", required: "1.0.0" },
        {  name: "Y", required: "1.0.0" },
        {  name: "Z", required: "1.0.0" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
  }

  m351Parameter
    = p:"B" v:("0" / "1") ws?{ return makeParameter(p, v, location()); }
    / p:"E" v:("0" / "1") ws?{ return makeParameter(p, v, location()); }
    / p:"S" v:("1" / "2") ws?{ return makeParameter(p, v, location()); }
    / p:"X" v:("0" / "1") ws?{ return makeParameter(p, v, location()); }
    / p:"Y" v:("0" / "1") ws?{ return makeParameter(p, v, location()); }
    / p:"Z" v:("0" / "1") ws?{ return makeParameter(p, v, location()); }

//M355 - Case Light Control
// M355 [P<byte>] [S<bool>]
// Parameters
// [P<byte>]	
// Set the brightness factor from 0 to 255.
// [S<bool>]	
// Turn the case light on or off.
m355Command 
  = c:"M355" !integer ws? params:m355Parameter* {
     var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        { name: "P", required: "1.0.0" },
        {  name: "S", required: "1.0.0" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
  }

  m355Parameter
    = p:"P" v:byte ws?{ return makeParameter(p, v, location()); }
    / p:"S" v:bool ws?{ return makeParameter(p, v, location()); }

//M380 - Activate Solenoid
// M380 [S<index>]
// Parameters
// [S<index>]  2.0.0 MANUAL_SOLENOID_CONTROL	
// Solenoid index (Requires MANUAL_SOLENOID_CONTROL)
m380Command 
  = c:"M380" !integer ws? params:m380Parameter* {
     var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "2.0.0" };
      const paramVersions = [
        { name: "S", required: "2.0.0" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
  }

  m380Parameter
    = p:"S" v:integer ws?{ return makeParameter(p, v, location()); }

//M381 - Deactivate Solenoids
// M381 [S<index>]
// Parameters
// [S<index>]  2.0.0 MANUAL_SOLENOID_CONTROL	
// Solenoid index (Requires MANUAL_SOLENOID_CONTROL)
m381Command 
  = c:"M381" !integer ws? params:m381Parameter* {
      var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "2.0.0" };
      const paramVersions = [
        { name: "S", required: "2.0.0" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
  }

  m381Parameter
    = p:"S" v:integer ws?{ return makeParameter(p, v, location()); }

//M401 - Deploy Probe
// M401 [H] [S<bool>]
// Parameters
// [H]  2.0.9.4 BLTOUCH_HS_MODE	
// Report the current BLTouch High Speed (HS) Mode state and exit.
// [S<bool>]  2.0.9.3 BLTOUCH_HS_MODE	
// Set the BLTouch High Speed (HS) Mode state and exit without deploy.
m401Command 
  = c:"M401" !integer ws? params:m401Parameter* {
     var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        { name: "H", required: "2.0.9.4" },
        {  name: "S", required: "2.0.9.3" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
  }

  m401Parameter
    = "H" ws?{ return makeParameter("H", true, location()); }
    / p:"S" v:bool ws?{ return makeParameter(p, v, location()); }

  
//M403 - MMU2 Filament Type
// M403 E<index> F<0|1|2>
// Parameters
// E<index>	
// The MMU2 slot [0..4] to set the material type for
// F<0|1|2>	
// The filament type.
// F0: Default (PLA, PETG, …)
// F1: Flexible filament
// F2: PVA
m403Command 
  = c:"M403" !integer ws? params:m403Parameter* {
     var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        { name: "E", required: "1.0.0" },
        {  name: "F", required: "1.0.0" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
  }

  m403Parameter
    = p:"E" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"F" v:("0" / "1" / "2") ws?{ return makeParameter(p, v, location()); }

 //M404 - Set Filament Diameter
// M404 [W<linear>]
// Parameters
// [W<linear>]	
// The new nominal width value
m404Command 
  = c:"M404" !integer ws? params:m404Parameter* {
     var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        { name: "W", required: "1.0.0" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
  }

  m404Parameter
    = p:"W" v:linear ws?{ return makeParameter(p, v, location()); }

//M405 - Filament Width Sensor On
// M405 [D<cm>]
// Parameters
// [D<cm>]	
// Distance from measurement point to hot end. If not given, the previous value will be used. The default startup value is set by MEASUREMENT_DELAY_CM.
m405Command 
  = c:"M405" !integer ws? params:m405Parameter* {
     var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        { name: "D", required: "1.0.0" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
  }

  m405Parameter
    = p:"D" v:cm ws?{ return makeParameter(p, v, location()); }

//M412 - Filament Runout
// M412 [D<linear>] [H<bool>] [R<bool>] [S<bool>]
// Parameters
// [D<linear>]	
// Set the filament runout distance.
// [H<bool>]	
// Flag to enable or disable host handling of a filament runout.
// [R<bool>]	
// Flag to reset the filament runout sensor. Not needed with S.
// [S<bool>]	
// Flag to enable or disable Filament Runout Detection. If omitted, the current enabled state will be reported.
m412Command 
  = c:"M412" !integer ws? params:m412Parameter* {
     var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "2.0.0" };
      const paramVersions = [
        { name: "D", required: "2.0.0" },
        {  name: "H", required: "2.0.0" },
        {  name: "R", required: "2.0.0" },
        {  name: "S", required: "2.0.0" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
  }

  m412Parameter
    = p:"D" v:linear ws?{ return makeParameter(p, v, location()); }
    / p:"H" v:bool ws?{ return makeParameter(p, v, location()); }
    / p:"R" v:bool ws?{ return makeParameter(p, v, location()); }
    / p:"S" v:bool ws?{ return makeParameter(p, v, location()); }

// M413 - Power-loss Recovery
// M413 [S<bool>]
// Parameters
// [S<bool>]	
// Flag to enable or disable Power-loss Recovery. If omitted, the current enabled state will be reported.
m413Command 
  = c:"M413" !integer ws? params:m413Parameter* {
     var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "2.0.0" };
      const paramVersions = [
        { name: "S", required: "2.0.0" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
  }

  m413Parameter
    = p:"S" v:bool ws?{ return makeParameter(p, v, location()); }

//M420 - Bed Leveling State
// M420 [C<bool>] [L<int>] [S<bool>] [T<0|1|4>] [V<bool>] [Z<linear>]
// Parameters
// [C<bool>]	
// Center the mesh on the mean of the lowest and highest points
// [L<int>]	
// Load mesh from EEPROM index (Requires AUTO_BED_LEVELING_UBL and EEPROM_SETTINGS)
// [S<bool>]	
// Set enabled or disabled. A valid mesh is required to enable bed leveling. If the mesh is invalid / incomplete leveling will not be enabled.
// [T<0|1|4>]	
// Format to print the mesh data
// T0: Human readable
// T1: CSV
// T4: Compact
// [V<bool>]	
// Verbose: Print the stored mesh / matrix data
// [Z<linear>]	
// Set Z fade height (Requires ENABLE_LEVELING_FADE_HEIGHT)
// With Fade enabled, bed leveling correction is gradually reduced as the nozzle gets closer to the Fade height. Above the Fade height no bed leveling compensation is applied at all, so movement is machine true.
// Set to 0 to disable fade, and leveling compensation will be fully applied to all layers of the print.
m420Command 
  = c:"M420" !integer ws? params:m420Parameter* {
     var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        { name: "C", required: "1.0.0" },
        {  name: "L", required: "1.0.0" },
        {  name: "S", required: "1.0.0" },
        {  name: "T", required: "1.0.0" },
        {  name: "V", required: "1.0.0" },
        {  name: "Z", required: "1.0.0" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
  }

  m420Parameter
    = p:"C" v:bool ws?{ return makeParameter(p, v, location()); }
    / p:"L" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"S" v:bool ws?{ return makeParameter(p, v, location()); }
    / p:"T" v:("0" / "1" / "4") ws?{ return makeParameter(p, v, location()); }
    / p:"V" v:bool ws?{ return makeParameter(p, v, location()); }
    / p:"Z" v:linear ws?{ return makeParameter(p, v, location()); }

//M421 - Set Mesh Value
// M421 [C<bool>] [I<int>] [J<int>] [N<bool>] [Q<linear>] [X<linear>] [Y<linear>] [Z<linear>]
// Parameters
// [C<bool>]	
// Set the mesh point closest to the current nozzle position (AUTO_BED_LEVELING_UBL only)
// [I<int>]	
// X index into the mesh array
// [J<int>]	
// Y index into the mesh array
// [N<bool>]	
// Set the mesh point to undefined (AUTO_BED_LEVELING_UBL only)
// [Q<linear>]	
// A value to add to the existing Z value
// [X<linear>]	
// X position (which should be very close to a grid line) (MESH_BED_LEVELING only)
// [Y<linear>]	
// Y position (which should be very close to a grid line) (MESH_BED_LEVELING only)
// [Z<linear>]	
// The new Z value to set
m421Command 
  = c:"M421" !integer ws? params:m421Parameter* {
      var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        { name: "C", required: "1.0.0" },
        {  name: "I", required: "1.0.0" },
        {  name: "J", required: "1.0.0" },
        {  name: "N", required: "1.0.0" },
        {  name: "Q", required: "1.0.0" },
        {  name: "X", required: "1.0.0" },
        {  name: "Y", required: "1.0.0" },
        {  name: "Z", required: "1.0.0" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
  }

  m421Parameter
    = p:"C" v:bool ws?{ return makeParameter(p, v, location()); }
    / p:"I" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"J" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"N" v:bool ws?{ return makeParameter(p, v, location()); }
    / p:"Q" v:linear ws?{ return makeParameter(p, v, location()); }
    / p:"X" v:linear ws?{ return makeParameter(p, v, location()); }
    / p:"Y" v:linear ws?{ return makeParameter(p, v, location()); }
    / p:"Z" v:linear ws?{ return makeParameter(p, v, location()); }

//M422 - Set Z Motor XY
// M422 [R] [S<index>] [W<index>] [X<linear>] [Y<linear>]
// Parameters
// [R]	
// Reset alignment and known points to the defaults. This will also be done by M502.
// [S<index>]	
// One-based index of a Z-Stepper whose probing-point will be set.
// [W<index>] Z_STEPPER_ALIGN_STEPPER_XY	
// One-based index of a Z-Stepper whose known position will be set.
// [X<linear>]	
// X position
// [Y<linear>]	
// Y position
m422Command 
  = c:"M422" !integer ws? params:m422Parameter* {
     var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "2.0.4" };
      const paramVersions = [
        { name: "R", required: "2.0.4" },
        {  name: "S", required: "2.0.4" },
        {  name: "W", required: "2.0.4" },
        {  name: "X", required: "2.0.4" },
        {  name: "Y", required: "2.0.4" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
  }

  m422Parameter
    = "R" ws?{ return makeParameter("R", true, location()); }
    / p:"S" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"W" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"X" v:linear ws?{ return makeParameter(p, v, location()); }
    / p:"Y" v:linear ws?{ return makeParameter(p, v, location()); }

//M423 - X Twist Compensation
// M423 [A<linear>] [I<linear>] [R] [X<index>] [Z<index>]
// Parameters
// [A<linear>]	
// Set the X-Axis Twist Compensation starting X position.
// [I<linear>]	
// Set the X-Axis Twist Compensation X-spacing.
// [R]	
// Reset the Twist Compensation array to the configured default values.
// [X<index>]	
// Zero-based index into the Twist Compensation array. Requires a Z value.
// [Z<index>]	
// A Z-offset value to set in the Twist Compensation array. Requires an X index.
m423Command 
  = c:"M423" !integer ws? params:m423Parameter* {
      var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "2.0.9.4" };
      const paramVersions = [
        { name: "A", required: "2.0.9.4" },
        {  name: "I", required: "2.0.9.4" },
        {  name: "R", required: "2.0.9.4" },
        {  name: "X", required: "2.0.9.4" },
        {  name: "Z", required: "2.0.9.4" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    

  }

  m423Parameter
    = p:"A" v:linear ws?{ return makeParameter(p, v, location()); }
    / p:"I" v:linear ws?{ return makeParameter(p, v, location()); }
    / "R" ws?{ return makeParameter("R", true, location()); }
    / p:"X" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"Z" v:integer ws?{ return makeParameter(p, v, location()); }

//M425 - Backlash compensation
// M425 [F<value>] [S<linear>] [X<linear>] [Y<linear>] [Z<linear>] [Z]
// Parameters
// [F<value>]	
// Enable or disables backlash correction, or sets an intermediate fade-out (0.0 = none; 1.0 = 100%)
// [S<linear>]	
// Distance over which backlash correction is spread
// [X<linear>]	
// Set the backlash distance on X (mm; 0 to disable)
// [Y<linear>]	
// Set the backlash distance on Y (mm; 0 to disable)
// [Z<linear>]	
// Set the backlash distance on Z (mm; 0 to disable)
// [Z]	
// When MEASURE_BACKLASH_WHEN_PROBING is enabled, loads the measured backlash into the backlash distance parameter
m425Command 
  = c:"M425" !integer ws? params:m425Parameter* {
      var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        { name: "F", required: "1.0.0" },
        {  name: "S", required: "1.0.0" },
        {  name: "X", required: "1.0.0" },
        {  name: "Y", required: "1.0.0" },
        {  name: "Z", required: "1.0.0" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
  }

  m425Parameter
    = p:"F" v:float ws?{ return makeParameter(p, v, location()); }
    / p:"S" v:linear ws?{ return makeParameter(p, v, location()); }
    / p:"X" v:linear ws?{ return makeParameter(p, v, location()); }
    / p:"Y" v:linear ws?{ return makeParameter(p, v, location()); }
    / p:"Z" v:linear ws?{ return makeParameter(p, v, location()); }
    / "Z" ws?{ return makeParameter("Z", true, location()); }
  
//M430 - Power Monitor
// M430 [I<bool>] [V<bool>] [W<bool>]
// Parameters
// [I<bool>]	
// display current (A) on LCD
// [V<bool>]	
// toggle display voltage (V) on LCD
// [W<bool>]	
// display power/watts (W) on LCD
m430Command 
  = c:"M430" !integer ws? params:m430Parameter* {
      var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        {  name: "I", required: "1.0.0" },
        {  name: "V", required: "1.0.0" },
        {  name: "W", required: "1.0.0" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
  }

  m430Parameter
    = p:"I" v:bool ws?{ return makeParameter(p, v, location()); }
    / p:"V" v:bool ws?{ return makeParameter(p, v, location()); }
    / p:"W" v:bool ws?{ return makeParameter(p, v, location()); }

//M486 - Cancel Objects
// M486 [C<flag>] [P<index>] [S<index>] [T<count>] [U<index>]
// Parameters
// [C<flag>]	
// Cancel the current object.
// [P<index>]	
// Cancel the object with the given index.
// [S<index>]	
// Set the index of the current object. If the object with the given index has been canceled, this will cause the firmware to skip to the next object. The value -1 is used to indicate something that isn’t an object and shouldn’t be skipped.
// [T<count>]	
// Reset the state and set the number of objects.
// [U<index>]	
// Un-cancel the object with the given index. This command will be ignored if the object has already been skipped.
m486Command 
  = c:"M486" !integer ws? params:m486Parameter* {
     var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        { name: "C", required: "1.0.0" },
        {  name: "P", required: "1.0.0" },
        {  name: "S", required: "1.0.0" },
        {  name: "T", required: "1.0.0" },
        {  name: "U", required: "1.0.0" },
      ];
return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
  }

  m486Parameter
    = p:"C" v:flag ws?{ return makeParameter(p, v, location()); }
    / p:"P" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"S" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"T" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"U" v:integer ws?{ return makeParameter(p, v, location()); }

//M503 - Report Settings
// M503 [C] [S]
// Parameters
// [C]  2.0.9.3 CONFIGURATION_EMBEDDING	
// Save the embedded configuration ZIP file to the SD Card or Flash Drive.
// [S]	
// Detailed output flag. (true if omitted.)
m503Command 
  = c:"M503" !integer ws? params:m503Parameter* {
      var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        { name: "C", required: "2.0.9.3" },
        {  name: "S", required: "1.0.0" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
  }

  m503Parameter
    = "C" ws?{ return makeParameter("C", true, location()); }
    / "S" ws?{ return makeParameter("S", true, location()); }

//M511 - Unlock Machine
// M511 P<passcode>
// Parameters
// P<passcode>	
// The passcode to try.
m511Command 
  = c:"M511" !integer ws? params:m511Parameter* {
     var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "2.0.6.1" };
      const paramVersions = [
        { name: "P", required: "2.0.6.1" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    

  }

  m511Parameter
    = p:"P" v:passcode ws?{ return makeParameter(p, v, location()); }

//M512 - Set Passcode
// M512 P<password> [S<password>]
// Parameters
// P<password>	
// Current passcode. This must be correct to clear or change the passcode.
// [S<password>]	
// If S is included the new passcode will be set to this value.
m512Command 
  = c:"M512" !integer ws? params:m512Parameter* {
     var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "2.0.6.1" };
      const paramVersions = [
        { name: "P", required: "2.0.6.1" },
        {  name: "S", required: "2.0.6.1" },
      ];
return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
  }

  m512Parameter
    = p:"P" v:passcode ws?{ return makeParameter(p, v, location()); }
    / p:"S" v:passcode ws?{ return makeParameter(p, v, location()); }

//M540 - Endstops Abort SD
// M540 S<flag>
// Parameters
// S<flag>	
// Whether (1) or not (0) to abort SD printing on endstop hit.
m540Command 
  = c:"M540" !integer ws? params:m540Parameter* {
     var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        { name: "S", required: "1.0.0" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
  }

  m540Parameter
    = p:"S" v:flag ws?{ return makeParameter(p, v, location()); }

//M569 - Set TMC stepping mode
//M569 [E] [I<index>] [T<index>] [X] [Y] [Z]
// Parameters
// [E]	
// Stepping mode for the E0 stepper
// [I<index>]	
// Index for multiple steppers. Use I1 for X2, Y2, and/or Z2, and I2 for Z3.
// [T<index>]	
// Index (tool) number for the E axis. If not specified, the E0 extruder.
// [X]	
// Stepping mode for the X stepper
// [Y]	
// Stepping mode for the Y stepper
// [Z]	
// Stepping mode for the Z stepper
m569Command 
  = c:"M569" !integer ws? params:m569Parameter* {
     var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "2.0.0" };
      const paramVersions = [
        { name: "E", required: "2.0.0" },
        {  name: "I", required: "2.0.0" },
        {  name: "T", required: "2.0.0" },
        {  name: "X", required: "2.0.0" },
        {  name: "Y", required: "2.0.0" },
        {  name: "Z", required: "2.0.0" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    

  }

  m569Parameter
    = "E" ws?{ return makeParameter("E", true, location()); }
    / p:"I" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"T" v:integer ws?{ return makeParameter(p, v, location()); }
    / "X" ws?{ return makeParameter("X", true, location()); }
    / "Y" ws?{ return makeParameter("Y", true, location()); }
    / "Z" ws?{ return makeParameter("Z", true, location()); }

//M575 - Serial baud rate
// M575 B<baud> [P]
// Parameters
// B<baud>	
// The baud rate to set. Permitted values are:
// 2400 (24)
// 9600 (96)
// 19200 (19, 192)
// 38400 (38, 384)
// 57600 (57, 576)
// 115200 (115, 1152)
// 250000 (250)
// 500000 (500)
// 1000000
// [P]	
// Serial Port index. Omit for all serial ports.
m575Command 
  = c:"M575" !integer ws? params:m575Parameter* {
     var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        { name: "B", required: "1.0.0" },
        {  name: "P", required: "1.0.0" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
  }

  m575Parameter
    = p:"B" v:("2400" / "9600" / "19200" / "38400" / "57600" / "115200" / "250000" / "5000000" / "1000000") ws?{ return makeParameter(p, v, location()); }
    / "P" ws?{ return makeParameter("P", true, location()); }


//M593 - Input Shaping
// M593 [D<zeta>] [F<hertz>] [X] [Y]
// Parameters
// [D<zeta>]	
// Set the zeta/damping factor for the specified axes. If X and Y are omitted, both will be set.
// [F<hertz>]	
// Set the damping frequency for the specified axes. If X and Y are omitted, both will be set.
// [X]	
// Flag to set the X axis value. If X and Y are omitted, both will be set.
// [Y]	
// Flag to set the Y axis value. If X and Y are omitted, both will be set.
m593Command 
  = c:"M593" !integer ws? params:m593Parameter* {
      var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "2.1.2" };
      const paramVersions = [
        { name: "D", required: "2.1.2" },
        {  name: "F", required: "2.1.2" },
        {  name: "X", required: "2.1.2" },
        {  name: "Y", required: "2.1.2" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
  }

  m593Parameter
    = p:"D" v:zeta ws?{ return makeParameter(p, v, location()); }
    / p:"F" v:hertz ws?{ return makeParameter(p, v, location()); }
    / "X" ws?{ return makeParameter("X", true, location()); }
    / "Y" ws?{ return makeParameter("Y", true, location()); }

//M600 - Filament Change
// M600 [B<beeps>] [E<pos>] [L<pos>] [R<temp>] [T<index>] [U<pos>] [X<pos>] [Y<pos>] [Z<pos>]
// Parameters
// [B<beeps>]	
// Number of beeps to alert user of filament change (default FILAMENT_CHANGE_ALERT_BEEPS)
// [E<pos>]	
// Retract before moving to change position (negative, default PAUSE_PARK_RETRACT_LENGTH)
// [L<pos>]	
// Load length, longer for bowden (negative)
// [R<temp>]	
// Resume temperature. (AUTOTEMP: the min auto-temperature.)
// [T<index>]	
// Target extruder
// [U<pos>]	
// Amount of retraction for unload (negative)
// [X<pos>]	
// X position for filament change
// [Y<pos>]	
// Y position for filament change
// [Z<pos>]	
// Z relative lift for filament change position
m600Command 
  = c:"M600" !integer ws? params:m600Parameter* {
      var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.1.0" };
      const paramVersions = [
        { name: "B", required: "1.1.0" },
        {  name: "E", required: "1.1.0" },
        {  name: "L", required: "1.1.0" },
        {  name: "R", required: "1.1.0" },
        {  name: "T", required: "1.1.0" },
        {  name: "U", required: "1.1.0" },
        {  name: "X", required: "1.1.0" },
        {  name: "Y", required: "1.1.0" },
        {  name: "Z", required: "1.1.0" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    

  }

  m600Parameter
    = p:"B" v:beeps ws?{ return makeParameter(p, v, location()); }
    / p:"E" v:pos ws?{ return makeParameter(p, v, location()); }
    / p:"L" v:pos ws?{ return makeParameter(p, v, location()); }
    / p:"R" v:temp ws?{ return makeParameter(p, v, location()); }
    / p:"T" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"U" v:pos ws?{ return makeParameter(p, v, location()); }
    / p:"X" v:pos ws?{ return makeParameter(p, v, location()); }
    / p:"Y" v:pos ws?{ return makeParameter(p, v, location()); }
    / p:"Z" v:pos ws?{ return makeParameter(p, v, location()); }

//M603 - Configure Filament Change
// M603 [L<pos>] [T<index>] [U<pos>]
// Parameters
// [L<pos>]	
// Load length, longer for bowden (negative)
// [T<index>]	
// Target extruder
// [U<pos>]	
// Amount of retraction for unload (negative)
m603Command 
  = c:"M603" !integer ws? params:m603Parameter* {
      var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.1.0" };
      const paramVersions = [
        { name: "L", required: "1.1.0" },
        {  name: "T", required: "1.1.0" },
        {  name: "U", required: "1.1.0" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
  }

  m603Parameter
    = p:"L" v:pos ws?{ return makeParameter(p, v, location()); }
    / p:"T" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"U" v:pos ws?{ return makeParameter(p, v, location()); }

//M605 - Multi Nozzle Mode
// M605 [E<index>] [P<mask>] [R<temp>] S<0|1|2|3> [X<linear>]
// Parameters
// [E<index>]	
// Last nozzle index to include in the duplication set. 0 disables duplication. (Requires MULTI_NOZZLE_DUPLICATION)
// [P<mask>]	
// Bit-mask of nozzles to include in the duplication set. 0 disables duplication. Bit 1 is E0, Bit 2 is E1 … Bit n is E(n-1). (Requires MULTI_NOZZLE_DUPLICATION)
// [R<temp>]	
// Temperature difference to apply to E1. (Requires DUAL_X_CARRIAGE)
// S<0|1|2|3>	
// Select the pin to set for all specified axes.
// S0: Full control mode. Both carriages are free to move, constrained by safe distance. (Requires DUAL_X_CARRIAGE)
// S1: Auto-park mode. One carriage parks while the other moves. (Requires DUAL_X_CARRIAGE)
// S2: Duplication mode. Carriages and extruders move in unison.
// S3: Mirrored mode. The second extruder duplicates the motions of the first, but reversed in the X axis.
// [X<linear>]	
// X distance between dual X carriages. (Requires DUAL_X_CARRIAGE)
m605Command 
  = c:"M605" !integer ws? params:m605Parameter* {
      var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        { name: "E", required: "1.0.0" },
        {  name: "P", required: "1.0.0" },
        {  name: "R", required: "1.0.0" },
        {  name: "S", required: "1.0.0" },
        {  name: "X", required: "1.0.0" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    

  }

  m605Parameter
    = p:"E" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"P" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"R" v:temp ws?{ return makeParameter(p, v, location()); }
    / p:"S" v:("0" / "1" / "2" / "3") ws?{ return makeParameter(p, v, location()); }
    / p:"X" v:linear ws?{ return makeParameter(p, v, location()); }

//M665 - Delta Configuration
// M665 [A<float>] [B<float>] [C<float>] [H<linear>] [L<linear>] [R<linear>] [S<float>] [X<float>] [Y<float>] [Z<float>]
// Parameters
// [A<float>]	
// Alpha (Tower 1) diagonal rod trim
// [B<float>]	
// Beta (Tower 2) diagonal rod trim
// [C<float>]	
// Gamma (Tower 3) diagonal rod trim
// [H<linear>]	
// Delta height
// [L<linear>]	
// Diagonal rod
// [R<linear>]	
// Delta radius
// [S<float>]	
// Segments per second
// [X<float>]	
// Alpha (Tower 1) angle trim
// [Y<float>]	
// Beta (Tower 2) angle trim
// [Z<float>]	
// Gamma (Tower 3) angle trim

// m665Command 
//   = c:"M665" !integer ws? params:m665Parameter* {
//       const errors = []; 
//       const duplicates = findDuplicateParameters(params);
//       if(duplicates.length > 0) {
//         errors.push({ 
//           type: 'duplicate_parameters',  
//           command: 'M665',
//           duplicates: duplicates,
//           location: {
//             start: location().start, 
//             end: location().end
//           }
//         });
//       }

//       return {
//         command: "M665",
//         parameters: params,
//         errors: errors.length > 0 ? errors : null, 
//         location: {
//           start: location().start,
//           end: location().end
//         }
//       };

//   }

//   m665Parameter
//     = p:"A" v:float ws?{ return makeParameter(p, v, location()); }
//     / p:"B" v:float ws?{ return makeParameter(p, v, location()); }
//     / p:"C" v:float ws?{ return makeParameter(p, v, location()); }
//     / p:"H" v:linear ws?{ return makeParameter(p, v, location()); }
//     / p:"L" v:linear ws?{ return makeParameter(p, v, location()); }
//     / p:"R" v:linear ws?{ return makeParameter(p, v, location()); }
//     / p:"S" v:float ws?{ return makeParameter(p, v, location()); }
//     / p:"X" v:float ws?{ return makeParameter(p, v, location()); }
//     / p:"Y" v:float ws?{ return makeParameter(p, v, location()); }
//     / p:"Z" v:float ws?{ return makeParameter(p, v, location()); }

//M666 - Set Delta endstop adjustments
// M666 [X<adj>] [Y<adj>] [Z<adj>]
// Parameters
// [X<adj>]	
// Adjustment for the X actuator endstop
// [Y<adj>]	
// Adjustment for the Y actuator endstop
// [Z<adj>]	
// Adjustment for the Z actuator endstop
m666Command 
  = c:"M666" !integer ws? params:m666Parameter* {
     var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        { name: "X", required: "1.0.0" },
        {  name: "Y", required: "1.0.0" },
        {  name: "Z", required: "1.0.0" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    

  }

  m666Parameter
    = p:"X" v:adj ws?{ return makeParameter(p, v, location()); }
    / p:"Y" v:adj ws?{ return makeParameter(p, v, location()); }
    / p:"Z" v:adj ws?{ return makeParameter(p, v, location()); }

//M672 - Duet Smart Effector sensitivity
// M672 [R<bool>] [S<sensitivity>]
// Parameters
// [R<bool>]	
// Revert sensitivity to factory settings
// [S<sensitivity>]	
// Set sensitivity (0-255)
m672Command 
  = c:"M672" !integer ws? params:m672Parameter* {
      var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "2.0.2" };
      const paramVersions = [
        { name: "R", required: "2.0.2" },
        {  name: "S", required: "2.0.2" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    

  }

  m672Parameter
    = p:"R" v:bool ws?{ return makeParameter(p, v, location()); }
    / p:"S" v:sensitivity ws?{ return makeParameter(p, v, location()); }

//M701 - Load filament
// M701 L<distance> [T<extruder>] [Z<distance>]
// Parameters
// L<distance>	
// Extrude distance for insertion (positive value) (manual reload)
// [T<extruder>]	
// Optional extruder index. Current extruder if omitted.
// [Z<distance>]	
// Move the Z axis by this distance
m701Command 
  = c:"M701" !integer ws? params:m701Parameter* {
     var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        { name: "L", required: "1.0.0" },
        {  name: "T", required: "1.0.0" },
        {  name: "Z", required: "1.0.0" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    

  }

  m701Parameter
    = p:"L" v:distance ws?{ return makeParameter(p, v, location()); }
    / p:"T" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"Z" v:distance ws?{ return makeParameter(p, v, location()); }

//M702 - Unload filament
// M702 [T<extruder>] U<distance> [Z<distance>]
// Parameters
// [T<extruder>]	
// Optional extruder number. If omitted, current extruder (or ALL extruders with FILAMENT_UNLOAD_ALL_EXTRUDERS).
// U<distance>	
// Retract distance for removal (manual reload)
// [Z<distance>]	
// Move the Z axis by this distance
m702Command 
  = c:"M702" !integer ws? params:m702Parameter* {
      var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        { name: "T", required: "1.0.0" },
        { name: "U", required: "1.0.0" },
        {  name: "Z", required: "1.0.0" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
  }

  m702Parameter
    = p:"T" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"U" v:distance ws?{ return makeParameter(p, v, location()); }
    / p:"Z" v:distance ws?{ return makeParameter(p, v, location()); }

//M710 - Controller Fan settings
// M710 [A<bool>] [D<seconds>] [I<speed>] [R<bool>] [S<speed>]
// Parameters
// [A<bool>]	
// Set whether the fan speed is set automatically. When turned off the controller fan speed will remain where it is.
// [D<seconds>]	
// Set the extra duration to keep the fan speed high after motors are turned off.
// [I<speed>]	
// Set the speed of the controller fan when motors are off.
// [R<bool>]	
// Reset all settings to defaults. Other parameters can be included to override.
// [S<speed>]	
// Set the speed of the controller fan when motors are active.
m710Command 
  = c:"M710" !integer ws? params:m710Parameter* {
 var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "2.0.5.2" };
      const paramVersions = [
        { name: "A", required: "2.0.5.2" },
        {  name: "D", required: "2.0.5.2" },
        {  name: "I", required: "2.0.5.2" },
        {  name: "R", required: "2.0.5.2" },
        {  name: "S", required: "2.0.5.2" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
  }

  m710Parameter
    = p:"A" v:bool ws?{ return makeParameter(p, v, location()); }
    / p:"D" v:seconds ws?{ return makeParameter(p, v, location()); }
    / p:"I" v:speed ws?{ return makeParameter(p, v, location()); }
    / p:"R" v:bool ws?{ return makeParameter(p, v, location()); }
    / p:"S" v:speed ws?{ return makeParameter(p, v, location()); }

//M808 - Repeat Marker
// M808 [L<count>]
// Parameters
// [L<count>]	
// Loop counter. Use L or L0 for an infinite loop.
m808Command 
  = c:"M808" !integer ws? params:m808Parameter* {
      var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "2.0.8" };
      const paramVersions = [
        { name: "L", required: "2.0.8" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
  }

  m808Parameter
    = p:"L" v:integer ws?{ return makeParameter(p, v, location()); }

//M810-M819 - G-code macros
// M810 [string]
// M811 [string]
// M812 [string]
// M813 [string]
// M814 [string]
// M815 [string]
// M816 [string]
// M817 [string]
// M818 [string]
// M819 [string]
// Parameters
// [string]	
// Set Macro to the given commands, separated by the pipe character.
m810Command 
  = c:("M810" / "M811" / "M812" / "M813"  / "M8162" / "M8172" / "M818" / "M819" ) !integer ws? params:m810Parameter {
      var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
  
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
  }

  m810Parameter
    = v:string? ws?{ return makeParameter(c, v, location()); }

//M851 - XYZ Probe Offset
// M851 [X<linear>] [Y<linear>] [Z<linear>]
// Parameters
// [X<linear>]	
// Z probe X offset
// [Y<linear>]	
// Z probe Y offset
// [Z<linear>]	
// Z probe Z offset
m851Command 
  = c:"M851" !integer ws? params:m851Parameter* {
      var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        { name: "X", required: "1.0.0" },
        {  name: "Y", required: "1.0.0" },
        {  name: "Z", required: "1.0.0" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
  }

  m851Parameter
    = p:"X" v:linear ws?{ return makeParameter(p, v, location()); }
    / p:"Y" v:linear ws?{ return makeParameter(p, v, location()); }
    / p:"Z" v:linear ws?{ return makeParameter(p, v, location()); }

//M852 - Bed Skew Compensation
// M852 [I] [J] [K] [S]
// Parameters
// [I]	
// Skew correction factor for XY axis.
// [J]	
// Skew correction factor for XZ axis
// [K]	
// Skew correction factor for YZ axis
// [S]	
// Alias for I when only XY skew correction is enabled
m852Command 
  = c:"M852" !integer ws? params:m852Parameter* {
     var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        { name: "I", required: "1.0.0" },
        {  name: "J", required: "1.0.0" },
        {  name: "K", required: "1.0.0" },
        {  name: "S", required: "1.0.0" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
  }

  m852Parameter
    = "I" ws?{ return makeParameter("I", true, location()); }
    / "J" ws?{ return makeParameter("J", true, location()); }
    / "K" ws?{ return makeParameter("K", true, location()); }
    / "S" ws?{ return makeParameter("S", true, location()); }

//M860-M869 - I2C Position Encoders
// M860 [E<axis>] [I<index>] [O<bool>] [P<int>] [R<bool>] [S<addr>] [S<bool>] [T<float>] [U<bool>] [X<axis>] [Y<axis>] [Z<axis>]
// M861 [E<axis>] [I<index>] [O<bool>] [P<int>] [R<bool>] [S<addr>] [S<bool>] [T<float>] [U<bool>] [X<axis>] [Y<axis>] [Z<axis>]
// M862 [E<axis>] [I<index>] [O<bool>] [P<int>] [R<bool>] [S<addr>] [S<bool>] [T<float>] [U<bool>] [X<axis>] [Y<axis>] [Z<axis>]
// M863 [E<axis>] [I<index>] [O<bool>] [P<int>] [R<bool>] [S<addr>] [S<bool>] [T<float>] [U<bool>] [X<axis>] [Y<axis>] [Z<axis>]
// M864 [E<axis>] [I<index>] [O<bool>] [P<int>] [R<bool>] [S<addr>] [S<bool>] [T<float>] [U<bool>] [X<axis>] [Y<axis>] [Z<axis>]
// M865 [E<axis>] [I<index>] [O<bool>] [P<int>] [R<bool>] [S<addr>] [S<bool>] [T<float>] [U<bool>] [X<axis>] [Y<axis>] [Z<axis>]
// M866 [E<axis>] [I<index>] [O<bool>] [P<int>] [R<bool>] [S<addr>] [S<bool>] [T<float>] [U<bool>] [X<axis>] [Y<axis>] [Z<axis>]
// M867 [E<axis>] [I<index>] [O<bool>] [P<int>] [R<bool>] [S<addr>] [S<bool>] [T<float>] [U<bool>] [X<axis>] [Y<axis>] [Z<axis>]
// M868 [E<axis>] [I<index>] [O<bool>] [P<int>] [R<bool>] [S<addr>] [S<bool>] [T<float>] [U<bool>] [X<axis>] [Y<axis>] [Z<axis>]
// M869 [E<axis>] [I<index>] [O<bool>] [P<int>] [R<bool>] [S<addr>] [S<bool>] [T<float>] [U<bool>] [X<axis>] [Y<axis>] [Z<axis>]
// Parameters
// [E<axis>]	
// Report on E axis encoder if present. (If A or I not specified)
// [I<index>]	
// Module index. [0, I2CPE_ENCODER_CNT - 1]
// [O<bool>]	
// Include homed zero-offset in returned position
// [P<int>]	
// Number of rePeats/iterations. (for M863 only)
// [R<bool>]	
// Reset error counter. (for M866 only)
// [S<addr>]	
// Module new I2C address. [30, 200]. (for M864 only)
// [S<bool>]	
// Enable/disable error correction. 1 enables, 0 disables. If not supplied, toggle. (for M867 only)
// [T<float>]	
// New error correction threshold. (for M868 only)
// [U<bool>]	
// Units in mm or raw step count. (for M860 only)
// [X<axis>]	
// Report on X axis encoder if present. (If A or I not specified)
// [Y<axis>]	
// Report on Y axis encoder if present. (If A or I not specified)
// [Z<axis>]	
// Report on Z axis encoder if present. (If A or I not specified)
  m860Command 
  = c:("M860" / "M861" / "M862" / "M863" / "M864" / "M865" / "M866" / "M867" / "M868" / "M869" ) !integer ws? params:m860Parameter {
     var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        { name: "E", required: "1.0.0" },
        {  name: "I", required: "1.0.0" },
        {  name: "O", required: "1.0.0" },
        {  name: "P", required: "1.0.0" },
        {  name: "R", required: "1.0.0" },
        {  name: "S", required: "1.0.0" },
        {  name: "S", required: "1.0.0" },
        {  name: "T", required: "1.0.0" },
        {  name: "U", required: "1.0.0" },
        {  name: "X", required: "1.0.0" },
        {  name: "Y", required: "1.0.0" },
        {  name: "Z", required: "1.0.0" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
  }

  m860Parameter
    = p:"E" v:axis ws?{ return makeParameter(p, v, location()); }
    / p:"I" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"O" v:bool ws?{ return makeParameter(p, v, location()); }
    / p:"P" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"R" v:bool ws?{ return makeParameter(p, v, location()); }
    / p:"S" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"S" v:bool ws?{ return makeParameter(p, v, location()); }
    / p:"T" v:float ws?{ return makeParameter(p, v, location()); }
    / p:"U" v:bool ws?{ return makeParameter(p, v, location()); }
    / p:"X" v:axis ws?{ return makeParameter(p, v, location()); }
    / p:"Y" v:axis ws?{ return makeParameter(p, v, location()); }
    / p:"Z" v:axis ws?{ return makeParameter(p, v, location()); }

//M876 - Handle Prompt Response
// M876 S<response>
// Parameters
// S<response>	
// Response to prompt
m876Command 
  = c:"M876" !integer ws? params:m876Parameter* {
     var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        { name: "S", required: "1.0.0" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
  }

  m876Parameter
    = p:"S" v:response ws?{ return makeParameter(p, v, location()); }

//M900 - Linear Advance Factor
// M900 [K<kfactor>] [L<kfactor>] [S<slot>] [T<index>]
// Parameters
// [K<kfactor>]	
// The K factor to set for the specified extruder. Unchanged if omitted. Set this value higher for more flexible filament or a longer filament path.
// With EXTRA_LIN_ADVANCE_K this sets the primary K factor. Note that this factor may be inactive and won’t take effect until the next M900 S0.
// [L<kfactor>]  2.0.0	
// Set the second K factor for the specified extruder. Requires EXTRA_LIN_ADVANCE_K. Note that this factor may be inactive and won’t take effect until the next M900 S1.
// [S<slot>]  2.0.0	
// Select slot and activate the last stored value. Requires EXTRA_LIN_ADVANCE_K.
// [T<index>]  2.0.0	
// Extruder to which K, L, and S will apply. Requires EXTRA_LIN_ADVANCE_K.
m900Command 
  = c:"M900" !integer ws? params:m900Parameter* {
     var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        { name: "K", required: "1.0.0" },
        {  name: "L", required: "2.0.0" },
        {  name: "S", required: "2.0.0" },
        {  name: "T", required: "2.0.0" },
      ];
return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
  }

  m900Parameter
    = p:"K" v:kfactor ws?{ return makeParameter(p, v, location()); }
    / p:"L" v:kfactor ws?{ return makeParameter(p, v, location()); }
    / p:"S" v:slot ws?{ return makeParameter(p, v, location()); }
    / p:"T" v:integer ws?{ return makeParameter(p, v, location()); }


//M906 - Stepper Motor Current
//M906 [E<mA>] I<index> [T<index>] [X<mA>] [Y<mA>] [Z<mA>]
// Parameters
// [E<mA>]	
// Current for the E0 stepper
// I<index>  1.1.9	
// Index for multiple steppers. (i.e., I1 for X2, Y2, Z2; I2 for Z3; I3 for Z4).
// [T<index>]  1.1.9	
// Index (tool) number for the E axis. If not specified, the E0 extruder.
// [X<mA>]	
// Current for the X stepper
// [Y<mA>]	
// Current for the Y stepper
// [Z<mA>]	
// Current for the Z stepper
m906Command 
  = c:"M906" !integer ws? params:m906Parameter* {
     var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        { name: "E", required: "1.0.0" },
        {  name: "I", required: "1.1.9" },
        {  name: "T", required: "1.1.9" },
        {  name: "X", required: "1.0.0" },
        {  name: "Y", required: "1.0.0" },
        {  name: "Z", required: "1.0.0" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
  }

  m906Parameter
    = p:"E" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"I" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"T" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"X" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"Y" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"Z" v:integer ws?{ return makeParameter(p, v, location()); }

//M907 - Set Motor Current
// M907 [B<current>] [C<current>] [D<current>] [E<current>] [S<current>] [X<current>] [Y<current>] [Z<current>]
// Parameters
// [B<current>]	
// Current for the E1 stepper (Requires DIGIPOTSS_PIN or DIGIPOT_I2C)
// [C<current>]	
// Current for the E2 stepper (Requires DIGIPOT_I2C)
// [D<current>]	
// Current for the E3 stepper (Requires DIGIPOT_I2C)
// [E<current>]	
// Current for the E0 stepper
// [S<current>]	
// Set this current on all steppers (Requires DIGIPOTSS_PIN or DAC_STEPPER_CURRENT)
// [X<current>]	
// Current for the X stepper (and the Y stepper with MOTOR_CURRENT_PWM_XY)
// [Y<current>]	
// Current for the Y stepper (Use X with MOTOR_CURRENT_PWM_XY)
// [Z<current>]	
// Current for the Z stepper
m907Command 
  = c:"M907" !integer ws? params:m907Parameter* {
     var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        { name: "B", required: "1.0.0" },
        {  name: "C", required: "1.0.0" },
        {  name: "D", required: "1.0.0" },
        {  name: "E", required: "1.0.0" },
        {  name: "S", required: "1.0.0" },
        {  name: "X", required: "1.0.0" },
        {  name: "Y", required: "1.0.0" },
        {  name: "Z", required: "1.0.0" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
  }

  m907Parameter
    = p:"B" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"C" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"D" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"E" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"S" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"X" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"Y" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"Z" v:integer ws?{ return makeParameter(p, v, location()); }

//M908 - Set Trimpot Pins
// M908 P<address> S<current>
// Parameters
// P<address>	
// Pin (i.e., Address, Channel)
// S<current>	
// Current value
m908Command 
  = c:"M908" !integer ws? params:m908Parameter* {
      var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        { name: "P", required: "1.0.0" },
        {  name: "S", required: "1.0.0" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
  }

  m908Parameter
    = p:"P" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"S" v:integer ws?{ return makeParameter(p, v, location()); }

//M912 - Clear TMC OT Pre-Warn
// M912 [E<-|0-4>] [I<0|1|2|3>] [X] [Y] [Z]
// Parameters
// [E<-|0-4>]	
// Clear all or one E stepper driver Over Temperature Pre-warn flag.
// E-: All E.
// E0-4: E index.
// [I<0|1|2|3>]  1.1.9	
// Stepper number to set. If omitted, all specified axes.
// I0: Both.
// I1: Base (X, Y, Z) steppers.
// I2: Second (X2, Y2, Z2) steppers.
// I3: Third (Z3) steppers.
// [X]	
// Clear X and/or X2 stepper driver Over Temperature Pre-warn flag.
// [Y]	
// Clear Y and/or Y2 stepper driver Over Temperature Pre-warn flag.
// [Z]	
// Clear Z and/or Z2 and/or Z3 stepper driver Over Temperature Pre-warn flag.
m912Command 
  = c:"M912" !integer ws? params:m912Parameter* {
      var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        { name: "E", required: "1.0.0" },
        {  name: "I", required: "1.1.9" },
        {  name: "X", required: "1.0.0" },
        {  name: "Y", required: "1.0.0" },
        {  name: "Z", required: "1.0.0" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
  }

  m912Parameter
    = p:"E" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"I" v:("0" / "1" / "2" / "3") ws?{ return makeParameter(p, v, location()); }
    / "X" ws?{ return makeParameter("X", true, location()); }
    / "Y" ws?{ return makeParameter("Y", true, location()); }
    / "Z" ws?{ return makeParameter("Z", true, location()); }

//M913 - Set Hybrid Threshold Speed
// M913 [E] [I<index>] [T<index>] [X] [Y] [Z]
// Parameters
// [E]	
// Set Hybrid Threshold for E to the given value.
// [I<index>]  1.1.9	
// Index for multiple steppers. (i.e., I1 for X2, Y2, Z2; I2 for Z3; I3 for Z4).
// [T<index>]  1.1.9	
// Index (tool) number for the E axis. If not specified, the E0 extruder.
// [X]	
// Set Hybrid Threshold for X to the given value.
// [Y]	
// Set Hybrid Threshold for Y to the given value.
// [Z]	
// Set Hybrid Threshold for Z to the given value.
m913Command 
  = c:"M913" !integer ws? params:m913Parameter* {
     var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        { name: "E", required: "1.0.0" },
        {  name: "I", required: "1.1.9" },
        {  name: "T", required: "1.1.9" },
        {  name: "X", required: "1.0.0" },
        {  name: "Y", required: "1.0.0" },
        {  name: "Z", required: "1.0.0" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
  }

  m913Parameter
    = "E" ws?{ return makeParameter("E", true, location()); }
    / p:"I" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"T" v:integer ws?{ return makeParameter(p, v, location()); }
    / "X" ws?{ return makeParameter("X", true, location()); }
    / "Y" ws?{ return makeParameter("Y", true, location()); }
    / "Z" ws?{ return makeParameter("Z", true, location()); }

//M914 - TMC Bump Sensitivity
// M914 [I<index>] [X<int>] [Y<int>] [Z<int>]
// Parameters
// [I<index>]  1.1.9	
// Index for multiple steppers. (i.e., I1 for X2, Y2, Z2; I2 for Z3; I3 for Z4).
// [X<int>]	
// Sensitivity of the X stepper driver.
// [Y<int>]	
// Sensitivity of the Y stepper driver.
// [Z<int>]	
// Sensitivity of the Z stepper driver.
m914Command 
  = c:"M914" !integer ws? params:m914Parameter* {
      var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        { name: "I", required: "1.1.9" },
        {  name: "X", required: "1.0.0" },
        {  name: "Y", required: "1.0.0" },
        {  name: "Z", required: "1.0.0" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
  }

  m914Parameter
    = p:"I" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"X" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"Y" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"Z" v:integer ws?{ return makeParameter(p, v, location()); }

//M915 - TMC Z axis calibration
// M915 [S<mA>] [Z<linear>]
// Parameters
// [S<mA>]	
// Current value to use for the raise move. (Default: CALIBRATION_CURRENT)
// [Z<linear>]	
// Extra distance past Z_MAX_POS to move the Z axis. (Default: CALIBRATION_EXTRA_HEIGHT)
m915Command 
  = c:"M915" !integer ws? params:m915Parameter* {
      var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "2.0.0" };
      const paramVersions = [
        { name: "S", required: "2.0.0" },
        {  name: "Z", required: "2.0.0" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
  }

  m915Parameter
    = p:"S" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"Z" v:linear ws?{ return makeParameter(p, v, location()); }

//M916 - L6474 Thermal Warning Test
// M916 [D<second>] [E<mm>] [F<feedrate>] [J<0|1|2|3|4|5|6|7>] [K<Kvalue>] [T<current>] [X<mm>] [Y<mm>] [Z<mm>]
// Parameters
// [D<second>]	
// Time (in seconds) to run each setting of KVAL_HOLD/TVAL. (Default zero, to run each setting once.)
// [E<mm>]	
// Monitor E with the given displacement (1 - 255mm) on either side of the current position.
// [F<feedrate>]	
// Feedrate for the moves. (Default max feedrate if unspecified.)
// [J<0|1|2|3|4|5|6|7>]	
// Select which driver(s) to monitor on multi-driver axis
// J0: (default) Monitor all drivers on the axis
// J1: Monitor only X, Y, Z, E1
// J2: Monitor only X2, Y2, Z2, E2
// J3: Monitor only Z3, E3
// J4: Monitor only Z4, E4
// J5: Monitor only Z5, E5
// J6: Monitor only Z6, E6
// J7: Monitor only Z7, E7
// [K<Kvalue>]	
// Value for KVAL_HOLD (0 - 255) (ignored for L6474). If unspecified, report current value from driver.
// [T<current>]	
// Current (mA) setting for TVAL (0 - 4A in 31.25mA increments, rounds down) - L6474 only. If unspecified, report current value from driver.
// [X<mm>]	
// Monitor X with the given displacement (1 - 255mm) on either side of the current position.
// [Y<mm>]	
// Monitor Y with the given displacement (1 - 255mm) on either side of the current position.
// [Z<mm>]	
// Monitor Z with the given displacement (1 - 255mm) on either side of the current position.
m916Command 
  = c:"M916" !integer ws? params:m916Parameter* {
     var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        { name: "D", required: "1.0.0" },
        {  name: "E", required: "1.0.0" },
        {  name: "F", required: "1.0.0" },
        {  name: "J", required: "1.0.0" },
        {  name: "K", required: "1.0.0" },
        {  name: "T", required: "1.0.0" },
        {  name: "X", required: "1.0.0" },
        {  name: "Y", required: "1.0.0" },
        {  name: "Z", required: "1.0.0" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
  }

  m916Parameter
    = p:"D" v:seconds ws?{ return makeParameter(p, v, location()); }
    / p:"E" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"F" v:feedrate ws?{ return makeParameter(p, v, location()); }
    / p:"J" v:("0" / "1" / "2" / "3" / "4" / "5" / "6" / "7") ws?{ return makeParameter(p, v, location()); }
    / p:"K" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"T" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"X" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"Y" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"Z" v:integer ws?{ return makeParameter(p, v, location()); }

//M917 - L6474 Overcurrent Warning Test
// M917 [E<mm>] [F<feedrate>] [I<current>] [J<0|1|2|3|4|5|6|7>] [K<Kvalue>] [T<current>] [X<mm>] [Y<mm>] [Z<mm>]
// Parameters
// [E<mm>]	
// Monitor E with the given displacement (1 - 255mm) on either side of the current position.
// [F<feedrate>]	
// Feedrate for the moves. If unspecified, uses the max feedrate.
// [I<current>]	
// Starting overcurrent threshold. Report current value from driver if not specified. If there are multiple drivers on the axis then all will be set the same.
// [J<0|1|2|3|4|5|6|7>]	
// Select which driver(s) to monitor on multi-driver axis.
// J0: (default) Monitor all drivers on the axis or E0.
// J1: Monitor only X, Y, Z, E1.
// J2: Monitor only X2, Y2, Z2, E2.
// J3: Monitor only Z3, E3
// J4: Monitor only Z4, E4
// J5: Monitor only Z5, E5
// J6: Monitor only Z6, E6
// J7: Monitor only Z7, E7
// [K<Kvalue>]	
// Value for KVAL_HOLD (0 - 255) (ignored for L6474). Report current value from driver if not specified
// [T<current>]	
// Current (mA) setting for TVAL (0 - 4A in 31.25mA increments, rounds down) - L6474 only. Report current value from driver if not specified.
// [X<mm>]	
// Monitor X with the given displacement (1 - 255mm) on either side of the current position.
// [Y<mm>]	
// Monitor Y with the given displacement (1 - 255mm) on either side of the current position.
// [Z<mm>]	
// Monitor Z with the given displacement (1 - 255mm) on either side of the current position.
m917Command 
  = c:"M917" !integer ws? params:m917Parameter* {
     var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        { name: "E", required: "1.0.0" },
        {  name: "F", required: "1.0.0" },
        {  name: "I", required: "1.0.0" },
        {  name: "J", required: "1.0.0" },
        {  name: "K", required: "1.0.0" },
        {  name: "T", required: "1.0.0" },
        {  name: "X", required: "1.0.0" },
        {  name: "Y", required: "1.0.0" },
        {  name: "Z", required: "1.0.0" },
      ];
return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
  }

  m917Parameter
    = p:"E" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"F" v:feedrate ws?{ return makeParameter(p, v, location()); }
    / p:"I" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"J" v:("0" / "1" / "2" / "3" / "4" / "5" / "6" / "7") ws?{ return makeParameter(p, v, location()); }
    / p:"K" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"T" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"X" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"Y" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"Z" v:integer ws?{ return makeParameter(p, v, location()); }

//M918 - L6474 Speed Warning Test
// M918 [E<mm>] [I<current>] [J<0|1|2|3|4|5|6|7>] [K<Kvalue>] [M<microsteps>] [T<current>] [X<mm>] [Y<mm>] [Z<mm>]
// Parameters
// [E<mm>]	
// Monitor E with the given displacement (1 - 255mm) on either side of the current position.
// [I<current>]	
// Overcurrent threshold. Report current value from driver if not specified.
// [J<0|1|2|3|4|5|6|7>]	
// Select which driver(s) to monitor on a multi-driver axis.
// J0: (default) Monitor all drivers on the axis or E0
// J1: Monitor only X, Y, Z, E1
// J2: Monitor only X2, Y2, Z2, E2
// J3: Monitor only Z3, E3
// J4: Monitor only Z4, E4
// J5: Monitor only Z5, E5
// J6: Monitor only Z6, E6
// J7: Monitor only Z7, E7
// [K<Kvalue>]	
// Value for KVAL_HOLD (0 - 255) (ignored for L6474). Report current value from driver if not specified.
// [M<microsteps>]	
// Value for microsteps (1 - 128). Report current value from driver if not specified.
// [T<current>]	
// Current (mA) setting for TVAL (0 - 4A in 31.25mA increments, rounds down) - L6474 only. Report current value from driver if not specified.
// [X<mm>]	
// Monitor X with the given displacement (1 - 255mm) on either side of the current position.
// [Y<mm>]	
// Monitor Y with the given displacement (1 - 255mm) on either side of the current position.
// [Z<mm>]	
// Monitor Z with the given displacement (1 - 255mm) on either side of the current position.
m918Command 
  = c:"M918" !integer ws? params:m918Parameter* {
     var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        { name: "E", required: "1.0.0" },
        {  name: "I", required: "1.0.0" },
        {  name: "J", required: "1.0.0" },
        {  name: "K", required: "1.0.0" },
        {  name: "M", required: "1.0.0" },
        {  name: "T", required: "1.0.0" },
        {  name: "X", required: "1.0.0" },
        {  name: "Y", required: "1.0.0" },
        {  name: "Z", required: "1.0.0" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
  }

  m918Parameter
    = p:"E" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"I" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"J" v:("0" / "1" / "2" / "3" / "4" / "5" / "6" / "7") ws?{ return makeParameter(p, v, location()); }
    / p:"K" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"M" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"T" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"X" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"Y" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"Z" v:integer ws?{ return makeParameter(p, v, location()); }

//M919 - TMC Chopper Timing
// M919 [A] [B] [C] [I<index>] [O<int>] [P<int>] [S<int>] [T<index>] [U] [V] [W] [X] [Y] [Z]
// Parameters
// [A] I_DRIVER_TYPE	
// Apply the given chopper timing to the A stepper. (Requires 4 or more axes.)
// [B] J_DRIVER_TYPE	
// Apply the given chopper timing to the B stepper. (Requires 5 or more axes.)
// [C] K_DRIVER_TYPE	
// Apply the given chopper timing to the C stepper. (Requires 6 or more axes.)
// [I<index>]	
// Index for multiple steppers. (i.e., I1 for X2, Y2, Z2; I2 for Z3; I3 for Z4). If omitted, all steppers for the selected axes.
// [O<int>]	
// Time-Off value (1..15). If omitted, use configured defaults for the axes.
// [P<int>]	
// Hysteresis End value (-3..12). If omitted, use configured defaults for the axes.
// [S<int>]	
// Hysteresis Start value (1..8). If omitted, use configured defaults for the axes.
// [T<index>]	
// Index (tool) number for the E axis. If omitted, all extruders.
// [U]  2.1 U_DRIVER_TYPE	
// Apply the given chopper timing to the U stepper. (Requires 7 or more axes.)
// [V]  2.1 V_DRIVER_TYPE	
// Apply the given chopper timing to the V stepper. (Requires 8 or more axes.)
// [W]  2.1 W_DRIVER_TYPE	
// Apply the given chopper timing to the W stepper. (Requires 9 axes.)
// [X]	
// Apply the given chopper timing to the X stepper(s).
// [Y] Y_DRIVER_TYPE	
// Apply the given chopper timing to the Y stepper(s). (Requires 2 or more axes.)
// [Z] Z_DRIVER_TYPE	
// Apply the given chopper timing to the Z stepper(s). (Requires 3 or more axes.)
m919Command 
  = c:"M919" !integer ws? params:m919Parameter* {
      var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "2.0.9.4" };
      const paramVersions = [
        { name: "A", required: "1.0.0" },
        {  name: "B", required: "1.0.0" },
        {  name: "C", required: "1.0.0" },
        {  name: "I", required: "1.0.0" },
        {  name: "O", required: "1.0.0" },
        {  name: "P", required: "1.0.0" },
        {  name: "S", required: "1.0.0" },
        {  name: "T", required: "1.0.0" },
        {  name: "U", required: "2.1.0" },
        {  name: "V", required: "2.1.0" },
        {  name: "W", required: "2.1.0" },
        {  name: "X", required: "1.0.0" },
        {  name: "Y", required: "1.0.0" },
        {  name: "Z", required: "1.0.0" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
  }

  m919Parameter
    = "A" ws?{ return makeParameter("A", true, location()); }
    / "B" ws?{ return makeParameter("B", true, location()); }
    / "C" ws?{ return makeParameter("C", true, location()); }
    / p:"I" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"O" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"P" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"S" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"T" v:integer ws?{ return makeParameter(p, v, location()); }
    / "U" ws?{ return makeParameter("U", true, location()); }
    / "V" ws?{ return makeParameter("V", true, location()); }
    / "W" ws?{ return makeParameter("W", true, location()); }
    / "X" ws?{ return makeParameter("X", true, location()); }
    / "Y" ws?{ return makeParameter("Y", true, location()); }
    / "Z" ws?{ return makeParameter("Z", true, location()); }

//M928 - Start SD Logging
//M928 filename
// Parameters
// filename	
// File name of log file
m928Command 
  = c:"M928" !integer ws? params:m928Parameter {
      var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        { name: "filename", required: "1.0.0" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
  }

  m928Parameter
    = p:"filename" v:string ws?{ return makeParameter(p, v, location()); }

//M951 - Magnetic Parking Extruder
// M951 [C<float>] [D<linear>] [H<linear>] [I<linear>] [J<linear>] [L<linear>] [R<linear>]
// Parameters
// [C<float>]	
// Set compensation factor. (Default MPE_COMPENSATION)
// [D<linear>]	
// Set travel feedrate. (Default MPE_TRAVEL_DISTANCE)
// [H<linear>]	
// Set fast feedrate. (Default MPE_FAST_SPEED)
// [I<linear>]	
// Set grab distance. (Default PARKING_EXTRUDER_GRAB_DISTANCE)
// [J<linear>]	
// Set slow feedrate. (Default MPE_SLOW_SPEED)
// [L<linear>]	
// Set X[0] position. (Default PARKING_EXTRUDER_PARKING_X)
// [R<linear>]	
// Set X[1] position. (Default PARKING_EXTRUDER_PARKING_X)
m951Command 
  = c:"M951" !integer ws? params:m951Parameter* {
      var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        { name: "C", required: "1.0.0" },
        {  name: "D", required: "1.0.0" },
        {  name: "H", required: "1.0.0" },
        {  name: "I", required: "1.0.0" },
        {  name: "J", required: "1.0.0" },
        {  name: "L", required: "1.0.0" },
        {  name: "R", required: "1.0.0" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
  }

  m951Parameter
    = p:"C" v:float ws?{ return makeParameter(p, v, location()); }
    / p:"D" v:linear ws?{ return makeParameter(p, v, location()); }
    / p:"H" v:linear ws?{ return makeParameter(p, v, location()); }
    / p:"I" v:linear ws?{ return makeParameter(p, v, location()); }
    / p:"J" v:linear ws?{ return makeParameter(p, v, location()); }
    / p:"L" v:linear ws?{ return makeParameter(p, v, location()); }
    / p:"R" v:linear ws?{ return makeParameter(p, v, location()); }

//M999 - STOP Restart
// M999 S<bool>
// Parameters
// S<bool>	
// Resume without flushing the command buffer. The default behavior is to flush the serial buffer and request a resend to the host starting on the last N line received.
m999Command 
  = c:"M999" !integer ws? params:m999Parameter {
     var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        { name: "S", required: "1.0.0" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
  }

  m999Parameter
    = p:"S" v:bool ws?{ return makeParameter(p, v, location()); }

//M7219 - MAX7219 Control
//M7219 [C<column>] [D<row>] [F] [I] [P] [R<row>] [U<index>] [V<bits>] [X<index>] [Y<index>]
// Parameters
// [C<column>]	
// Set the column specified by C to bit pattern V.
// [D<row>]	
// Directly set a Max7219 native row (on the unit specified by U) to the 8-bit pattern V.
// [F]	
// Fill the matrix by turning on all LEDs.
// [I]	
// Initialize (clear) all matrixes.
// [P]	
// Print the LED array state for debugging.
// [R<row>]	
// Set the row specified by R to bit pattern V.
// [U<index>]	
// Used with D to specify which matrix unit to set.
// [V<bits>]	
// Value to apply when using the C, R, or X/Y parameters.
// [X<index>]	
// Set a matrix LED at the given X position to the V value. If no V is given, toggle the LED state.
// [Y<index>]	
// Set a matrix LED at the given Y position to the V value. If no V is given, toggle the LED state.
m7219Command 
  = c:"M7219" !integer ws? params:m7219Parameter* {
     var errors = [];
      const duplicates = findDuplicateParameters(params);
      const commandVersion = { required: "1.0.0" };
      const paramVersions = [
        { name: "C", required: "1.0.0" },
        {  name: "D", required: "1.0.0" },
        {  name: "F", required: "1.0.0" },
        {  name: "I", required: "1.0.0" },
        {  name: "P", required: "1.0.0" },
        {  name: "R", required: "1.0.0" },
        {  name: "U", required: "1.0.0" },
        {  name: "V", required: "1.0.0" },
        {  name: "X", required: "1.0.0" },
        {  name: "Y", required: "1.0.0" },
      ];

return createCommand(c, params, duplicates, commandVersion, paramVersions, null , errors, location());
    
  }

  m7219Parameter
    = p:"C" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"D" v:integer ws?{ return makeParameter(p, v, location()); }
    / "F" ws?{ return makeParameter("F", true, location()); }
    / "I" ws?{ return makeParameter("I", true, location()); }
    / "P" ws?{ return makeParameter("P", true, location()); }
    / p:"R" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"U" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"V" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"X" v:integer ws?{ return makeParameter(p, v, location()); }
    / p:"Y" v:integer ws?{ return makeParameter(p, v, location()); }

                                