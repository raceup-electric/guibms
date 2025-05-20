class SlaveData {
  final List<double> voltages;
  final List<double> temps;
  final int errorCount;

  SlaveData(
      {required this.voltages, required this.temps, required this.errorCount});
  factory SlaveData.fromMap(Map<String, dynamic> m) => SlaveData(
        voltages: List<double>.from(m['voltages'].map((v) => v / 10000)),
        temps: List<double>.from(m['temps']),
        errorCount: m['errorCount'],
      );
  factory SlaveData.empty(int nVs, int nTs) => SlaveData(
        voltages: List.filled(nVs, 0),
        temps: List.filled(nTs, 0),
        errorCount: 0,
      );
}
