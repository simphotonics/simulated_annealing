import 'dart:collection';
import 'dart:math';

import 'package:lazy_memo/lazy_memo.dart';
import 'package:list_operators/list_operators.dart';

import 'annealing_schedule.dart';
import 'energy_field.dart';
import 'interval.dart';
import 'search_space.dart';

/// Function returning an integer representing a Markov
/// chain length (the number of simulated annealing iterations
/// performed at constant temperature).
/// * temperature: The current system temperature.
typedef MarkovChainLength = int Function(num temperature);

/// Returns an integer linearly interpolated
/// between `chainLengthStart` and `chainLengthEnd`.
/// * `markovChainlength(tStart) = mStart`,
/// * `markovChainlength(tEnd) = mEnd`.
/// *  The following must hold: `tStart <= temperature <= tEnd`.
int markovChainLength(
  num temperature, {
  required num tStart,
  required num tEnd,
  int chainLengthStart = 5,
  int chainLengthEnd = 20,
}) =>
    ((chainLengthStart - chainLengthEnd) *
            (temperature - tStart) ~/
            (tStart - tEnd) +
        chainLengthStart);

/// Function returning a sequence of pertubation
/// magnitude vectors.
typedef PerturbationSequence = List<List<num>> Function(
  List<num> temperatures,
  List<num> deltaPositionMax,
  List<num> deltaPositionMin,
);

/// Returns a sequence of vectors
/// by interpolating between
/// `start` and `end`.
///
/// The resulting sequence is linearly related to `temperatures`.
List<List<T>> interpolate<T extends num>(
  List<num> temperatures,
  List<T> start,
  List<T> end,
) {
  final a = (start - end) / (temperatures.first - temperatures.last);
  final b = start -
      (start - end) *
          (temperatures.first / (temperatures.first - temperatures.last));
  return List<List<T>>.generate(
      temperatures.length,
      (i) => T == int
          ? (a * temperatures[i]).plus(b).toListOfInt() as List<T>
          : (a * temperatures[i]).plus(b) as List<T>);
}

/// Returns a sequence of perturbation magnitude vectors by
/// interpolating between `deltPositionMax` and  `deltaPositionMin`.
///
/// The resulting sequence is linearly related to `temperatures`.
List<List<num>> defaultPerturbationSequence(
  List<num> temperatures,
  List<num> deltaPositionMax,
  List<num> deltaPositionMin,
) =>
    interpolate(
      temperatures,
      deltaPositionMax,
      deltaPositionMin,
    );

/// Annealing simulator
abstract class Simulator {
  /// Simulator constructor.
  /// * `field`: An object of type `EnergyField` encapsulating the
  ///   energy function (cost function)  and search space.
  /// ----
  /// Optional parameters:
  /// * gammaStart: Expectation value of the solution acceptance at the
  //    initial temperature of the annealing process.
  /// * gammaEnd: Expectation value of the solution acceptance at the
  //    final temperatures of the annealing process.
  /// * outerIterations: Number of iterations when cooling.
  /// * innerIterationsStart: Number of iterations at constant temperature
  ///   at the start of the annealing process.
  /// * innerIterationsEnd: Number of iterations at constant temperature
  ///   at the end of the annealing process.
  /// * sampleSize: Size of sample used to estimate the start temperature
  ///   and the final temperature of the annealing process.
  Simulator(
    EnergyField field, {
    this.gammaStart = 0.7,
    this.gammaEnd = 0.2,
    this.outerIterations = 750,
    this.innerIterationsStart = 5,
    this.innerIterationsEnd = 20,
    this.sampleSize = 500,
  }) : _field = EnergyField.of(field) {
    /// Initial values:
    _currentMinEnergy = _field.value;
    _currentMinPosition = _field.position;
    _acceptanceProbability = 1.0;
    _startPosition = _field.position;
  }

  /// Energy field.
  final EnergyField _field;

  /// Acceptance probability at temperature `tStart`.
  final num gammaStart;

  /// Acceptance probability at temperature `tEnd`.
  final num gammaEnd;

  /// Number of temperature steps defining the annealing schedule.
  final int outerIterations;

  /// Number of iterations at constant temperature
  /// at the start of the annealing process.
  final int innerIterationsStart;

  /// Number of iterations at constant temperature
  /// at the end of the annealing process.
  final int innerIterationsEnd;

  /// Size of the sample used to estimate the initial and final
  /// annealing temperature.
  final int sampleSize;

  /// Initial annealing temperature.
  late final Lazy<Future<num>> _tStart = Lazy<Future<num>>(() => _field.tStart(
        gammaStart,
        grid: gridStart,
        deltaPosition: deltaPositionStart,
        sampleSize: sampleSize,
      ));

  /// Initial annealing temperature.
  Future<num> get tStart => _tStart();

  /// Final annealing temperature.
  late final Lazy<Future<num>> _tEnd = Lazy<Future<num>>(() => _field.tStart(
        gammaEnd,
        grid: gridEnd,
        deltaPosition: deltaPositionEnd,
        sampleSize: sampleSize,
      ));

  /// Final annealing temperature.
  Future<num> get tEnd => _tEnd();

