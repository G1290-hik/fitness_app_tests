import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:health_example/src/widgets/util.dart';

import 'service/service.dart';

void main() => runApp(HealthApp());

class HealthApp extends StatefulWidget {
  @override
  _HealthAppState createState() => _HealthAppState();
}

class _HealthAppState extends State<HealthApp> {
  final HealthService _healthService = HealthService();
  AppState _state = AppState.DATA_NOT_FETCHED;
  List<HealthDataPoint> _healthDataList = [];
  int _nofSteps = 0;
  String _healthConnectStatus = 'Unknown';

  @override
  void initState() {
    _healthService.configureHealth();
    authorize();
    super.initState();
  }

  Future<void> authorize() async {
    bool authorized = await _healthService.authorize();
    setState(() =>
        _state = authorized ? AppState.AUTHORIZED : AppState.AUTH_NOT_GRANTED);
  }

  Future<void> getHealthConnectSdkStatus() async {
    String status = await _healthService.getHealthConnectSdkStatus();
    setState(() {
      _healthConnectStatus = status;
      _state = AppState.HEALTH_CONNECT_STATUS;
    });
  }

  Future<void> fetchData(List<HealthDataType> dataTypes) async {
    setState(() => _state = AppState.FETCHING_DATA);

    List<HealthDataPoint> healthDataList =
        await _healthService.fetchData(dataTypes);

    setState(() {
      _healthDataList = healthDataList;
      _state = _healthDataList.isEmpty ? AppState.NO_DATA : AppState.DATA_READY;
    });
  }

  Future<void> addData() async {
    bool success = await _healthService.addData();
    setState(() {
      _state = success ? AppState.DATA_ADDED : AppState.DATA_NOT_ADDED;
    });
  }

  Future<void> deleteData() async {
    bool success = await _healthService.deleteData();
    setState(() {
      _state = success ? AppState.DATA_DELETED : AppState.DATA_NOT_DELETED;
    });
  }

  Future<void> fetchStepData() async {
    int steps = await _healthService.fetchStepData();
    setState(() {
      _nofSteps = steps;
      _state = steps == 0 ? AppState.NO_DATA : AppState.STEPS_READY;
    });
  }

  Future<void> revokeAccess() async {
    await _healthService.revokeAccess();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Health Example'),
          backgroundColor: Colors.blueAccent,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            children: <Widget>[
              SizedBox(height: 20),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ElevatedButton(
                      onPressed: getHealthConnectSdkStatus,
                      child: Text('Health Connect Status'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue),
                    ),
                    ..._buildGroupedButtons(),
                    ElevatedButton(
                      onPressed: fetchStepData,
                      child: Text('Fetch Step Data'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              const Divider(),
              _content(),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildGroupedButtons() {
    return groupedDataTypesAndroid.entries.map((entry) {
      return ElevatedButton(
        onPressed: () => fetchData(entry.value),
        child: Text('Fetch ${entry.key} Data'),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
      );
    }).toList();
  }

  Widget _content() {
    if (_state == AppState.FETCHING_DATA)
      return CircularProgressIndicator();
    else if (_state == AppState.NO_DATA)
      return Text('No Data Available');
    else if (_state == AppState.DATA_READY)
      return Column(
        children: _healthDataList.map((data) => Text(data.toString())).toList(),
      );
    else if (_state == AppState.STEPS_READY)
      return Text('Steps: $_nofSteps');
    else if (_state == AppState.HEALTH_CONNECT_STATUS)
      return Text(_healthConnectStatus);
    else
      return Container();
  }
}
