import 'dart:math';

import 'package:exception_templates/exception_templates.dart';
import 'package:list_operators/list_operators.dart' show IndexOutOfRange;

extension CylindricalCoordinates on List<num> {
  /// Transforms Cylindrical coordinates `[rho, phi, z]`
  /// to Cartesian coordiantes `[x. y, z]`.
  /// * `rho`: radius, a value larger equal zero.
  /// * `phi`: azimuth, a value between 0 and 2*pi.
  /// * `z`: vertical coordinate.
  List<num> get cylindricalToCartesian => [
    this[0] * cos(this[1]),
    this[0] * sin(this[1]),
    this[2],
  ];

  /// Transforms Cartesian coordinates `[x, y, z]`
  /// to Cylindrical coordinates `[rho, phi, z]`.
  /// ---
  /// Note: The angle `phi` is mapped to the interval 0...2*pi.
  List<num> get cartesianToCylindrical {
    final x = this[0];
    final y = this[1];
    final z = this[2];
    late final rho = sqrt(x * x + y * y);
    if (x == 0) {
      if (y > 0) {
        // Point on y-z plane.
        return [y, pi / 2, z];
      } else if (y < 0) {
        // Point on y-z plane, y < 0.
        return [y, pi, z];
      } else {
        // Point on z-axis, x = 0, y = 0.
        return [0, 0, z];
      }
    }
    // Note: The range of the function atan is -pi/2 ... pi/2.
    if (x < 0) {
      // Second and third quadrant (x < 0).
      return [rho, pi + atan(y / x), z];
    }
    if (y < 0) {
      // Fourth quadrant (x > 0, y < 0).
      return [rho, 2 * pi + atan(y / x), z];
    }
    // First quadrant. (x > 0, y > 0).
    return [rho, atan(y / x), z];
  }
}

/// Converts a list containing Cartesian coordinates
/// to a list containing Cylindrical coordinates.
extension CylindricalCoordinateList on List<List<num>> {
  /// Converts a list of Polar Spherical coordinates `[rho, phi, z]`
  /// to a list of Cartesian coordiantes `[x. y, z]`.
  /// * `rho`: radius, a value larger equal zero.
  /// * `phi`: the azimuth, a value between 0 and 2*pi.
  /// * `z`: the vertical coordinate.
  List<List<num>> get cylindricalToCartesian {
    try {
      return List<List<num>>.generate(
        length,
        (index) => this[index].cylindricalToCartesian,
      );
    } on RangeError catch (e) {
      throw ErrorOfType<IndexOutOfRange>(
        message: 'Error in getter <cylindricalToCartesian>.',
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
  /// * `[x, y, z]` ->  `[rho, phi, z]`,
  /// * `rho` is the radius.
  /// * `phi` is azimuth in rad taking values 0...2*pi.
  List<List<num>> get cartesianToCylindrical {
    try {
      return List<List<num>>.generate(
        length,
        (index) => this[index].cartesianToCylindrical,
      );
    } on RangeError catch (e) {
      throw ErrorOfType<IndexOutOfRange>(
        message: 'Error in getter <cartesianToCylindrical>.',
        invalidState:
            'Could not access list '
            'element with index:<${e.invalidValue}>.',
        expectedState: 'A set of coordinates as a List<num> with length 3.',
      );
    }
  }
}
