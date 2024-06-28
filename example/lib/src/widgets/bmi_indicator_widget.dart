import 'package:flutter/material.dart';
import 'package:geekyants_flutter_gauges/geekyants_flutter_gauges.dart';
import 'package:health_example/src/utils/theme.dart';

class BMIWidget extends StatelessWidget {
  BMIWidget({
    Key? key,
    required this.height,
  }) : super(key: key);

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
        child: Column(
          children: [
            IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'CURRENT BMI',
                          style: TextStyle(
                            color: AppColors.contentColorWhite.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        const Text(
                          '22.5',
                          style: TextStyle(
                            color: AppColors.contentColorWhite,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        Text(
                          'Current weight: 94.0',
                          style: TextStyle(
                            color: AppColors.contentColorWhite,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    flex: 2,
                    child: GaugeWidget(
                      height: 350,
                      size: true,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GaugeWidget extends StatelessWidget {
  const GaugeWidget({
    super.key,
    required this.height,
    required this.size,
  });

  final double height;
  final bool size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height, // Adjust height as needed
      child: Column(
        children: [
          RadialGauge(
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
                    TextStyle(color: AppColors.contentColorWhite, fontSize: 12),
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
                needleWidth: 5,
                needleHeight: 100,
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.black54,
                    Colors.grey,
                    AppColors.contentColorWhite
                  ],
                  stops: [
                    0.0,
                    0.33,
                    0.66,
                    1.0, // end
                  ],
                ),
                tailRadius: 0,
                value: 22.5,
              ),
            ],
          ),
          if (size != true)
            Text(
              "22.5",
              style: TextStyle(
                  color: AppColors.contentColorWhite,
                  fontSize: 36,
                  shadows: [
                    Shadow(color: AppColors.contentColorWhite, blurRadius: 7),
                  ],
                  fontWeight: FontWeight.bold),
            ),
        ],
      ),
    );
  }
}
