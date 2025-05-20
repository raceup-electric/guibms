import 'dart:async';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter_libserialport/flutter_libserialport.dart';

class SerialController {
  SerialPort? _port;
  SerialPortReader? _reader;
  List<int> _buffer = [];
  final int _packetSize = 64; // Match ESP32's packet size

  Future<void> close() async {
    _reader?.close();
    if (_port?.isOpen == true) {
      _port!.write(Uint8List.fromList([0x44])); // Send 'D' as byte
      _port!.close();
    }
  }

  Future<Uint8List?> readPacket() async {
    // Wait until buffer has at least one full packet
    while (_buffer.length < _packetSize) {
      await Future.delayed(Duration(microseconds: 10));
    }

    // Extract packet and remove from buffer
    final packet = Uint8List.fromList(_buffer.sublist(0, _packetSize));
    _buffer.removeRange(0, _packetSize);
    return packet;
  }

  Future<SerialPort?> open(String portName, int baudRate) async {
    try {
      _port = SerialPort(portName);
      print(portName);
      _port!.open(mode: 3);
      if (_port!.isOpen) {
        print('OK');
      }
      _port!.config = SerialPortConfig()
        ..baudRate = 115200
        ..bits = 8
        ..stopBits = 1
        ..parity = SerialPortParity.none
        ..rts = SerialPortRts.flowControl
        ..cts = SerialPortCts.flowControl
        ..dsr = SerialPortDsr.flowControl
        ..dtr = SerialPortDtr.flowControl
        ..setFlowControl(SerialPortFlowControl.rtsCts);

      _reader = SerialPortReader(_port!);

      // Start continuous binary data listener
      _reader!.stream.listen((data) {
        _buffer.addAll(data);
      });

      // Send 'C' as byte (0x43)
      _port!.write(Uint8List.fromList([0x43]));
      return _port;
    } catch (e) {
      print("Port open error: $e");
      return null;
    }
  }

  void setMode(String mode) {
    if (_port != null && _port!.isOpen) {
      _port!.write(Uint8List.fromList(utf8.encode(mode)));
    }
  }
}
