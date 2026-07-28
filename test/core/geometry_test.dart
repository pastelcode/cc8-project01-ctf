import 'package:flutter_test/flutter_test.dart';

import 'package:capture_the_flag/core/constants.dart';
import 'package:capture_the_flag/core/geometry.dart';

void main() {
  group('Geometry.distance', () {
    test('(0,0) to (3,4) → 5.0', () {
      expect(Geometry.distance(0, 0, 3, 4), 5.0);
    });

    test('(500,500) to (500,500) → 0.0', () {
      expect(Geometry.distance(500, 500, 500, 500), 0.0);
    });
  });

  group('Geometry.distanceToCenter', () {
    test('(500, 500) → 0.0', () {
      expect(Geometry.distanceToCenter(500, 500), 0.0);
    });

    test('(800, 500) → 300.0', () {
      expect(Geometry.distanceToCenter(800, 500), 300.0);
    });
  });

  group('Geometry.clampToMap', () {
    test('0 → 15.0', () {
      expect(Geometry.clampToMap(0), 15.0);
    });

    test('1000 → 985.0', () {
      expect(Geometry.clampToMap(1000), 985.0);
    });

    test('500 → 500.0', () {
      expect(Geometry.clampToMap(500), 500.0);
    });

    test('-100 → 15.0', () {
      expect(Geometry.clampToMap(-100), 15.0);
    });
  });

  group('Geometry.isInsideCircle', () {
    test('center (500, 500) → true', () {
      expect(Geometry.isInsideCircle(500, 500), isTrue);
    });

    test('(500, 185) → true (distance = 315, boundary)', () {
      expect(Geometry.isInsideCircle(500, 185), isTrue);
    });
  });

  group('Geometry.isOutsideCircle', () {
    test('(500, 184) → true (distance = 316, outside)', () {
      expect(Geometry.isOutsideCircle(500, 184), isTrue);
    });
  });

  group('Geometry.withinInteractRange', () {
    test('(500,500) to (540,500) → true (distance = 40)', () {
      expect(Geometry.withinInteractRange(500, 500, 540, 500), isTrue);
    });

    test('(500,500) to (541,500) → false (distance = 41)', () {
      expect(Geometry.withinInteractRange(500, 500, 541, 500), isFalse);
    });
  });

  group('Geometry.randomSpawnPosition', () {
    test('100 positions — all in ring [350, 450] and outside circle', () {
      for (var i = 0; i < 100; i++) {
        final pos = Geometry.randomSpawnPosition();
        final d = Geometry.distanceToCenter(pos.x, pos.y);

        expect(
          d,
          greaterThanOrEqualTo(Constants.spawnRadiusMin),
          reason: 'spawn distance $d < min ${Constants.spawnRadiusMin}',
        );
        expect(
          d,
          lessThanOrEqualTo(Constants.spawnRadiusMax),
          reason: 'spawn distance $d > max ${Constants.spawnRadiusMax}',
        );
        expect(
          Geometry.isOutsideCircle(pos.x, pos.y),
          isTrue,
          reason: 'spawn at (${pos.x}, ${pos.y}) is inside circle (d=$d)',
        );
      }
    });
  });
}
