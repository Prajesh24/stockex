// lib/core/services/sensors/shake_detector.dart

import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:sensors_plus/sensors_plus.dart';

class ShakeDetector {
  static const double _shakeThreshold = 15.0;
  static const int _minTimeBetweenShakes = 1000; // ms

  int _lastShakeTime = 0;
  StreamSubscription? _subscription;

  void start(VoidCallback onShake) {
    _subscription = accelerometerEventStream().listen((event) {
      final magnitude = sqrt(
        event.x * event.x +
        event.y * event.y +
        event.z * event.z,
      ) - 9.8; // subtract gravity

      final now = DateTime.now().millisecondsSinceEpoch;

      if (magnitude > _shakeThreshold &&
          now - _lastShakeTime > _minTimeBetweenShakes) {
        _lastShakeTime = now;
        onShake();
      }
    });
  }

  void dispose() {
    _subscription?.cancel();
  }
}