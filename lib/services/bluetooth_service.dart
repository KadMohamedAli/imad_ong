import 'dart:async';
import 'dart:math';

class BluetoothService {
  final StreamController<Map<String, double>> _positionController =
      StreamController.broadcast();
  Stream<Map<String, double>> get positionStream => _positionController.stream;

  double _x = 5.0;
  double _y = 5.0;
  final Random _random = Random();
  Timer? _timer;

  void startListening() {
    _timer = Timer.periodic(const Duration(milliseconds: 250), (_) {
      _x += (_random.nextDouble() - 0.5); // -0.5 to +0.5
      _y += (_random.nextDouble() - 0.5);

      _x = _x.clamp(0.0, 20.0);
      _y = _y.clamp(0.0, 20.0);

      _positionController.add({'x': _x, 'y': _y});
    });
  }

  void dispose() {
    _timer?.cancel();
    _positionController.close();
  }
}
