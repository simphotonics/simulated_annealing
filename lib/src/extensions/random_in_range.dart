import 'dart:math';

import 'package:exception_templates/exception_templates.dart';

/// Inverse cummulative distribution function of a probability distribution
/// function with non-zero support over the interval: `[xMin, xMax)`.
/// The function must return a numerical value in the interval: `[xMin, xMax)`.
/// * `p`: A probability `0 <= p < 1`,
/// * `xMin`: the lower limit,
/// * `xMax`: the upper limit.
typedef InverseCdf = num Function(num p, num xMin, num xMax);

/// Extension on [Random] providing the methods
/// `nextInRange` and `nextIntFromList`.
extension RandomInRange on Random {
  /// Generates a random floating point
  /// value in the range from `xMin`,
  /// inclusive, to `xMax`, exclusive.
  /// * `xMin`: left boundary of the interval.
  /// * `xMax`: right boundary of the interval, `xMin <= xMax`.
  /// * `inverseCdf`: inverse of the cummulative
  ///   probability distribution function  with
  ///   non-zero support over the range [xMin,&nbsp;xMax).
  /// * `nGrid`: Number of grid points.
  ///   If `nGrid > 1` the interval
  ///   is divided into an equidistant grid
  ///   with `nGrid` points: `[xMin + dx, xMin + 2 * dx, ..., xMax - dx]`
  ///   where `dx = (xMax - xMin) / nGrid` and any random number returned
  ///   coincides with a gridpoint `xMin` exclusive, `xMax` exclusive.
  /// ---
  /// * If `inverseCdf == null` it is assumed that the values are
  ///   uniformly distributed.
  /// * If `inverseCdf` is non-null, the random value is generated using:
  ///   `inverseCdf(nextDouble(), xMin, xMax)`.
  /// * Note: The function `inverseCdf(p, xMin, xMax)` must return a
  ///   value in the range `[xMin, xMax)` for each argument `p`
  ///   in the range `[0,1)`.
  num nextInRange(
    num xMin,
    num xMax, {
    InverseCdf? inverseCdf,
    int nGrid = 0,
  }) {
    if (xMin == xMax) {
      return xMax;
    }
    if (nGrid < 2) {
      return inverseCdf == null
          ? xMin + nextDouble() * (xMax - xMin)
          : inverseCdf(nextDouble(), xMin, xMax);
    } else {
      final dx = (xMax - xMin) / (nGrid);
      if (inverseCdf == null) {
        return xMin +
            0.5 * dx +
            (((1.0 - 1.0 / nGrid) * nextDouble() * (xMax - xMin)) / dx)
                    .roundToDouble() *
                dx;
      } else {
        return (xMin +
            0.5 * dx +
            (((1.0 - 1.0 / nGrid) * inverseCdf(nextDouble(), xMin, xMax) -
                            xMin) /
                        dx)
                    .roundToDouble() *
                dx);
      }
    }
  }

  /// Returns a list containing the grid points of an interval
  /// with
  /// * `xMin`: left boundary,
  /// * `xMax`: right boundary,
  /// * `nGrid`: number of grid points.
  ///
  /// Returns an empty list if `grid < 2`.
  List<num> gridPoints(num xMin, num xMax, int nGrid) {
    if (nGrid < 2) return [];
    final dx = (xMax - xMin) / (nGrid);
    final x0 = xMin + 0.5 * dx;
    final result = List<num>.generate(nGrid, (i) => x0 + i * dx);
    return result;
  }

  /// Generates a integer randomly picked from
  /// a list of integers.
  /// The list must not be empty.
  int nextIntFromList(List<int> list) {
    if (list.isEmpty) {
      throw ErrorOf<Random>(
          message: 'Could not generate next int from list.',
          invalidState: 'The provided list is empty.');
    }
    return list[nextInt(list.length)];
  }
}
