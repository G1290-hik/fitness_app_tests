import 'package:flutter/material.dart';
import 'package:health_example/src/service/fetcher/fetcher.dart';
import 'package:health_example/src/utils/theme.dart';
import 'package:health_example/src/widgets/widgets.dart';

class HeartRateDetailScreen extends StatefulWidget {
  @override
  _HeartRateDetailScreenState createState() => _HeartRateDetailScreenState();
}

class _HeartRateDetailScreenState extends State<HeartRateDetailScreen>
    with SingleTickerProviderStateMixin {
  final HeartRateFetcher _heartRateFetcher = HeartRateFetcher();
  List<double> _minHeartRates7Days = [];
  List<double> _maxHeartRates7Days = [];
  List<DateTime> _dates7Days = [];
  List<double> _minHeartRates30Days = [];
  List<double> _maxHeartRates30Days = [];
  List<DateTime> _dates30Days = [];
  List<double> _hourlyHeartRatesMin = [];
  List<double> _hourlyHeartRatesMax = [];
  List<DateTime> _hourlyDates = [];
  DateTime _startDate = DateTime.now().subtract(Duration(days: 6));
  bool _isLoading = true;
  double _maxHeartRate = 0;
  double _minHeartRate = 0;
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController?.addListener(_handleTabChange);
    _fetchHeartRateData();
  }

  void _handleTabChange() {
    setState(() {
      switch (_tabController?.index) {
        case 0:
          _updateMinMaxHeartRate(_hourlyHeartRatesMin, _hourlyHeartRatesMax);
          break;
        case 1:
          _updateMinMaxHeartRate(_minHeartRates7Days, _maxHeartRates7Days);
          break;
        case 2:
          _updateMinMaxHeartRate(_minHeartRates30Days, _maxHeartRates30Days);
          break;
      }
    });
  }

  void _updateMinMaxHeartRate(List<double> minRates, List<double> maxRates) {
    double minHeartRate = double.infinity;
    double maxHeartRate = double.negativeInfinity;

    for (int i = 0; i < minRates.length; i++) {
      if (minRates[i] > 0 && minRates[i] < minHeartRate) {
        minHeartRate = minRates[i];
      }
      if (maxRates[i] > 0 && maxRates[i] > maxHeartRate) {
        maxHeartRate = maxRates[i];
      }
    }

    setState(() {
      _minHeartRate = minHeartRate != double.infinity ? minHeartRate : 0;
      _maxHeartRate =
          maxHeartRate != double.negativeInfinity ? maxHeartRate : 0;
    });
  }

  Future<void> _fetchHeartRateData() async {
    setState(() {
      _isLoading = true;
    });

    Map<String, dynamic> data =
        await _heartRateFetcher.fetchHeartRateData(_startDate);

    setState(() {
      _minHeartRates7Days = data['minHeartRates7Days'];
      _maxHeartRates7Days = data['maxHeartRates7Days'];
      _dates7Days = data['dates7Days'];

      _minHeartRates30Days = data['minHeartRates30Days'];
      _maxHeartRates30Days = data['maxHeartRates30Days'];
      _dates30Days = data['dates30Days'];

      _hourlyHeartRatesMin = data['hourlyHeartRatesMin'];
      _hourlyHeartRatesMax = data['hourlyHeartRatesMax'];
      _hourlyDates = data['hourlyDates'];

      _isLoading = false;

      _maxHeartRate = data['overallMaxHeartRate'];
      _minHeartRate = data['overallMinHeartRate'];
    });

    // Debugging output
    print('Min heart rates 7 days: $_minHeartRates7Days');
    print('Max heart rates 7 days: $_maxHeartRates7Days');
    print('Dates 7 days: $_dates7Days');

    print('Min heart rates 30 days: $_minHeartRates30Days');
    print('Max heart rates 30 days: $_maxHeartRates30Days');
    print('Dates 30 days: $_dates30Days');

    print('Hourly heart rates min: $_hourlyHeartRatesMin');
    print('Hourly heart rates max: $_hourlyHeartRatesMax');
    print('Hourly dates: $_hourlyDates');

    print('Overall max heart rate: $_maxHeartRate');
    print('Overall min heart rate: $_minHeartRate');

    // Set initial min and max heart rate based on the 1-day data
    _updateMinMaxHeartRate(_hourlyHeartRatesMin, _hourlyHeartRatesMax);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.pageBackground,
        appBar: AppBar(
          iconTheme: IconThemeData(color: AppColors.contentColorWhite),
          backgroundColor: AppColors.pageBackground.withOpacity(0.8),
          title: Text(
            "Heart Rate",
            style: TextStyle(color: AppColors.mainTextColor1),
          ),
          bottom: TabBar(
            controller: _tabController,
            unselectedLabelColor: AppColors.contentColorWhite,
            indicatorColor: AppColors.contentColorWhite,
            labelColor: AppColors.contentColorOrange,
            tabs: [
              Tab(text: '1 Day'),
              Tab(text: '7 Day'),
              Tab(text: '30 Day'),
            ],
          ),
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator(color: AppColors.contentColorWhite,))
            : SizedBox(
                height: MediaQuery.sizeOf(context).height,
                width: MediaQuery.sizeOf(context).width,
                child: Column(
                  children: [
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          // 1-day chart
                          SingleDayHeartRateLineChart(
                            fontSize: 10,
                            interval: 2,
                            minHeartRateValues: _hourlyHeartRatesMin,
                            maxHeartRateValues: _hourlyHeartRatesMax,
                            dates: _hourlyDates,
                          ),
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
                    GridWidget(
                      dataItems: [
                        DataItem(
                          title: 'Min Heart Rate',
                          value: _minHeartRate,
                          unit: 'bpm',
                        ),
                        DataItem(
                          title: 'Max Heart Rate',
                          value: _maxHeartRate,
                          unit: 'bpm',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }
}
