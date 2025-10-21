import 'package:exception_templates/exception_templates.dart';
import 'package:list_operators/list_operators.dart';

/// A storage that can be used to log data of type `T`.
/// Each log record is accessed using a unique [String] key.
///
/// Usage:
/// ```Dart
/// import 'package:simulated_annealing/simulated_annealing.dart';
/// final log = DataLog<num>();
///
/// // Store values
/// log.add('temperature', 4.56);
/// log.add('temperature', 3.78);
///
/// // Retrieve record
/// final temperatures = log['temperature'];
/// ```
class DataLog<T extends Object> {
  final _data = <String, List<T>>{};

  /// Returns a view of the record of values logged using [key].
  ///
  /// If the record is empty or does
  /// not exist, an empty list is returned.
  List<T> get(String key) => _data[key]?.unmodifiable ?? <T>[];

  /// Adds [value] to the log stored under [key].
  ///
  /// Usage:
  /// ```Dart
  /// import 'package:simulated_annealing/simulated_annealing.dart';
  /// final log = DataLog<num>();
  ///
  /// // Store values
  /// log.add('temperature', 4.56);
  /// log.add('temperature', 3.78);
  ///
  /// // Retrieve record
  /// final temperatures = log['temperature'];
  /// ```
  void add(String key, T value) {
    if (containsKey(key)) {
      _data[key]!.add(value);
    } else {
      _data[key] = [value];
    }
  }

  /// Adds `values[i]` to the log stored under `keys[i]`.
  ///
  /// The length of [keys] and [values] must be the same.
  /// Usage:
  /// ```Dart
  /// import 'package:simulated_annealing/simulated_annealing.dart';
  /// final log = DataLog<num>();
  /// final positionKeys = ['x', 'y', 'z'];
  ///
  /// // Store values
  /// log.addAll(positionKeys, [3, 3.1, 5]);
  ///
  /// // Retrieve record
  /// final temperatures = log['temperature'];
  void addAll(List<String> keys, List<T> values) {
    if (keys.length != values.length) {
      throw ErrorOf<DataLog<T>>(
        message:
            'Error in method addAll($keys, $values). '
            'Could not store $values using keys $keys.',
        expectedState: 'Both lists must have the same length.',
        invalidState:
            'keys.length: ${keys.length}, '
            'values.length: ${values.length}.',
      );
    }
    for (var i = 0; i < keys.length; i++) {
      add(keys[i], values[i]);
    }
  }

  /// Clear the log removing all keys and the corresponding records.
  void clear() => _data.clear();

  /// Returns `true` if the log keys contain [key].
  bool containsKey(String key) => _data.containsKey(key);

  /// Returns `true` if [keys] is empty.
  bool get isEmpty => _data.isEmpty;

  /// Returns `true` if [keys] is not empty.
  bool get isNotEmpty => _data.isNotEmpty;

  /// Returns the [keys] that can be used to access the logged records
  /// using the methods [get] and [getAll].
  ///
  /// Each record corresponds to one key.
  Iterable<String> get keys => _data.keys;

  /// Returns the number of records stored in the log.
  int get length => _data.length;

  /// Returns the record stored under key and deleted it from the log.
  List<T> remove(String key) => _data.remove(key) ?? <T>[];

  /// Returns a list with entries of type [List<T>]. Each inner list contains
  /// one instance of the values logged under [keys].
  ///
  /// Note: The records for each key must have the same length.
  List<List<T>> getAll(List<String> keys) {
    final result = <List<T>>[];
    final dim = keys.length;
    // Check all records have same length.
    final count = get(keys.first).length;
    for (var i = 1; i < dim; i++) {
      int tmp = get(keys[i]).length;
      if (count != tmp) {
        throw ErrorOf<DataLog<T>>(
          message: 'Error in method getAll($keys).',
          invalidState: 'The record ${keys[i]} has length $tmp.',
          expectedState: 'All records must have the same length.',
        );
      }
    }

    for (var i = 0; i < count; ++i) {
      result.add(List<T>.generate(dim, (k) => get(keys[k])[i]));
    }
    return result;
  }

  @override
  String toString() {
    final b = StringBuffer('$runtimeType:');
    for (final key in keys) {
      b.writeln('  $key => record length: ${get(key).length}');
    }
    return b.toString();
  }
}

/// Records data of type `num` and `List<num>`.
extension Export on DataLog<num> {
  /// Exports all records as a `String`.
  ///
  /// All entities must have the same number of entries.
  String export({int precision = 10, String delimiter = '   '}) {
    final data = <List<num>>[];
    final b = StringBuffer('#  ');
    for (var key in keys) {
      b.write('  $key   ');
      b.write(''.padRight(precision ~/ 2));
      data.add(get(key));
    }
    b.write('\n');
    b.writeln(
      data.export(
        label: '',
        flip: true,
        precision: precision,
        delimiter: delimiter,
      ),
    );
    return b.toString();
  }

  /// Exports the first record as a `String`.
  ///
  /// All entities must have at least one entry.
  String exportFirst({int precision = 10, String delimiter = '   '}) {
    final data = <num>[];
    final b = StringBuffer('#  ');
    for (var key in keys) {
      b.write('  $key   ');
      b.write(''.padRight(precision ~/ 2));
      data.add(get(key).first);
    }
    b.write('\n');
    for (var entry in data) {
      b.write(entry.toStringAsPrecision(precision) + delimiter);
    }
    b.write('\n');
    return b.toString();
  }

  /// Exports the last record as a `String`.
  ///
  /// All entities must have at least one entry.
  /// All entities must have the same number of records (the same length).
  String exportLast({int precision = 10, String delimiter = '   '}) {
    final data = <num>[];
    final b = StringBuffer('#  ');
    for (var key in keys) {
      b.write('  $key   ');
      b.write(''.padRight(precision ~/ 2));
      data.add(get(key).last);
    }
    b.write('\n');
    for (var entry in data) {
      b.write(entry.toStringAsPrecision(precision) + delimiter);
    }
    b.write('\n');
    return b.toString();
  }
}