  /// Triggers an update of the lazy variables
  /// `_tStart`,`_tEnd`,`_temperatures`, and `_perturbationMagnitudes`.
  void _updateLazyVariables() {
    _tStart.updateCache();
    _tEnd.updateCache();
    _temperatures.updateCache();
    _perturbationMagnitudes.updateCache();
  }

  /// Function used to calculate the temperature sequence.
  TemperatureSequence _temperatureSequence = exponentialSequence;

  /// Function used to calculate the temperature sequence.
  TemperatureSequence get temperatureSequence => _temperatureSequence;

  /// Sets the function used to calculate the temperature sequence.
  ///
  /// * The default `temperatureSequence` is [exponentialSequence].
  /// * Other available functions from the library `[AnnealingSchedule]`
  ///   are [lundySequence], [linearSequence], [normalSequence],
  ///   and [geometricSequence].
  set temperatureSequence(TemperatureSequence value) {
    _temperatureSequence = value;
    _temperatures.updateCache();
    _perturbationMagnitudes.updateCache();
  }

  /// The function used to calculate the sequence of perturbation
  /// magnitudes.
  PerturbationSequence _perturbationSequence = defaultPerturbationSequence;

  /// Function used to calculate the sequence of pertubation
  /// magnitudes.
  PerturbationSequence get perturbationSequence => _perturbationSequence;

  /// Sets the function used to calculate the sequence of perturbation
  /// magnitudes.
  set perturbationSequence(PerturbationSequence value) {
    _perturbationSequence = value;
    _perturbationMagnitudes.updateCache();
  }

  /// The initial perturbation magnitudes.
  late final List<num> _deltaPositionStart = _field.size;

  /// Returns the initial perturbation magnitudes.
  List<num> get deltaPositionStart => List.of(_deltaPositionStart);

  /// Sets the initial perturbation magnitudes.
  set deltaPositionStart(List<num> value) {
    _deltaPositionStart
      ..clear()
      ..addAll(value);
    _updateLazyVariables();
  }

  /// The perturbation magnitudes at the end of the annealing cycle.
  late final List<num> _deltaPositionEnd = List<num>.filled(
    _field.dimensions,
    1e-6,
    growable: true,
  );

  /// Returns the perturbation magnitudes at the end of the annealing cycle.
  List<num> get deltaPositionEnd => List.of(_deltaPositionEnd);

  /// Sets the perturbation magnitudes at the end of the annealing cycle.
  set deltaPositionEnd(List<num> value) {
    _deltaPositionEnd
      ..clear()
      ..addAll(value);
    _updateLazyVariables();
  }

  /// Specifies the number of grid points at
  /// the beginning of the annealing process.
  late final List<int> _gridStart = List<int>.filled(
    _field.dimensions,
    40,
    growable: true,
  );

  /// Returns the grid sizes along each dimension
  ///  at the beginning of the annealing process.
  List<int> get gridStart => List.of(_gridStart);

  /// Sets the number of grid points at the beginning of the annealing process.
  ///
  /// Default value: 40 grid points along each dimension.
  set gridStart(List<int> value) {
    _gridStart
      ..clear()
      ..addAll(value);
    _updateLazyVariables();
  }

  /// Grid sizes along each dimension at the end of the annealing process.
  late final List<int> _gridEnd = List<int>.filled(
    _field.dimensions,
    40,
    growable: true,
  );

  /// Returns the number of grid points along each dimension
  ///  at the end of the annealing process.
  List<int> get gridEnd => List.of(_gridEnd);

  /// Sets the grid sizes at the end of the annealing process.
  ///
  /// Default value: 40 grid points along each dimension.
  set gridEnd(List<int> value) {
    _gridEnd
      ..clear()
      ..addAll(value);
    _updateLazyVariables();
  }

  /// A sequence of grid vectors.
  late final Lazy<Future<List<List<int>>>> _grid =
      Lazy<Future<List<List<int>>>>(() => _temperatures()
          .then<List<List<int>>>((temperatures) => interpolate<int>(
                temperatures,
                gridStart,
                gridEnd,
              )));

  /// Returns the currently used sequence of grid vectors.
  Future<List<List<int>>> get grid => _grid().then<List<List<int>>>((grid) =>
      List<List<int>>.generate(grid.length, (i) => List<int>.of(grid[i])));

  /// The starting position.
  late final List<num> _startPosition;

  /// Returns the starting position of the annealing process.
  List<num> get startPosition => List.of(_startPosition);

  /// Sets the starting position of the annealing process.
  set startPosition(List<num> value) {
    _startPosition
      ..clear()
      ..addAll(value);
    _field.perturb(_startPosition, deltaPositionStart * 0.0);
  }

  /// Annealing temperatures.
  late final Lazy<Future<List<num>>> _temperatures = Lazy<Future<List<num>>>(
    () => Future.wait([tStart, tEnd]).then((t) => temperatureSequence(
          t[0],
          t[1],
          iterations: outerIterations,
        )),
  );

  /// Returns an [UnmodifiableListView] of the annealing temperatures
  /// determining the annealing schedule.
  Future<List<num>> get temperatures =>
      _temperatures().then((temperatures) => temperatures.unmodifiable);

