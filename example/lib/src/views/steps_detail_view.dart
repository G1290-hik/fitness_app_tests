import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:health_example/src/service/service.dart';
import 'package:health_example/src/utils/theme.dart';
import 'package:intl/intl.dart'; // Add this import for date formatting

class StepDetailsScreen extends StatefulWidget {
  @override
  _StepDetailsScreenState createState() => _StepDetailsScreenState();
}

class _StepDetailsScreenState extends State<StepDetailsScreen> {
  final HealthService _healthService = HealthService();
  int _selectedChipIndex = 0;
  double _totalSteps = 0;
  double _totalDistance = 0.0;
  double _totalCalories = 0.0;
  bool _isLoading = false;

  List<FlSpot> _stepSpots = [];

  final List<String> _chipLabels = ['1 DAY', '7 DAY', '30 DAY'];

  @override
  void initState() {
    super.initState();
    _initializeHealthService();
    _fetchHealthData();
  }

  Future<void> _initializeHealthService() async {
    await _healthService.configureHealth();
    await _healthService.authorize();
  }

  Future<void> _fetchHealthData() async {
    setState(() {
      _isLoading = true;
    });

    DateTime now = DateTime.now();
    DateTime startTime;
    int interval;
    int numberOfIntervals;

    switch (_selectedChipIndex) {
      case 0:
        // 1-day view: fetch hourly data
        startTime = DateTime(now.year, now.month, now.day); // Start of today
        interval = 1; // hours
        numberOfIntervals = 24;
        break;
      case 1:
        // 7-day view: fetch daily data
        startTime = now.subtract(Duration(days: 6));
        interval = 24; // hours
        numberOfIntervals = 7;
        break;
      case 2:
        // 30-day view: fetch daily data
        startTime = now.subtract(Duration(days: 29));
        interval = 24; // hours
        numberOfIntervals = 30;
        break;
      default:
        return;
    }

    double totalSteps = 0;
    double totalDistance = 0.0;
    double totalCalories = 0.0;

    List<FlSpot> stepSpots = [];
    DateTime currentTime = startTime;

    for (int i = 0; i < numberOfIntervals; i++) {
      DateTime nextTime = currentTime.add(Duration(hours: interval));
      double steps = await _healthService.getTotalSteps(currentTime, nextTime);
      double distance = await _healthService.getDistance(currentTime, nextTime);
      double calories =
          await _healthService.getCaloriesBurnt(currentTime, nextTime);

      totalSteps += steps;
      totalDistance += distance;
      totalCalories += calories;

      stepSpots.add(
        FlSpot(i.toDouble(), totalSteps),
      );

      currentTime = nextTime;
    }

    setState(() {
      _totalSteps = totalSteps;
      _totalDistance = totalDistance;
      _totalCalories = totalCalories;
      _stepSpots = stepSpots;
      _isLoading = false;
    });

    // Debug prints
    debugPrint('Total steps: $_totalSteps');
    debugPrint('Total distance: $_totalDistance km');
    debugPrint('Total calories: $_totalCalories kcal');
  }

  void _onChipSelected(int index) {
    setState(() {
      _selectedChipIndex = index;
      _isLoading = true;
    });
    _fetchHealthData(); // Fetch and update data based on the selected chip
  }

  String _getCurrentDate() {
    DateTime now = DateTime.now();
    return DateFormat('d MMM yyyy').format(now);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        backgroundColor: AppColors.menuBackground,
        title: Text('Step Details'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        height: MediaQuery.sizeOf(context).height,
        width: MediaQuery.sizeOf(context).width,
        child: ListView(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List<Widget>.generate(
                _chipLabels.length,
                (int index) {
                  return ChoiceChip(
                    label: Text(_chipLabels[index]),
                    selected: _selectedChipIndex == index,
                    onSelected: (bool selected) {
                      _onChipSelected(index);
                    },
                  );
                },
              ).toList(),
            ),
            SizedBox(height: 16),
            Text(
              _getCurrentDate(), // Use the current date here
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'TOTAL',
              style: TextStyle(fontSize: 18, color: AppColors.mainTextColor2),
            ),
            Text(
              '${_totalSteps.toStringAsFixed(0)} steps',
              style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.mainTextColor1),
            ),
            SizedBox(height: 16),
            OneDayLineChart(
              isLoading: _isLoading,
              totalSteps: _totalSteps,
              stepSpots: _stepSpots,
              selectedChipIndex: _selectedChipIndex,
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      'TOTAL DISTANCE',
                      style: TextStyle(color: AppColors.mainTextColor2),
                    ),
                    Text(
                      '${_totalDistance.toStringAsFixed(1)} km',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.mainTextColor1),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      'TOTAL CALORIES',
                      style: TextStyle(color: AppColors.mainTextColor2),
                    ),
                    Text(
                      '${_totalCalories.toStringAsFixed(0)} kcal',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.mainTextColor1),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class OneDayLineChart extends StatelessWidget {
  const OneDayLineChart({
    Key? key,
    required bool isLoading,
    required double totalSteps,
    required List<FlSpot> stepSpots,
    required int selectedChipIndex,
  })  : _isLoading = isLoading,
        _stepSpots = stepSpots,
        _selectedChipIndex = selectedChipIndex,
        super(key: key);

  final bool _isLoading;
  final List<FlSpot> _stepSpots;
  final int _selectedChipIndex;

  String formatHour(int hour) {
    if (hour == 0 || hour == 24) {
      return '12AM';
    } else if (hour == 12) {
      return '12PM';
    } else if (hour < 12) {
      return '${hour}AM';
    } else {
      return '${hour - 12}PM';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      width: 300,
      padding: EdgeInsets.all(8),
      child: _isLoading
          ? Center(child: CircularProgressIndicator())
          : LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 60,
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Text(
                            formatHour(value.toInt()),
                            style: TextStyle(color: AppColors.mainTextColor1),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX:
                    _selectedChipIndex == 0 ? 24 : _stepSpots.length.toDouble(),
                minY: 0,
                maxY: 12000,
                lineBarsData: [
                  LineChartBarData(
                    spots: _stepSpots,
                    isCurved: true,
                    color: Colors.lightBlueAccent,
                    barWidth: 5,
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (List<LineBarSpot> touchedSpots) {
                      return touchedSpots.map((LineBarSpot touchedSpot) {
                        final flSpot = touchedSpot;
                        return LineTooltipItem(
                          'Hour: ${formatHour(flSpot.x.toInt())}\nSteps: ${flSpot.y.toInt()}',
                          const TextStyle(color: Colors.white),
                        );
                      }).toList();
                    },
                  ),
                  touchCallback:
                      (FlTouchEvent event, LineTouchResponse? response) {
                    if (response == null || response.lineBarSpots == null) {
                      return;
                    }
                  },
                  handleBuiltInTouches: true,
                ),
              ),
            ),
    );
  }
}
