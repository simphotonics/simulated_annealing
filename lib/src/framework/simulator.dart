import 'dart:math' as math;
import 'dart:math';

import 'package:lazy_memo/lazy_memo.dart';
import 'package:list_operators/list_operators.dart';

import 'annealing_schedule.dart';
import 'energy_field.dart';

import 'search_space.dart';

/// Function returning an integer representing a Markov
/// chain length (the number of simulated annealing iterations
/// performed at constant temperature).
typedef MarkovChainLength = int Function(num temperature);

/// Function returning a sequence of pertubation
/// magnitude vectors.
typedef PertubationSequence = List<List<num>> Function(
  List<num> temperatures,
  List<num> deltaPositionMax,
  List<num> deltaPositionMin,
);

/// Returns a sequence of pertubation magnitude vectors
/// by interpolating between
/// `deltaPositionMax` and `deltaPositionMin`.
/// * `temperatures`: A sequence of temperatures.
/// * `dxMax`: The initial perturbation magnitude vector.
/// * `dxMin`: The final perturbation magnitude vector.
List<List<num>> perturbationSequence(
  List<num> temperatures,
  List<num> deltaPositionMax,
  List<num> deltaPositionMin,
) {
  final a = (deltaPositionMax - deltaPositionMin) /
      (temperatures.first - temperatures.last);
  final b = deltaPositionMax -
      (deltaPositionMax - deltaPositionMin) *
          (temperatures.first / (temperatures.first - temperatures.last));
  return List<List<num>>.generate(
      temperatures.length, (i) => (a * temperatures[i]).plus(b));
}

/// Returns an integer between `chainLengthStart` and `chainLengthEnd`.
/// * `markovChainlength(tStart) = mStart`,
/// * `markovChainlength(tEnd) = mEnd`.
///
/// Note: The following must hold: `tStart <= temperature <= tEnd`.
int markovChainLength(
  num temperature, {
  required num tStart,
  required num tEnd,
  int chainLengthStart = 5,
  int chainLengthEnd = 20,
}) {
  return (chainLengthStart - chainLengthEnd) * temperature ~/ (tStart - tEnd) +
      chainLengthStart -
      (chainLengthStart - chainLengthEnd) * tStart ~/ (tStart - tEnd);
}

/// Annealing simulator
abstract class Simulator {
  /// Simulator constructor.
  /// * field: An object of type `EnergyField` encapsulating the
  ///   energy function (cost function)  and search space.
  /// * temperatureSequence: A function with typedef `TemperatureSequence`. It
  ///   specifies the simulated annealing temperature schedule.
  ///
  /// ----
  ///
  /// Optional parameters:
  /// * tEnd: The system temperature at the end of the annealing process.
  /// * gammaStart: Probability of solution acceptance if `dE == dEnergyStart`
  ///   and the temperature is the initial temperature of the annealing process.
  /// * gammaEnd: Probability of solution acceptance if `dE == dEnergyEnd`
  ///   and the temperature is the final temperatures of the annealing process.
  /// * iterations: Number of iterations when cooling
  ///   the system from the initial annealing
  ///   temperature to the final temperature `tEnd`.
  /// * xStart: Defaults to `field.minPosition`. Can be used to specify the
  ///   starting point of the simulated annealing process.
  /// * dEnergyStart: Defaults to `field.dEnergyStart`. Can be used for testing
  ///   purposes. It is an estimate of the typical variation of
  ///   the energy function when perturbing the current position randomly with
  ///   magnitude `dxMax`.
  /// * dEnergyEnd: Defaults to `field.dEnergyEnd`. Can be used for testing
  ///   purposes. It is an estimate of the typical variation of
  ///   the system energy function when perturbing the current position
  ///   randomly with magnitude `dxMin`.
  Simulator(
    EnergyField field,
    TemperatureSequence temperatureSequence,
    PertubationSequence perturbationSequence, {
    this.tEnd = 1e-4,
    this.gammaStart = 0.7,
    this.gammaEnd = 0.05,
    this.iterations = 750,
    List<num>? startPosition,
    num? dEnergyStart,
    num? dEnergyEnd,
  }) : _field = EnergyField.from(field) {
    // Initializing late variables:
    _dEnergyStart = Lazy<Future<num>>(
      () => (dEnergyStart == null)
          ? _field.dEnergyStart
          : Future<num>.value(dEnergyStart),
    );
    _dEnergyEnd = Lazy<Future<num>>(
      () => (dEnergyEnd == null)
          ? _field.dEnergyEnd
          : Future<num>.value(dEnergyEnd),
    );
    _kB = Lazy<Future<num>>(
      () =>
          this.dEnergyEnd.then((value) => -value / (tEnd * math.log(gammaEnd))),
    );
    _tStart = Lazy<Future<num>>(
      () => Future.wait([this.dEnergyStart, kB])
          .then((value) => -value[0] / (value[1] * math.log(gammaStart))),
    );
    _temperatures = Lazy<Future<List<num>>>(
      () => tStart.then<List<num>>((_tStart) =>
          temperatureSequence(_tStart, tEnd, iterations: iterations)),
    );
    _perturbationMagnitudes = Lazy<Future<List<List<num>>>>(
      () => _temperatures()
          .then<List<List<num>>>((temperatures) => perturbationSequence(
                temperatures,
                _field.deltaPositionMax,
                _field.deltaPositionMin * 0.5,
              )),
    );

    /// Set initial position:
    if (startPosition != null) {
      _field.perturb(startPosition, _field.deltaPositionMin * 0.0);
    } else {
      _field.perturb(_field.minPosition, _field.deltaPositionMin * 0.0);
    }
    _currentMinEnergy = _field.value;
    _currentMinPosition = _field.position;
    _acceptanceProbability = 1.0;
  }

