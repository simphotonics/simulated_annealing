import 'dart:math';

import 'package:simulated_annealing/simulated_annealing.dart';
import 'package:test/test.dart';

void main() {
  final rand = Random();
  // Testing class: Interval.
  group('SingularInterval:', () {
    final s = SingularInterval(5);
    test('start == end', () {
      expect(s.start, 5);
      expect(s.end, 5);
      expect(s.size, 0);
    });
    test('next()', () {
      expect(s.next(), 5);
    });
    test('factory', () {
      final interval = FixedInterval(7, 7);
      expect(interval, isA<SingularInterval>());
    });
  });
  group('FixedInterval:', () {
    final xMin = 0;
    final xMax = 3;
    final interval = FixedInterval(xMin, xMax);
    final gridPoints = rand.gridPoints(xMin, xMax, 3);

    test('factory constructor', () {
      expect(interval, isA<FixedInterval>());
    });
    test('copy constructor', () {
      final copy = FixedInterval.of(interval);
      expect(copy.start, interval.start);
      expect(copy.end, interval.end);
    });
    test('limits', () {
      expect(interval.next() < xMax, true);
      expect(interval.next() > xMin, true);
    });
    test('boundaries', () {
      final interval = FixedInterval(9.5, -2);
      expect(interval.start, -2);
      expect(interval.end, 9.5);
      expect(interval.start < interval.end, isTrue);
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
  group('PeriodicInterval:', () {
    final xMin = 0;
    final xMax = 3;
    final interval = PeriodicInterval(xMin, xMax);
    final gridPoints = rand.gridPoints(xMin, xMax, 3);
    test('limits', () {
      expect(interval.next() < xMax, true);
      expect(interval.next() > xMin, true);
    });
    test('caching', () {
      expect(interval.next(), interval.next());
      final prev = interval.next();
      interval.clearCache();
      final current = interval.next();
      expect(current, isNot(prev));
    });
    test('perturb', () {
      final position = 0;
      final deltaPosition = 4.5;
      interval.clearCache();
      final xRand = interval.perturb(position, deltaPosition);
      expect(interval.contains(xRand), isTrue);
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
}
