import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:health_example/src/utils/theme.dart';

class HeartRateChart extends StatelessWidget {
  final List<double> minHeartRates;
  final List<double> maxHeartRates;
  final List<String> days;
//TODO - Add gradients instead of static rod colors and add it to the constructor
  HeartRateChart({
    required this.minHeartRates,
    required this.maxHeartRates,
    required this.days,
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
                    String day = days[group.x.toInt()];
                    double minValue = minHeartRates[group.x.toInt()];
                    double maxValue = maxHeartRates[group.x.toInt()];
                    return BarTooltipItem(
                      '$day\nMax HR: $maxValue\nMin HR: $minValue',
                      TextStyle(
                          color: AppColors.mainTextColor1,
                          fontWeight: FontWeight.bold),
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
                    showTitles: true,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: Text(days[value.toInt()],
                            style: TextStyle(
                              color: AppColors.mainTextColor2,
                            )),
                      );
                    },
                    reservedSize: 28,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      return Text(value.toInt().toString(),
                          style: TextStyle(
                            color: AppColors.mainTextColor2,
                          ));
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
                      color: AppColors.contentColorWhite.withOpacity(0.1))),
              barGroups: List.generate(minHeartRates.length, (index) {
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: maxHeartRates[index],
                      color: Colors.redAccent,
                      width: 22,
                      borderRadius: BorderRadius.circular(100),
                      rodStackItems: [
                        BarChartRodStackItem(
                          minHeartRates[index],
                          minHeartRates[index],
                          Colors
                              .transparent, // Transparent part from 0 to minHeartRates
                        ),
                        BarChartRodStackItem(
                          minHeartRates[index],
                          maxHeartRates[index],
                          Colors
                              .redAccent, // Actual visible part from minHeartRates to maxHeartRates
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
