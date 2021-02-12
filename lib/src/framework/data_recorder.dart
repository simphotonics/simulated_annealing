import 'package:exception_templates/exception_templates.dart';
import 'package:list_operators/list_operators.dart';

/// Records numerical data of type `T` and `List<T>`.
class DataRecorder<T> {
  /// Data storage.
  final _scalars = <String, List<T>>{};

  /// Data storage.
  final _vectors = <String, List<T>>{};

  /// Map storing record dimension.
  final _dimensions = <String, int>{};

  /// Adds an entry with key `label` to `_scalars`.
  /// The value is an empty list.
  ///
  /// Note: Does not overwrite an existing entry with the same label.
  void _registerScalar(String label) {
    _scalars[label] ??= [];
    _dimensions[label] ??= 0;
  }

  /// Adds `dimension` entries to _vectors with keys `label0, label1, ...`.
  /// Each value is an empty list.
  ///
  /// /// Note: Does not overwrite existing entries.
  void _registerVector(String label, int dimension) {
    if (dimension < 1) {
      throw ErrorOf<DataRecorder>(
        message: 'Could not prepare '
            'storage for vector \'label\'.',
        invalidState: 'List `label` has length $dimension.',
        expectedState: 'The list must not be empty.',
      );
    }
    for (var i = 0; i < dimension; i++) {
      _vectors[label + i.toString()] ??= [];
    }
    _dimensions[label] ??= dimension;
  }

  /// Records the scalar `value`.
  void addScalar(String label, T value) {
    switch (_dimensions[label]) {
      case 0:
        _scalars[label]!.add(value);
        break;
      case null:
        _registerScalar(label);
        _scalars[label]!.add(value);
        break;
      default:
        throw ErrorOf<DataRecorder<T>>(
            message: 'Could not add $value with label: $label.',
            invalidState:
                'A non-scalar with label \'$label\' is already registered.',
            expectedState:
                'Try adding an object of type  \'List<$T>\' with length '
                '${_dimensions[label]} using addVector($label, List<$T> value).');
    }
  }

  /// Records the vector `value`.
  void addVector(String label, List<T> value) {
    switch (_dimensions[label]) {
      case 0:
        throw ErrorOf<DataRecorder<T>>(
            message: 'Could not add list: $value with label: $label.',
            invalidState:
                'A scalar with label \'$label\' is already registered.',
            expectedState: 'Try adding a object of type \'$T\' '
                'using addScalar($label, T value).');
      case null:
        _registerVector(label, value.length);
        for (var i = 0; i < value.length; i++) {
          _vectors[label + i.toString()]!.add(value[i]);
        }
        break;
      default:
        if (value.length == _dimensions[label]) {
          for (var i = 0; i < value.length; i++) {
            _vectors[label + i.toString()]!.add(value[i]);
          }
        } else {
          if (value.length != _dimensions[label]) {
            throw ErrorOf<DataRecorder<T>>(
                message: 'Could not add list: $value with label: $label.',
                invalidState: 'The length of $value does not match the '
                    'registered vector length.',
                expectedState: 'Try adding a list of length '
                    '${_dimensions[label]}.');
          }
        }
    }
  }

  /// Returns a list of scalars of type `T` recorded under `label`.
  List<T> getScalar(String label) {
    return _scalars[label] ?? <T>[];
  }

  /// Returns a list with entries of type `List<T>` recorded under `label`.
  List<List<T>> getVector(String label) {
    final result = <List<T>>[];
    for (var i = 0; i < getDimension(label); ++i) {
      result.add(_vectors[label + '$i']!);
    }
    return result;
  }

  /// Returns the dimension of the storage with the given `label`.
  /// * Scalars have dimension 0.
  /// * Returns -1 if the label is unknown.
  int getDimension(String label) {
    return _dimensions[label] ?? -1;
  }
}

class NumericalDataRecorder extends DataRecorder<num> {
  /// Exports all records as a `String`.
  ///
  /// All entities must have the same number of entries.
  String export({int precision = 10, String delimiter = '   '}) {
    final data = <List<num>>[];
    final b = StringBuffer();
    for (var key in _vectors.keys) {
      b.write('$key  ');
      data.add(_vectors[key]!);
    }
    for (var key in _scalars.keys) {
      b.write('$key  ');
      data.add(_scalars[key]!);
    }
    b.write('\n');
    b.writeln(data.export(
      label: '',
      flip: true,
      precision: precision,
      delimiter: delimiter,
    ));
    return b.toString();
  }

  /// Exports the first record as a `String`.
  ///
  /// All entities must have at least one entry.
  String exportFirst({int precision = 10, String delimiter = '   '}) {
    final data = <num>[];
    final b = StringBuffer();
    for (var key in _vectors.keys) {
      b.write('$key  ');
      data.add(_vectors[key]!.first);
    }
    for (var key in _scalars.keys) {
      b.write('$key  ');
      data.add(_scalars[key]!.first);
    }
    b.write('\n');
    for (var entry in data) {
      b.write(entry.toStringAsPrecision(precision) + delimiter);
    }
    return b.toString();
  }

  /// Exports the first record as a `String`.
  ///
  /// All entities must have at least one entry.
  /// All entities must have the same number of records (the same length).
  String exportLast({int precision = 10, String delimiter = '   '}) {
    // Get number of records
    if (_dimensions.isEmpty) {
      return 'NumericalDataRecorder: Data records are empty.';
    }

    final firstKey = _dimensions.keys.first;
    final length = (_dimensions[firstKey] == 0)
        ? _scalars[firstKey]!.length
        : _vectors[firstKey + '0']!.length;

    final data = <num>[];
    final b = StringBuffer();
    for (var key in _vectors.keys) {
      b.write('$key  ');
      if (length == _vectors[key]!.length) {
        data.add(_vectors[key]!.last);
      } else {
        throw ErrorOf<NumericalDataRecorder>(
            message: 'Could not export last record of entity: $key.',
            invalidState: 'Entity $key does not have $length entries.',
            expectedState: 'All entities must '
                'have the same number of records.');
      }
    }
    for (var key in _scalars.keys) {
      b.write('$key  ');
      if (length == _scalars[key]!.length) {
        data.add(_scalars[key]!.last);
      } else {
        throw ErrorOf<NumericalDataRecorder>(
            message: 'Could not export last record of entity: $key.',
            invalidState: 'Entity $key does not have $length entries.',
            expectedState: 'All entities must '
                'have the same number of records.');
      }
    }
    b.write('\n');
    for (var entry in data) {
      b.write(entry.toStringAsPrecision(precision) + delimiter);
    }
    return b.toString();
  }
}
