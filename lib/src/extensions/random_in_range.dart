import 'dart:math';

import 'package:exception_templates/exception_templates.dart';

const oneThird = 1 / 3;

/// Inverse cummulative distribution function of a probability distribution
/// function with non-zero support over the interval: `[start, end)`.
/// The function must return a numerical value in the interval: `[start, end)`.
/// * `p`: A probability `0 <= p < 1`,
/// * `start`: the lower limit,
/// * `end`: the upper limit.
typedef InverseCdf = num Function(num p, num start, num end);

/// A function that scales a probability ( a value between 0 and 1)
/// such that the returned `value` is also a probability:
/// * 0 < value < 1,
/// * value = 0 for p = 0,
/// * value = 1 for p = 1.
typedef ProbabilityScale = num Function(num p);

/// A generalized inverse cummulative distribution function,
/// where the probability is scaled by a function of typedef [ProbabilityScale].
typedef FunctionalInverseCdf = num Function(
  num p,
  num start,
  num end, {
  required ProbabilityScale scale,
});

abstract class InverseCdfs {
  /// The inverse cummulative distribution of
  /// a random variable that is uniformly distributed in the
  /// interval `[start, end]`.
  /// * Returns a value that lies in the interval `start`...`end`.
  /// * p: A probability with value 0...1.
  static num uniform(num p, num start, num end) {
    return start + p * (end - start);
  }

  /// The inverse cummulative distribution of a random variable that
  /// is non-uniformly distributed in the interval `[start, end]`.
  /// * Returns a value that lies in the interval `start`...`end`.
  /// * p: A probability with value 0...1.
  /// * scale: A function of typedef [ProbabilityScale].
  static num functional(
    num p,
    num start,
    num end, {
    required ProbabilityScale scale,
  }) {
    return start + scale(p) * (end - start);
  }

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
  static num polarAngle(num p, num thetaMin, num thetaMax) {
    final cosThetaMin = cos(thetaMin);
    final cosThetaMax = cos(thetaMax);
    return (cosThetaMin == cosThetaMax)
        ? uniform(p, thetaMin, thetaMax)
        : acos(cosThetaMin - p * (cosThetaMin - cosThetaMax));
  }

  /// Returns the inverse cummulative distribution of the coordinate `x` of
  /// a two-dimensional search space with triangular geometry.
  /// The search space:
  /// * Extends from `xMin` to `xMax` along the horizontal axis.
  /// * Has zero extent in y-direction if the first coordinate is `xMin`.
  /// * Extends from `yMin` to `yMax` if the first corrdinate is `xMax`.
  /// * p is a probability with value 0...1.
  static num triangular(num p, num xMin, num xMax) =>
      xMin + (xMax - xMin) * sqrt(p);

  /// Returns the inverse cummulative distribution of the radius `rho` of
  /// a search space with cylindrical geometry specified by the coordinates
  /// `[rho, phi, z]`. See [SearchSpace].
  /// * `rho` >= 0.
  /// * `phi` takes values in the range 0...2*pi.
  static num rho(num p, num rhoMin, num rhoMax) =>
      rhoMin + (rhoMax - rhoMin) * sqrt(p);

  /// Returns the inverse cummulative distribution function of the radius `r`
  /// of a search space with spherical geometry specified by the coordinates
  /// `[r, theta, phi]` where `theta` is the polar angle
  /// and `phi` is the azimuth.
  static num r(num p, num rMin, num rMax) =>
      rMin + (rMax - rMin) * pow(p, oneThird);
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
  ///   non-zero support over the range [start]...[end].

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
  }) =>
      (inverseCdf == null)
          ? InverseCdfs.uniform(nextDouble(), start, end)
          : inverseCdf(nextDouble(), start, end);

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
  num nextLevelInRange(
    num start,
    num end,
    int levels, {
    InverseCdf? inverseCdf,
  }) {
    inverseCdf ??= InverseCdfs.uniform;
    final dx = (end - start) / (levels - 1);
    final next = nextInRange(start, end, inverseCdf: inverseCdf);
    return start + dx * ((next - start) / dx).round();
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
            message: 'Could not generate next value using the '
                'extension method `nextFromList`.',
            invalidState: 'The provided list is empty.',
            expectedState: 'A non-empty list containing possible values.');
      }
      rethrow;
    }
  }

  /// Returns the equidistant grid points of a discrete interval.
  /// The first point coincides with [start], the last one with [end].
  List<num> gridPoints(num start, num end, int levels) {
    final left = min(start, end);
    final right = max(start, end);
    final dx = (right - left) / (levels - 1);
    return List<num>.generate(levels, (index) => start + index * dx);
  }
}
