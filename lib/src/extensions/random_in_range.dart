import 'dart:math';

import 'package:exception_templates/exception_templates.dart';

/// Inverse cummulative distribution function of a probability distribution
/// function with non-zero support over the interval: `[start, end)`.
/// The function must return a numerical value in the interval: `[start, end)`.
/// * `p`: A probability `0 <= p < 1`,
/// * `start`: the lower limit,
/// * `end`: the upper limit.
typedef InverseCdf = num Function(num p, num start, num end);

abstract class InverseCdfs {
  /// The inverse cummulative distribution of
  /// a random variable that is uniformly distributed in the
  /// interval `[start, end]`.
  /// * Returns a value that lies in the interval `start`...`end`.
  /// * p: A probability with value 0...1.
  static InverseCdf get uniform => (num p, num start, num end) {
        return start + p * (end - start);
      };

  /// Returns the inverse cummulative distribution of the
  /// a random variable with probability distribution:
  /// pdf(theta) = sin(theta)/delta.
  /// ---
  /// Derivation: Let delta = cos(thetaMin) - cos(thetaMax)
  /// * pdf(theta) = sin(theta)/delta
  /// * cdf(theta) = cos(thetaMin) - cos(theta)/delta
  /// * inverseCdf(p) = acos(cos(thetaMin) - p*delta))
  /// ---
  /// Note: It is not defined for `cos(thetaMin) - cos(thetaMax) == 0`.
  /// In this case, we use a uniform distribution.
  static InverseCdf get polarAngle => (num p, num thetaMin, num thetaMax) {
        final cosThetaMin = cos(thetaMin);
        final cosThetaMax = cos(thetaMax);
        return (cosThetaMin == cosThetaMax)
            ? uniformInverseCdf(p, thetaMin, thetaMax)
            : acos(cosThetaMin - p * (cosThetaMin - cosThetaMax));
      };

  /// Returns the inverse cummulative distribution of the coordinate `x` of
  /// a two-dimensional search space with triangular geometry.
  /// The search space:
  /// * Extends from `xMin` to `xMax` along the horizontal axis.
  /// * Has zero extent in y-direction if the first coordinate is `xMin`.
  /// * Extends from `yMin` to `yMax` if the first corrdinate is `xMax`.
  /// * p is a probability with value 0...1.
  static InverseCdf get triangular =>
      (num p, num xMin, num xMax) => xMin + (xMax - xMin) * sqrt(p);
}

/// The inverse cummulative distribution of
/// a random variable that is uniformly distributed in the
/// interval `[start, end]`.
/// * Returns a value that lies in the interval `start`...`end`.
/// * p: A probability with value 0...1.
num uniformInverseCdf(num p, num start, num end) {
  return start + p * (end - start);
}

/// Extension on [Random] providing the methods
/// `nextInRange` and `nextIntFromList`.
extension RandomInRange on Random {
  /// Generates a random floating point
  /// value in the range from `start`,
  /// inclusive, to `end`, exclusive.
  /// * `start`: left boundary of the interval.
  /// * `end`: right boundary of the interval, `start <= end`.
  /// * `inverseCdf`: inverse of the cummulative
  ///   probability distribution function  with
  ///   non-zero support over the range [start,&nbsp;end).
  /// * `nGrid`: Number of grid points.
  ///   If `nGrid > 1` the interval
  ///   is divided into an equidistant grid
  ///   with `nGrid` points: `[start + dx, start + 2 * dx, ..., end - dx]`
  ///   where `dx = (end - start) / nGrid` and any random number returned
  ///   coincides with a gridpoint `start` exclusive, `end` exclusive.
  /// ---
  /// * If `inverseCdf == null` it is assumed that the values are
  ///   uniformly distributed.
  /// * If `inverseCdf` is non-null, the random value is generated using:
  ///   `inverseCdf(nextDouble(), start, end)`.
  /// * Note: The function `inverseCdf(p, start, end)` must return a
  ///   value in the range `[start, end)` for each argument `p`
  ///   in the range `[0,1)`.
  num nextInRange(
    num start,
    num end, {
    InverseCdf? inverseCdf,
    int nGrid = 0,
  }) {
    if (start == end) {
      return end;
    }
    if (nGrid < 2) {
      return inverseCdf == null
          ? start + nextDouble() * (end - start)
          : inverseCdf(nextDouble(), start, end);
    } else {
      final dx = (end - start) / (nGrid);
      if (inverseCdf == null) {
        return start +
            0.5 * dx +
            (((1.0 - 1.0 / nGrid) * nextDouble() * (end - start)) / dx)
                    .roundToDouble() *
                dx;
      } else {
        return (start +
            0.5 * dx +
            (((1.0 - 1.0 / nGrid) * inverseCdf(nextDouble(), start, end) -
                            start) /
                        dx)
                    .roundToDouble() *
                dx);
      }
    }
  }

  /// Returns a list containing the grid points of an interval
  /// with
  /// * `start`: left boundary,
  /// * `end`: right boundary,
  /// * `nGrid`: number of grid points.
  ///
  /// Returns an empty list if `nGrid < 2`.
  List<num> gridPoints(num start, num end, int nGrid) {
    if (nGrid < 2) return [];
    final dx = (end - start) / (nGrid);
    final x0 = start + 0.5 * dx;
    final result = List<num>.generate(nGrid, (i) => x0 + i * dx);
    return result;
  }

  /// Generates an integer randomly picked from
  /// a list of integers.
  /// The list must not be empty.
  T nextFromList<T>(List<T> list) {
    try {
      return list[nextInt(list.length)];
    } catch (e) {
      if (list.isEmpty) {
        throw ErrorOf<Random>(
            message: 'Could not generate next random value from list.',
            invalidState: 'The provided list is empty.');
      }
      rethrow;
    }
  }
}
