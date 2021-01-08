import 'dart:math';

/// Extension on Random providing the method
/// `nextDoubleInRange`.
extension RandomInRange on Random {
  /// Generates a random floating point
  /// value uniformly distributed in the range from `xMin`,
  /// inclusive, to `xMax`, exclusive.
  double nextDoubleInRange(num xMin, num xMax) =>
      xMin + nextDouble() * (xMax - xMin);
}
