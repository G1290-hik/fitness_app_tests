import 'package:flutter/material.dart';
import 'package:health_example/src/service/fetcher/blood_oxygen_fetcher.dart';
import 'package:health_example/src/utils/theme.dart';
import 'package:health_example/src/widgets/widgets.dart';

class BloodOxygenDetailScreen extends StatefulWidget {
  @override
  _BloodOxygenDetailScreenState createState() =>
      _BloodOxygenDetailScreenState();
}

class _BloodOxygenDetailScreenState extends State<BloodOxygenDetailScreen>
    with SingleTickerProviderStateMixin {
  final BloodOxygenFetcher _bloodOxygenFetcher = BloodOxygenFetcher();
  List<double> _minBloodOxygen7Days = [];
  List<double> _maxBloodOxygen7Days = [];
  List<DateTime> _dates7Days = [];
  List<double> _minBloodOxygen30Days = [];
  List<double> _maxBloodOxygen30Days = [];
  List<DateTime> _dates30Days = [];
  List<double> _hourlyBloodOxygenMin = [];
  List<double> _hourlyBloodOxygenMax = [];
  List<DateTime> _hourlyDates = [];
  DateTime _startDate = DateTime.now().subtract(Duration(days: 6));
  bool _isLoading = true;
  double _maxBloodOxygen = 0;
  double _minBloodOxygen = 0;
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController?.addListener(_handleTabChange);
    _fetchBloodOxygenData();
  }

  void _handleTabChange() {
    setState(() {
      switch (_tabController?.index) {
        case 0:
          _updateMinMaxBloodOxygen(
              _hourlyBloodOxygenMin, _hourlyBloodOxygenMax);
          break;
        case 1:
          _updateMinMaxBloodOxygen(_minBloodOxygen7Days, _maxBloodOxygen7Days);
          break;
        case 2:
          _updateMinMaxBloodOxygen(
              _minBloodOxygen30Days, _maxBloodOxygen30Days);
          break;
      }
    });
  }

  void _updateMinMaxBloodOxygen(List<double> minRates, List<double> maxRates) {
    double minBloodOxygen = double.infinity;
    double maxBloodOxygen = double.negativeInfinity;

    for (int i = 0; i < minRates.length; i++) {
      if (minRates[i] > 0 && minRates[i] < minBloodOxygen) {
        minBloodOxygen = minRates[i];
      }
      if (maxRates[i] > 0 && maxRates[i] > maxBloodOxygen) {
        maxBloodOxygen = maxRates[i];
      }
    }

    setState(() {
      _minBloodOxygen = minBloodOxygen != double.infinity ? minBloodOxygen : 0;
      _maxBloodOxygen =
          maxBloodOxygen != double.negativeInfinity ? maxBloodOxygen : 0;
    });
  }

  Future<void> _fetchBloodOxygenData() async {
    setState(() {
      _isLoading = true;
    });

    Map<String, dynamic> data =
        await _bloodOxygenFetcher.fetchBloodOxygenData(_startDate);

    setState(() {
      _minBloodOxygen7Days = data['minBloodOxygen7Days'];
      _maxBloodOxygen7Days = data['maxBloodOxygen7Days'];
      _dates7Days = data['dates7Days'];

      _minBloodOxygen30Days = data['minBloodOxygen30Days'];
      _maxBloodOxygen30Days = data['maxBloodOxygen30Days'];
      _dates30Days = data['dates30Days'];

      _hourlyBloodOxygenMin = data['hourlyBloodOxygenMin'];
      _hourlyBloodOxygenMax = data['hourlyBloodOxygenMax'];
      _hourlyDates = data['hourlyDates'];

      _isLoading = false;

      _maxBloodOxygen = data['overallMaxBloodOxygen'];
      _minBloodOxygen = data['overallMinBloodOxygen'];
    });

    // Set initial min and max blood oxygen based on the 1-day data
    _updateMinMaxBloodOxygen(_hourlyBloodOxygenMin, _hourlyBloodOxygenMax);
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
            "Blood Oxygen",
            style: TextStyle(color: AppColors.mainTextColor1),
          ),
          bottom: TabBar(
            controller: _tabController,
            unselectedLabelColor: AppColors.contentColorWhite,
            indicatorColor: AppColors.contentColorWhite,
            labelColor: AppColors.contentColorYellow,
            tabs: [
              Tab(text: '1 Day'),
              Tab(text: '7 Day'),
              Tab(text: '30 Day'),
            ],
          ),
        ),
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                color: AppColors.contentColorWhite,
              ))
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
                            isO2: true,
                            fontSize: 10,
                            interval: 2,
                            minHeartRateValues: _hourlyBloodOxygenMin,
                            maxHeartRateValues: _hourlyBloodOxygenMax,
                            dates: _hourlyDates,
                          ),
                          // 7-day chart
                          DaySummary(
                            minHeartRatesDays: _minBloodOxygen7Days,
                            maxHeartRatesDays: _maxBloodOxygen7Days,
                            datesDays: _dates7Days,
                            interval: 1,
                            width: 8,
                            font: 8,
                            isO2: true,
                          ),
                          // 30-day chart
                          DaySummary(
                            minHeartRatesDays: _minBloodOxygen30Days,
                            maxHeartRatesDays: _maxBloodOxygen30Days,
                            datesDays: _dates30Days,
                            interval: 5,
                            width: 5,
                            font: 8,
                            isO2: true,
                          ),
                        ],
                      ),
                    ),
                    GridWidget(
                      dataItems: [
                        DataItem(
                          title: 'Min Blood Oxygen',
                          value: _minBloodOxygen,
                          unit: '%',
                        ),
                        DataItem(
                          title: 'Max Blood Oxygen',
                          value: _maxBloodOxygen,
                          unit: '%',
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
