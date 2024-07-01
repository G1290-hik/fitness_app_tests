import 'package:flutter/material.dart';

class AuthorizationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Authorization Required')),
      body: Center(child: Text('Please authorize the app to proceed.')),
    );
  }
}
