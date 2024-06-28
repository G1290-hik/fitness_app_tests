import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:health_example/src/service/service.dart';
import 'package:health_example/src/utils/theme.dart';
import 'package:health_example/src/widgets/charts/blood_pressure_candlestick_widget.dart';
import 'package:health_example/src/widgets/charts/blood_pressure_linechart_widget.dart';
import 'package:health_example/src/widgets/min_max_grid_widget.dart';

class BloodPressureDetailScreen extends StatefulWidget {
  @override
  _BloodPressureDetailScreenState createState() =>
      _BloodPressureDetailScreenState();
}

class _BloodPressureDetailScreenState extends State<BloodPressureDetailScreen>
    with SingleTickerProviderStateMixin {
  final HealthService _healthService = HealthService();
  List<double> _systolicValues1Day = [];
  List<double> _diastolicValues1Day = [];
  List<double> _minSystolic7Days = [];
  List<double> _maxSystolic7Days = [];
  List<double> _minDiastolic7Days = [];
  List<double> _maxDiastolic7Days = [];
  List<DateTime> _dates7Days = [];
  List<double> _minSystolic30Days = [];
  List<double> _maxSystolic30Days = [];
  List<double> _minDiastolic30Days = [];
  List<double> _maxDiastolic30Days = [];
  List<DateTime> _dates30Days = [];
  DateTime _startDate = DateTime.now().subtract(Duration(days: 6));
  bool _isLoading = true;
  double _maxSystolic = 0;
  double _minSystolic = 0;
  double _maxDiastolic = 0;
  double _minDiastolic = 0;

  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController?.addListener(_updateMinMaxValues);
    _fetchBloodPressureData();
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
        _maxSystolic = _filterZeroValues(_maxSystolic7Days).isNotEmpty
            ? _filterZeroValues(_maxSystolic7Days)
            .reduce((a, b) => a > b ? a : b)
            : 0;
        _minSystolic = _filterZeroValues(_minSystolic7Days).isNotEmpty
            ? _filterZeroValues(_minSystolic7Days)
            .reduce((a, b) => a < b ? a : b)
            : 0;
        _maxDiastolic = _filterZeroValues(_maxDiastolic7Days).isNotEmpty
            ? _filterZeroValues(_maxDiastolic7Days)
            .reduce((a, b) => a > b ? a : b)
            : 0;
        _minDiastolic = _filterZeroValues(_minDiastolic7Days).isNotEmpty
            ? _filterZeroValues(_minDiastolic7Days)
            .reduce((a, b) => a < b ? a : b)
            : 0;
      } else if (_tabController?.index == 2) {
        _maxSystolic = _filterZeroValues(_maxSystolic30Days).isNotEmpty
            ? _filterZeroValues(_maxSystolic30Days)
            .reduce((a, b) => a > b ? a : b)
            : 0;
        _minSystolic = _filterZeroValues(_minSystolic30Days).isNotEmpty
            ? _filterZeroValues(_minSystolic30Days)
            .reduce((a, b) => a < b ? a : b)
            : 0;
        _maxDiastolic = _filterZeroValues(_maxDiastolic30Days).isNotEmpty
            ? _filterZeroValues(_maxDiastolic30Days)
            .reduce((a, b) => a > b ? a : b)
            : 0;
        _minDiastolic = _filterZeroValues(_minDiastolic30Days).isNotEmpty
            ? _filterZeroValues(_minDiastolic30Days)
            .reduce((a, b) => a < b ? a : b)
            : 0;
      }
    });
  }

  Future<void> _fetchBloodPressureData() async {
    setState(() {
      _isLoading = true;
    });

    DateTime startTime1Day = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );

    DateTime endTime1Day = DateTime.now();

    DateTime startTime7Days = _startDate;
    DateTime startTime30Days = DateTime.now().subtract(Duration(days: 29));

    List<double> systolicValues1Day = [];
    List<double> diastolicValues1Day = [];
    List<double> minSystolic7Days = [];
    List<double> maxSystolic7Days = [];
    List<double> minDiastolic7Days = [];
    List<double> maxDiastolic7Days = [];
    List<DateTime> dates7Days = [];

    List<double> minSystolic30Days = [];
    List<double> maxSystolic30Days = [];
    List<double> minDiastolic30Days = [];
    List<double> maxDiastolic30Days = [];
    List<DateTime> dates30Days = [];

    // Fetch 1 day of data from midnight to current time
    for (int i = 0; i <= endTime1Day.difference(startTime1Day).inHours; i++) {
      DateTime hourStart = startTime1Day.add(Duration(hours: i));
      DateTime hourEnd = hourStart.add(Duration(hours: 1));

      double systolic = await _healthService.aggregateData(
          [HealthDataType.BLOOD_PRESSURE_SYSTOLIC],
          hourStart,
          hourEnd,
              (values) => values.isEmpty
              ? 0
              : values.reduce((a, b) => a + b) / values.length);
      double diastolic = await _healthService.aggregateData(
          [HealthDataType.BLOOD_PRESSURE_DIASTOLIC],
          hourStart,
          hourEnd,
              (values) => values.isEmpty
              ? 0
              : values.reduce((a, b) => a + b) / values.length);

      systolicValues1Day.add(systolic);
      diastolicValues1Day.add(diastolic);
    }

    // Fetch 7 days of data
    for (int i = 0; i < 7; i++) {
      DateTime dayStart = startTime7Days.add(Duration(days: i));
      DateTime dayEnd = dayStart.add(Duration(days: 1));

      double minSystolic =
      await _healthService.getMinSystolicBloodPressure(dayStart, dayEnd);
      double maxSystolic =
      await _healthService.getMaxSystolicBloodPressure(dayStart, dayEnd);
      double minDiastolic =
      await _healthService.getMinDiastolicBloodPressure(dayStart, dayEnd);
      double maxDiastolic =
      await _healthService.getMaxDiastolicBloodPressure(dayStart, dayEnd);

      minSystolic7Days.add(minSystolic);
      maxSystolic7Days.add(maxSystolic);
      minDiastolic7Days.add(minDiastolic);
      maxDiastolic7Days.add(maxDiastolic);
      dates7Days.add(dayStart);
    }

    // Fetch 30 days of data
    for (int i = 0; i < 30; i++) {
      DateTime dayStart = startTime30Days.add(Duration(days: i));
      DateTime dayEnd = dayStart.add(Duration(days: 1));

      double minSystolic =
      await _healthService.getMinSystolicBloodPressure(dayStart, dayEnd);
      double maxSystolic =
      await _healthService.getMaxSystolicBloodPressure(dayStart, dayEnd);
      double minDiastolic =
      await _healthService.getMinDiastolicBloodPressure(dayStart, dayEnd);
      double maxDiastolic =
      await _healthService.getMaxDiastolicBloodPressure(dayStart, dayEnd);

      minSystolic30Days.add(minSystolic);
      maxSystolic30Days.add(maxSystolic);
      minDiastolic30Days.add(minDiastolic);
      maxDiastolic30Days.add(maxDiastolic);
      dates30Days.add(dayStart);
    }

    setState(() {
      _systolicValues1Day = systolicValues1Day;
      _diastolicValues1Day = diastolicValues1Day;
      _minSystolic7Days = minSystolic7Days;
      _maxSystolic7Days = maxSystolic7Days;
      _minDiastolic7Days = minDiastolic7Days;
      _maxDiastolic7Days = maxDiastolic7Days;
      _dates7Days = dates7Days;
      _minSystolic30Days = minSystolic30Days;
      _maxSystolic30Days = maxSystolic30Days;
      _minDiastolic30Days = minDiastolic30Days;
      _maxDiastolic30Days = maxDiastolic30Days;
      _dates30Days = dates30Days;
      _isLoading = false;
      _updateMinMaxValues();
    });
  }

  List<double> _filterZeroValues(List<double> values) {
    return values.where((value) => value != 0).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        title: Text('Blood Pressure',style: TextStyle(color: AppColors.contentColorWhite),),
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
//TODO:Add a row widget that let's the user switch the current day
  Widget _build1DayView() {
    return Column(
      children: [
        Expanded(
          child: SingleDayBloodPressureLineChart(
            systolicValues: _systolicValues1Day,
            diastolicValues: _diastolicValues1Day,
            fontSize: 6,
            interval: 1,
            date: DateTime(
              DateTime.now().year,
              DateTime.now().month,
              DateTime.now().day,
            ), // Start date set to midnight of the current day
          ),
        ),
        MinMaxGridWidget(
          minSystolic: _filterZeroValues(_systolicValues1Day).isNotEmpty
              ? _filterZeroValues(_systolicValues1Day)
              .reduce((a, b) => a < b ? a : b)
              : 0,
          maxSystolic: _filterZeroValues(_systolicValues1Day).isNotEmpty
              ? _filterZeroValues(_systolicValues1Day)
              .reduce((a, b) => a > b ? a : b)
              : 0,
          minDiastolic: _filterZeroValues(_diastolicValues1Day).isNotEmpty
              ? _filterZeroValues(_diastolicValues1Day)
              .reduce((a, b) => a < b ? a : b)
              : 0,
          maxDiastolic: _filterZeroValues(_diastolicValues1Day).isNotEmpty
              ? _filterZeroValues(_diastolicValues1Day)
              .reduce((a, b) => a > b ? a : b)
              : 0,
          showHeartRate: false,
          maxHeartRate: null,
          minHeartRate: null,
        ),
      ],
    );
  }

  Widget _build7DayView() {
    return Column(
      children: [
        Expanded(
          child: BloodPressureCandleStickChart(
            minSystolic: _minSystolic7Days,
            maxSystolic: _maxSystolic7Days,
            minDiastolic: _minDiastolic7Days,
            maxDiastolic: _maxDiastolic7Days,

            dates: _dates7Days,
            fontSize: 8, interval: 1, barWidth: 6, is7DayChart: false,
          ),
        ),
        MinMaxGridWidget(
          minSystolic: _minSystolic,
          maxSystolic: _maxSystolic,
          minDiastolic: _minDiastolic,
          maxDiastolic: _maxDiastolic,
          showHeartRate: false,
          maxHeartRate: null,
          minHeartRate: null,
        ),
      ],
    );
  }

  Widget _build30DayView() {
    return Column(
      children: [
        Expanded(
          child: BloodPressureCandleStickChart(
            minSystolic: _minSystolic30Days,
            maxSystolic: _maxSystolic30Days,
            minDiastolic: _minDiastolic30Days,
            maxDiastolic: _maxDiastolic30Days,
            dates: _dates30Days,
            fontSize: 8, interval: 3,is7DayChart: false,barWidth: 5,

          ),
        ),
        MinMaxGridWidget(
          minSystolic: _minSystolic,
          maxSystolic: _maxSystolic,
          minDiastolic: _minDiastolic,
          maxDiastolic: _maxDiastolic,
          showHeartRate: false,
          maxHeartRate: null,
          minHeartRate: null,
        ),
      ],
    );
  }
}
