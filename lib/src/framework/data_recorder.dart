import '../extensions/list_utils.dart';

/// Records numerical data in scalar and vector format.
class DataRecorder {
  /// Map storing numerical data.
  final _store = <String, List<num>>{};

  /// Adds a map entry with key `label`. The value is an empty list.
  void prepareScalar(String label) {
    _store[label] = [];
  }

  /// Adds `dimension` map entries with keys `label0, label1, ...`.
  /// Each value is an empty list.
  void prepareVector(String label, int dimension) {
    for (var i = 0; i < dimension; ++i) {
      _store[label + i.toString()] = [];
    }
  }

  /// Records the scalar `value`.
  void addScalar(String label, num value) {
    _store[label]!.add(value);
  }

  /// Records the vector `value`.
  void addVector(String label, List<num> value) {
    for (var i = 0; i < value.length; ++i) {
      _store[label + i.toString()]!.add(value[i]);
    }
  }

  /// Exports all records as a `String`.
  String export() {
    final data = <List<num>>[];
    final b = StringBuffer();
    for (var key in _store.keys) {
      b.write('$key  ');
      data.add(_store[key]!);
    }
    b.write('\n');
    b.writeln(data.export(label: '', flip: true));
    return b.toString();
  }

  /// Returns the scalar recorded under `label`.
  List<num> getScalar(String label) {
    return _store[label] ?? <num>[];
  }

  /// Returns the vector recorded under `label`.
  List<List<num>> getVector(String label) {
    final result = <List<num>>[];
    var i = 0;
    while (_store.containsKey(label + '$i')) {
      result.add(_store[label + '$i']!);
      ++i;
    }
    return result;
  }
}
