import 'package:exception_templates/exception_templates.dart';
import 'package:test/test.dart';

import 'package:simulated_annealing/simulated_annealing.dart';

void main() {
  group('getDimension:', () {
    final rec = NumericalDataRecorder();
    test('non-existent record', () {
      expect(rec.getDimension('non-existent'), -1);
    });
  });
  group('adding entries:', () {
    final rec = NumericalDataRecorder();
    test('scalar', () {
      rec.addScalar('temperature', 100);
      expect(rec.getScalar('temperature'), [100.0]);
      expect(rec.getDimension('temperature'), 0);
    });
    test('vector', () {
      rec.addVector('position', [1, 2, 3]);
      expect(rec.getDimension('position'), 3);
      expect(rec.getVector('position'), [
        [1],
        [2],
        [3]
      ]);
      rec.addVector('position', [1.2, 2.5, 3.6]);
      expect(rec.getVector('position'), [
        [1, 1.2],
        [2, 2.5],
        [3, 3.6]
      ]);
    });
  });
  group('Errors:', () {
    final rec = NumericalDataRecorder();
    test('Adding an empty list.', () {
      try {
        rec.addVector('position', []);
      } on ErrorOf<DataRecorder> catch (e) {
        expect(
            e.message,
            anyOf('Could not prepare storage for vector \'label\'.',
                'Could not add list: [] with label: position.'));
      }
    });
    test('Adding a list with wrong length.', () {
      try {
        rec.addVector('position', [9]);
      } on ErrorOf<DataRecorder> catch (e) {
        expect(e.message, 'Could not add list: [9] with label: position.');
      }
    });
    test('Adding a list where a scalar is expected.', () {
      try {
        rec.addVector('temperature', [100, 101]);
      } on ErrorOf<DataRecorder> catch (e) {
        expect(
            e.message,
            'Could not add list: [100, 101]'
            ' with label: temperature.');
      }
    });
  });
  group('NumericalDataRecorder:', () {
    final numRec = NumericalDataRecorder();
    numRec.addScalar('temperature', 100.0);
    numRec.addScalar('temperature', 101.2);
    numRec.addVector('position', [0, 0, 0]);
    numRec.addVector('position', [1, 2, 3]);
    test('export', () {
      expect(
          numRec.export(precision: 4),
          'position0  position1  position2  temperature  \n'
          '0.000   0.000   0.000   100.0   \n'
          '1.000   2.000   3.000   101.2   \n'
          '\n'
          '');
    });
    test('exportFirst', () {
      expect(
          numRec.exportFirst(precision: 4),
          'position0  position1  position2  temperature  \n'
          '0.000   0.000   0.000   100.0   ');
    });
    test('exportLast', () {
      expect(
          numRec.exportFirst(precision: 4),
          'position0  position1  position2  temperature  \n'
          '0.000   0.000   0.000   100.0   ');
    });
  });
}
