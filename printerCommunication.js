const SerialPort = require('serialport');
const Readline = require('@serialport/parser-readline');

class Printer {
  constructor(port, baudRate) {
    this.port = port;
    this.baudRate = baudRate;
    this.serialPort = new SerialPort(this.port, { baudRate: this.baudRate });
    this.parser = this.serialPort.pipe(new Readline({ delimiter: '\n' }));
  }

  connect() {
    return new Promise((resolve, reject) => {
      this.serialPort.on('open', () => {
        console.log('Connected to printer on', this.port);
        resolve();
      });

      this.serialPort.on('error', (err) => {
        console.error('Failed to connect to printer:', err);
        reject(err);
      });
    });
  }

  sendCommand(command) {
    return new Promise((resolve, reject) => {
      this.serialPort.write(command + '\n', (err) => {
        if (err) {
          console.error('Failed to send command to printer:', err);
          reject(err);
        } else {
          console.log('Command sent:', command);
          resolve();
        }
      });
    });
  }

  onData(callback) {
    this.parser.on('data', callback);
  }

  close() {
    this.serialPort.close((err) => {
      if (err) {
        console.error('Failed to close printer connection:', err);
      } else {
        console.log('Printer connection closed');
      }
    });
  }
}

module.exports = Printer;
