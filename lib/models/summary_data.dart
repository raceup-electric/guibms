class SummaryData {
  final double maxV, minV, balV, totV, avgV;
  final double maxT, minT, avgT, current;
  final List<List<double>> slaveVoltages;
  final List<List<double>> slaveTemps;
  final List<int> slaveErrorCounts;

  SummaryData({
    required this.maxV,
    required this.minV,
    required this.balV,
    required this.totV,
    required this.avgV,
    required this.maxT,
    required this.minT,
    required this.avgT,
    required this.current,
    required this.slaveVoltages,
    required this.slaveTemps,
    required this.slaveErrorCounts,
  });

  factory SummaryData.fromMap(Map<String, dynamic> m) {
    // Parse summary fields
    double maxV = (m['voltages_max'] ?? 0) / 10000;
    double minV = (m['voltages_min'] ?? 0) / 10000;
    double totV = (m['voltages_tot'] ?? 0) / 10000;
    double avgV = (m['voltages_avg'] ?? 0) / 10000;

    double maxT = (m['temps_max'] ?? 0).toDouble();
    double minT = (m['temps_min'] ?? 0).toDouble();
    double avgT = (m['temps_avg'] ?? 0).toDouble();

    double current = (m['current'] ?? 0) / 1000;

    // Determine number of slaves by finding max index
    final slaveIndices = <int>{};
    final regex = RegExp(r"^slaves_(\d+)_");
    for (var key in m.keys) {
      final match = regex.firstMatch(key);
      if (match != null) {
        slaveIndices.add(int.parse(match.group(1)!));
      }
    }
    final sortedIndices = slaveIndices.toList()..sort();

    // Initialize containers
    final slaveVoltages = <List<double>>[];
    final slaveTemps = <List<double>>[];
    final slaveErrorCounts = <int>[];

    for (var idx in sortedIndices) {
      // Collect voltages and temps lists
      final voltList = <double>[];
      final tempList = <double>[];

      // Voltages keys pattern: slaves_{idx}_voltages_{j}
      final voltRegex = RegExp('^slaves_${idx}_voltages_(\\d+)\$');
      final tempRegex = RegExp('^slaves_${idx}_temps_(\\d+)\$');
      for (var key in m.keys) {
        var vm = voltRegex.firstMatch(key);
        if (vm != null) {
          voltList.add((m[key] ?? 0) / 10000);
        }
        var tm = tempRegex.firstMatch(key);
        if (tm != null) {
          tempList.add((m[key] ?? 0).toDouble());
        }
      }

      // Error count
      final errKey = 'slaves_${idx}_errorCount';
      final errCount = m[errKey] ?? 0;

      slaveVoltages.add(voltList);
      slaveTemps.add(tempList);
      slaveErrorCounts
          .add(errCount is int ? errCount : (errCount as num).toInt());
    }

    return SummaryData(
      maxV: maxV,
      minV: minV,
      balV: maxV - minV,
      totV: totV,
      avgV: avgV,
      maxT: maxT,
      minT: minT,
      avgT: avgT,
      current: current,
      slaveVoltages: slaveVoltages,
      slaveTemps: slaveTemps,
      slaveErrorCounts: slaveErrorCounts,
    );
  }

  factory SummaryData.empty() => SummaryData(
        maxV: 0,
        minV: 0,
        balV: 0,
        totV: 0,
        avgV: 0,
        maxT: 0,
        minT: 0,
        avgT: 0,
        current: 0,
        slaveVoltages: [],
        slaveTemps: [],
        slaveErrorCounts: [],
      );
}
