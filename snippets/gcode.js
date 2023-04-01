// const vscode = require('vscode');
// const fs = require('fs');
// const path = require('path');
// const MarkdownIt = require('markdown-it');
// const md = new MarkdownIt();
//MAYBE CAN INJECT DESCRIPTION

// const registerSnippets = (context) => {
//   const { subscriptions } = context;

//   for (const snippet of snippets) {
//     subscriptions.push(
//       vscode.languages.registerCompletionItemProvider(
//         'marlin',
//         {
//           provideCompletionItems: () => [new vscode.CompletionItem(
//             snippet.label,

//             vscode.CompletionItemKind.Keyword

//           ) ]
//         },
//         snippet.prefix // Trigger for the snippet
//       )
//     );
//   }
// };

// module.exports = { registerSnippets };

// // Add following snippets
// // G0-G1: Linear Move
// // G2-G3: Arc or Circle Move
// // G4: Dwell
// // G5: Bézier cubic spline
// // G6: Direct Stepper Move
// // G10: Retract
// // G11: Recover
// // G12: Clean the Nozzle
// // G17-G18-G19: CNC Workspace Planes
// // G20: Inch Units
// // G21: Millimeter Units
// // G26: Mesh Validation Pattern
// // G27: Park toolhead
// // G28: Auto Home
// // G29: Bed Leveling
// // G29: Bed Leveling (3-Point)
// // G29: Bed Leveling (Linear)
// // G29: Bed Leveling (Manual)
// // G29: Bed Leveling (Bilinear)
// // G29: Bed Leveling (Unified)
// // G30: Single Z-Probe
// // G31: Dock Sled
// // G32: Undock Sled
// // G33: Delta Auto Calibration
// // G34: Z Steppers Auto-Alignment
// // G34: Mechanical Gantry Calibration
// // G35: Tramming Assistant
// // G38.2-G38.5: Probe target
// // G42: Move to mesh coordinate
// // G53: Move in Machine Coordinates
// // G54-G59.3: Workspace Coordinate System
// // G60: Save Current Position
// // G61: Return to Saved Position
// // G76: Probe temperature calibration
// // G80: Cancel Current Motion Mode
// // G90: Absolute Positioning
// // G91: Relative Positioning
// // G92: Set Position
// // G425: Backlash Calibration
// // M0-M1: Unconditional stop
// // M3: Spindle CW / Laser On
// // M4: Spindle CCW / Laser On
// // M5: Spindle / Laser Off
// // M7-M08-M9: Coolant Controls
// // M10-M11: Vacuum / Blower Control
// // M16: Expected Printer Check
// // M17: Enable Steppers
// // M18, M84: Disable steppers
// // M20: List SD Card
// // M21: Init SD card
// // M22: Release SD card
// // M23: Select SD file
// // M24: Start or Resume SD print
// // M25: Pause SD print
// // M26: Set SD position
// // M27: Report SD print status
// // M28: Start SD write
// // M29: Stop SD write
// // M30: Delete SD file
// // M31: Print time
// // M32: Select and Start
// // M33: Get Long Path
// // M34: SDCard Sorting
// // M42: Set Pin State
// // M43: Debug Pins
// // M43 T: Toggle Pins
// // M48: Probe Repeatability Test
// // M73: Set Print Progress
// // M75: Start Print Job Timer
// // M76: Pause Print Job Timer
// // M77: Stop Print Job Timer
// // M78: Print Job Stats
// // M80: Power On
// // M81: Power Off
// // M82: E Absolute
// // M83: E Relative
// // M85: Inactivity Shutdown
// // M92: Set Axis Steps-per-unit
// // M100: Free Memory
// // M102: Configure Bed Distance Sensor
// // M104: Set Hotend Temperature
// // M105: Report Temperatures
// // M106: Set Fan Speed
// // M107: Fan Off
// // M108: Break and Continue
// // M109: Wait for Hotend Temperature
// // M110: Set Line Number
// // M111: Debug Level
// // M112: Emergency Stop
// // M113: Host Keepalive
// // M114: Get Current Position
// // M115: Firmware Info
// // M117: Set LCD Message
// // M118: Serial print
// // M119: Endstop States
// // M120: Enable Endstops
// // M121: Disable Endstops
// // M122: TMC Debugging
// // M123: Fan Tachometers
// // M125: Park Head
// // M126: Baricuda 1 Open
// // M127: Baricuda 1 Close
// // M128: Baricuda 2 Open
// // M129: Baricuda 2 Close
// // M140: Set Bed Temperature
// // M141: Set Chamber Temperature
// // M143: Set Laser Cooler Temperature
// // M145: Set Material Preset
// // M149: Set Temperature Units
// // M150: Set RGB(W) Color
// // M154: Position Auto-Report
// // M155: Temperature Auto-Report
// // M163: Set Mix Factor
// // M164: Save Mix
// // M165: Set Mix
// // M166: Gradient Mix
// // M190: Wait for Bed Temperature
// // M191: Wait for Chamber Temperature
// // M192: Wait for Probe temperature
// // M193: Set Laser Cooler Temperature
// // M200: Set Filament Diameter
// // M201: Print Move Limits
// // M203: Set Max Feedrate
// // M204: Set Starting Acceleration
// // M205: Set Advanced Settings
// // M206: Set Home Offsets
// // M207: Set Firmware Retraction
// // M208: Firmware Recover
// // M209: Set Auto Retract
// // M211: Software Endstops
// // M217: Filament swap parameters
// // M218: Set Hotend Offset
// // M220: Set Feedrate Percentage
// // M221: Set Flow Percentage
// // M226: Wait for Pin State
// // M240: Trigger Camera
// // M250: LCD Contrast
// // M255: LCD Sleep/Backlight Timeout
// // M256: LCD Brightness
// // M260: I2C Send
// // M261: I2C Request
// // M280: Servo Position
// // M281: Edit Servo Angles
// // M282: Detach Servo
// // M290: Babystep
// // M300: Play Tone
// // M301: Set Hotend PID
// // M302: Cold Extrude
// // M303: PID autotune
// // M304: Set Bed PID
// // M305: User Thermistor Parameters
// // M306: Model predictive temperature control
// // M350: Set micro-stepping
// // M351: Set Microstep Pins
// // M355: Case Light Control
// // M360: SCARA Theta A
// // M361: SCARA Theta-B
// // M362: SCARA Psi-A
// // M363: SCARA Psi-B
// // M364: SCARA Psi-C
// // M380: Activate Solenoid
// // M381: Deactivate Solenoids
// // M400: Finish Moves
// // M401: Deploy Probe
// // M402: Stow Probe
// // M403: MMU2 Filament Type
// // M404: Set Filament Diameter
// // M405: Filament Width Sensor On
// // M406: Filament Width Sensor Off
// // M407: Filament Width
// // M410: Quickstop
// // M412: Filament Runout
// // M413: Power-loss Recovery
// // M420: Bed Leveling State
// // M421: Set Mesh Value
// // M422: Set Z Motor XY
// // M423: X Twist Compensation
// // M425: Backlash compensation
// // M428: Home Offsets Here
// // M430: Power Monitor
// // M486: Cancel Objects
// // M500: Save Settings
// // M501: Restore Settings
// // M502: Factory Reset
// // M503: Report Settings
// // M504: Validate EEPROM contents
// // M510: Lock Machine
// // M511: Unlock Machine
// // M512: Set Passcode
// // M524: Abort SD print
// // M540: Endstops Abort SD
// // M569: Set TMC stepping mode
// // M575: Serial baud rate
// // M593: Input Shaping
// // M600: Filament Change
// // M603: Configure Filament Change
// // M605: Multi Nozzle Mode
// // M665: Delta Configuration
// // M665: SCARA Configuration
// // M666: Set Delta endstop adjustments
// // M666: Set dual endstop offsets
// // M672: Duet Smart Effector sensitivity
// // M701: Load filament
// // M702: Unload filament
// // M710: Controller Fan settings
// // M808: Repeat Marker
// // M810-M819: G-code macros
// // M851: XYZ Probe Offset
// // M852: Bed Skew Compensation
// // M860-M869: I2C Position Encoders
// // M871: Probe temperature config
// // M876: Handle Prompt Response
// // M900: Linear Advance Factor
// // M906: Stepper Motor Current
// // M907: Set Motor Current
// // M908: Set Trimpot Pins
// // M909: DAC Print Values
// // M910: Commit DAC to EEPROM
// // M911: TMC OT Pre-Warn Condition
// // M912: Clear TMC OT Pre-Warn
// // M913: Set Hybrid Threshold Speed
// // M914: TMC Bump Sensitivity
// // M915: TMC Z axis calibration
// // M916: L6474 Thermal Warning Test
// // M917: L6474 Overcurrent Warning Test
// // M918: L6474 Speed Warning Test
// // M919: TMC Chopper Timing
// // M928: Start SD Logging
// // M951: Magnetic Parking Extruder
// // M993-M994: SD / SPI Flash
// // M995: Touch Screen Calibration
// // M997: Firmware update
// // M999: STOP Restart
// // M7219: MAX7219 Control
// // T0 -T6: Select Tool
// const snippets = [
//   {
//     label: 'G0: Linear rapid Move',
//     prefix: 'G0',
//   },
//   {
//     label: 'G1: Linear Move',
//     prefix: 'G1',
//   }, {
//     label: 'G2: Clockwise arc',
//     prefix: 'G2',
//   },
//   {
//     label: 'G3: Counterclockwise arc',
//     prefix: 'G3',
//   },
//   { label: 'G4: Dwell', prefix: 'G4' },
//   { label: 'G5: Cubic B-spline', prefix: 'G5' },
//   { label: 'G6: Direct Stepper Move', prefix: 'G6' },
//   { label: 'G10: Retract', prefix: 'G10' },
//   { label: 'G11: Recover', prefix: 'G11' },
//   { label: 'G12: Clean the nozzle', prefix: 'G12' },


// ];
