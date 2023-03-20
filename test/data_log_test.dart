import 'package:exception_templates/exception_templates.dart';
import 'package:test/test.dart';

import 'package:simulated_annealing/simulated_annealing.dart';

void main() {
  group('Info:', () {
    final log = DataLog<num>();
    test('non-existent record', () {
      expect(
          log.get('non-existent'),
          isA<List<num>>().having(
            (list) => list.isEmpty,
            'isEmpty',
            true,
          ));
    });
    test('length', () {
      expect(log.length, 0);
      log.add('x', 1.0);
      expect(log.length, 1);
      expect(log.keys, equals(['x']));
    });
  });
  group('Entries:', () {
    test('add/get value', () {
      final log = DataLog<num>();
      log.add('temperature', 100);
      expect(log.get('temperature'), [100.0]);
    });
    test('addAll', () {
      final log = DataLog<num>();
      log.addAll(['x', 'y', 'z'], [1, 2, 3]);
      log.addAll(['x', 'y', 'z'], [1.1, 2.2, 3.3]);
      expect(log.get('x'), [1, 1.1]);
    });
    test('getAll', () {
      final log = DataLog<num>();
      log.addAll(['x', 'y', 'z'], [1, 2, 3]);
      log.addAll(['x', 'y', 'z'], [1.1, 2.2, 3.3]);
      expect(log.getAll(['x', 'y', 'z']), [
        [1, 2, 3],
        [1.1, 2.2, 3.3],
      ]);
    });
  });
  group('Errors:', () {
    final log = DataLog<num>();
    test('Adding an empty list.', () {
      expect(
        () => log.addAll(['x', 'y', 'z'], []),
        throwsA(
          isA<ErrorOf<DataLog>>().having(
            (e) => e.message,
            'message',
            'Error in method addAll([x, y, z], []). '
                'Could not store [] using keys [x, y, z].',
          ),
        ),
      );
    });
    test('Adding a list with wrong length.', () {
      expect(
        () => log.addAll(['x', 'y', 'z'], [9]),
        throwsA(
          isA<ErrorOf<DataLog>>().having(
            (e) => e.message,
            'message',
            'Error in method addAll([x, y, z], [9]). '
                'Could not store [9] using keys [x, y, z].',
          ),
        ),
      );
    });
  });
  group('Extension Export:', () {
    final log = DataLog<num>();
    log.add('temperature', 100.0);
    log.add('temperature', 101.2);
    log.addAll(['x', 'y', 'z'], [0, 0, 0]);
    log.addAll(['x', 'y', 'z'], [1, 2, 3]);
    test('export', () {
      expect(
          log.export(precision: 4),
          '#    temperature       x       y       z     \n'
          '100.0   0.000   0.000   0.000   \n'
          '101.2   1.000   2.000   3.000   \n'
          '\n'
          '');
    });
    test('exportFirst', () {
      expect(
          log.exportFirst(precision: 4),
          '#    temperature       x       y       z     \n'
          '100.0   0.000   0.000   0.000   \n'
          '');
    });
    test('exportLast', () {
      expect(
          log.exportLast(precision: 4),
          '#    temperature       x       y       z     \n'
          '101.2   1.000   2.000   3.000   \n'
          '');
    });
  });
}
