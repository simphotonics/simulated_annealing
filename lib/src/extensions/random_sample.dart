import 'dart:math';

import 'package:exception_templates/exception_templates.dart';

/// Inverse cummulative distribution function of a probability distribution
/// function with non-zero support over the interval: `(xMin, xMax)`.
/// The function must return a numerical value in the interval: `(xMin, xMax)`.
/// * `p`: A probability `0 <= p < 1`,
/// * `xMin`: the lower limit,
/// * `xMax`: the upper limit.
typedef InverseCdf = num Function(num p, num xMin, num xMax);

/// Extension on Random providing the methods
/// `nextInRange` and `nextIntFromList`.
extension RandomInRange on Random {
  /// Generates a random floating point
  /// value in the range from `xMin`,
  /// inclusive, to `xMax`, exclusive.
  /// * If `inverseCdf` is `null` it is assumed that the values are
  ///   uniformly distributed.
  /// * If `inverseCdf` is non-null, the random value is generated using
  ///   inversion sampling.
  num nextInRange(
    num xMin,
    num xMax,
    InverseCdf? inverseCdf,
  ) =>
      (inverseCdf == null)
          ? xMin + nextDouble() * (xMax - xMin)
          : inverseCdf(nextDouble(), xMin, xMax);

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
