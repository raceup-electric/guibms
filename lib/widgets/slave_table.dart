import 'package:flutter/material.dart';
import '../models/slave_data.dart';

class SlaveTable extends StatelessWidget {
  final List<SlaveData> slaves;
  static const int N_VS = 11;
  static const int N_TS = 5;

  SlaveTable({required this.slaves});

  @override
  Widget build(BuildContext context) {
    return Table(
      border: TableBorder.all(color: Colors.grey),
      defaultColumnWidth: FixedColumnWidth(70),
      children: _buildRows(),
    );
  }

  List<TableRow> _buildRows() {
    List<TableRow> rows = [];
    // Header
    rows.add(TableRow(children: [
      Container(),
      ...List.generate(slaves.length, (i) => Center(child: Text('Slv $i')))
    ]));
    // Data rows
    for (int row = 0; row < N_VS + N_TS; row++) {
      final label = row < N_VS ? 'Cell ${row + 1}' : 'Tmp ${row - N_VS + 1}';
      rows.add(TableRow(children: [
        Container(
            padding: EdgeInsets.all(4),
            color: Colors.grey[300],
            child: Text(label)),
        for (var slv in slaves)
          Container(
            padding: EdgeInsets.all(4),
            color: _cellColor(slv, row),
            child: Text(_cellText(slv, row)),
          ),
      ]));
    }
    return rows;
  }

  String _cellText(SlaveData slv, int index) {
    if (slv.errorCount > 10) return 'DEAD';
    if (slv.errorCount != 0) return 'ERR';
    if (index < N_VS) return slv.voltages[index].toStringAsFixed(3);
    return slv.temps[index - N_VS].toStringAsFixed(2);
  }

  Color _cellColor(SlaveData slv, int index) {
    if (slv.errorCount > 10) return Colors.black;
    if (slv.errorCount != 0) return Colors.grey;
    double val = index < N_VS ? slv.voltages[index] : slv.temps[index - N_VS];
    if (index < N_VS) {
      if (val >= 3.5 && val < 4.1) return Colors.green;
      if ((val >= 3.3 && val < 3.5) || (val >= 4.1 && val < 4.2))
        return Colors.yellow;
      return Colors.red;
    } else {
      if (val < 20) return Colors.blue;
      if (val < 50) return Colors.green;
      if (val < 60) return Colors.yellow;
      return Colors.red;
    }
  }
}
