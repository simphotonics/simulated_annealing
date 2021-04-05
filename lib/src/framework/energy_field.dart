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
  /// search space. The default value is an empty list (i.e. a continuous search space).
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
      var eMin = energy(position);
      final result = <num>[];
      do {
        if (eMin < perturb(position, deltaPosition, grid: grid)) {
          result.add(value);
          ++i;
        }
      } while (i < sampleSize);
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
    List<num> e0,
    List<num> e1,
    num temperature, [
    num kB = 1.0,
  ]) =>
      e1.exp(-kB / temperature).sum() / e0.exp(-kB / temperature).sum();

  /// Returns the expected value of gamma, the acceptance probability
  /// of a transition from a state with energy `e0`
  /// to a state `e1[i]`
  /// at a given `temperature`.
  /// Note:
  /// * The transitions must be selected such that `e0[i] < e1[i]`.
  /// * The energies `e1[i]` have been rescaled such that `e0 = 0`.
  num _gammaEnd(
    List<num> e1,
    num temperature, [
    num kB = 1.0,
  ]) =>
      e1.exp(-kB / temperature).sum() / e1.length;

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
    num kB = 1.0,
  }) async {
    if (gamma <= 0 || gamma >= 1) {
      throw ErrorOf<EnergyField>(
          message: 'Error in function optimalTemperature',
          invalidState: 'Found \'gamma\': $gamma.',
          expectedState: 'Expected: 0 < gamma < 1.');
    }

    // Initial transition values.
    final e0 = <num>[];
    // Final transition values.
    final e1 = <num>[];
    var initialValue = value;
    var finalValue = value;
    var initialPosition = position;
    // Generating up-hill transitions e0[i] => e1[i];
    for (var i = 0; i < sampleSize; ++i) {
      initialValue = next(grid: grid);
      initialPosition = position;
      if (initialValue.isNaN) {
        print('Warning: energy at $initialPosition is NaN.');
        --i;
        continue;
      }
      e0.add(initialValue);
      do {
        finalValue = perturb(
          initialPosition,
          deltaPosition,
          grid: grid,
        );
        if (finalValue.isNaN) {
          print('Warning: energy at $position is NaN.');
        }
      } while (finalValue < initialValue);
      e1.add(finalValue);
    }

    /// First estimate for the initial temperature.
    var optTemperature = -e0.stdDev() / log(gamma);
    num gammaEstimate = 0;

    var counter = 0;
    final e0Min = e0.min();

    //Rescaling energy
    for (var i = 0; i < e0.length; i++) {
      e0[i] -= e0Min;
      e1[i] -= e0Min;
    }

    do {
      gammaEstimate = _gammaStart(e0, e1, optTemperature, kB);
      optTemperature = optTemperature *
          pow(
            log(gammaEstimate) / log(gamma),
            0.2,
          );
      ++counter;
      //print('gamma: $gammaEstimate temperature: $optTemperature');
    } while ((gammaEstimate - gamma).abs() > 1e-4 && counter < 20);
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
    num kB = 1.0,
  }) async {
    if (gamma <= 0 || gamma >= 1) {
      throw ErrorOf<EnergyField>(
          message: 'Error in function optimalTemperature',
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
      gammaEstimate = _gammaEnd(e1, optTemperature, kB);
      optTemperature = optTemperature *
          pow(
            log(gammaEstimate) / log(gamma),
            0.2,
          );
      ++counter;
      //print('gamma: $gammaEstimate temperature: $optTemperature');
    } while ((gammaEstimate - gamma).abs() > 1e-4 && counter < 20);
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
