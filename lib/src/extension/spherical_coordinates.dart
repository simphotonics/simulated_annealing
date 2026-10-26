import 'dart:math';

import 'package:exception_templates/exception_templates.dart';
import 'package:list_operators/list_operators.dart' show IndexOutOfRange;

/// Transforms a list containing Cartesian coordinates `[x, y, z]`
/// to Polar Spherical coordinates `[r, theta, phi]`.
extension SphericalCoordinates on List<num> {
  /// Transforms Polar Spherical coordinates `[r, theta, phi]`
  /// to Cartesian coordiantes `[x. y, z]`.
  /// * `r`: radius, a value larger equal zero.
  /// * `theta`: the polar angle, a value between 0 and pi.
  /// * `phi`: the azimuth, a value between 0 and 2*pi.
  List<num> get sphericalToCartesian => [
    this[0] * sin(this[1]) * cos(this[2]),
    this[0] * sin(this[1]) * sin(this[2]),
    this[0] * cos(this[1]),
  ];

  /// Transforms Cartesian coordinates `[x, y, z]`
  /// to Polar Spherical coordinates `[r, theta, phi]`.
  /// * first coordinate: x (the first horizontal coordinate),
  /// * second coordinate: y (the second horizontal coordinate),
  /// * third coordinate: z (the vertical coordinate).
  List<num> get cartesianToSpherical {
    if (this[0] == 0 && this[1] == 0) {
      // Origin
      if (this[2] == 0) {
        return [0, 0, 0];
      }
      // Point on z-axis
      return [this[2].abs(), this[2].isNegative ? pi : 0, 0];
    }

    // Rest of points
    num rxy2 = this[0] * this[0] + this[1] * this[1];
    num r = sqrt(rxy2 + this[2] * this[2]);
    return [r, acos(this[2] / r), this[1].sign * acos(this[0] / sqrt(rxy2))];
  }
}

/// Converts a list containing Cartesian coordinates
/// to a list containing Polar Spherical coordinates.
extension SphericalCoordinateList on List<List<num>> {
  /// Converts a list of Polar Spherical coordinates `[r, theta, phi]`
  /// to a list of Cartesian coordiantes `[x. y, z]`.
  /// * `r`: radius, a value larger equal zero.
  /// * `theta`: the polar angle, a value between 0 and pi.
  /// * `phi`: the azimuth, a value between 0 and 2*pi.
  List<List<num>> get sphericalToCartesian {
    try {
      return List<List<num>>.generate(
        length,
        (index) => this[index].sphericalToCartesian,
      );
    } on RangeError catch (e) {
      throw ErrorOfType<IndexOutOfRange>(
        message: 'Error in getter <sphericalToCartesian>.',
        invalidState:
            'Could not access list '
            'element with index:<${e.invalidValue}>.',
        expectedState: 'A set of coordinates as a List<num> with length 3.',
      );
    }
  }

  /// Converts a list of Cartesian coordinates
  /// to a list of Polar Spherical coordinates:
  ///
  /// * `[x, y, z]` ->  `[r, theta, phi]`,
  /// * `theta` is the angle between the z-axis and the
  /// line connecting the origin with the point `[x, y, z]`,
  /// * `phi` is the angle between the x-axis and the
  /// line connecting the origin with the projection point of
  /// `[x, y, z]` onto the
  /// x-y plane.
  List<List<num>> get cartesianToSpherical {
    try {
      return List<List<num>>.generate(
        length,
        (index) => this[index].cartesianToSpherical,
      );
    } on RangeError catch (e) {
      throw ErrorOfType<IndexOutOfRange>(
        message: 'Error in getter <cartesianToSpherical>.',
        invalidState:
            'Could not access list '
            'element with index:<${e.invalidValue}>.',
        expectedState: 'A set of coordinates as a List<num> with length 3.',
      );
    }
  }
}
