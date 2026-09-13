import 'package:geolocator/geolocator.dart';

class RunningEngine {
  int elapsedSeconds = 0;
  Position? lastPosition;
  double totalDistance = 0;
  double currentSpeed = 0;
  bool isPaused = false;

  void onTick() {
    if (!isPaused) {
      elapsedSeconds++;
    }
  }

  void onPositionUpdate(Position position) {
    if (!isPaused && position.accuracy <= 15) {
      if (lastPosition != null) {
        final distance = Geolocator.distanceBetween(
          lastPosition!.latitude,
          lastPosition!.longitude,
          position.latitude,
          position.longitude,
        );
        if (distance >= 3) {
          totalDistance += distance;
          currentSpeed = position.speed;
        }
      }
      lastPosition = position;
    }
  }

  void togglePause() {
    isPaused = !isPaused;
  }

  String formatPace() {
    if (currentSpeed <= 0) {
      return '--';
    }
    final paceSeconds = 1000 / currentSpeed; // seconds per km

    final minutes = paceSeconds ~/ 60;
    final seconds = paceSeconds.round() % 60;

    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')} min/km';
  }
}
