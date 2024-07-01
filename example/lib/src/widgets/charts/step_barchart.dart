import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:health_example/src/utils/theme.dart';
import 'package:intl/intl.dart';

class StepsBarChart extends StatelessWidget {
  final List<double> stepsValues;
  final List<DateTime> dates;
  final double barWidth;
  final double fontSize;
  final double interval;
  final bool is7DayChart;

  StepsBarChart({
    required this.stepsValues,
    required this.dates,
    required this.barWidth,
    required this.fontSize,
    required this.interval,
    required this.is7DayChart,
    required double maxY,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate maxY based on the maximum step value and round it up to the nearest 1000
    double maxStepsValue = stepsValues.isNotEmpty
        ? stepsValues.reduce((a, b) => a > b ? a : b)
        : 0;
    double maxY = ((maxStepsValue / 1000).ceil() * 1000).toDouble();

    return AspectRatio(
      aspectRatio: is7DayChart ? 1 : 1.2,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceBetween,
              maxY: maxY,
              minY: 0,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  tooltipPadding: EdgeInsets.all(8),
                  tooltipMargin: 8,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    DateTime date = dates[group.x.toInt()];
                    double steps = stepsValues[group.x.toInt()];
                    return BarTooltipItem(
                      '${DateFormat('d MMM').format(date)}\nSteps: $steps',
                      TextStyle(
                          color: AppColors.mainTextColor1,
                          fontWeight: FontWeight.bold,
                          fontSize: 10),
                    );
                  },
                ),
                touchCallback: (FlTouchEvent event, barTouchResponse) {
                  if (event.isInterestedForInteractions &&
                      barTouchResponse != null &&
                      barTouchResponse.spot != null) {
                    final touchIndex =
                        barTouchResponse.spot!.touchedBarGroupIndex;
                    print('Touched index: $touchIndex');
                  } else {
                    print('No bar touched');
                  }
                },
                handleBuiltInTouches: true,
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    interval: interval,
                    showTitles: true,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      int index = value.toInt();
                      if (index % interval == 0 &&
                          index >= 0 &&
                          index < dates.length) {
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(
                            DateFormat('d MMM').format(dates[index]),
                            style: TextStyle(
                              color: AppColors.mainTextColor2,
                              fontSize: fontSize,
                            ),
                          ),
                        );
                      }
                      return Container();
                    },
                    reservedSize: 50,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      return Text(
                        value.toInt().toString(),
                        style: TextStyle(
                            color: AppColors.mainTextColor2, fontSize: 10),
                      );
                    },
                    reservedSize: 35,
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
              barGroups: List.generate(stepsValues.length, (index) {
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: stepsValues[index],
                      gradient: LinearGradient(
                        colors: [
                          AppColors.contentColorGreen,
                          AppColors.contentColorYellow,
                          AppColors.contentColorOrange,
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                      width: barWidth,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ],
                  showingTooltipIndicators: [],
                );
              }),
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
            ),
          ),
        ),
      ),
    );
  }
}
