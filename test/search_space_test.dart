import 'package:minimal_test/minimal_test.dart';
import 'package:simulated_annealing/simulated_annealing.dart';

void main(List<String> args) {
  // Testing class: Interval.
  group('FixedInterval', () {
    final min = -1;
    final max = 3;
    final x = FixedInterval(min, max);
    test('limits', () {
      expect(x.next() < max, true);
      expect(x.next() > min, true);
    });
    test('caching', () {
      expect(x.next(), x.next());
      final prev = x.next();
      x.clearCache();
      expect(x.next() != prev, true);
    });
    test('sub-interval', () {
      final mid = 2;
      final magnitude = 0.1;
      x.clearCache();
      final next = x.next(midPoint: mid, magnitude: magnitude);
      expect(next < mid + magnitude, true);
      expect(mid - magnitude < next, true);
    });
    test('contains', () {
      expect(x.contains(0), true);
      expect(x.contains(-5), false);
    });
    test('overlaps', () {
      expect(x.overlaps(-1, 2), true);
      expect(x.overlaps(3.1, 2), true);
      expect(x.overlaps(4, 6), false);
    });
  });
  // Testing class: ParametricInterval.
  group('ParametricInterval', () {
    final min = 0;
    final max = 3;
    final x = FixedInterval(min, max);
    final y = ParametricInterval(() => 0, () => x.next());
    test('limits', () {
      expect(y.next() < x.next(), true);
      expect(y.next() > 0, true);
    });
    test('caching', () {
      expect(y.next(), y.next());
      final prev = y.next();
      y.clearCache();
      expect(y.next() != prev, true);
    });
    test('sub-interval', () {
      final mid = 2;
      final magnitude = 0.1;
      y.clearCache();
      final next = y.next(midPoint: mid, magnitude: magnitude);
      expect(next < mid + magnitude, true);
      expect(mid - magnitude < next, true);
    });
    test('contains', () {
      expect(y.contains(0), true);
      expect(y.contains(-5), false);
    });
    test('overlaps', () {
      expect(y.overlaps(-1, 2), true);
      expect(y.overlaps(4, 6), false);
    });
  });
  // Testing class: Space
  group('', () {});
}
