import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:health_example/src/utils/theme.dart';
import 'package:intl/intl.dart';

class BarChartWidget extends StatelessWidget {
  final List<HealthDataPoint> sleepData;
  final int days;
  final double maxY;
  final int? touchedIndex;
  final Function(int?) onBarTouched;
  final double interval;
  final double barWidth;

  BarChartWidget({
    required this.sleepData,
    required this.days,
    required this.maxY,
    this.touchedIndex,
    required this.onBarTouched,
    required this.interval,
    required this.barWidth,
  });

  List<BarChartGroupData> _convertToBarGroups() {
    return sleepData.asMap().entries.map((entry) {
      int index = entry.key;
      HealthDataPoint dataPoint = entry.value;
      double y = 0.0;
      if (dataPoint.value is NumericHealthValue) {
        y = (dataPoint.value as NumericHealthValue).numericValue.toDouble();
      }
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: y,
            gradient: LinearGradient(
              colors: [
                AppColors.contentColorWhite,
                AppColors.contentColorPurple,
              ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            width: barWidth,
          ),
        ],
        showingTooltipIndicators: touchedIndex == index ? [0] : [],
      );
    }).toList();
  }

  String _formatDuration(Duration duration) {
    int hours = duration.inHours;
    int minutes = duration.inMinutes.remainder(60);
    return '$hours h $minutes m';
  }

  String _getYAxisLabel(double value) {
    Duration duration = Duration(minutes: value.toInt());
    return _formatDuration(duration);
  }

  String _getBottomTitle(double value) {
    int index = value.toInt();
    if (index % interval != 0)
      return ''; // Show title only for specified interval
    if (index < 0 || index >= sleepData.length) return '';
    DateTime date = sleepData[index].dateFrom;
    return DateFormat('dd MMM').format(date);
  }

  @override
  Widget build(BuildContext context) {
    print("Interval: $interval"); // Debug print to check the interval value

    return BarChart(
      BarChartData(
        maxY: maxY,
        barGroups: _convertToBarGroups(),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 60,
              getTitlesWidget: (value, meta) {
                return Text(
                  _getYAxisLabel(value),
                  style: TextStyle(
                      color: AppColors.contentColorWhite, fontSize: 10),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                print(
                    "Bottom title value: $value"); // Debug print for each value
                return Text(
                  _getBottomTitle(value),
                  style: TextStyle(
                      color: AppColors.contentColorWhite, fontSize: 10),
                );
              },
              interval: interval,
            ),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: true),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              Duration duration = Duration(minutes: rod.toY.toInt());
              DateTime date = sleepData[group.x.toInt()].dateFrom;
              return BarTooltipItem(
                '${DateFormat('dd MMM').format(date)}\n${_formatDuration(duration)}',
                TextStyle(color: Colors.white),
              );
            },
            tooltipPadding: const EdgeInsets.all(8),
          ),
          touchCallback: (FlTouchEvent event, barTouchResponse) {
            if (barTouchResponse != null &&
                barTouchResponse.spot != null &&
                event is FlTapUpEvent) {
              onBarTouched(barTouchResponse.spot!.touchedBarGroupIndex);
            } else {
              onBarTouched(null);
            }
          },
          handleBuiltInTouches: true,
        ),
      ),
    );
  }
}
