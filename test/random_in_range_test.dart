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
  group('nextInRange(xMin, xMax, gridPoints: 5):', () {
    final xMin = 0;
    final xMax = 4.0;
    test('next <= xMax', () {
      final next = r.nextInRange(xMin, xMax, nGrid: 5);
      expect(next <= xMax, true);
    });
    test('next <= xMax', () {
      expect(r.nextInRange(xMax, xMin, nGrid: 5) <= xMax, true);
    });
    test(' xMin <= next ', () {
      expect(r.nextInRange(xMin, xMax, nGrid: 5) >= xMin, true);
    });
    test(' xMin <= next', () {
      expect(r.nextInRange(xMax, xMin, nGrid: 5) >= xMin, true);
    });
  });
  group('nextInRange(xMin, xMax, gridPoints: 5, inverseCdf: inverseCdf):', () {
    final xMin = 0;
    final xMax = 4.0;
    final nGrid = 5;
    test('next <= xMax', () {
      final next =
          r.nextInRange(xMin, xMax, nGrid: nGrid, inverseCdf: inverseCdf);
      expect(next, lessThanOrEqualTo(xMax));
    });

    test(' xMin <= next ', () {
      expect(
        r.nextInRange(xMin, xMax, nGrid: nGrid, inverseCdf: inverseCdf),
        greaterThanOrEqualTo(xMin),
      );
    });

    test('Value coincides with grid point', () {
      expect(
          r.gridPoints(xMin, xMax, nGrid),
          contains(closeTo(
            r.nextInRange(xMin, xMax, nGrid: nGrid, inverseCdf: inverseCdf),
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
            'Could not generate next random value from list.',
          )));
    });
  });
}
