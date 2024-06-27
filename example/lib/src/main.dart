import 'package:flutter/material.dart';
import 'package:health_example/src/service/service.dart';
import 'package:health_example/src/utils/util.dart';
import 'package:health_example/src/views/view.dart';

void main() => runApp(HealthApp());

class HealthApp extends StatefulWidget {
  @override
  _HealthAppState createState() => _HealthAppState();
}

class _HealthAppState extends State<HealthApp> {
  final HealthService _healthService = HealthService();
  AppState _state = AppState.DATA_NOT_FETCHED;

  @override
  void initState() {
    super.initState();
    if (_state != AppState.AUTHORIZED) {
      _healthService.configureHealth();
      authorize();
    } else {
      _healthService.configureHealth();
      authorize();
    }
  }

  Future<void> authorize() async {
    bool authorized = await _healthService.authorize();
    setState(() =>
        _state = authorized ? AppState.AUTHORIZED : AppState.AUTH_NOT_GRANTED);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: _state == AppState.AUTHORIZED
          ? HeartRateDetailScreen()
          : AuthorizationScreen(),
    );
  }
}

class AuthorizationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Authorization Required')),
      body: Center(child: Text('Please authorize the app to proceed.')),
    );
  }
}