  /// Energy field.
  final EnergyField _field;

  /// Acceptance probability at temperature `tStart` and
  /// `dE = dEnergyStart`.
  final num gammaStart;

  /// Acceptance probability at temperature `tEnd` and
  /// `dE = dEnergyEnd`.
  final num gammaEnd;

  /// System Boltzmann constant.
  late final Lazy<Future<num>> _kB;

  /// System Boltzmann constant. Relates the temperature to
  /// the acceptance probability if `dE = E - E_min > 0`.
  /// * `P(dE > 0, T) = exp(-dE / (kB * T))`: Uphill moves are accepted with
  /// probability `P(dE > 0, T)`.
  /// * Note: `P(dE < 0, T) = 1.0`: Downhill moves are always accepted.
  Future<num> get kB async => await _kB();

  /// Number of outer simulated annealing iterations. Iterations at
  /// decreasing temperature.
  int iterations;

  /// Annealing temperatures.
  late final Lazy<Future<List<num>>> _temperatures;

  /// Perturbation magnitudes.
  late final Lazy<Future<List<List<num>>>> _perturbationMagnitudes;

  /// Initial annealing temperature.
  late final Lazy<Future<num>> _tStart;

  /// Initial annealing temperature.
  Future<num> get tStart => _tStart();

  /// Final annealing temperature.
  final num tEnd;

  /// Estimated energy difference when perturbing the current position
  /// randomly with magnitude `deltaPositionMax`.
  late final Lazy<Future<num>> _dEnergyStart;

  /// Estimated energy difference when perturbing the current position
  /// randomly with magnitude `deltaPositionMax`.
  Future<num> get dEnergyStart => _dEnergyStart();

  /// Estimated energy difference when perturbing the current position
  /// randomly with magnitude `deltaPositionMin`.
  late final Lazy<Future<num>> _dEnergyEnd;

  /// Estimated energy difference when perturbing the current position
  /// randomly with magnitude `deltaPositionMin`.
  Future<num> get dEnergyEnd => _dEnergyEnd();

  /// Current field position.
  List<num> get currentPosition => _field.position;

  /// Energy at current field position.
  num get currentEnergy => _field.value;

  /// Current energy minimizing field position.
  late List<num> _currentMinPosition;

  /// Current energy minimizing solution. If the argument `startPosition` is not
  /// specified in the constructor it is initialized as `field.minPosition`.
  List<num> get currentMinPosition => List<num>.from(_currentMinPosition);

  /// Current energy minimum.
  late num _currentMinEnergy;

  /// Current energy minimum.
  num get currentMinEnergy => _currentMinEnergy;

  /// Global energy minimizing solution.
  List<num> get globalMinPosition => _field.minPosition;

  /// Global energy minimum.
  num get globalMinEnergy => _field.minValue;

  /// Current temperature;
  late num _t;

  /// Current temperature.
  num get t => _t;

