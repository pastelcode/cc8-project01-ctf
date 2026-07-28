import 'dart:math';

import 'constants.dart';

/// Game-math utilities: distance, clamping, spawn positions, and victory checks.
///
/// All methods are static. Pure Dart — no Flutter dependencies.
class Geometry {
  Geometry._();

  /// Euclidean distance between two points.
  static double distance(double x1, double y1, double x2, double y2) {
    final dx = x2 - x1;
    final dy = y2 - y1;
    return sqrt(dx * dx + dy * dy);
  }

  /// Distance from a point to the map center (500, 500).
  static double distanceToCenter(double x, double y) {
    return distance(x, y, Constants.circleCenterX, Constants.circleCenterY);
  }

  /// Clamp a coordinate to the valid map range [playerRadius, mapSize – playerRadius].
  ///
  /// That is, [15, 985].
  static double clampToMap(double value) {
    return value.clamp(
      Constants.playerRadius.toDouble(),
      (Constants.mapSize - Constants.playerRadius).toDouble(),
    );
  }

  /// Returns `true` when the point is on or inside the victory circle
  /// (distance to center ≤ 315).
  static bool isInsideCircle(double x, double y) {
    return distanceToCenter(x, y) <= Constants.victoryDistance;
  }

  /// Returns `true` when the point is completely outside the victory circle
  /// (distance to center > 315).
  static bool isOutsideCircle(double x, double y) {
    return distanceToCenter(x, y) > Constants.victoryDistance;
  }

  /// Generate a uniform random spawn position in the ring _R_ ∈ [350, 450]
  /// around the center (500, 500).
  ///
  /// Per SPEC §3.3: angle θ ∈ [0, 2π), radius R ∈ [350, 450],
  /// x = 500 + R·cos(θ), y = 500 + R·sin(θ).
  static ({double x, double y}) randomSpawnPosition() {
    final random = Random();
    final angle = random.nextDouble() * 2 * pi;
    final radius =
        Constants.spawnRadiusMin +
        random.nextDouble() *
            (Constants.spawnRadiusMax - Constants.spawnRadiusMin);
    return (
      x: Constants.circleCenterX + radius * cos(angle),
      y: Constants.circleCenterY + radius * sin(angle),
    );
  }

  /// Returns `true` when the Euclidean distance between the two points is
  /// ≤ [Constants.interactRadius] (40 units).
  static bool withinInteractRange(double x1, double y1, double x2, double y2) {
    return distance(x1, y1, x2, y2) <= Constants.interactRadius.toDouble();
  }
}
