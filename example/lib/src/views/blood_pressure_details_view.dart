import 'package:flutter/material.dart';
import 'package:health_example/src/service/fetcher/fetcher.dart';
import 'package:health_example/src/utils/theme.dart';
import 'package:health_example/src/widgets/charts/blood_pressure_candlestick_widget.dart';
import 'package:health_example/src/widgets/charts/blood_pressure_linechart_widget.dart';
import 'package:health_example/src/widgets/grid_widget.dart';

class BloodPressureDetailScreen extends StatefulWidget {
  @override
  _BloodPressureDetailScreenState createState() =>
      _BloodPressureDetailScreenState();
}

class _BloodPressureDetailScreenState extends State<BloodPressureDetailScreen>
    with SingleTickerProviderStateMixin {
  final BloodPressureFetcher _bloodPressureFetcher = BloodPressureFetcher();
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

    _systolicValues1Day = await _bloodPressureFetcher.fetchHourlySystolic(
        startTime1Day, endTime1Day);
    _diastolicValues1Day = await _bloodPressureFetcher.fetchHourlyDiastolic(
        startTime1Day, endTime1Day);

    Map<String, List<double>> bloodPressure7Days =
        await _bloodPressureFetcher.fetchDailyBloodPressure(startTime7Days, 7);
    _minSystolic7Days = bloodPressure7Days["minSystolic"]!;
    _maxSystolic7Days = bloodPressure7Days["maxSystolic"]!;
    _minDiastolic7Days = bloodPressure7Days["minDiastolic"]!;
    _maxDiastolic7Days = bloodPressure7Days["maxDiastolic"]!;
    _dates7Days =
        List.generate(7, (index) => startTime7Days.add(Duration(days: index)));

    Map<String, List<double>> bloodPressure30Days = await _bloodPressureFetcher
        .fetchDailyBloodPressure(startTime30Days, 30);
    _minSystolic30Days = bloodPressure30Days["minSystolic"]!;
    _maxSystolic30Days = bloodPressure30Days["maxSystolic"]!;
    _minDiastolic30Days = bloodPressure30Days["minDiastolic"]!;
    _maxDiastolic30Days = bloodPressure30Days["maxDiastolic"]!;
    _dates30Days = List.generate(
        30, (index) => startTime30Days.add(Duration(days: index)));

    setState(() {
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
        title: Text(
          'Blood Pressure',
          style: TextStyle(color: AppColors.contentColorWhite),
        ),
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
    List<DataItem> dataItems = [
      DataItem(
          title: "Max Systolic BP",
          value: _filterZeroValues(_systolicValues1Day).isNotEmpty
              ? _filterZeroValues(_systolicValues1Day)
                  .reduce((a, b) => a > b ? a : b)
              : 0,
          unit: "mmHg"),
      DataItem(
          title: "Min Systolic BP",
          value: _filterZeroValues(_systolicValues1Day).isNotEmpty
              ? _filterZeroValues(_systolicValues1Day)
                  .reduce((a, b) => a < b ? a : b)
              : 0,
          unit: "mmHg"),
      DataItem(
          title: "Max Diastolic BP",
          value: _filterZeroValues(_diastolicValues1Day).isNotEmpty
              ? _filterZeroValues(_diastolicValues1Day)
                  .reduce((a, b) => a > b ? a : b)
              : 0,
          unit: "mmHg"),
      DataItem(
          title: "Min Diastolic BP",
          value: _filterZeroValues(_diastolicValues1Day).isNotEmpty
              ? _filterZeroValues(_diastolicValues1Day)
                  .reduce((a, b) => a < b ? a : b)
              : 0,
          unit: "mmHg"),
    ];

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
            ),
          ),
        ),
        GridWidget(dataItems: dataItems),
      ],
    );
  }

  Widget _build7DayView() {
    List<DataItem> dataItems = [
      DataItem(title: "Max Systolic BP", value: _maxSystolic, unit: "mmHg"),
      DataItem(title: "Min Systolic BP", value: _minSystolic, unit: "mmHg"),
      DataItem(title: "Max Diastolic BP", value: _maxDiastolic, unit: "mmHg"),
      DataItem(title: "Min Diastolic BP", value: _minDiastolic, unit: "mmHg"),
    ];

    return Column(
      children: [
        Expanded(
          child: BloodPressureCandleStickChart(
            minSystolic: _minSystolic7Days,
            maxSystolic: _maxSystolic7Days,
            minDiastolic: _minDiastolic7Days,
            maxDiastolic: _maxDiastolic7Days,
            dates: _dates7Days,
            fontSize: 8,
            interval: 1,
            barWidth: 6,
            is7DayChart: false,
          ),
        ),
        GridWidget(dataItems: dataItems),
      ],
    );
  }

  Widget _build30DayView() {
    List<DataItem> dataItems = [
      DataItem(title: "Max Systolic BP", value: _maxSystolic, unit: "mmHg"),
      DataItem(title: "Min Systolic BP", value: _minSystolic, unit: "mmHg"),
      DataItem(title: "Max Diastolic BP", value: _maxDiastolic, unit: "mmHg"),
      DataItem(title: "Min Diastolic BP", value: _minDiastolic, unit: "mmHg"),
    ];

    return Column(
      children: [
        Expanded(
          child: BloodPressureCandleStickChart(
            minSystolic: _minSystolic30Days,
            maxSystolic: _maxSystolic30Days,
            minDiastolic: _minDiastolic30Days,
            maxDiastolic: _maxDiastolic30Days,
            dates: _dates30Days,
            fontSize: 8,
            interval: 3,
            is7DayChart: false,
            barWidth: 5,
          ),
        ),
        GridWidget(dataItems: dataItems),
      ],
    );
  }
}
