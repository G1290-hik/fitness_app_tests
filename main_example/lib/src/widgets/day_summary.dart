import 'package:flutter/material.dart';

import 'widgets.dart';

class DaySummary extends StatelessWidget {
  const DaySummary({
    super.key,
    required this.minHeartRatesDays,
    required this.maxHeartRatesDays,
    required this.datesDays,
    required this.interval,
    required this.width,
    required this.font,
    required this.isO2,
  });

  final List<double> minHeartRatesDays;
  final List<double> maxHeartRatesDays;
  final List<DateTime> datesDays;
  final double interval;
  final double width;
  final double font;
  final bool isO2;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          isO2
              ? O2CandleStickChart(
                  fontSize: font,
                  interval: interval,
                  barWidth: width,
                  minHeartRates: minHeartRatesDays,
                  maxHeartRates: maxHeartRatesDays,
                  dates: datesDays,
                  is7DayChart: true,
                )
              : CandleStickChart(
                  fontSize: font,
                  interval: interval,
                  barWidth: width,
                  minHeartRates: minHeartRatesDays,
                  maxHeartRates: maxHeartRatesDays,
                  dates: datesDays,
                  is7DayChart: true,
                ),
        ],
      ),
    );
  }
}
