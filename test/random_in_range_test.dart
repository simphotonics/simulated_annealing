import 'dart:math';

import 'package:exception_templates/exception_templates.dart';
import 'package:test/test.dart';

import 'package:simulated_annealing/simulated_annealing.dart';

num inverseCdf(num p, num xMin, num xMax) => xMin + (xMax - xMin) * sqrt(p);

void main() {
  final r = Random();
  group('nextInRange(xMin, xMax):', () {
    final xMin = -1;
    final xMax = 8.0;
    test('next < xMax', () {
      expect(r.nextInRange(xMin, xMax) < xMax, true);
    });
    test('next < xMax', () {
      expect(r.nextInRange(xMax, xMin) < xMax, true);
    });
    test(' xMin <= next ', () {
      expect(r.nextInRange(xMin, xMax) > xMin, true);
    });
    test(' xMin <= next', () {
      expect(r.nextInRange(xMax, xMin) > xMin, true);
    });
  });

  group('nextInRange(xMin, xMax, inverseCdf: inverseCdf):', () {
    final xMin = 0;
    final xMax = 4.0;

    test('next <= xMax', () {
      final next = r.nextInRange(xMin, xMax, inverseCdf: inverseCdf);
      expect(next, lessThanOrEqualTo(xMax));
    });

    test(' xMin <= next ', () {
      expect(
        r.nextInRange(xMin, xMax, inverseCdf: inverseCdf),
        greaterThanOrEqualTo(xMin),
      );
    });

    test('Value coincides with grid point', () {
      expect(
          r.gridPoints(xMin, xMax, 10),
          contains(closeTo(
            r.nextLevelInRange(xMin, xMax, 10, inverseCdf: inverseCdf),
            1e-12,
          )));
    });
  });
  group('nextFromList():', () {
    final list = <int>[1, 3, 9, 11];
    test('Values', () {
      expect(list.contains(r.nextFromList(list)), true);
    });
    test('Error if list is empty', () {
      expect(
          () => r.nextFromList(<String>[]),
          throwsA(isA<ErrorOf<Random>>().having(
            (e) => e.message,
            'message',
            'Could not generate next value using the extension'
                ' method `nextFromList`.',
          )));
    });
  });
}
