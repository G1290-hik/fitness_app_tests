import 'package:pedometer/pedometer.dart';

class StepService {
  late Stream<StepCount> _stepCountStream;
  late Stream<PedestrianStatus> _pedestrianStatusStream;
  String _status = '0', _steps = '';

  void Function(String) onStatusChanged;
  void Function(String) onStepsChanged;

  StepService({required this.onStatusChanged, required this.onStepsChanged});

  void initPlatformState() {
    _pedestrianStatusStream = Pedometer.pedestrianStatusStream;
    _pedestrianStatusStream
        .listen(onPedestrianStatusChanged)
        .onError(onPedestrianStatusError);

    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream.listen(onStepCount).onError(onStepCountError);
  }

  void onStepCount(StepCount event) {
    _steps = event.steps.toString();
    onStepsChanged(_steps);
  }

  void onPedestrianStatusChanged(PedestrianStatus event) {
    _status = event.status;
    onStatusChanged(_status);
  }

  void onPedestrianStatusError(error) {
    _status = 'Pedestrian Status not available';
    onStatusChanged(_status);
  }

  void onStepCountError(error) {
    _steps = 'Step Count not available';
    onStepsChanged(_steps);
  }
}
