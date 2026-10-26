import 'dart:math';

import 'package:exception_templates/exception_templates.dart';
import 'package:list_operators/list_operators.dart' show LengthMismatch;

enum Coordinates {
  /// Rectangular coordinate system: `[x, y, z]`.
  cartesian,

  /// Spherical coordinate system: `[r, theta, phi]`
  /// where `theta` is the polar angle and `phi` is the azimuth.
  spherical,

  /// Cylindrical coordinate system: `[r, phi, z]` where
  /// `phi` is the azimuth.
  cylindrical,
}

extension EuclideanMetric on List<num> {
  /// Returns the Euclidean distance (straight line distance)
  /// between the origin and `this`assuming the entries
  /// represent Cartesian coordinates.
  num get distanceFromOrigin =>
      sqrt(fold<num>(0, (sum, element) => sum + element * element));

  /// Returns the Euclidean distance (straight line distance)
  /// between `this` and [other].
  ///
  /// Throws an error if `this.length != other.length`.
  num distance(
    List<num> other, {
    Coordinates coordinates = Coordinates.cartesian,
  }) {
    try {
      switch (coordinates) {
        case Coordinates.cartesian:
          num result = 0;
          for (var i = 0; i < length; ++i) {
            result += pow(this[i] - other[i], 2);
          }
          return sqrt(result);
        case Coordinates.spherical:
          return sqrt(
            pow(this[0], 2) +
                pow(other[0], 2) -
                2 *
                    this[0] *
                    other[0] *
                    (sin(this[1]) * sin(other[1]) * cos(this[2] - other[2]) +
                        cos(this[1]) * cos(other[1])),
          );
        case Coordinates.cylindrical:
          return sqrt(
            pow(this[0], 2) +
                pow(other[0], 2) -
                2 * this[0] * other[0] * cos(this[1] + other[1]) +
                pow(this[2] - other[2], 2),
          );
      }
    } on RangeError catch (_) {
      throw ErrorOfType<LengthMismatch>(
        message: 'Can\'t calculate distance between $this and $other.',
        invalidState: 'Length of other is: ${other.length}.',
        expectedState: 'The argument \'other\' must have length: $length.',
      );
    }
  }
}
