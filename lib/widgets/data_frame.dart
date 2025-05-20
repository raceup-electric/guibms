import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../controllers/serial_controller.dart';
import '../controllers/websocket_controller.dart';
import '../models/slave_data.dart';
import '../models/summary_data.dart';
import 'slave_table.dart';
import 'summary_info.dart';
import '../models/enums.dart';

class DataFrame extends StatefulWidget {
  final SerialController serialController;
  final WebSocketController wsController;
  final ConnectionType connType;
  final BmsMode mode;
  final bool isOn;
  final int baudRate;
  final String? port;
  final ValueChanged<List<SlaveData>> onSlaves;
  final ValueChanged<SummaryData> onSummary;

  const DataFrame({
    Key? key,
    required this.serialController,
    required this.wsController,
    required this.connType,
    required this.mode,
    required this.isOn,
    required this.baudRate,
    required this.port,
    required this.onSlaves,
    required this.onSummary,
  }) : super(key: key);

  @override
  _DataFrameState createState() => _DataFrameState();
}

class _DataFrameState extends State<DataFrame> {
  static const int N_SLAVES = 12;
  List<SlaveData> _slaves =
      List.generate(N_SLAVES, (_) => SlaveData.empty(11, 5));
  SummaryData _summary = SummaryData.empty();
  late Timer _timer;

  /// Accumulates serial fragments until we can extract a full JSON
  String _incomplete = '';

  @override
  void initState() {
    super.initState();
    _timer =
        Timer.periodic(const Duration(microseconds: 300), (_) => _update());
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _update() async {
    if (!widget.isOn) return;

    try {
      String? rawJson;

      if (widget.connType == ConnectionType.serial) {
        // 1) Read one packet of bytes
        final data = await widget.serialController.readPacket();
        if (data == null) return;

        // 2) Decode to string (allow malformed)
        _incomplete += utf8.decode(data, allowMalformed: true);

        // 3) Find start of JSON
        final startIdx = _incomplete.indexOf('{');
        if (startIdx < 0) {
          // No JSON start yet; drop old data if too large
          if (_incomplete.length > 4096) _incomplete = '';
          return;
        }

        // 4) Find matching closing brace after that
        final endIdx = _incomplete.indexOf('}', startIdx + 1);
        if (endIdx < 0) {
          // Haven't got full JSON yet—trim leading junk and wait
          if (startIdx > 0) {
            _incomplete = _incomplete.substring(startIdx);
          }
          return;
        }
        print(_incomplete);
        // 5) Extract the full JSON string
        rawJson = _incomplete.substring(startIdx, endIdx + 1);

        // 6) Remove the processed data from buffer
        _incomplete = _incomplete.substring(endIdx + 1);
      } else {
        // Websocket mode: assume full JSON arrives in one call
        rawJson = widget.wsController.readPacket();
      }

      // If we have a JSON payload, parse and update
      if (rawJson.isNotEmpty) {
        final map = json.decode(rawJson) as Map<String, dynamic>;

        // Build summary
        final summary = SummaryData.fromMap(map);

        // Build slaves from flat keys
        final idxRx = RegExp(r'^slaves_(\d+)_');
        final slaveIndices = <int>{};
        for (var key in map.keys) {
          final m = idxRx.firstMatch(key);
          if (m != null) slaveIndices.add(int.parse(m[1]!));
        }
        final sorted = slaveIndices.toList()..sort();

        final slaves = <SlaveData>[];
        for (var i in sorted) {
          final volts = List<double>.generate(
            11,
            (j) => (map['slaves_${i}_voltages_$j'] ?? 0) / 10000,
          );
          final temps = List<double>.generate(
            5,
            (j) => (map['slaves_${i}_temps_$j'] ?? 0).toDouble(),
          );
          final errCount = (map['slaves_${i}_errorCount'] ?? 0) as num;
          slaves.add(SlaveData(
            voltages: volts,
            temps: temps,
            errorCount: errCount.toInt(),
          ));
        }

        // Update UI
        setState(() {
          _slaves = slaves;
          _summary = summary;
        });
        widget.onSlaves(slaves);
        widget.onSummary(summary);
      }
    } catch (e) {
      debugPrint('Error updating data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SlaveTable(slaves: _slaves),
          ),
        ),
        SummaryInfo(summary: _summary),
      ],
    );
  }
}
