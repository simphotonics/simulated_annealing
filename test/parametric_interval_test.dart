import 'package:simulated_annealing/simulated_annealing.dart';
import 'package:test/test.dart';

void main() {
  // Testing class: ParametricInterval.
  group('ParametricInterval:', () {
    final left = 0;
    final right = 3;
    final x = FixedInterval(left + 2, right);
    final y = ParametricInterval(
      () => left,
      () => x.next(),
      name: 'Test',
    );
    test('name', () {
      expect(x.name, '');
      expect(y.name, 'Test');
    });
    test('limits', () {
      expect(y.next(), lessThanOrEqualTo(x.next()));
      expect(y.next(), greaterThanOrEqualTo(left));
    });
    test('caching', () {
      expect(y.next(), y.next());
      final prev = y.next();
      y.updateCache();
      expect(y.next() != prev, true);
    });
    test('perturb', () {
      final position = x.next();
      final deltaPosition = 0.4;
      y.updateCache();
      final p = y.perturb(position, deltaPosition);
      expect(p < position + deltaPosition, true);
      expect(position - deltaPosition < p, true);
      expect(y.contains(p) || p == position, true);
    });
    test('contains', () {
      expect(y.contains(0), true);
      expect(y.contains(-5), false);
    });
    test('overlaps', () {
      expect(y.overlaps(-1, 2), true);
      expect(y.overlaps(4, 6), false);
    });
    test('size', () {
      x.updateCache();
      y.updateCache();
      expect(y.size, x.next() - left);
    });
  });
}
