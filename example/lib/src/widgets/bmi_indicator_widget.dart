import 'package:flutter/material.dart';
import 'package:geekyants_flutter_gauges/geekyants_flutter_gauges.dart';
import 'package:health_example/src/widgets/theme.dart';

class BMIWidget extends StatelessWidget {
  const BMIWidget({
    super.key,
    required this.height,
  });

  final double height;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.menuBackground.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        height: height,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text(
                          'CURRENT BMI',
                          style: TextStyle(
                            color: AppColors.contentColorWhite.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        const Text(
                          '22.5',
                          style: TextStyle(
                            color: AppColors.contentColorWhite,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    flex: 2,
                    child: SizedBox(
                      height: height * 0.8, // Adjust height as needed
                      child: const RadialGauge(
                        track: RadialTrack(
                          thickness: 20,
                          trackStyle: TrackStyle(
                            primaryRulersHeight: -15,
                            secondaryRulersWidth: 0,
                            primaryRulersWidth: 0,
                            secondaryRulersHeight: -10,
                            showPrimaryRulers: false,
                            showSecondaryRulers: false,
                            labelStyle:
                                TextStyle(color: AppColors.contentColorWhite),
                          ),
                          color: Colors.white,
                          steps: 5,
                          startAngle: 0,
                          endAngle: 180,
                          start: 10,
                          end: 35,
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Color(0xFF00E5FF), // Cyan
                              Color(0xFF00FF00), // Green
                              Color(0xFFFFFF00), // Yellow
                              Color(0xFFFF0000), // Red
                            ],
                            stops: [
                              0.0, // start
                              0.33, // one-third point
                              0.66, // two-third point
                              1.0, // end
                            ],
                          ),
                        ),
                        needlePointer: [
                          NeedlePointer(
                            needleHeight: 100,
                            needleWidth: 10,
                            color: AppColors.contentColorWhite,
                            tailColor: AppColors.contentColorWhite,
                            tailRadius: 0,
                            value: 22.5,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  'Current weight: 94.0',
                  style: TextStyle(
                    color: AppColors.contentColorWhite,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
