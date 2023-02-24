import 'dart:math';

import 'package:exception_templates/exception_templates.dart';
import 'package:list_operators/list_operators.dart';

import 'search_space.dart';

/// Function representing the system energy (cost function).
typedef Energy = num Function(List<num> x);

/// Class representing the system `energy` and
/// the *domain* over which it is defined (the *search space*).
/// * The function `energy` must be defined for each point belonging
///   to the search space.
class EnergyField {
  /// Constructs an object of type `EnergyField`.
  /// * `energy`: Function representing the system energy (or cost function).
  /// * `searchSpace`: The function domain.
  EnergyField(
    this.energy,
    SearchSpace searchSpace,
  )   : _searchSpace = searchSpace,
        _minValue = double.infinity {
    // Populate field _minPosition with a random point in the search space.
    next();
  }

  /// Copy constructor.
  factory EnergyField.of(EnergyField energyField) => EnergyField(
        energyField.energy,
        energyField._searchSpace,
      );

  /// Function representing the system energy.
  final Energy energy;

  /// The domain over which the `energy` function is defined.
  /// The simulated annealing algorithm will search this region for
  /// optimal solutions.
  final SearchSpace _searchSpace;

  /// Stores the current field position.
  late List<num> _position;

  /// Returns the current field position.
  List<num> get position => List<num>.from(_position);

  /// Stores the current energy value.
  late num _value;

  /// Returns the current value of the energy at location `position`.
  num get value => _value;

  /// Stores the smallest energy value encountered.
  num _minValue;

  /// Returns the smallest energy value encountered.
  num get minValue => _minValue;

  /// Stores the field position with energy value `minValue`.
  late List<num> _minPosition;

  /// Returns the field position with the smallest energy encountered.
  List<num> get minPosition => List<num>.from(_minPosition);

  /// Returns the energy at a point selected randomly
  /// from the region (`position - deltaPosition, position + deltaPosition`).
  /// * The quantity `deltaPosition` represents a vector. Each component specifies the
  /// max. perturbation magnitude along the corrsponding dimension.
  /// * The new position can be accessed via the getter
  /// `this.position`. The return value of `perturb()` can
  /// also be accessed via `this.value`.
  num perturb(
    List<num> position,
    List<num> deltaPosition, {
    List<int> grid = const [],
  }) {
    _position = _searchSpace.perturb(
      position,
      deltaPosition,
      nGrid: grid,
    );
    _value = energy(_position);
    if (_value < _minValue) {
      _minValue = _value;
      _minPosition = _position;
    }
    return _value;
  }

  /// Returns the energy at a randomly
  /// selected point in the search space.
  ///
  /// `grid`: The grid sizes along each dimension.
  /// The grid is used to turn a continuous search space into a discret
  /// search space. The default value is an empty list
  /// (i.e. a continuous search space).
  ///
  /// Note: The new position can be accessed via the getter
  /// `this.position`. The return value of `next()` can
  /// also be accessed via `this.value`.
  num next({List<int> grid = const []}) {
    _position = _searchSpace.next(nGrid: grid);
    _value = energy(_position);
    if (_value < _minValue) {
      _minValue = _value;
      _minPosition = _position;
    }
    return _value;
  }

  /// Returns a list of energy values sampled from the entire search space.
  Future<List<num>> sample({
    int sampleSize = 100,
    List<int> grid = const [],
  }) async =>
      List<num>.generate(
        sampleSize,
        (_) => next(
          grid: grid,
        ),
      );

  /// Returns a list containing the energy values at two
  /// positions separated at most by `deltaPosition`.
  /// * The lower energy state is listed first.
  /// * Throws an exception of type `ExceptionOf<EnergyField>` if
  /// no transition could be generated in `maxTrials` trials.
  List<List<num>> transitions(
    List<num> deltaPosition,
    List<int> grid, {
    int sampleSize = 100,
    int maxTrials = 10,
  }) {
    maxTrials = maxTrials < 1 ? 10 : maxTrials;

    final result = <List<num>>[[], []];
    var count = 0;
    num state0 = 0;
    num state1 = 0;

    for (var i = 0; i < sampleSize; i++) {
      do {
        state0 = next(grid: grid);
        state1 = perturb(position, deltaPosition, grid: grid);
        ++count;
      } while (state0 == state1 && count < maxTrials);
      if (count >= maxTrials) {
        throw ExceptionOf<EnergyField>(
            message: 'Error in function \'transitions().\'',
            invalidState: 'Could not generate an uphill transition. '
                'in $maxTrials trials.',
            expectedState: 'A non-constant energy function.');
      } else {
        if (state0 < state1) {
          result.first.add(state0);
          result.last.add(state1);
        } else {
          result.first.add(state1);
          result.last.add(state0);
        }
        count = 0;
      }
    }
    return result;
  }

  /// Returns a list of energy values sampled from a neighbourhood
  /// around `position` using perturbation
  /// magnitudes `deltaPosition`.
  /// * `grid`: The grid sizes along each dimension.
  /// The grid is used to turn a continuous search space into a discret
  /// search space. The default value is an empty list (i.e. a continuous search space).
  /// * `selectUphillMoves`: Set to `true` to filter out down-hill transitions (
  /// where the new energy value is lower than the energy at `position`).
  /// * `sampleSize`: The length of the returned list containing the sample.
  Future<List<num>> sampleNeighbourhood(
    List<num> position,
    List<num> deltaPosition, {
    List<int> grid = const [],
    int sampleSize = 100,
    bool selectUphillMoves = false,
  }) async {
    if (selectUphillMoves) {
      var i = 0;
      var counter = 0;
      var eMin = energy(position);
      final result = <num>[];
      do {
        if (eMin < perturb(position, deltaPosition, grid: grid)) {
          result.add(value);
          ++i;
        } else {
          ++counter;
        }
      } while (i < sampleSize && counter < 50 * sampleSize);
      if (result.length < sampleSize) {
        throw ExceptionOf<EnergyField>(
            message: 'Error in function \'sampleNeighbourhood()\'',
            invalidState: 'Could not generate $sampleSize uphill transitions '
                'with initial position $position and energy $eMin. ');
      }
      return result;
    } else {
      return List<num>.generate(
          sampleSize,
          (_) => perturb(
                position,
                deltaPosition,
                grid: grid,
              ));
    }
  }

