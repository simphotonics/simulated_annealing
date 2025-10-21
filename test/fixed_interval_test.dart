import 'package:simulated_annealing/simulated_annealing.dart';
import 'package:test/test.dart';

void main() {
  // Testing class: FixedInterval.
  group('FixedInterval:', () {
    num left = 0;
    num right = 3;
    final interval = FixedInterval(left, right, name: 'Test');
    test('name', () {
      expect(interval.name, 'Test');
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
      expect(interval.perturb(7, 0.5), isNaN);
    });
    test('factory', () {
      final singularInterval = FixedInterval(7, 7);
      expect(singularInterval, isA<SingularInterval>());
    });
    test('copy constructor', () {
      final copy = FixedInterval.of(interval);
      expect(copy.start, interval.start);
      expect(copy.end, interval.end);
    });
    test('levels cont.', () {
      expect(interval.levels, 0);
    });
    test('dx', () {
      expect(interval.dx(), 0);
    });
    test('copy constructor', () {
      final intervalCopy = FixedInterval.of(interval);
      expect(intervalCopy, isA<FixedInterval>());
    });
    test('overlaps', () {
      expect(interval.overlaps(left - 1, right), isTrue);
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
  group('Fixed Discrete Interval:', () {
    num left = 0;
    num right = 5;
    final discreteInterval = FixedInterval(left, right)..levels = 10;
    test('levels', () {
      expect(
        discreteInterval,
        isA<FixedInterval>().having(
          (interval) => interval.levels,
          'levels',
          10,
        ),
      );
    });
    test('isDiscrete', () {
      expect(discreteInterval.isDiscrete, isTrue);
    });
    test('dx', () {
      expect(
        discreteInterval.dx(),
        (right - left) / (discreteInterval.levels - 1),
      );
    });
    test('next()', () {
      final next = discreteInterval.next();
      expect(discreteInterval.gridPoints.contains(next), isTrue);
    });
    test('perturb()', () {
      expect(discreteInterval.perturb(7, 2), 5);
    });
    test('perturb() out of range', () {
      expect(discreteInterval.perturb(7, 0.5), isNaN);
    });
  });
}
