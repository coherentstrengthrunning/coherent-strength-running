import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:coherent_strength_running/running_engine.dart';

void main() {
  late RunningEngine engine;

  setUp(() {
    engine = RunningEngine();
  });

  // Helper to create position objects
  Position createPos(double lat, double lon, double acc, {double speed = 0}) {
    return Position(
        latitude: lat,
        longitude: lon,
        timestamp: DateTime.now(),
        accuracy: acc,
        altitude: 0,
        heading: 0,
        speed: speed,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0
    );
  }

  group('RunningEngine', () {
    test('1. Initial state is correct', () {
      expect(engine.elapsedSeconds, 0);
      expect(engine.totalDistance, 0);
      expect(engine.currentSpeed, 0);
      expect(engine.lastPosition, isNull);
      expect(engine.isPaused, isFalse);
    });

    group('2. Timer', () {
      test('Ticks advance elapsed time', () {
        engine.onTick();
        expect(engine.elapsedSeconds, 1);
        engine.onTick();
        engine.onTick();
        expect(engine.elapsedSeconds, 3);
      });
      test('Ticks do not advance time when paused', () {
        engine.togglePause();
        engine.onTick();
        expect(engine.elapsedSeconds, 0);
      });
    });

    group('3. Distance & Position Flow', () {
      test('First valid position establishes lastPosition but adds no distance', () {
        final pos1 = createPos(0, 0, 10);
        engine.onPositionUpdate(pos1);
        expect(engine.lastPosition, pos1);
        expect(engine.totalDistance, 0);
      });
      test('Second valid position accumulates distance', () {
        engine.onPositionUpdate(createPos(0, 0, 10)); // Establishes last
        // Use a position that actually yields distance (e.g., small lat change)
        engine.onPositionUpdate(createPos(0.0001, 0, 10));
        expect(engine.totalDistance, greaterThan(0));
        expect(engine.lastPosition?.latitude, 0.0001);
      });
    });

    group('4. Accuracy', () {
      test('Accuracy exactly 15m is accepted', () {
        engine.onPositionUpdate(createPos(0, 0, 15));
        expect(engine.lastPosition, isNotNull);
      });
      test('Accuracy > 15m is ignored', () {
        engine.onPositionUpdate(createPos(0, 0, 15)); // Valid
        engine.onPositionUpdate(createPos(0.0001, 0, 16)); // Invalid
        expect(engine.lastPosition?.accuracy, 15); // Not replaced
      });
    });

    group('5. Speed & 6. Pace', () {
      test('Current speed reflects GPS speed', () {
        engine.onPositionUpdate(createPos(0, 0, 10, speed: 5.5));
        expect(engine.currentSpeed, 5.5);
      });
      test('Pace calculation: 5km in 30min is 06:00 min/km', () {
        // Manually setting state to verify formatter logic
        // because we cannot simulate precise GPS distance easily.
        engine.totalDistance = 5000;
        engine.elapsedSeconds = 1800;
        engine.currentSpeed = 5000 / 1800;
        expect(engine.formatPace(), '06:00 min/km');
      });
      test('Zero distance returns --', () {
        expect(engine.formatPace(), '--');
      });
    });

    group('7. Pause & 8. Resume', () {
      test('Pause freezes time and distance', () {
        engine.onPositionUpdate(createPos(0, 0, 10));
        engine.togglePause();
        engine.onTick();
        engine.onPositionUpdate(createPos(0.0001, 0, 10));
        expect(engine.elapsedSeconds, 0);
        expect(engine.totalDistance, 0);
      });
      test('Resume continues time and distance', () {
        engine.togglePause();
        engine.togglePause(); // Resume
        engine.onTick();
        expect(engine.elapsedSeconds, 1);
      });
    });

    group('9. GPS signal loss', () {
      test('Ticks continue but distance remains unchanged', () {
        engine.onPositionUpdate(createPos(0, 0, 10));
        engine.onTick();
        engine.onTick();
        expect(engine.elapsedSeconds, 2);
        expect(engine.totalDistance, 0);
      });
    });

    // 10. GPS spike:
    // NOTE: GPS-spike rejection is currently not implemented in RunningEngine.
  });
}
