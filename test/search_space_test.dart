import 'dart:math';

import 'package:list_operators/list_operators.dart';
import 'package:minimal_test/minimal_test.dart';
import 'package:simulated_annealing/simulated_annealing.dart';

void main(List<String> args) {
  // Testing class: Interval.
  group('FixedInterval', () {
    final min = 0;
    final max = 3;
    final interval = FixedInterval(min, max);
    test('limits', () {
      expect(interval.next() < max, true);
      expect(interval.next() > min, true);
    });
    test('caching', () {
      expect(interval.next(), interval.next());
      final prev = interval.next();
      interval.clearCache();
      expect(interval.next() != prev, true);
    });
    test('perturb', () {
      final position = 2.8;
      final dPosition = 0.4;
      interval.clearCache();
      final xRand = interval.perturb(position, dPosition);
      expect(
          position - dPosition < xRand && xRand < position + dPosition, true);
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
  });
  // Testing class: ParametricInterval.
  group('ParametricInterval', () {
    final min = 0;
    final max = 3;
    final x0 = FixedInterval(min, max);
    final x1 = ParametricInterval(() => min, () => x0.next());
    test('limits', () {
      expect(x1.next() < x0.next(), true);
      expect(x1.next() > min, true);
    });
    test('caching', () {
      expect(x1.next(), x1.next());
      final prev = x1.next();
      x1.clearCache();
      expect(x1.next() != prev, true);
    });
    test('perturb', () {
      final position = 2.8;
      final dPosition = 0.4;
      x1.clearCache();
      final xRand = x1.perturb(position, dPosition);
      expect(xRand < position + dPosition, true);
      expect(position - dPosition < xRand, true);
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
  });
  // Testing class: Space
  group('SearchSpace: Fixed', () {
    final space = SearchSpace(
      [FixedInterval(0, 2), FixedInterval(10, 100)],
      dPositionMin: [0.1, 0.1],
    );
    test('limits', () {
      final point = space.next();
      expect(<num>[0, 10] < point && point < [2, 100], true);
    });
    test('perturbation', () {
      final position = <num>[1, 20];
      final dPosition = [1e-2, 1e-1];
      final point = space.perturb(position, dPosition);
      expect(position - dPosition < point && point < position.plus(dPosition),
          true);
      expect(space.contains(point) || match(point, position), true);
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
    final dPositionMin = [1e-6, 1e-6, 1e-6];
    final space = SearchSpace([x0, x1, x2], dPositionMin: dPositionMin);
    final position = [0.5, 0.7, 0.8];
    test('next()', () {
      final point = space.next();
      expect(<num>[-2, -2, -2] < point && point < [2, 2, 2], true);
    });
    test('contains()', () {
      expect(space.contains(space.next()), true);
      final point = space.perturb(position, dPositionMin);
      expect(space.contains(point) || match(point, position), true);
    });

    test('size', () {
      expect(space.size, [4.0, 4.0, 4.0], precision: 0.5);
    });
  });
}
