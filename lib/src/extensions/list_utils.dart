import 'package:exception_templates/exception_templates.dart';
import 'package:simulated_annealing/src/exceptions/incompatible_vectors.dart';

extension Export on List<List<num>> {
  /// Exports vectors `List<num>` as rows.
  String export({
    String label = '# x  y  z',
    String delimiter = ' ',
    int precision = 20,
    bool flip = false,
  }) {
    final b = StringBuffer();
    b.writeln(label);

    if (flip) {
      final dims = List<num>.generate(length, (i) => this[i].length);
      var nCount = dims[0];
      if (dims.every((current) => current == nCount)) {
        for (var n = 0; n < nCount; ++n) {
          for (var i = 0; i < length; ++i) {
            b.write('${this[i][n].toStringAsPrecision(precision)}$delimiter');
          }
          b.writeln('');
        }
      } else {
        b.writeln('Could not export List<List<num>> with option <flipped>.');
        b.writeln('All sub-lists must have the same length!');
      }
    } else {
      for (var n = 0; n < length; ++n) {
        for (var i = 0; i < this[n].length; ++i) {
          b.write('${this[n][i].toStringAsPrecision(precision)}$delimiter');
        }
        b.writeln('');
      }
    }
    return b.toString();
  }
}

extension SimpleExport on List<num> {
  /// Exports vectors `List<num>` as rows.
  String export({
    String label = '# x ',
    String delimiter = ' ',
    int precision = 20,
  }) {
    final b = StringBuffer();
    b.writeln(label);

    for (var i = 0; i < length; ++i) {
      b.writeln('${this[i].toStringAsPrecision(precision)}$delimiter');
    }
    return b.toString();
  }
}

extension VectorOperators on List<num> {
  /// Asserts that `this` and `other` have the same length.
  void assertSameLength(List<num> other, {String operatorSymbol = ''}) {
    if (length != other.length) {
      throw ErrorOfType<IncompatibleVector>(
        message: 'Vector operation $this $operatorSymbol $other not supported.',
        invalidState: 'Vector length does not match.',
        expectedState: 'A vector of length: $length.',
      );
    }
  }

  /// Adds two numerical lists of same length.
  List<num> plus(List<num> other) {
    assertSameLength(other, operatorSymbol: '+');
    return List<num>.generate(length, (i) => this[i] + other[i]);
  }

  /// Subtracts two numerical lists of same length.
  List<num> operator -(List<num> other) {
    assertSameLength(other, operatorSymbol: '-');
    return List<num>.generate(length, (i) => this[i] - other[i]);
  }

  /// Returns the scalar vector product of `this` and `other`.
  num operator *(List<num> other) {
    assertSameLength(other, operatorSymbol: '*');
    num sum = 0;
    for (var i = 0; i < length; i++) {
      sum += this[i] * other[i];
    }
    return sum;
  }

  /// Divides each component of `this` by `scalar`.
  List<num> divide(num scalar) {
    return List<num>.generate(length, (i) => this[i] / scalar);
  }

  /// Multiplies each component of `this` with `scalar`.
  List<num> times(num scalar) {
    return List<num>.generate(length, (i) => this[i] * scalar);
  }
}
