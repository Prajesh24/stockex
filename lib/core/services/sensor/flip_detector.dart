// lib/core/services/sensor/flip_detector.dart

import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:sensors_plus/sensors_plus.dart';

class FlipDetector {
  // Z-axis threshold — strongly negative = face-down, strongly positive = face-up
  // 7.0 is conservative enough to avoid false triggers from slight tilts
  static const double _faceDownThreshold = -7.0;
  static const double _faceUpThreshold = 7.0;

  // Minimum ms the phone must stay in position before firing — prevents
  // triggering mid-rotation while the phone is still moving
  static const int _debounceMs = 400;

  bool _isFaceDown = false;
  Timer? _debounceTimer;
  StreamSubscription<AccelerometerEvent>? _subscription;

  /// [onFaceDown] fires when phone is flipped face-down and held there.
  /// [onFaceUp]   fires when phone is returned face-up and held there.
  void start({
    required VoidCallback onFaceDown,
    required VoidCallback onFaceUp,
  }) {
    _subscription = accelerometerEventStream(
      samplingPeriod: SensorInterval.normalInterval,
    ).listen((AccelerometerEvent event) {
      final bool detectedFaceDown = event.z < _faceDownThreshold;
      final bool detectedFaceUp = event.z > _faceUpThreshold;

      if (!detectedFaceDown && !detectedFaceUp) {
        // Phone is mid-rotation — cancel any pending debounce
        _debounceTimer?.cancel();
        return;
      }

      // Only act if orientation actually changed
      if (detectedFaceDown && !_isFaceDown) {
        _debounceTimer?.cancel();
        _debounceTimer = Timer(
          const Duration(milliseconds: _debounceMs),
          () {
            _isFaceDown = true;
            onFaceDown();
          },
        );
      } else if (detectedFaceUp && _isFaceDown) {
        _debounceTimer?.cancel();
        _debounceTimer = Timer(
          const Duration(milliseconds: _debounceMs),
          () {
            _isFaceDown = false;
            onFaceUp();
          },
        );
      }
    });
  }

  void dispose() {
    _debounceTimer?.cancel();
    _subscription?.cancel();
    _subscription = null;
  }
}