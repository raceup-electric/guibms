import 'package:flutter/material.dart';
import '../models/enums.dart';

class ConfigurationPanel extends StatefulWidget {
  final ConnectionType connType;
  final BmsMode mode;
  final bool isOn;
  final int baudRate;
  final List<String> ports;
  final String? selectedPort;

  final ValueChanged<ConnectionType> onTypeChanged;
  final ValueChanged<BmsMode> onModeChanged;
  final ValueChanged<bool> onSwitchChanged;
  final ValueChanged<int> onBaudChanged;
  final ValueChanged<String?> onPortChanged;
  final VoidCallback onRefreshPorts;
  final ValueChanged<ThemeMode> onThemeChanged;

  const ConfigurationPanel({
    Key? key,
    required this.connType,
    required this.mode,
    required this.isOn,
    required this.baudRate,
    required this.ports,
    required this.selectedPort,
    required this.onTypeChanged,
    required this.onModeChanged,
    required this.onSwitchChanged,
    required this.onBaudChanged,
    required this.onPortChanged,
    required this.onRefreshPorts,
    required this.onThemeChanged,
  }) : super(key: key);

  @override
  _ConfigurationPanelState createState() => _ConfigurationPanelState();
}

class _ConfigurationPanelState extends State<ConfigurationPanel>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabs,
          tabs: const [
            Tab(text: 'GENERAL'),
            Tab(text: 'SERIAL'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabs,
            children: [
              _buildGeneralTab(context),
              _buildSerialTab(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGeneralTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Mode', style: Theme.of(context).textTheme.titleMedium),
          ...BmsMode.values.map((m) => RadioListTile<BmsMode>(
                title: Text(m.toString().split('.').last.toUpperCase()),
                value: m,
                groupValue: widget.mode,
                onChanged: (v) => widget.onModeChanged(v!),
              )),
          const SizedBox(height: 12),
          Text('Connection', style: Theme.of(context).textTheme.titleMedium),
          ...ConnectionType.values.map((t) => RadioListTile<ConnectionType>(
                title:
                    Text(t == ConnectionType.serial ? 'Serial' : 'WebSocket'),
                value: t,
                groupValue: widget.connType,
                onChanged: (v) => widget.onTypeChanged(v!),
              )),
          const SizedBox(height: 12),
          SwitchListTile(
            title: const Text('ON / OFF'),
            value: widget.isOn,
            onChanged: widget.onSwitchChanged,
          ),
          const Divider(),
          Text('Appearance', style: Theme.of(context).textTheme.titleMedium),
          DropdownButton<ThemeMode>(
            isExpanded: true,
            value: Theme.of(context).brightness == Brightness.dark
                ? ThemeMode.dark
                : ThemeMode.light,
            items: const [
              DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
              DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
              DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
            ],
            onChanged: (ThemeMode? m) {
              if (m != null) widget.onThemeChanged(m);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSerialTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Baud Rate', style: Theme.of(context).textTheme.titleMedium),
          RadioListTile<int>(
            title: const Text('115200'),
            value: 115200,
            groupValue: widget.baudRate,
            onChanged: (v) => widget.onBaudChanged(v!),
          ),
          RadioListTile<int>(
            title: const Text('9600'),
            value: 9600,
            groupValue: widget.baudRate,
            onChanged: (v) => widget.onBaudChanged(v!),
          ),
          const SizedBox(height: 12),
          Text('COM Port', style: Theme.of(context).textTheme.titleMedium),
          Row(
            children: [
              Expanded(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: widget.selectedPort,
                  hint: const Text('Select port'),
                  items: widget.ports
                      .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                      .toList(),
                  onChanged: widget.onPortChanged,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: widget.onRefreshPorts,
                tooltip: 'Refresh Ports',
              ),
            ],
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: widget.onRefreshPorts,
              child: const Text('Refresh Serial'),
            ),
          ),
        ],
      ),
    );
  }
}
