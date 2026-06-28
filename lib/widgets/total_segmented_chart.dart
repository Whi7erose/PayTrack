import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class TotalSegmentedChart extends StatelessWidget {
  final int active;
  final int pending;
  final int completed;
  final double totalAmount; // Not really needed for the plan count bar chart, but we keep it

  const TotalSegmentedChart({
    Key? key,
    required this.active, // Monthly
    required this.pending, // Weekly
    required this.completed, // Annually
    required this.totalAmount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int maxVal = [active, pending, completed].reduce((a, b) => a > b ? a : b) + 2;
    if (maxVal < 5) maxVal = 5;

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
                    String text = '';
                    switch (value.toInt()) {
                      case 0:
                        text = 'Weekly';
                        break;
                      case 1:
                        text = 'Monthly';
                        break;
                      case 2:
                        text = 'Annually';
                        break;
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(text, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  getTitlesWidget: (value, meta) {
                    if (value % 2 != 0) return const SizedBox.shrink();
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
                    toY: pending.toDouble(),
                    color: Colors.orangeAccent.shade200,
                    width: 24,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
              BarChartGroupData(
                x: 1,
                barRods: [
                  BarChartRodData(
                    toY: active.toDouble(),
                    color: Colors.cyanAccent.shade400,
                    width: 24,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
              BarChartGroupData(
                x: 2,
                barRods: [
                  BarChartRodData(
                    toY: completed.toDouble(),
                    color: Colors.pinkAccent.shade100,
                    width: 24,
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
