import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

class WorkoutAddPage extends StatefulWidget {
  const WorkoutAddPage({super.key});

  @override
  WorkoutAddPageState createState() => WorkoutAddPageState();
}

class WorkoutAddPageState extends State<WorkoutAddPage> {
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
                const Icon(FluentIcons.person_walking_24_regular,
                    size: 48, color: Colors.purple),
                const SizedBox(height: 10),
                const Text('Workout',
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                _buildListItem(Icons.directions_run, 'Cardiovascular'),
                const Divider(),
                _buildListItem(Icons.favorite, 'Workout Routine'),
                const Divider(),
                _buildListItem(Icons.fitness_center, 'Strength'),
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
            backgroundColor: Colors.purple.withOpacity(0.2),
            child: Icon(icon, color: Colors.purple),
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
    String appBarTitle = 'Add Workout';
    switch (selectedWorkout) {
      case 'Cardiovascular':
        body = const Center(child: Text('Cardiovascular Workout Details'));
        appBarTitle = 'Add Cardio Workout';
        break;
      case 'Workout Routine':
        body = const Center(child: Text('Workout Routine Details'));
        appBarTitle = 'Add Workout Routine';
        break;
      case 'Strength':
        body = const Center(child: Text('Strength Workout Details'));
        appBarTitle = 'Add Strength Workout';
        break;
      default:
        body = const Center(child: Text('Welcome to My Stateful Screen!'));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          appBarTitle,
        ),
      ),
      body: body,
    );
  }
}
