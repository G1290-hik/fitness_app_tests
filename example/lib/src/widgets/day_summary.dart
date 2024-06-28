
import 'package:flutter/material.dart';

import 'widgets.dart';

class DaySummary extends StatelessWidget {
  const DaySummary({
    super.key,
    required List<double> minHeartRatesDays,
    required List<double> maxHeartRatesDays,
    required List<DateTime> datesDays,
    required this.interval,
    required this.width,
    required this.font,
  })
      : _minHeartRatesDays = minHeartRatesDays,
        _maxHeartRatesDays = maxHeartRatesDays,
        _datesDays = datesDays;

  final List<double> _minHeartRatesDays;
  final List<double> _maxHeartRatesDays;
  final List<DateTime> _datesDays;
  final double interval;
  final double width;
  final double font;

  @override
  Widget build(BuildContext context) {
    //TODO:Add a row widget that let's the user switch the current day
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CandleStickChart(

        fontSize: font,
        interval: interval,
        barWidth: width,
        minHeartRates: _minHeartRatesDays,
        maxHeartRates: _maxHeartRatesDays,
        dates: _datesDays,
        is7DayChart: false,
      ),
    );
  }
}