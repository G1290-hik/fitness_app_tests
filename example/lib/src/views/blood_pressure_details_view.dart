import 'package:flutter/material.dart';
import 'package:health_example/src/service/service.dart';
import 'package:health_example/src/utils/theme.dart';
import 'package:health_example/src/widgets/blood_pressure_candlestick_widget.dart';
import 'package:health_example/src/widgets/min_max_grid_widget.dart';

class BloodPressureDetailScreen extends StatefulWidget {
  @override
  _BloodPressureDetailScreenState createState() =>
      _BloodPressureDetailScreenState();
}

class _BloodPressureDetailScreenState extends State<BloodPressureDetailScreen> {
  final HealthService _healthService = HealthService();
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

  @override
  void initState() {
    super.initState();
    _fetchBloodPressureData();
  }

  Future<void> _fetchBloodPressureData() async {
    setState(() {
      _isLoading = true;
    });

    DateTime startTime7Days = _startDate;
    DateTime startTime30Days = DateTime.now().subtract(Duration(days: 29));

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

      // Calculate overall min and max values for displaying in the MinMaxGridWidget
      _maxSystolic = _filterZeroValues(maxSystolic7Days).isNotEmpty
          ? _filterZeroValues(maxSystolic7Days).reduce((a, b) => a > b ? a : b)
          : 0;
      _minSystolic = _filterZeroValues(minSystolic7Days).isNotEmpty
          ? _filterZeroValues(minSystolic7Days).reduce((a, b) => a < b ? a : b)
          : 0;
      _maxDiastolic = _filterZeroValues(maxDiastolic7Days).isNotEmpty
          ? _filterZeroValues(maxDiastolic7Days).reduce((a, b) => a > b ? a : b)
          : 0;
      _minDiastolic = _filterZeroValues(minDiastolic7Days).isNotEmpty
          ? _filterZeroValues(minDiastolic7Days).reduce((a, b) => a < b ? a : b)
          : 0;

      _isLoading = false;
    });

    // Debugging output
    print('Min systolic 7 days: $_minSystolic7Days');
    print('Max systolic 7 days: $_maxSystolic7Days');
    print('Min diastolic 7 days: $_minDiastolic7Days');
    print('Max diastolic 7 days: $_maxDiastolic7Days');
    print('Dates 7 days: $_dates7Days');

    print('Min systolic 30 days: $_minSystolic30Days');
    print('Max systolic 30 days: $_maxSystolic30Days');
    print('Min diastolic 30 days: $_minDiastolic30Days');
    print('Max diastolic 30 days: $_maxDiastolic30Days');
    print('Dates 30 days: $_dates30Days');
  }

  List<double> _filterZeroValues(List<double> values) {
    return values.where((value) => value != 0).toList();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.pageBackground,
        appBar: AppBar(
          backgroundColor: AppColors.pageBackground.withOpacity(0.8),
          title: Text(
            "Blood Pressure",
            style: TextStyle(color: AppColors.mainTextColor1),
          ),
          bottom: TabBar(
            unselectedLabelColor: AppColors.contentColorWhite,
            indicatorColor: AppColors.contentColorWhite,
            labelColor: AppColors.contentColorOrange,
            tabs: [
              Tab(
                text: '1 Day',
              ),
              Tab(
                text: '7 Day',
              ),
              Tab(
                text: '30 Day',
              ),
            ],
          ),
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : SizedBox(
                height: MediaQuery.sizeOf(context).height,
                width: MediaQuery.sizeOf(context).width,
                child: Column(
                  children: [
                    Expanded(
                      child: TabBarView(
                        children: [
                          //1-day chart
                          Placeholder(),
                          // 7-day chart
                          BloodPressureDaySummary(
                            minSystolic: _minSystolic7Days,
                            maxSystolic: _maxSystolic7Days,
                            minDiastolic: _minDiastolic7Days,
                            maxDiastolic: _maxDiastolic7Days,
                            dates: _dates7Days,
                            interval: 1,
                            barWidth: 8,
                            fontSize: 8,
                          ),
                          // 30-day chart
                          BloodPressureDaySummary(
                            minSystolic: _minSystolic30Days,
                            maxSystolic: _maxSystolic30Days,
                            minDiastolic: _minDiastolic30Days,
                            maxDiastolic: _maxDiastolic30Days,
                            dates: _dates30Days,
                            interval: 5,
                            barWidth: 5,
                            fontSize: 8,
                          ),
                        ],
                      ),
                    ),
                    MinMaxGridWidget(
                      maxSystolic: _maxSystolic,
                      minSystolic: _minSystolic,
                      maxDiastolic: _maxDiastolic,
                      minDiastolic: _minDiastolic,
                      maxHeartRate: null,
                      minHeartRate: null,
                      showHeartRate: false,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class BloodPressureDaySummary extends StatelessWidget {
  const BloodPressureDaySummary({
    super.key,
    required List<double> minSystolic,
    required List<double> maxSystolic,
    required List<double> minDiastolic,
    required List<double> maxDiastolic,
    required List<DateTime> dates,
    required this.interval,
    required this.barWidth,
    required this.fontSize,
  })  : _minSystolic = minSystolic,
        _maxSystolic = maxSystolic,
        _minDiastolic = minDiastolic,
        _maxDiastolic = maxDiastolic,
        _dates = dates;

  final List<double> _minSystolic;
  final List<double> _maxSystolic;
  final List<double> _minDiastolic;
  final List<double> _maxDiastolic;
  final List<DateTime> _dates;
  final double interval;
  final double barWidth;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: BloodPressureCandleStickChart(
              minSystolic: _minSystolic,
              maxSystolic: _maxSystolic,
              minDiastolic: _minDiastolic,
              maxDiastolic: _maxDiastolic,
              dates: _dates,
              interval: interval,
              barWidth: barWidth,
              fontSize: fontSize,
              is7DayChart: false,
            ),
          ),
        ],
      ),
    );
  }
}
