import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:health_example/src/service/health_service.dart';
import 'package:health_example/src/utils/theme.dart';
import 'package:health_example/src/widgets/charts/step_barchart.dart';
import 'package:health_example/src/widgets/charts/steps_linechart_widget.dart';
import 'package:health_example/src/widgets/min_max_grid_widget.dart';

class StepDetailsScreen extends StatefulWidget {
  @override
  _StepDetailsScreenState createState() => _StepDetailsScreenState();
}

class _StepDetailsScreenState extends State<StepDetailsScreen>
    with SingleTickerProviderStateMixin {
  final HealthService _healthService = HealthService();
  List<double> _stepsValues1Day = [];
  List<double> _stepsValues7Days = [];
  List<double> _stepsValues30Days = [];
  List<double> _caloriesValues1Day = [];
  List<double> _caloriesValues7Days = [];
  List<double> _caloriesValues30Days = [];
  bool _isLoading = true;
  double _maxSteps = 0;
  double _totalCalories1Day = 0;
  double _totalCalories7Days = 0;
  double _totalCalories30Days = 0;

  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController?.addListener(_updateMinMaxValues);
    _fetchStepData();
  }

  @override
  void dispose() {
    _tabController?.removeListener(_updateMinMaxValues);
    _tabController?.dispose();
    super.dispose();
  }

  void _updateMinMaxValues() {
    setState(() {
      if (_tabController?.index == 1) {
        _maxSteps = _stepsValues7Days.isNotEmpty
            ? _stepsValues7Days.reduce((a, b) => a > b ? a : b)
            : 0;
        _totalCalories7Days = _caloriesValues7Days.reduce((a, b) => a + b);
      } else if (_tabController?.index == 2) {
        _maxSteps = _stepsValues30Days.isNotEmpty
            ? _stepsValues30Days.reduce((a, b) => a > b ? a : b)
            : 0;
        _totalCalories30Days = _caloriesValues30Days.reduce((a, b) => a + b);
      }
    });
  }

  Future<void> _fetchStepData() async {
    setState(() {
      _isLoading = true;
    });

    DateTime now = DateTime.now();
    DateTime startTime1Day = DateTime(now.year, now.month, now.day);
    DateTime endTime1Day = now;

    DateTime startTime7Days = now.subtract(Duration(days: 6));
    DateTime startTime30Days = now.subtract(Duration(days: 29));

    List<double> stepsValues1Day = [];
    List<double> stepsValues7Days = [];
    List<double> stepsValues30Days = [];

    List<double> caloriesValues1Day = [];
    List<double> caloriesValues7Days = [];
    List<double> caloriesValues30Days = [];

    // Fetch 1 day of data from midnight to current time
    for (int i = 0; i <= endTime1Day.difference(startTime1Day).inHours; i++) {
      DateTime hourStart = startTime1Day.add(Duration(hours: i));
      DateTime hourEnd = hourStart.add(Duration(hours: 1));

      double steps = await _healthService.aggregateData(
          [HealthDataType.STEPS],
          hourStart,
          hourEnd,
          (values) => values.isEmpty ? 0 : values.reduce((a, b) => a + b));
      stepsValues1Day.add(steps);

      double calories = await _healthService.aggregateData(
          [HealthDataType.TOTAL_CALORIES_BURNED],
          hourStart,
          hourEnd,
          (values) => values.isEmpty ? 0 : values.reduce((a, b) => a + b));
      caloriesValues1Day.add(calories);
    }

    // Fetch 7 days of data
    for (int i = 0; i < 7; i++) {
      DateTime dayStart = startTime7Days.add(Duration(days: i));
      DateTime dayEnd = dayStart.add(Duration(days: 1));

      double steps = await _healthService.aggregateData(
          [HealthDataType.STEPS],
          dayStart,
          dayEnd,
          (values) => values.isEmpty ? 0 : values.reduce((a, b) => a + b));
      stepsValues7Days.add(steps);

      double calories = await _healthService.aggregateData(
          [HealthDataType.TOTAL_CALORIES_BURNED],
          dayStart,
          dayEnd,
          (values) => values.isEmpty ? 0 : values.reduce((a, b) => a + b));
      caloriesValues7Days.add(calories);
    }

    // Fetch 7 days of data
    for (int i = 0; i < 28; i++) {
      DateTime dayStart = startTime30Days.add(Duration(days: i));
      DateTime dayEnd = dayStart.add(Duration(days: 1));

      double steps = await _healthService.aggregateData(
          [HealthDataType.STEPS],
          dayStart,
          dayEnd,
          (values) => values.isEmpty ? 0 : values.reduce((a, b) => a + b));
      stepsValues30Days.add(steps);

      double calories = await _healthService.aggregateData(
          [HealthDataType.TOTAL_CALORIES_BURNED],
          dayStart,
          dayEnd,
          (values) => values.isEmpty ? 0 : values.reduce((a, b) => a + b));
      caloriesValues30Days.add(calories);
    }

    setState(() {
      _stepsValues1Day = stepsValues1Day;
      _stepsValues7Days = stepsValues7Days;
      _stepsValues30Days = stepsValues30Days;
      _caloriesValues1Day = caloriesValues1Day;
      _caloriesValues7Days = caloriesValues7Days;
      _caloriesValues30Days = caloriesValues30Days;
      _isLoading = false;
      _totalCalories1Day = _caloriesValues1Day.reduce((a, b) => a + b);
      _totalCalories7Days = _caloriesValues7Days.reduce((a, b) => a + b);
      _totalCalories30Days = _caloriesValues30Days.reduce((a, b) => a + b);
      _updateMinMaxValues();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        title:
            Text('Steps', style: TextStyle(color: AppColors.contentColorWhite)),
        backgroundColor: AppColors.pageBackground,
        bottom: TabBar(
          controller: _tabController,
          unselectedLabelColor: AppColors.contentColorWhite,
          labelColor: AppColors.contentColorPink,
          tabs: [
            Tab(text: '1 Day'),
            Tab(text: '7 Days'),
            Tab(text: '30 Days'),
          ],
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _build1DayView(),
                _build7DayView(),
                _build30DayView(),
              ],
            ),
    );
  }

  Widget _build1DayView() {
    double avgSteps1Day = _stepsValues1Day.isNotEmpty
        ? _stepsValues1Day.reduce((a, b) => a + b) / _stepsValues1Day.length
        : 0;
    return Column(
      children: [
        Expanded(
          child: StepsLineChart(
            stepsValues: _stepsValues1Day,
            fontSize: 6,
            interval: 1,
            date: DateTime(
              DateTime.now().year,
              DateTime.now().month,
              DateTime.now().day,
            ),
          ),
        ),
        MinMaxGridWidget(
          dataItems: [
            DataItem(
              title: 'Avg Steps',
              value: avgSteps1Day.toDouble(),
              unit: 'steps',
            ),
            DataItem(
              title: 'Max Steps',
              value: _stepsValues1Day.isNotEmpty
                  ? _stepsValues1Day.reduce((a, b) => a > b ? a : b).toDouble()
                  : 0,
              unit: 'steps',
            ),
            DataItem(
              title: 'Total Calories',
              value: _totalCalories1Day.toDouble(),
              unit: 'calories',
            ),
          ],
        ),
      ],
    );
  }

  Widget _build7DayView() {
    double avgSteps7Days = _stepsValues7Days.isNotEmpty
        ? _stepsValues7Days.reduce((a, b) => a + b) / _stepsValues7Days.length
        : 0;
    return Column(
      children: [
        Expanded(
          child: StepsBarChart(
            stepsValues: _stepsValues7Days,
            dates: List.generate(7,
                (index) => DateTime.now().subtract(Duration(days: 6 - index))),
            barWidth: 15,
            fontSize: 10,
            interval: 1,
            is7DayChart: true,
          ),
        ),
        MinMaxGridWidget(
          dataItems: [
            DataItem(
              title: 'Avg Steps',
              value: avgSteps7Days.toDouble(),
              unit: 'steps',
            ),
            DataItem(
              title: 'Max Steps',
              value: _maxSteps.toDouble(),
              unit: 'steps',
            ),
            DataItem(
              title: 'Total Calories',
              value: _totalCalories7Days.toDouble(),
              unit: 'calories',
            ),
          ],
        ),
      ],
    );
  }

  Widget _build30DayView() {
    double avgSteps30Days = _stepsValues30Days.isNotEmpty
        ? _stepsValues30Days.reduce((a, b) => a + b) / _stepsValues30Days.length
        : 0;
    return Column(
      children: [
        Expanded(
          child: StepsBarChart(
            stepsValues: _stepsValues30Days,
            dates: List.generate(29,
                (index) => DateTime.now().subtract(Duration(days: 29 - index))),
            barWidth: 10,
            fontSize: 10,
            interval: 5,
            is7DayChart: false,
          ),
        ),
        MinMaxGridWidget(
          dataItems: [
            DataItem(
              title: 'Avg Steps',
              value: avgSteps30Days.toDouble(),
              unit: 'steps',
            ),
            DataItem(
              title: 'Max Steps',
              value: _maxSteps.toDouble(),
              unit: 'steps',
            ),
            DataItem(
              title: 'Total Calories',
              value: _totalCalories30Days.toDouble(),
              unit: 'calories',
            ),
          ],
        ),
      ],
    );
  }
}
