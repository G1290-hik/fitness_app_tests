import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:health_example/src/utils/theme.dart';
import 'package:intl/intl.dart';

class SingleDayBloodPressureLineChart extends StatelessWidget {
  final List<double> systolicValues;
  final List<double> diastolicValues;
  final DateTime date;
  final double fontSize;
  final double interval;

  SingleDayBloodPressureLineChart({
    required this.fontSize,
    required this.interval,
    required this.systolicValues,
    required this.diastolicValues,
    required this.date,
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

                      // Ensure interval and date.hour are correctly defined
                      if (interval > 0 && index % interval == 0 && index >= 0 && index >= date.hour) {
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(
                            DateFormat('HH:mm').format(
                              date.add(Duration(hours: index)),
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
                  spots: List.generate(systolicValues.length, (index) {
                    return FlSpot(index.toDouble(), systolicValues[index]);
                  }),
                  isCurved: true,
                  color: AppColors.contentColorRed,
                  barWidth: 2,
                  isStrokeCapRound: true,
                  dotData: FlDotData(show: false),
                ),
                LineChartBarData(
                  spots: List.generate(diastolicValues.length, (index) {
                    return FlSpot(index.toDouble(), diastolicValues[index]);
                  }),
                  isCurved: true,
                  color: AppColors.contentColorBlue,
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
                      final time = date.add(Duration(hours: flSpot.x.toInt()));
                      return LineTooltipItem(
                        '${DateFormat('HH:mm').format(time)}\n${flSpot.y.toInt()}',
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
