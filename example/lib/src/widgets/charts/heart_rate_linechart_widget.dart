import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:health_example/src/utils/theme.dart';
import 'package:intl/intl.dart';

class SingleDayHeartRateLineChart extends StatelessWidget {
  final List<double> minHeartRateValues;
  final List<double> maxHeartRateValues;
  final List<DateTime> dates;
  final double fontSize;
  final double interval;

  SingleDayHeartRateLineChart({
    required this.fontSize,
    required this.interval,
    required this.minHeartRateValues,
    required this.maxHeartRateValues,
    required this.dates,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.2,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: LineChart(
            LineChartData(
              maxY: 200,
              minY: 0,
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      int index = value.toInt();
                      if (index % interval == 0 &&
                          index >= 0 &&
                          index < dates.length) {
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(
                            DateFormat('HH:mm').format(
                              dates[index],
                            ),
                            style: TextStyle(
                              color: AppColors.mainTextColor2,
                              fontSize: fontSize,
                            ),
                          ),
                        );
                      }
                      return Container();
                    },
                    reservedSize: 45,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      return Text(
                        value.toInt().toString(),
                        style: TextStyle(
                          color: AppColors.mainTextColor2,
                        ),
                      );
                    },
                    reservedSize: 40,
                  ),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(
                    width: 2,
                    color: AppColors.contentColorWhite.withOpacity(0.1)),
              ),
              gridData: FlGridData(
                show: true,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: AppColors.gridLinesColor,
                    strokeWidth: 2,
                  );
                },
                drawVerticalLine: true,
                getDrawingVerticalLine: (value) {
                  return FlLine(
                    color: AppColors.gridLinesColor,
                    strokeWidth: 2,
                  );
                },
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: List.generate(minHeartRateValues.length, (index) {
                    return FlSpot(index.toDouble(), minHeartRateValues[index]);
                  }),
                  isCurved: true,
                  color: AppColors.contentColorPink,
                  barWidth: 4,
                  isStrokeCapRound: true,
                  dotData: FlDotData(show: false),
                ),
                LineChartBarData(
                  spots: List.generate(maxHeartRateValues.length, (index) {
                    return FlSpot(index.toDouble(), maxHeartRateValues[index]);
                  }),
                  isCurved: true,
                  color: AppColors.contentColorRed,
                  barWidth: 4,
                  isStrokeCapRound: true,
                  dotData: FlDotData(show: false),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
