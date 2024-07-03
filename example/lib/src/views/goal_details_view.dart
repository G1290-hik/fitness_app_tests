import 'package:flutter/material.dart';
import 'package:health_example/src/service/fetcher/fetcher.dart';
import 'package:health_example/src/utils/theme.dart';
import 'package:health_example/src/widgets/charts/step_barchart.dart';
import 'package:health_example/src/widgets/charts/steps_linechart_widget.dart';
import 'package:health_example/src/widgets/grid_widget.dart';

class GoalDetailsScreen extends StatefulWidget {
  @override
  _GoalDetailsScreenState createState() => _GoalDetailsScreenState();
}

class _GoalDetailsScreenState extends State<GoalDetailsScreen>
    with SingleTickerProviderStateMixin {
  final StepDataFetcher _stepDataFetcher = StepDataFetcher();
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
    DateTime endTime7Days = now;

    DateTime startTime30Days = now.subtract(Duration(days: 29));
    DateTime endTime30Days = now;

    _stepsValues1Day = await _stepDataFetcher.fetchStepsData(
        startTime1Day, endTime1Day, Duration(hours: 1));
    _caloriesValues1Day = await _stepDataFetcher.fetchCaloriesData(
        startTime1Day, endTime1Day, Duration(hours: 1));

    _stepsValues7Days = await _stepDataFetcher.fetchStepsData(
        startTime7Days, endTime7Days, Duration(days: 1));
    _caloriesValues7Days = await _stepDataFetcher.fetchCaloriesData(
        startTime7Days, endTime7Days, Duration(days: 1));

    _stepsValues30Days = await _stepDataFetcher.fetchStepsData(
        startTime30Days, endTime30Days, Duration(days: 1));
    _caloriesValues30Days = await _stepDataFetcher.fetchCaloriesData(
        startTime30Days, endTime30Days, Duration(days: 1));

    setState(() {
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
        iconTheme: IconThemeData(color: AppColors.contentColorWhite),
        title:
            Text('Goal', style: TextStyle(color: AppColors.contentColorWhite)),
        backgroundColor: AppColors.pageBackground,
        bottom: TabBar(
          controller: _tabController,
          unselectedLabelColor: AppColors.contentColorWhite,
          labelColor: AppColors.contentColorGreen,
          indicatorColor: AppColors.contentColorWhite,
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
    double totalDistance1Day = _stepsValues1Day.isNotEmpty
        ? _stepsValues1Day.reduce((a, b) => a + b) *
            0.0008 // Example conversion factor
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
        GridWidget(
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
            DataItem(
              title: 'Total Distance',
              value: totalDistance1Day,
              unit: 'km',
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
    double totalDistance7Days = _stepsValues7Days.isNotEmpty
        ? _stepsValues7Days.reduce((a, b) => a + b) *
            0.0008 // Example conversion factor
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
            maxY: 10000,
          ),
        ),
        GridWidget(
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
              unit: 'cals',
            ),
            DataItem(
              title: 'Total Distance',
              value: totalDistance7Days,
              unit: 'km',
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
    double totalDistance30Days = _stepsValues30Days.isNotEmpty
        ? _stepsValues30Days.reduce((a, b) => a + b) *
            0.0008 // Example conversion factor
        : 0;
    return Column(
      children: [
        Expanded(
          child: StepsBarChart(
            stepsValues: _stepsValues30Days,
            dates: List.generate(30,
                (index) => DateTime.now().subtract(Duration(days: 29 - index))),
            barWidth: 5,
            fontSize: 10,
            interval: 5,
            is7DayChart: false,
            maxY: 10000,
          ),
        ),
        GridWidget(
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
              unit: 'cals',
            ),
            DataItem(
              title: 'Total Distance',
              value: totalDistance30Days,
              unit: 'km',
            ),
          ],
        ),
      ],
    );
  }
}
