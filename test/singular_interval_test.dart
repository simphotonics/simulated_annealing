import 'package:simulated_annealing/simulated_annealing.dart';
import 'package:test/test.dart';

void main() {
  // Testing class: Interval.
  group('SingularInterval:', () {
    final s = SingularInterval(5, name: 'Singular Interval');
    test('name', () {
      expect(s.name, 'Singular Interval');
    });
    test('start == end', () {
      expect(s.start, 5);
      expect(s.end, 5);
    });
    test('size', () {
      expect(s.size, 0);
    });
    test('next()', () {
      expect(s.next(), 5);
    });
    test('perturb()', () {
      expect(s.perturb(7, 3), 5);
      expect(s.perturb(7, 0.5), isNaN);
    });
    test('factory', () {
      final interval = FixedInterval(7, 7);
      expect(interval, isA<SingularInterval>());
    });
    test('copy constructor', () {
      final copy = FixedInterval.of(s);
      expect(copy.start, s.start);
      expect(copy.end, s.end);
    });
    test('levels cont.', () {
      expect(s.levels, 0);
    });
    test('dx', () {
      expect(s.dx(), 0);
    });
    test('copy constructor', () {
      final s1 = SingularInterval.of(s);
      expect(s1, isA<SingularInterval>());
    });
    test('overlaps', () {
      expect(s.overlaps(4, 6), isTrue);
    });
    test('gridPoints:', () {
      expect(
        s.gridPoints,
        isA<List<num>>().having((list) => list.isEmpty, 'isEmpty', true),
      );
    });
  });
  group('Discrete Interval:', () {
    final d = SingularInterval(5)..levels = 10;
    test('isDiscrete', () {
      expect(d.isDiscrete, isTrue);
    });
    test('dx', () {
      expect(d.dx(), 0);
    });
    test('next()', () {
      expect(d.next(), 5);
    });
    test('perturb()', () {
      expect(d.perturb(7, 3), 5);
      expect(d.perturb(7, 0.5), isNaN);
    });
  });
}
