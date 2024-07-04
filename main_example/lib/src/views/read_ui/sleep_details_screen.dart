import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:health_example/src/service/health_service.dart';
import 'package:health_example/src/utils/theme.dart';
import 'package:health_example/src/widgets/sleep_widgets.dart';

class SleepDetailScreen extends StatefulWidget {
  @override
  _SleepDetailScreenState createState() => _SleepDetailScreenState();
}

class _SleepDetailScreenState extends State<SleepDetailScreen>
    with SingleTickerProviderStateMixin {
  final HealthService _healthService = HealthService();
  List<HealthDataPoint> _allSleepData = [];
  bool _isLoading = true;
  int? _touchedIndex;
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchSleepData();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _fetchSleepData() async {
    setState(() {
      _isLoading = true;
    });

    DateTime now = DateTime.now();
    DateTime startTime30Days = now.subtract(Duration(days: 29));

    _allSleepData = await _healthService.fetchSleepData([
      HealthDataType.SLEEP_ASLEEP,
      HealthDataType.SLEEP_LIGHT,
      HealthDataType.SLEEP_DEEP,
      HealthDataType.SLEEP_REM,
      HealthDataType.SLEEP_SESSION,
    ], startTime30Days, now);

    setState(() {
      _isLoading = false;
    });
  }

  List<HealthDataPoint> _getFilteredData({required int days}) {
    DateTime now = DateTime.now();
    DateTime startTime = now.subtract(Duration(days: days - 1));
    return _allSleepData.where((dataPoint) {
      return dataPoint.dateFrom.isAfter(startTime) &&
          dataPoint.dateFrom.isBefore(now);
    }).toList();
  }

  double _getMaxY(List<HealthDataPoint> sleepData) {
    double maxY = 0.0;
    for (var dataPoint in sleepData) {
      if (dataPoint.value is NumericHealthValue) {
        double value =
            (dataPoint.value as NumericHealthValue).numericValue.toDouble();
        if (value > maxY) {
          maxY = value;
        }
      }
    }
    return maxY + 120;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        backgroundColor: AppColors.pageBackground,
        iconTheme: IconThemeData(color: AppColors.contentColorWhite),
        title: Text(
          'Sleep Details',
          style: TextStyle(color: AppColors.mainTextColor1),
        ),
        bottom: TabBar(
          controller: _tabController,
          unselectedLabelColor: AppColors.contentColorWhite,
          indicatorColor: AppColors.contentColorWhite,
          labelColor: AppColors.contentColorPurple,
          tabs: [
            Tab(text: '7 Days'),
            Tab(text: '30 Days'),
          ],
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
              color: AppColors.contentColorWhite,
            ))
          : TabBarView(
              controller: _tabController,
              children: [
                SleepDataWidget(
                  sleepData: _getFilteredData(days: 7),
                  maxY: _getMaxY(_getFilteredData(days: 7)),
                  touchedIndex: _touchedIndex,
                  onBarTouched: (index) {
                    setState(() {
                      _touchedIndex = index;
                    });
                  },
                  days: 7,
                  interval: 1,
                ),
                SleepDataWidget(
                  sleepData: _getFilteredData(days: 30),
                  maxY: _getMaxY(_getFilteredData(days: 30)),
                  touchedIndex: _touchedIndex,
                  onBarTouched: (index) {
                    setState(() {
                      _touchedIndex = index;
                    });
                  },
                  days: 30,
                  interval: 6,
                ),
              ],
            ),
    );
  }
}
