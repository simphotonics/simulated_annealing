import 'dart:math';

import 'package:exception_templates/exception_templates.dart';
import 'package:list_operators/list_operators.dart';
import 'package:simulated_annealing/simulated_annealing.dart';
import 'package:test/test.dart';

void main() {
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
  group('Exceptions:', () {
    final space = SearchSpace.box();
    test('thrown in next()', () {
      expect(
        () => space.next(nGrid: [30, 40]),
        throwsA(
          isA<ErrorOf<SearchSpace>>().having(
            (e) => e.message,
            'message',
            'Could not generate random point using method next().',
          ),
        ),
      );
    });
    test('thrown in perturb(), position', () {
      final position = [0.5, 0.5];
      final deltaPosition = [0.1, 0.1, 0.1];
      expect(
        () => space.perturb(position, deltaPosition, nGrid: [30, 40]),
        throwsA(
          isA<ErrorOf<SearchSpace>>().having(
            (e) => e.message,
            'message',
            'Could not generate random point around $position.',
          ),
        ),
      );
    });
    test('thrown in perturb(), deltaPosition', () {
      final position = [0.5, 0.5, 0.5];
      final deltaPosition = [0.1, 0.1];
      expect(
        () => space.perturb(position, deltaPosition, nGrid: [30, 40]),
        throwsA(
          isA<ErrorOf<SearchSpace>>().having(
            (e) => e.message,
            'message',
            'Could not generate perturbation using magnitudes $deltaPosition.',
          ),
        ),
      );
    });
  });
}
