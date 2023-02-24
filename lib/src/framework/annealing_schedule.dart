import 'dart:math';

typedef TemperatureSequence = List<num> Function(
  num tStart,
  num tEnd, {
  int iterations,
});

/// Linear temperature sequence with entries:
///
/// `tStart, tStart - dt, ..., tStart - n * dt`
/// where `dt = (tEnd - tStart)/(n - 1)`
List<num> linearSequence(num tStart, num tEnd, {int iterations = 1000}) {
  final dt = (tEnd - tStart) / (iterations - 1);
  return List<num>.generate(iterations, (i) => tStart + dt * i);
}

/// Returns a geometric sequence with
/// entries:
///
/// `tStart, tStart * beta, ..., tStart * pow(beta, n-1)`.
///
/// The factor `beta` is calculated such that the last
/// entry of the sequence is equal to `tEnd`.
List<num> geometricSequence(
  num tStart,
  num tEnd, {
  int iterations = 1000,
}) {
  final beta = exp(log(tEnd / tStart) / (iterations - 1));
  var current = tStart.abs();
  final result =
      List<num>.generate(iterations - 1, (i) => current = current * beta);
  return result..insert(0, tStart.abs());
}

/// Returns a monotonically decreasing sequence with
/// entries: `tStart, ..., tEnd`.
///
/// `t(k) = tStart * exp(-pow(k / (2 * sigma), 2)` where
/// `sigma = n/sqrt(2 * log(tStart / tEnd))`.
List<num> normalSequence(
  num tStart,
  num tEnd, {
  int iterations = 1000,
}) {
  final invTwoSigmaSq = log(tStart / tEnd) / pow(iterations - 1, 2);
  return List<num>.generate(
      iterations, (i) => tStart * exp(-i * i * invTwoSigmaSq));
}

/// Exponentially decreasing sequence with start value `tStart` and
/// end value `tEnd`.
///
/// The general form of the sequence members is:
///
/// `t(k) = tStart * exp( -lambda * k)` where
/// `lambda = -log(tEnd.abs() / tStart.abs()) / (n - 1)`.
List<num> exponentialSequence(num tStart, num tEnd, {int iterations = 1000}) {
  final lambda = -log(tEnd.abs() / tStart.abs()) / (iterations - 1);
  final beta = exp(-lambda);
  var prev = tStart / beta;
  return List<num>.generate(iterations, (i) => prev = prev * beta);
}

/// Returns the sequence: `tStart, tStart / (1 + beta * tStart),`
/// `..., tStart / (1 * (n-1) * beta * tStart)`
/// where `beta = (1 / tEnd - 1 / tStart) / (n - 1)`.
List<num> lundySequence(num tStart, num tEnd, {int iterations = 1000}) {
  final beta = (1 / tEnd - 1 / tStart) / (iterations - 1);
  return List<num>.generate(
      iterations, (i) => tStart / (1 + i * beta * tStart));
}
