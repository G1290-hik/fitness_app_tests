import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:health_example/src/utils/theme.dart';
import 'package:intl/intl.dart';

class StepsLineChart extends StatelessWidget {
  final List<double> stepsValues;
  final double fontSize;
  final double interval;
  final DateTime? date;

  StepsLineChart({
    required this.fontSize,
    required this.interval,
    required this.stepsValues,
    this.date,
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
              maxY: stepsValues.isNotEmpty ? (stepsValues.reduce((a, b) => a > b ? a : b)).toDouble() + 10 : 100,
              minY: 0,
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      int index = value.toInt();
                      if (interval > 0 && index % interval == 0 && index >= 0) {
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(
                            date != null
                                ? DateFormat('HH:mm').format(date!.add(Duration(hours: index)))
                                : '$index',
                            style: TextStyle(
                              color: AppColors.mainTextColor2,
                              fontSize: fontSize,
                            ),
                          ),
                        );
                      }
                      return Container();
                    },
                    reservedSize: 30,
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
                  spots: List.generate(stepsValues.length, (index) {
                    return FlSpot(index.toDouble(), stepsValues[index].toDouble());
                  }),
                  isCurved: true,
                  color: AppColors.contentColorRed,
                  barWidth: 2,
                  isStrokeCapRound: true,
                  dotData: FlDotData(show: false),
                ),
              ],
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (List<LineBarSpot> touchedSpots) {
                    return touchedSpots.map((barSpot) {
                      final flSpot = barSpot;
                      final time = date != null ? date!.add(Duration(hours: flSpot.x.toInt())) : null;
                      return LineTooltipItem(
                        '${time != null ? DateFormat('HH:mm').format(time) : flSpot.x.toInt()}\n${flSpot.y.toInt()}',
                        TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: fontSize,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
