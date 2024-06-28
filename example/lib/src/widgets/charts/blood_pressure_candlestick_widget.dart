import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:health_example/src/utils/theme.dart';
import 'package:intl/intl.dart';

class BloodPressureCandleStickChart extends StatelessWidget {
  final List<double> minSystolic;
  final List<double> maxSystolic;
  final List<double> minDiastolic;
  final List<double> maxDiastolic;
  final List<DateTime> dates;
  final bool is7DayChart;
  final double barWidth;
  final double fontSize;
  final double interval;

  BloodPressureCandleStickChart({
    required this.fontSize,
    required this.interval,
    required this.barWidth,
    required this.minSystolic,
    required this.maxSystolic,
    required this.minDiastolic,
    required this.maxDiastolic,
    required this.dates,
    required this.is7DayChart,
  });

  @override
  Widget build(BuildContext context) {
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
              maxY: 200,
              minY: 0,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  tooltipPadding: EdgeInsets.all(8),
                  tooltipMargin: 8,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    DateTime date = dates[group.x.toInt()];
                    double minSystolicValue = minSystolic[group.x.toInt()];
                    double maxSystolicValue = maxSystolic[group.x.toInt()];
                    double minDiastolicValue = minDiastolic[group.x.toInt()];
                    double maxDiastolicValue = maxDiastolic[group.x.toInt()];
                    return BarTooltipItem(
                      '${DateFormat('d MMM').format(date)}\nMax Systolic: $maxSystolicValue mmHg\nMin Systolic: $minSystolicValue mmHg\nMax Diastolic: $maxDiastolicValue mmHg\nMin Diastolic: $minDiastolicValue mmHg',
                      TextStyle(
                          color: AppColors.mainTextColor1,
                          fontWeight: FontWeight.bold,
                          fontSize: 8),
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
              barGroups: List.generate(minSystolic.length, (index) {
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: maxSystolic[index],
                      gradient: LinearGradient(
                        colors: [
                          AppColors.contentColorPink,
                          AppColors.contentColorRed,
                          AppColors.contentColorOrange,
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                      width: barWidth,
                      borderRadius: BorderRadius.circular(6),
                      rodStackItems: [
                        BarChartRodStackItem(
                          minSystolic[index],
                          minSystolic[index],
                          Colors.transparent,
                        ),
                        BarChartRodStackItem(
                          minSystolic[index],
                          maxSystolic[index],
                          Colors.redAccent,
                        ),
                        BarChartRodStackItem(
                          minDiastolic[index],
                          minDiastolic[index],
                          Colors.transparent,
                        ),
                        BarChartRodStackItem(
                          minDiastolic[index],
                          maxDiastolic[index],
                          Colors.blueAccent,
                        ),
                      ],
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
