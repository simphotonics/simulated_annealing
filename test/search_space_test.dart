import 'dart:math';

import 'package:list_operators/list_operators.dart';
import 'package:simulated_annealing/simulated_annealing.dart';
import 'package:test/test.dart';

void main() {
  final rand = Random();
  // Testing class: Interval.
  group('FixedInterval', () {
    final xMin = 0;
    final xMax = 3;
    final interval = FixedInterval(xMin, xMax);
    final gridPoints = rand.gridPoints(xMin, xMax, 3);
    test('limits', () {
      expect(interval.next() < xMax, true);
      expect(interval.next() > xMin, true);
    });
    test('caching', () {
      expect(interval.next(), interval.next());
      final prev = interval.next();
      interval.clearCache();
      expect(interval.next() != prev, true);
    });
    test('perturb', () {
      final position = 2.8;
      final deltaPosition = 0.4;
      interval.clearCache();
      final xRand = interval.perturb(position, deltaPosition);
      expect(
          position - deltaPosition < xRand && xRand < position + deltaPosition,
          true);
      expect(interval.contains(xRand) || xRand == position, true);
    });
    test('contains', () {
      expect(interval.contains(0), true);
      expect(interval.contains(-5), false);
    });
    test('overlaps', () {
      expect(interval.overlaps(-1, 2), true);
      expect(interval.overlaps(3.1, 2), true);
      expect(interval.overlaps(4, 6), false);
    });
    test('grid', () {
      interval.clearCache();
      expect(gridPoints.contains(interval.next(nGrid: 3)), true);
    });
  });
  // Testing class: ParametricInterval.
  group('ParametricInterval', () {
    final xMin = 0;
    final xMax = 3;
    final x0 = FixedInterval(xMin, xMax);
    final x1 = ParametricInterval(() => xMin, () => x0.next());
    test('limits', () {
      expect(x1.next() < x0.next(), true);
      expect(x1.next() > xMin, true);
    });
    test('caching', () {
      expect(x1.next(), x1.next());
      final prev = x1.next();
      x1.clearCache();
      expect(x1.next() != prev, true);
    });
    test('perturb', () {
      final position = 2.8;
      final deltaPosition = 0.4;
      x1.clearCache();
      final xRand = x1.perturb(position, deltaPosition);
      expect(xRand < position + deltaPosition, true);
      expect(position - deltaPosition < xRand, true);
      expect(x1.contains(xRand) || xRand == position, true);
    });
    test('contains', () {
      expect(x1.contains(0), true);
      expect(x1.contains(-5), false);
    });
    test('overlaps', () {
      expect(x1.overlaps(-1, 2), true);
      expect(x1.overlaps(4, 6), false);
    });
    test('next(numberOfGridPoints: 3)', () {
      x0.clearCache();
      x1.clearCache();
      expect(
        rand
            .gridPoints(
              x1.pStart(),
              x1.pEnd(),
              3,
            )
            .contains(
              x1.next(
                nGrid: 3,
              ),
            ),
        true,
      );
    });
    test('perturb(numberOfGridPoints: 3)', () {
      x0.clearCache();
      x1.clearCache();
      final x = 1.0;
      final dx = 0.75;
      final gridPoints = rand.gridPoints(
        max(x - dx, x1.pStart()),
        min(x + dx, x1.pEnd()),
        3,
      );
      // In case the intersection between [x - dx, x + dx] and x1
      // is empty the point x is returned unperturbed.
      gridPoints.add(1.0);
      expect(
        gridPoints.contains(
          x1.perturb(
            1,
            0.75,
            nGrid: 3,
          ),
        ),
        true,
      );
    });
  });
  // Testing class: Space
  group('SearchSpace Fixed:', () {
    final space = SearchSpace([FixedInterval(0, 2), FixedInterval(10, 100)]);
    test('limits', () {
      final point = space.next();
      expect(<num>[0, 10] <= point && point < [2, 100], true);
    });
    test('perturbation', () {
      final position = <num>[1, 20];
      final deltaPosition = [1e-2, 1e-1];
      final point = space.perturb(position, deltaPosition);
      expect(
          position - deltaPosition <= point &&
              point < position.plus(deltaPosition),
          true);
      expect(space.contains(point), true);
      for (var i = 0; i < position.length; i++) {
        expect(point[i], closeTo(position[i], deltaPosition[i]));
      }
    });
    test('perturbation with grid', () {
      final position = <num>[1, 20];
      final deltaPosition = [1e-2, 1e-1];
      final point = space.perturb(position, deltaPosition, nGrid: [10, 10]);
      expect(
          position - deltaPosition <= point &&
              point <= position.plus(deltaPosition),
          true);
      expect(space.contains(point), true);
      for (var i = 0; i < position.length; i++) {
        expect(point[i], closeTo(position[i], deltaPosition[i]));
      }
    });
    test('size', () {
      expect(space.size, [2, 90]);
    });
  });
  group('Search Space: Parametric', () {
    // Defining a spherical space.
    final radius = 2;
    final x0 = FixedInterval(-radius, radius);
    final x1 = ParametricInterval(
      () => -sqrt(pow(radius, 2) - pow(x0.next(), 2)),
      () => sqrt(pow(radius, 2) - pow(x0.next(), 2)),
    );
    final x2 = ParametricInterval(
      () => -sqrt(pow(radius, 2) - pow(x1.next(), 2) - pow(x0.next(), 2)),
      () => sqrt(pow(radius, 2) - pow(x1.next(), 2) - pow(x0.next(), 2)),
    );
    final deltaPositionMin = [1e-6, 1e-6, 1e-6];
    final space = SearchSpace([x0, x1, x2]);
    final position = [0.5, 0.7, 0.8];
    test('next()', () {
      final point = space.next();
      expect(<num>[-2, -2, -2] < point && point < [2, 2, 2], true);
    });
    test('contains()', () {
      expect(space.contains(space.next(nGrid: [10, 10, 10])), true);
      final point = space.perturb(position, deltaPositionMin);
      expect(space.contains(point), isTrue);
      expect(point, CloseToList(position, deltaPositionMin.mean()));
    });

    test('size', () {
      expect(
        space.size,
        CloseToList([4.0, 4.0, 4.0], 0.25),
      );
    });
  });
}
