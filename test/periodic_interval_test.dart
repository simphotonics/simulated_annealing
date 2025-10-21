import 'package:simulated_annealing/simulated_annealing.dart';
import 'package:test/test.dart';

void main() {
  // Testing class: PeriodicInterval.
  group('PeriodicInterval:', () {
    num left = 0;
    num right = 3;
    final interval = PeriodicInterval(left, right, name: 'Periodic Interval');
    test('name', () {
      expect(interval.name, 'Periodic Interval');
    });
    test('start, end', () {
      expect(interval.start, left);
      expect(interval.end, right);
    });
    test('size', () {
      expect(interval.size, right - left);
    });
    test('next() limits', () {
      interval.updateCache();
      expect(interval.next() < right, true);
      expect(left < interval.next(), true);
    });
    test('perturb() in range', () {
      num pos = 1.0;
      num deltaPos = 0.5;
      final p = interval.perturb(pos, deltaPos);
      expect(p, greaterThanOrEqualTo(pos - deltaPos));
      expect(p, lessThanOrEqualTo(pos + deltaPos));
    });
    test('perturb() out of range', () {
      expect(interval.perturb(7, 0.5), isNotNaN);
    });
    test('factory', () {
      final copy = FixedInterval.of(interval);
      expect(copy, isA<PeriodicInterval>());
    });
    test('copy constructor', () {
      final copy = PeriodicInterval.of(interval);
      expect(copy.start, interval.start);
      expect(copy.end, interval.end);
    });
    test('levels cont.', () {
      expect(interval.levels, 0);
    });
    test('dx', () {
      expect(interval.dx(), 0);
    });

    test('overlaps', () {
      expect(interval.overlaps(left - 1, right), isTrue);
    });

    test('overlaps, out of range', () {
      expect(interval.overlaps(-7, -6), isTrue);
    });
    test('gridPoints:', () {
      expect(
        interval.gridPoints,
        isA<List<num>>().having((list) => list.isEmpty, 'isEmpty', true),
      );
    });
    test('caching', () {
      expect(interval.next(), interval.next());
      final prev = interval.next();
      interval.updateCache();
      expect(interval.next() != prev, true);
    });
  });
  group('Periodic Discrete Interval:', () {
    num left = 0;
    num right = 5;
    final discreteInterval = PeriodicInterval(left, right)..levels = 10;
    test('isDiscrete', () {
      expect(discreteInterval.isDiscrete, isTrue);
    });
    test('levels', () {
      expect(
        discreteInterval,
        isA<PeriodicInterval>().having(
          (interval) => interval.levels,
          'levels',
          10,
        ),
      );
    });
    test('dx', () {
      expect(
        discreteInterval.dx(),
        (right - left) / (discreteInterval.levels - 1),
      );
    });
    test('next()', () {
      discreteInterval.updateCache();
      final next = discreteInterval.next();
      expect(discreteInterval.gridPoints.contains(next), isTrue);
    });
    test('perturb()', () {
      discreteInterval.updateCache();
      // Note: The point 7 wraps around and is equal to 2.
      //       The perturbation magnitude is 2. => perturbation interval 0...4.
      final p = discreteInterval.perturb(7, 2);
      expect(p, greaterThanOrEqualTo(0));
      expect(p, lessThanOrEqualTo(4));
    });
    test('perturb() out of range', () {
      expect(discreteInterval.perturb(7, 0.5), isNotNaN);
    });
  });
}