  /// Returns the expected value of gamma, the acceptance probability
  /// of a transition from a state with energy `e0[i]` to a state `e1[i]`
  /// at a given `temperature`.
  /// Note:
  /// * The transitions must be selected such that `e0[i] < e1[i]`.
  /// * To avoid a zero denominator it is advisable to rescale all
  //    energies by subtracting `e0.min()`.
  num _gammaStart(
    List<List<num>> transitions,
    num temperature, [
    num kB = 1.0,
  ]) =>
      transitions.last.exp(-kB / temperature).sum() /
      transitions.first.exp(-kB / temperature).sum();

  /// Returns the expected value of gamma, the acceptance probability
  /// of a transition from a state with energy `e0`
  /// to a state `e1[i]`
  /// at a given `temperature`.
  /// Note:
  /// * The transitions must be selected such that `e0[i] < e1[i]`.
  /// * The energies `e1[i]` have been rescaled such that `e0 = 0`.
  num _gammaEnd(List<num> e1, num temperature) =>
      e1.exp(-1.0 / temperature).sum() / e1.length;

  /// Returns the temperature at which the expectation value
  /// of the acceptance probability of up-hill transitions
  /// approaches `gamma`.
  ///
  /// Note: The algorithm converges only for `gamma` in
  /// the range: `0 < gamma < 1`.
  Future<num> tStart(
    num gamma, {
    required List<int> grid,
    required List<num> deltaPosition,
    int sampleSize = 200,
  }) async {
    if (gamma <= 0 || gamma >= 1) {
      throw ErrorOf<EnergyField>(
          message: 'Error in function optimalTemperature',
          invalidState: 'Found \'gamma\': $gamma.',
          expectedState: 'Expected: 0 < gamma < 1.');
    }
    final transitions = this.transitions(
      deltaPosition,
      grid,
      sampleSize: sampleSize,
    );

    final deltaE = transitions.last - transitions.first;

    /// First estimate of the initial temperature.
    var optTemperature = deltaE.stdDev() / (-log(gamma));
    num gammaEstimate = 0;

    var counter = 0;

    // Rescaling transition energies
    final transitionsGS = transitions.first.min();
    for (var i = 0; i < sampleSize; ++i) {
      transitions.first[i] -= transitionsGS;
      transitions.last[i] -= transitionsGS;
    }
    do {
      gammaEstimate = _gammaStart(transitions, optTemperature);
      optTemperature = optTemperature *
          pow(
            log(gammaEstimate) / log(gamma),
            0.2,
          );
      ++counter;
      //print('gamma: $gammaEstimate temperature: $optTemperature');
    } while ((gammaEstimate - gamma).abs() > gamma * 1e-3 && counter < 20);
    return optTemperature;
  }

  /// Returns the temperature at which the expectation value
  /// of the acceptance probability of up-hill transitions
  /// approaches `gamma`.
  ///
  /// Note: The algorithm converges only for `gamma` in
  /// the range: `0 < gamma < 1`.
  Future<num> tEnd(
    num gamma, {
    required List<int> grid,
    required List<num> deltaPosition,
    int sampleSize = 200,
  }) async {
    if (gamma <= 0 || gamma >= 1) {
      throw ErrorOf<EnergyField>(
          message: 'Error in function tEnd()',
          invalidState: 'Found \'gamma\': $gamma.',
          expectedState: 'Expected: 0 < gamma < 1.');
    }
    // Initial transition values.
    final e0 = _minValue;
    // Final transition values.
    final e1 = await sampleNeighbourhood(
      _minPosition,
      deltaPosition,
      grid: grid,
      sampleSize: sampleSize,
      selectUphillMoves: true,
    );

    /// First estimate for the initial temperature.
    var optTemperature = -e1.stdDev() / log(gamma);
    num gammaEstimate = 0;
    var counter = 0;
    //Rescaling energy
    for (var i = 0; i < e1.length; i++) {
      e1[i] -= e0;
    }
    do {
      gammaEstimate = _gammaEnd(e1, optTemperature);
      optTemperature = optTemperature *
          pow(
            log(gammaEstimate) / log(gamma),
            0.2,
          );
      ++counter;
      //print('gamma: $gammaEstimate temperature: $optTemperature');
    } while ((gammaEstimate - gamma).abs() > gamma * 1e-3 && counter < 100);
    return optTemperature;
  }

  /// Returns the search space dimension.
  int get dimension => _searchSpace.dimension;

  /// Returns the size of the energy field domain (the search space).
  List<num> get size => List<num>.of(_searchSpace.size);

  @override
  String toString() {
    final b = StringBuffer();
    b.writeln('Energy Field: ');
    b.writeln('  minPosition: $minPosition');
    b.writeln('  energy min: $_minValue');
    b.writeln('  $_searchSpace'.replaceAll('\n', '\n  '));
    return b.toString();
  }
}
