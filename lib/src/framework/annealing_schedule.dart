import 'dart:collection';
import 'dart:math';

import '../extensions/list_utils.dart';

/// Linear temperature sequence with entries:
///
/// `[tStart, tStart - dt, ..., tStart - n * dt]` where `dt = (tEnd - tStart)/(n - 1)`
List<num> linearSequence(num tStart, num tEnd, {int n = 3000}) {
  final dt = (tEnd - tStart) / (n - 1);
  return List<num>.generate(n, (i) => tStart + dt * i);
}

/// Returns a geometric sequence with
/// entries:
///
/// `tStart * beta(0), tStart * beta(0)* beta(1), ..., tStart * beta(0) * ... * beta(n-1)`.
///
/// where `beta` is linearly interpolated between `betaStart` and `betaEnd`.
List<num> geometricSequence(
  num tStart, {
  betaStart = 0.99,
  betaEnd = 0.999,
  int n = 3000,
}) {
  final beta = linearSequence(betaStart, betaEnd, n: n - 1);
  beta.insert(0, 1);
  var current = tStart.abs();
  return List<num>.generate(n, (i) => current = current * beta[i]);
}

/// Returns a monotonically decreasing sequence with entries: `tStart, ..., tEnd`.
///
/// `tK = tStart * exp(-pow(k / (2 * sigma), 2)` where
/// `sigma = n/sqrt(2 * log(tStart / tEnd))`.
List<num> normalSequence(
  num tStart,
  num tEnd, {
  int n = 3000,
}) {
  final invTwoSigmaSq = log(tStart / tEnd) / pow(n - 1, 2);
  print(invTwoSigmaSq);
  return List<num>.generate(n, (i) => tStart * exp(-i * i * invTwoSigmaSq));
}

/// Exponentially decreasing sequence with start value `tStart` and
/// end value `tEnd`.
///
/// The general form of the sequence members is:
///
/// `t_k = t0 * exp( -lambda * k)` where
/// `lambda = -log(tEnd.abs() / tStart.abs()) / (n - 1)`.
List<num> exponentialSequence(num tStart, num tEnd, {int n = 3000}) {
  final lambda = -log(tEnd.abs() / tStart.abs()) / (n - 1);
  final beta = exp(-lambda);
  var prev = tStart / beta;
  return List<num>.generate(n, (i) => prev = prev * beta);
}

/// Exponentially decreasing sequence,
///
/// After `n05` iterations the temperature will be `tStart / 2`.
///
/// Note: The function is not continous but has a kink at `tStart/2`.
/// For `n > n05` the decay constant is calculated such that the last element
/// in the sequence is equal to `tEnd`.
List<num> exponentialSequenceN05(
  num tStart,
  num tEnd, {
  int n05 = 600,
  int n = 3000,
}) {
  final _tStart = tStart.abs();
  final lambda = 1 / n05.abs();
  final firstPart =
      List<num>.generate(n05, (i) => _tStart * pow(2, -lambda * i));
  final secondPart = exponentialSequence(tStart / 2, tEnd, n: n - n05);
  return <num>[...firstPart, ...secondPart];
}

/// Returns the sequence: `tStart, tStart / (1 + beta * tStart),`
/// `... tStart / (1 * (n-1) * beta * tStart)`
List<num> lundy(num tStart, num beta, {int n = 3000}) {
  return List<num>.generate(n, (i) => tStart / (1 + i * beta * tStart));
}

/// Annealing schedule consisting of a sequence of temperatures.
/// The initial temperature must be the largest value in the sequence.
///
/// The sequence should decrease
/// (not necessarily monotonically) and tend towards zero.
class AnnealingSchedule {
  /// Constructs an object of type `AnnealingSchedule`.
  /// * `temperatures`: sequence of temperatures,
  /// * `dxMax`: Vector components containing the maximum perturbation
  /// magnitudes (typically the size of the search space along each
  /// dimension).
  /// * `dxMin`: Vector components containing the minimum perturbation
  /// magnitudes (tyically related to the
  /// required solution precision).
  AnnealingSchedule(
    List<num> temperatures,
    List<num> dxMax,
    List<num> dxMin,
  )   : _temperatures = List<num>.generate(
            temperatures.length, (i) => temperatures[i].abs()),
        dxMax = UnmodifiableListView(dxMax),
        dxMin = UnmodifiableListView(dxMin) {
    a = UnmodifiableListView(
      (dxMax - dxMin).divide(tStart - tEnd),
    );
    b = UnmodifiableListView(dxMax - a.times(tStart));
  }

  /// Sequence of temperatures defining the annealing schedule.
  /// * The initial temperature `tStart` must be the largest temperature
  /// in the sequence as it is used to estimate the system
  /// Boltzmann constant `kB`.
  final List<num> _temperatures;

  /// Initial temperature.
  num get tStart => _temperatures.first;

  /// Final temperature.
  num get tEnd => _temperatures.last;

  /// Annealing temperatures.
  List<num> get temperatures => List<num>.of(_temperatures);

  /// Sample space size. Parameter used by the neighbourhood function.
  UnmodifiableListView<num> dxMax;

  /// Minimum size of the search neighbourhood.
  UnmodifiableListView<num> dxMin;

  /// Returns the factor a used in dx = a * temperature + b.
  late UnmodifiableListView<num> a;

  /// Returns the factor b used in dx = a * temperature + b.
  late UnmodifiableListView<num> b;

  /// Returns the neighbourhood vector for a given temperature.
  /// * `dx(tStart) = spaceSize`
  /// * `dx(tEnd) = precision`
  List<num> dx(num temperature) => a.times(temperature).plus(b);
}
