import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class InstallmentsProgressChart extends StatelessWidget {
  final int paidCount;
  final int unpaidCount;

  const InstallmentsProgressChart({
    Key? key,
    required this.paidCount,
    required this.unpaidCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int maxVal = (paidCount > unpaidCount ? paidCount : unpaidCount) + 5;
    if (maxVal < 10) maxVal = 10;

    return SizedBox(
      height: 200,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxVal.toDouble(),
            barTouchData: BarTouchData(enabled: false),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final text = value == 0 ? 'Done' : 'Left';
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  getTitlesWidget: (value, meta) {
                    if (value % 5 != 0) return const SizedBox.shrink();
                    return Text(value.toInt().toString(), style: const TextStyle(fontSize: 10));
                  },
                ),
              ),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            barGroups: [
              BarChartGroupData(
                x: 0,
                barRods: [
                  BarChartRodData(
                    toY: paidCount.toDouble(),
                    color: Colors.blueAccent.shade200,
                    width: 32,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
              BarChartGroupData(
                x: 1,
                barRods: [
                  BarChartRodData(
                    toY: unpaidCount.toDouble(),
                    color: Colors.deepPurpleAccent.shade100,
                    width: 32,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
