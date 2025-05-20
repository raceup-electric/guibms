import 'package:flutter/material.dart';
import '../models/summary_data.dart';

class SummaryInfo extends StatelessWidget {
  final SummaryData summary;
  SummaryInfo({required this.summary});

  @override
  Widget build(BuildContext context) {
    final labels = [
      'MAX V',
      'MIN V',
      'BAL',
      'TOT V',
      'AVG V',
      'MAX T',
      'MIN T',
      'AVG T',
      'CUR'
    ];
    final values = [
      summary.maxV,
      summary.minV,
      summary.balV,
      summary.totV,
      summary.avgV,
      summary.maxT,
      summary.minT,
      summary.avgT,
      summary.current
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(labels.length, (i) {
        return Column(
          children: [Text(labels[i]), Text(values[i].toStringAsFixed(3))],
        );
      }),
    );
  }
}
