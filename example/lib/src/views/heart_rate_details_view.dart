import 'package:flutter/material.dart';
import 'package:health_example/src/service/service.dart';
import 'package:health_example/src/utils/theme.dart';
import 'package:health_example/src/widgets/heart_rate_candlestick_widget.dart';
import 'package:health_example/src/widgets/min_max_grid_widget.dart';

class HeartRateDetailScreen extends StatefulWidget {
  @override
  _HeartRateDetailScreenState createState() => _HeartRateDetailScreenState();
}

class _HeartRateDetailScreenState extends State<HeartRateDetailScreen> {
  final HealthService _healthService = HealthService();
  List<double> _minHeartRates7Days = [];
  List<double> _maxHeartRates7Days = [];
  List<DateTime> _dates7Days = [];
  List<double> _minHeartRates30Days = [];
  List<double> _maxHeartRates30Days = [];
  List<DateTime> _dates30Days = [];
  DateTime _startDate = DateTime.now().subtract(Duration(days: 6));
  bool _isLoading = true;
  double _maxHeartRate = 0;
  double _minHeartRate = 0;

  @override
  void initState() {
    super.initState();
    _fetchHeartRateData();
  }

  Future<void> _fetchHeartRateData() async {
    setState(() {
      _isLoading = true;
    });

    DateTime startTime7Days = _startDate;
    DateTime startTime30Days = DateTime.now().subtract(Duration(days: 29));

    List<double> minHeartRates7Days = [];
    List<double> maxHeartRates7Days = [];
    List<DateTime> dates7Days = [];

    List<double> minHeartRates30Days = [];
    List<double> maxHeartRates30Days = [];
    List<DateTime> dates30Days = [];

    double overallMinHeartRate = double.infinity;
    double overallMaxHeartRate = double.negativeInfinity;

    // Fetch 7 days of data
    for (int i = 0; i < 7; i++) {
      DateTime dayStart = startTime7Days.add(Duration(days: i));
      DateTime dayEnd = dayStart.add(Duration(days: 1));

      double minHeartRate =
          await _healthService.getMinHeartRate(dayStart, dayEnd);
      double maxHeartRate =
          await _healthService.getMaxHeartRate(dayStart, dayEnd);

      minHeartRates7Days.add(minHeartRate > 0 ? minHeartRate : 0);
      maxHeartRates7Days.add(maxHeartRate > 0 ? maxHeartRate : 0);
      dates7Days.add(dayStart);

      if (minHeartRate > 0 && minHeartRate < overallMinHeartRate) {
        overallMinHeartRate = minHeartRate;
      }
      if (maxHeartRate > 0 && maxHeartRate > overallMaxHeartRate) {
        overallMaxHeartRate = maxHeartRate;
      }
    }

    // Fetch 30 days of data
    for (int i = 0; i < 30; i++) {
      DateTime dayStart = startTime30Days.add(Duration(days: i));
      DateTime dayEnd = dayStart.add(Duration(days: 1));

      double minHeartRate =
          await _healthService.getMinHeartRate(dayStart, dayEnd);
      double maxHeartRate =
          await _healthService.getMaxHeartRate(dayStart, dayEnd);

      minHeartRates30Days.add(minHeartRate > 0 ? minHeartRate : 0);
      maxHeartRates30Days.add(maxHeartRate > 0 ? maxHeartRate : 0);
      dates30Days.add(dayStart);

      if (minHeartRate > 0 && minHeartRate < overallMinHeartRate) {
        overallMinHeartRate = minHeartRate;
      }
      if (maxHeartRate > 0 && maxHeartRate > overallMaxHeartRate) {
        overallMaxHeartRate = maxHeartRate;
      }
    }

    setState(() {
      _minHeartRates7Days = minHeartRates7Days;
      _maxHeartRates7Days = maxHeartRates7Days;
      _dates7Days = dates7Days;

      _minHeartRates30Days = minHeartRates30Days;
      _maxHeartRates30Days = maxHeartRates30Days;
      _dates30Days = dates30Days;

      _isLoading = false;

      _maxHeartRate = overallMaxHeartRate;
      _minHeartRate = overallMinHeartRate;
    });

    // Debugging output
    print('Min heart rates 7 days: $_minHeartRates7Days');
    print('Max heart rates 7 days: $_maxHeartRates7Days');
    print('Dates 7 days: $_dates7Days');

    print('Min heart rates 30 days: $_minHeartRates30Days');
    print('Max heart rates 30 days: $_maxHeartRates30Days');
    print('Dates 30 days: $_dates30Days');
    print('Overall max heart rate: $_maxHeartRate');
    print('Overall min heart rate: $_minHeartRate');
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
            "Heart Rate",
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
                          DaySummary(
                            minHeartRatesDays: _minHeartRates7Days,
                            maxHeartRatesDays: _maxHeartRates7Days,
                            datesDays: _dates7Days,
                            interval: 1,
                            width: 8,
                            font: 8,
                          ),
                          // 30-day chart
                          DaySummary(
                            minHeartRatesDays: _minHeartRates30Days,
                            maxHeartRatesDays: _maxHeartRates30Days,
                            datesDays: _dates30Days,
                            interval: 5,
                            width: 5,
                            font: 8,
                          ),
                        ],
                      ),
                    ),
                    MinMaxGridWidget(
                      maxHeartRate: _maxHeartRate,
                      minHeartRate: _minHeartRate,
                      showHeartRate: true,
                      minDiastolic: null,
                      minSystolic: null,
                      maxDiastolic: null,
                      maxSystolic: null,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class DaySummary extends StatelessWidget {
  const DaySummary({
    super.key,
    required List<double> minHeartRatesDays,
    required List<double> maxHeartRatesDays,
    required List<DateTime> datesDays,
    required this.interval,
    required this.width,
    required this.font,
  })  : _minHeartRatesDays = minHeartRatesDays,
        _maxHeartRatesDays = maxHeartRatesDays,
        _datesDays = datesDays;

  final List<double> _minHeartRatesDays;
  final List<double> _maxHeartRatesDays;
  final List<DateTime> _datesDays;
  final double interval, width, font;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: CandleStickChart(
            interval: interval,
            fontSize: font,
            barWidth: width,
            minHeartRates: _minHeartRatesDays,
            maxHeartRates: _maxHeartRatesDays,
            dates: _datesDays,
            is7DayChart: false,
          ),
        ),
        //TODO - Add a See History Card ,which leads to a page with history chunked in the manner of the detail_view.
      ],
    );
  }
}