  /// Perturbation magnitudes.
  late final Lazy<Future<List<List<num>>>> _perturbationMagnitudes =
      Lazy<Future<List<List<num>>>>(
    () => _temperatures().then<List<List<num>>>((temperatures) => interpolate(
          temperatures,
          deltaPositionStart,
          deltaPositionEnd,
        )),
  );

  /// Returns the sequence of perturbation magnitudes.
  Future<List<List<num>>> get perturbationMagnitudes =>
      _perturbationMagnitudes().then<List<List<num>>>((pertubationMagnitudes) =>
          List<List<num>>.generate(pertubationMagnitudes.length,
              (i) => List<num>.of(pertubationMagnitudes[i])));

  /// Current field position.
  List<num> get currentPosition => _field.position;

  /// Energy at current field position.
  num get currentEnergy => _field.value;

  /// Current energy minimizing field position.
  late List<num> _currentMinPosition;

  /// Current energy minimizing solution.
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

  /// Holds the grid used in the current iteration step.
  late List<int> _currentGrid;

  /// Returns the grid used in the current iteration step.
  List<int> get currentGrid => _currentGrid;

  /// Current perturbation magnitude.
  late List<num> _deltaPosition;

  /// Current perturbation magnitude.
  List<num> get deltaPosition => List.of(_deltaPosition);

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

  // Initializing late variables:

  /// Starts the simulated annealing process and
  /// returns the best solution found.
  /// * isRecursive: Flag used to call the method recursively if the algorithm
  /// converges towards a local minimum. (The algorithm
  /// keeps track of the lowest energy values previously visited.)
  /// * ratio: Factor reducing the length of the initial
  /// temperature sequence during recursive calls. The parameter is used
  /// to model repeated annealing cycles with decreasing initial temperature.
  /// * Note: `0.0 < ratio < 1.0`.
  /// * scaleMarkovChain: Set to `true` to increase the Markov chain length by
  ///   a factor of `pow(currentGrid.prod(), 1.0 /
  ///   (currentGrid.length * 3)).toInt()`.
  ///   This increases the probability of convergence since the chain length
  ///   is scaled with the number of grid points.
  ///
  Future<List<num>> anneal({
    bool isRecursive = false,
    num ratio = 0.5,
    bool isVerbose = false,
  }) async {
    /// Initialize parameters:
    final temperatures = await this.temperatures;
    final perturbationMagnitudes = await this.perturbationMagnitudes;
    final grid = await this.grid;

    int nInner(num t) => markovChainLength(t,
        tStart: temperatures.first,
        tEnd: temperatures.last,
        chainLengthStart: innerIterationsStart,
        chainLengthEnd: innerIterationsEnd);

    num dE = 0;

    if (_recursionCounter == 0) {
      _t = temperatures.first;
      _deltaPosition = perturbationMagnitudes.first;
      _currentGrid = grid.first;
      prepareLog();
      recordLog();
    }

    // During the first iteration pow(ratio.abs(), _recursionCounter) = 1.0
    // and therefore i = 0.
    var i = (temperatures.length * (1.0 - pow(ratio.abs(), _recursionCounter)))
        .toInt();

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
      _deltaPosition = perturbationMagnitudes[i];
      _currentGrid = grid[i];

      // int scalingFactor =
      //     pow(_currentGrid.prod(), 1.0 / (_currentGrid.length * 3)).toInt();

      // Inner iteration loop.
      for (var j = 0; j < nInner(_t); j++) {
        // Choose next random point and calculate energy difference.
        dE = _field.perturb(
              _currentMinPosition,
              _deltaPosition,
              grid: _currentGrid,
            ) -
            _currentMinEnergy;

        if (dE < 0) {
          _currentMinEnergy = _field.value;
          _currentMinPosition = _field.position;
          _acceptanceProbability = 1.0;
        } else {
          _acceptanceProbability = exp(-dE / _t);
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
          isRecursive: isRecursive,
          ratio: ratio,
        );
      }
    }
    return _currentMinPosition;
  }

  @override
  String toString() {
    final b = StringBuffer();
    b.writeln('Simulator: ');
    b.writeln('  outerIterations: $outerIterations');
    b.writeln('  startPosition: $_startPosition');
    b.writeln('  gridStart: $gridStart');
    b.writeln('  gridEnd: $gridEnd');
    b.writeln('  Field: $_field'.replaceAll('\n', '\n  '));
    return b.toString();
  }

  /// Returns a `String` containing object info.
  ///
  /// Note: The method calls asynchronous methods.
  Future<String> get info async {
    final b = StringBuffer();
    b.writeln('Simulator: ');
    b.writeln('  outerIterations: $outerIterations');
    b.writeln('  startPosition: $_startPosition');
    b.writeln('  gridStart: $gridStart');
    b.writeln('  gridEnd: $gridEnd');
    b.writeln('  tStart: ${await tStart}');
    b.writeln('  tEnd: ${await tEnd}');
    b.writeln('  Field: $_field'.replaceAll('\n', '\n  '));
    return b.toString();
  }
}
