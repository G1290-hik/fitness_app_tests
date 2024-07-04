import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:health_example/src/widgets/grid_widget.dart';

import 'charts/bar_chart.dart';

class SleepDataWidget extends StatelessWidget {
  final List<HealthDataPoint> sleepData;
  final double maxY;
  final int? touchedIndex;
  final Function(int?) onBarTouched;
  final int days;
  final double interval;

  SleepDataWidget({
    required this.sleepData,
    required this.maxY,
    this.touchedIndex,
    required this.onBarTouched,
    required this.days,
    required this.interval,
  });

  @override
  Widget build(BuildContext context) {
    HealthDataPoint? longestSession = sleepData.isNotEmpty
        ? sleepData.reduce((a, b) =>
    (a.value as NumericHealthValue).numericValue >
        (b.value as NumericHealthValue).numericValue
        ? a
        : b)
        : null;

    HealthDataPoint? smallestSession = sleepData.isNotEmpty
        ? sleepData.reduce((a, b) =>
    (a.value as NumericHealthValue).numericValue <
        (b.value as NumericHealthValue).numericValue
        ? a
        : b)
        : null;

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            padding: const EdgeInsets.all(8.0),
            height: 300, // Adjust height as needed
            child: BarChartWidget(
              barWidth:days>7?5:12,
              sleepData: sleepData,
              days: days,
              maxY: maxY,
              touchedIndex: touchedIndex,
              onBarTouched: onBarTouched,
              interval: interval,
            ),
          ),
        ),
        GridWidget(
          dataItems: [
            if (longestSession != null)
              DataItem(
                title: 'Longest Sleep Session',
                value: (longestSession.value as NumericHealthValue)
                    .numericValue
                    .toDouble(),
                unit: 'minutes',
              ),
            if (smallestSession != null)
              DataItem(
                title: 'Smallest Sleep Session',
                value: (smallestSession.value as NumericHealthValue)
                    .numericValue
                    .toDouble(),
                unit: 'minutes',
              ),
          ],
        ),
      ],
    );
  }
}
