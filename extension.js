const vscode = require('vscode');
// const SerialPort = require('serialport');
// const Readline = require('@serialport/parser-readline');
// const path = require('path');
// const { fork } = require('child_process');
const { hoverInfoActivate } = require('./hover');
const { graphics } = require('./graphics');
const Printer = require('./printerCommunication');


function activate(context) {
  console.log('Congratulations, your extension "extension" is now active!');
  hoverInfoActivate(context);
  graphics(context);
  let printer;

  context.subscriptions.push(
    vscode.commands.registerCommand('marlin.connect', async () => {
      // Get the port and baud rate from the user or configuration
      const port = await vscode.window.showInputBox({
        prompt: 'Enter the printer port (e.g., COM3)',
        value: vscode.workspace.getConfiguration('marlin').get('port'),
      });

      const baudRate = parseInt(
        await vscode.window.showInputBox({
          prompt: 'Enter the printer baud rate (e.g., 115200)',
          value: vscode.workspace.getConfiguration('marlin').get('baudRate'),
        })
      );

      if (port && baudRate) {
        // Create a new Printer instance and connect to the printer
        printer = new Printer(port, baudRate);
        await printer.connect();
      }
    })
  );

  context.subscriptions.push(
    vscode.commands.registerCommand('marlin.sendCommand', async () => {
      if (!printer) {
        vscode.window.showErrorMessage('Printer not connected');
        return;
      }

      // Get the command from the user
      const command = await vscode.window.showInputBox({
        prompt: 'Enter the G-code command to send',
      });

      if (command) {
        await printer.sendCommand(command);
      }
    })
  );

  context.subscriptions.push(
    vscode.commands.registerCommand('marlin.disconnect', () => {
      if (!printer) {
        vscode.window.showErrorMessage('Printer not connected');
        return;
      }

      printer.close();
      printer = null;
    })
  );

}


function deactivate() {

}

module.exports = {
  activate,
  deactivate
};