  /// Current perturbation magnitude.
  late List<num> _dx;

  /// Current perturbation magnitude.
  List<num> get dx => List.from(_dx);

  /// Acceptance probability of current solution.
  late num _acceptanceProbability;

  /// Acceptance probability of current solution.
  num get acceptanceProbability => _acceptanceProbability;

  /// Recursion counter.
  int _recursionCounter = 0;

  /// Method called once from within `anneal` before any
  /// simulated annealing iterations.
  ///
  /// Can be used to setup a log.
  void prepareLog();

  /// Method called during each (inner) iteration.
  ///
  /// Can be used to add entries to a log.
  void recordLog();

  /// Starts the simulated annealing process and
  /// returns the best solution found.
  /// * isRecursive: Flag used to call the method recursively if the algorithm
  /// converges towards a local minimum. (The algorithm
  /// keeps track of the lowest energy values previously visited.)
  /// * ratio: Factor reducing the length of the initial
  /// temperature sequence during recursive calls. The parameter is used
  /// to model repeated annealing cycles with decreasing initial temperature.
  /// * Note: `0.0 < ratio < 1.0`.
  Future<List<num>> anneal(
    MarkovChainLength markov, {
    bool isRecursive = false,
    num ratio = 0.5,
    bool isVerbose = false,
  }) async {
    final kB = await this.kB;

    /// Initialize parameters:
    final temperatures = await _temperatures();
    final perturbationMagnitudes = await _perturbationMagnitudes();
    num dE = 0;

    if (_recursionCounter == 0) {
      _t = temperatures.first;
      _dx = perturbationMagnitudes.first;
      prepareLog();
      recordLog();
    }

    // During the first iteration _ratio = 1.0 and i = 0.
    final _ratio = pow(ratio.abs(), _recursionCounter);
    var i = (temperatures.length * (1.0 - _ratio)).toInt();

    if (_recursionCounter > 0 && isVerbose) {
      print('Restarted annealing at:');
      print('  temperature: ${temperatures[i]},');
      print('  position: $_currentMinPosition, ');
      print('  energy: $_currentMinEnergy');
    }
    ++_recursionCounter;

    // Outer iteration loop.
    for (i; i < temperatures.length; i++) {
      _t = temperatures[i];
      _dx = perturbationMagnitudes[i];

      // Inner iteration loop.
      for (var j = 0; j < markov(_t); j++) {
        // Choose next random point and calculate energy difference.
        dE = _field.perturb(_currentMinPosition, _dx) - _currentMinEnergy;

        if (dE < 0) {
          _currentMinEnergy = _field.value;
          _currentMinPosition = _field.position;
          _acceptanceProbability = 1.0;
        } else {
          _acceptanceProbability = math.exp(-dE / (kB * _t));
          if (_acceptanceProbability > Interval.random.nextDouble()) {
            _currentMinEnergy = _field.value;
            _currentMinPosition = _field.position;
          }
        }
        recordLog();
      }
    }
    if (globalMinEnergy < _currentMinEnergy) {
      if (isVerbose) {
        print('------------------------------------------------');
        print('E_min_global($globalMinPosition) = $globalMinEnergy ');
        print('E_min($_currentMinPosition) = $_currentMinEnergy!');
        print('Returning global minimum solution!');
        print('');
      }
      _currentMinPosition = globalMinPosition;
      _currentMinEnergy = globalMinEnergy;
      if (isRecursive) {
        _currentMinPosition = await anneal(
          markov,
          isRecursive: isRecursive,
          ratio: ratio,
        );
      }
    }
    return _currentMinPosition;
  }

  @override
  String toString() => runtimeType.toString();

  /// Returns a `String` containing object info.
  ///
  /// Note: The method calls asynchronous methods.
  Future<String> get info async {
    final b = StringBuffer();
    b.writeln('Simulator: ');
    b.writeln('  iterations: $iterations');
    b.writeln('  dEnergyStart: ${await dEnergyStart}');
    b.writeln('  dEnergyEnd: ${await dEnergyEnd}');
    b.writeln('  kB: ${await _kB()}');
    b.writeln('  xMin: ${_field.minPosition}');
    b.writeln('  tStart: ${await tStart}');
    b.writeln('  tEnd: ${await tEnd}');
    b.writeln('  Field: ${await _field.info}'.replaceAll('\n', '\n  '));
    return b.toString();
  }
}
