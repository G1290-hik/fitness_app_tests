import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:health_example/src/utils/theme.dart';

class HealthAddPage extends StatefulWidget {
  const HealthAddPage({super.key});

  @override
  HealthAddPageState createState() => HealthAddPageState();
}

class HealthAddPageState extends State<HealthAddPage> {
  String? selectedWorkout;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _showCustomAlertDialog(context));
  }

  void _showCustomAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(FluentIcons.heart_48_filled,
                    size: 48, color: Colors.red),
                const SizedBox(height: 10),
                const Text('Health',
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                _buildListItem(FluentIcons.heart_48_regular, 'Cardiovascular'),
                const Divider(),
                _buildListItem(Icons.thermostat, 'Blood Oxygen'),
                const Divider(),
                _buildListItem(FluentIcons.sleep_24_regular, 'Sleep'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildListItem(IconData icon, String title) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedWorkout = title;
        });
        Navigator.of(context).pop();
      },
      child: Row(
        children: <Widget>[
          CircleAvatar(
            backgroundColor: Colors.red.withOpacity(0.2),
            child: Icon(icon, color: Colors.red),
          ),
          const SizedBox(width: 10),
          Text(title, style: const TextStyle(fontSize: 18)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    String appBarTitle = 'Add Health Data';
    switch (selectedWorkout) {
      case 'Cardiovascular':
        body = const Center(
          child: Text(
            'Cardiovascular Data',
            style: TextStyle(color: AppColors.mainTextColor1),
          ),
        );
        appBarTitle = 'Add Cardiac Data';
        break;
      case 'Blood Oxygen':
        body = const Center(
            child: Text(
          'Blood Oxygen Data',
          style: TextStyle(color: AppColors.mainTextColor1),
        ));
        appBarTitle = 'Add Blood Oxygen Data';
        break;
      case 'Sleep':
        body = const Center(
            child: Text(
          'Sleep Data',
          style: TextStyle(color: AppColors.mainTextColor1),
        ));
        appBarTitle = 'Add Sleep Data';
        break;
      default:
        body = const Center(child: Text('Retry'));
    }

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        backgroundColor: AppColors.pageBackground,
        iconTheme: IconThemeData(color: AppColors.contentColorWhite),
        title: Text(
          appBarTitle,
          style: TextStyle(color: AppColors.mainTextColor1),
        ),
      ),
      body: body,
    );
  }
}
