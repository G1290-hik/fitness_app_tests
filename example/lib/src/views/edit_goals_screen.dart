import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:health_example/src/utils/theme.dart';
import 'package:health_example/src/widgets/picker_widget.dart';

class EditGoalsScreen extends StatefulWidget {
  final double initialWalkSteps;
  final double initialBurnKcals;
  final double initialCoverDistance;

  EditGoalsScreen({
    required this.initialWalkSteps,
    required this.initialBurnKcals,
    required this.initialCoverDistance,
  });

  @override
  State<EditGoalsScreen> createState() => _EditGoalsScreenState();
}

class _EditGoalsScreenState extends State<EditGoalsScreen> {
  late double walkSteps;
  late double burnKcals;
  late double coverDistance;

  @override
  void initState() {
    super.initState();
    walkSteps = widget.initialWalkSteps;
    burnKcals = widget.initialBurnKcals;
    coverDistance = widget.initialCoverDistance;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        backgroundColor: AppColors.pageBackground,
        iconTheme: IconThemeData(color: AppColors.contentColorWhite),
      ),
      body: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Icon(
              FluentIcons.target_arrow_24_regular,
              color: Colors.white,
              size: 70,
            ),
            Text(
              'Set Your Goals',
              style: TextStyle(
                  color: AppColors.mainTextColor1,
                  fontSize: 32,
                  fontWeight: FontWeight.bold),
            ),
            Column(
              children: [
                SizedBox(
                  width: width,
                  child: PickerWidget(
                    color: AppColors.contentColorRed,
                    start: walkSteps,
                    max: 100000,
                    min: 0,
                    step: 500,
                    fontsize: 42,
                    onChange: (value) {
                      setState(() {
                        walkSteps = value;
                      });
                    },
                  ),
                ),
                Text(
                  'steps/day',
                  style: TextStyle(
                    color: AppColors.mainTextColor2,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            Column(
              children: [
                SizedBox(
                  width: width,
                  child: PickerWidget(
                    color: AppColors.contentColorOrange,
                    start: burnKcals,
                    max: 10000,
                    min: 0,
                    step: 500,
                    fontsize: 42,
                    onChange: (value) {
                      setState(() {
                        burnKcals = value;
                      });
                    },
                  ),
                ),
                Text(
                  'kcals/day',
                  style: TextStyle(
                    color: AppColors.mainTextColor2,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            Column(
              children: [
                SizedBox(
                  width: width,
                  child: PickerWidget(
                    color: AppColors.contentColorYellow,
                    start: coverDistance,
                    max: 100,
                    min: 0,
                    step: 0.5,
                    fontsize: 42,
                    change: 1,
                    onChange: (value) {
                      setState(() {
                        coverDistance = value;
                      });
                    },
                  ),
                ),
                Text(
                  'km/day',
                  style: TextStyle(
                    color: AppColors.mainTextColor2,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            Text(
              "I will walk ${walkSteps.toStringAsFixed(0)} steps, burn ${burnKcals.toStringAsFixed(0)} calories/day, and cover $coverDistance km",
              style: TextStyle(
                color: AppColors.mainTextColor1,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            MaterialButton(
              minWidth: width * 0.9,
              height: MediaQuery.sizeOf(context).height * 0.08,
              onPressed: () {
                Navigator.pop(context, {
                  'walkSteps': walkSteps,
                  'burnKcals': burnKcals,
                  'coverDistance': coverDistance,
                });
              },
              elevation: 8,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              color: AppColors.menuBackground,
              child: Text(
                "Save Goals",
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.mainTextColor1,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
