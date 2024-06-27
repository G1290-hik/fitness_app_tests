import 'package:flutter/material.dart';
import 'package:health_example/src/service/service.dart';
import 'package:health_example/src/utils/theme.dart';
import 'package:health_example/src/widgets/7_day_candlestick_widget.dart';
import 'package:intl/intl.dart';

class HeartRateScreen extends StatefulWidget {
  @override
  _HeartRateScreenState createState() => _HeartRateScreenState();
}

class _HeartRateScreenState extends State<HeartRateScreen> {
  final HealthService _healthService = HealthService();
  List<double> _minHeartRates = [];
  List<double> _maxHeartRates = [];
  List<String> _days = [];
  DateTime _startDate = DateTime.now().subtract(Duration(days: 6));
  DateTime _endDate = DateTime.now();
  bool _isLoading = true;
  double _weeklyMaxHeartRate = 0;
  double _weeklyMinHeartRate = 0;

  @override
  void initState() {
    super.initState();
    _fetchHeartRateData();
  }

  Future<void> _fetchHeartRateData() async {
    setState(() {
      _isLoading = true;
    });

    DateTime startTime = _startDate;

    List<double> minHeartRates = [];
    List<double> maxHeartRates = [];
    List<String> days = [];

    for (int i = 0; i < 7; i++) {
      DateTime dayStart = startTime.add(Duration(days: i));
      DateTime dayEnd = dayStart.add(Duration(days: 1));

      double minHeartRate =
          await _healthService.getMinHeartRate(dayStart, dayEnd);
      double maxHeartRate =
          await _healthService.getMaxHeartRate(dayStart, dayEnd);

      if (minHeartRate > 0) {
        minHeartRates.add(minHeartRate);
      }
      if (maxHeartRate > 0) {
        maxHeartRates.add(maxHeartRate);
      }
      days.add(DateFormat.E().format(dayEnd));
    }

    double weeklyMaxHeartRate = maxHeartRates.isNotEmpty
        ? maxHeartRates.reduce((a, b) => a > b ? a : b)
        : 0;
    double weeklyMinHeartRate = minHeartRates.isNotEmpty
        ? minHeartRates.reduce((a, b) => a < b ? a : b)
        : 0;

    setState(() {
      _minHeartRates = minHeartRates;
      _maxHeartRates = maxHeartRates;
      _days = days;
      _weeklyMaxHeartRate = weeklyMaxHeartRate;
      _weeklyMinHeartRate = weeklyMinHeartRate;
      _isLoading = false;
    });

    // Debugging output
    print('Min heart rates: $_minHeartRates');
    print('Max heart rates: $_maxHeartRates');
    print('Days: $_days');
    print('Weekly Max heart rate: $_weeklyMaxHeartRate');
    print('Weekly Min heart rate: $_weeklyMinHeartRate');
  }

  void _moveBackward() {
    setState(() {
      _startDate = _startDate.subtract(Duration(days: 7));
      _endDate = _endDate.subtract(Duration(days: 7));
      _fetchHeartRateData();
    });
  }

  void _moveForward() {
    DateTime newStartDate = _startDate.add(Duration(days: 7));
    DateTime newEndDate = _endDate.add(Duration(days: 7));

    if (newEndDate.isBefore(DateTime.now())) {
      setState(() {
        _startDate = newStartDate;
        _endDate = newEndDate;
        _fetchHeartRateData();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Format the dates to display in the desired format
    final DateFormat dateFormat = DateFormat("d MMM''yy");
    final String dateRange =
        '${dateFormat.format(_startDate)} - ${dateFormat.format(_endDate)}';

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back_ios),
                  onPressed: _moveBackward,
                  color: const Color.fromARGB(255, 255, 255, 255),
                ),
                Text(
                  dateRange,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.mainTextColor1,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward_ios),
                  onPressed: _moveForward,
                  color: AppColors.contentColorWhite,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : HeartRateChart(
                    minHeartRates: _minHeartRates,
                    maxHeartRates: _maxHeartRates,
                    days: _days,
                  ),
          ),
          Container(
            padding: EdgeInsets.all(8),
            height: 300,
            width: MediaQuery.sizeOf(context).width,
            child: GridView.count(
              crossAxisCount: 2,
              children: [
                Card(
                  color: AppColors.itemsBackground,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Max HR.",
                          style: TextStyle(color: AppColors.mainTextColor2),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '${_weeklyMaxHeartRate.toStringAsFixed(1)}',
                          style: TextStyle(
                            fontSize: 20,
                            color: AppColors.mainTextColor1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  color: AppColors.itemsBackground,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Min HR.",
                          style: TextStyle(color: AppColors.mainTextColor2),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '${_weeklyMinHeartRate.toStringAsFixed(1)}',
                          style: TextStyle(
                            fontSize: 20,
                            color: AppColors.mainTextColor1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
