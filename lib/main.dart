import 'package:flutter/material.dart';
import 'models/enums.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'controllers/serial_controller.dart';
import 'controllers/websocket_controller.dart';
import 'widgets/configuration_panel.dart';
import 'widgets/data_frame.dart';
import 'models/slave_data.dart';
import 'models/summary_data.dart';

void main() => runApp(BmsApp());

class BmsApp extends StatefulWidget {
  @override
  _BmsAppState createState() => _BmsAppState();
}

class _BmsAppState extends State<BmsApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BMS UIx',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: _themeMode,
      home:
          BmsHome(onThemeChanged: (mode) => setState(() => _themeMode = mode)),
    );
  }
}

class BmsHome extends StatefulWidget {
  final ValueChanged<ThemeMode> onThemeChanged;
  BmsHome({required this.onThemeChanged});

  @override
  _BmsHomeState createState() => _BmsHomeState();
}

class _BmsHomeState extends State<BmsHome> with SingleTickerProviderStateMixin {
  // controllers
  final serialController = SerialController();
  final wsController = WebSocketController();

  // configuration state
  ConnectionType _connType = ConnectionType.serial;
  BmsMode _mode = BmsMode.normal;
  bool _isOn = false;
  int _baudRate = 115200;
  List<String> _ports = [];
  String? _selectedPort;

  // data holders
  List<SlaveData> _slaves = List.generate(12, (_) => SlaveData.empty(11, 5));
  SummaryData _summary = SummaryData.empty();

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _refreshPorts();
  }

  void _refreshPorts() {
    _ports = SerialPort.availablePorts;
    if (_ports.isNotEmpty && !_ports.contains(_selectedPort)) {
      _selectedPort = _ports.first;
    }
    setState(() {});
  }

  void _open() async {
    if (_connType == ConnectionType.serial && _selectedPort != null) {
      SerialPort? port = await serialController.open(_selectedPort!, _baudRate);
      if (port != null && port.isOpen) {
        serialController.setMode(_mode.name[0].toUpperCase());
      }
    } else if (_connType == ConnectionType.websocket) {
      wsController.open('ws://192.168.4.1/ws', _mode.name[0].toUpperCase());
    }
  }

  void _close() {
    if (_connType == ConnectionType.serial)
      serialController.close();
    else
      wsController.close();
  }

  void _onSwitch(bool v) {
    setState(() {
      _isOn = v;
      if (v)
        _open();
      else
        _close();
    });
  }

  void _onMode(BmsMode m) {
    setState(() => _mode = m);
    if (_isOn) {
      if (_connType == ConnectionType.serial)
        serialController.setMode(m.name[0].toUpperCase());
      else
        wsController.setMode(m.name[0].toUpperCase());
    }
  }

  void _onType(ConnectionType t) => setState(() => _connType = t);
  void _onBaud(int b) => setState(() => _baudRate = b);
  void _onPort(String? p) => setState(() => _selectedPort = p);
  void _onTheme(ThemeMode m) => widget.onThemeChanged(m);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('BMS UIx')),
      body: Row(
        children: [
          Container(
            width: 260,
            child: ConfigurationPanel(
              connType: _connType,
              mode: _mode,
              isOn: _isOn,
              baudRate: _baudRate,
              ports: _ports,
              selectedPort: _selectedPort,
              onTypeChanged: _onType,
              onModeChanged: _onMode,
              onSwitchChanged: _onSwitch,
              onBaudChanged: _onBaud,
              onPortChanged: _onPort,
              onRefreshPorts: _refreshPorts,
              onThemeChanged: _onTheme,
            ),
          ),
          Expanded(
            child: DataFrame(
              serialController: serialController,
              wsController: wsController,
              connType: _connType,
              mode: _mode,
              isOn: _isOn,
              baudRate: _baudRate,
              port: _selectedPort,
              onSlaves: (sl) => setState(() => _slaves = sl),
              onSummary: (sm) => setState(() => _summary = sm),
            ),
          ),
        ],
      ),
    );
  }
}
