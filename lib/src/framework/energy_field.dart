import 'dart:collection';

import 'package:lazy_memo/lazy_memo.dart';
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
  /// * `sampleSize`: The size of the sample used to estimate the quantities
  ///   `sampleMean`, `sampleMin`, `sampleMax` and `sampleStdDev`.
  EnergyField(
    this.energy,
    SearchSpace searchSpace, {
    this.sampleSize = 600,
  })  : _searchSpace = searchSpace,
        _minValue = double.infinity {
    // Populate field _minPosition with a random point in the search space.
    next();
    // Initialize late variables
    _sample = Lazy<Future<List<num>>>(() => sampleField());
    _mean = Lazy<Future<num>>(() => _sample().then((sample) => sample.mean()));
    _max = Lazy<Future<num>>(() => _sample().then((sample) => sample.max()));
    _stdDev = Lazy<Future<num>>(
      () => _sample().then((value) => value.stdDev()),
    );
    // _min = Lazy<Future<num>>(() => _sample().then((sample) => sample.min()));
    _dEnergyStart = Lazy<Future<num>>(() => Future.wait<num>([stdDev, mean])
        .then((result) => result[0] + 0.1 * (result[1] - _minValue)));
    // Using _sample() to make sure that _minPosition holds a meaningful value.
    _dEnergyEnd = Lazy<Future<num>>(
        () => _sample().then((_) => _calculateEnergyEnd(_minPosition)));
  }

  /// Returns a shallow copy of `energyField` using the parameters:
  /// `energy`, `searchSpace`, and `sampleSize`.
  ///
  /// Note: Internal variables used to calculate `mean`, `stdDev`,
  /// `dEnergyStart`,
  /// and `dEnergyEnd` are **not** copied but re-initialized.
  factory EnergyField.from(EnergyField energyField) =>
      EnergyField(energyField.energy, energyField._searchSpace,
          sampleSize: energyField.sampleSize);

  /// Function representing the system energy.
  final Energy energy;

  /// The domain over which the `energy` function is defined.
  /// The simulated annealing algorithm will search this region for
  /// optimal solutions.
  final SearchSpace _searchSpace;

  // Maximum size of the search neighbourhood.
  UnmodifiableListView<num> get deltaPositionMax => _searchSpace.dxMax;

  /// Minimum size of the search neighbourhood.
  ///
  /// For continuous problems this parameter determines the solution precision.
  UnmodifiableListView<num> get deltaPositionMin => _searchSpace.dxMin;

  /// Size of energy value sample used to
  /// determine the quantities: `mean`, `stdDev`, `max`.
  final int sampleSize;

  /// Stores the current field position.
  late List<num> _position;

  /// Returns the current field position.
  List<num> get position => _position;

  /// Stores the previous field position.
  late List<num> _previousPosition;

  List<num> get previousPosition => _previousPosition;

  late num _previousValue;

  num get previousValue => _previousValue;

  /// Stores the current energy value.
  late num _value;

  /// Returns the current value of the energy at location `position`.
  num get value => _value;

  /// Stores the smallest energy value encountered.
  num _minValue;

  /// Stores the field position with energy value `minValue`.
  late List<num> _minPosition;

  /// Returns the field position with the smallest energy encountered.
  List<num> get minPosition => _minPosition;

  /// Lazy variable returning the random sample of energy values.
  late final Lazy<Future<List<num>>> _sample;

  /// Energy sample mean.
  late final Lazy<Future<num>> _mean;

  /// Returns the energy sample mean.
  Future<num> get mean => _mean();

  /// Energy sample max.
  late final Lazy<Future<num>> _max;

  /// Returns the energy sample maximum.
  Future<num> get max => _max();

  /// Corrected standard deviation of the energy values at
  /// random positions across the entire search space.
  late final Lazy<Future<num>> _stdDev;

  /// Corrected standard deviation of the energy values at
  /// random positions across the entire search space.
  Future<num> get stdDev => _stdDev();

  /// Corrected standard deviation of the energy values at
  /// random positions around `xMin` with maximum perturbation
  /// magnitude `dxMin`.
  late final num stdDevMin;

  /// Smallest energy value encountered.
  num get minValue => _minValue;

  /// Estimated energy difference encountered when evaluating
  /// `energy` at random points in the search space.
  ///
  /// Returns `stdDev + (mean - min)`
  late final Lazy<Future<num>> _dEnergyStart;

  /// Estimated energy difference encountered when evaluating
  /// `energy` at random points in the search space.
  ///
  /// Returns `stdDev + (mean - min)`
  Future<num> get dEnergyStart => _dEnergyStart();

  /// Returns the energy standard deviation of the sample obtained
  /// by evaluating the energy at random points around
  /// `minPosition` with maximum perturbation magnitude `dxMin`.
  late final Lazy<Future<num>> _dEnergyEnd;

  /// Returns the energy standard deviation of the sample obtained
  /// by evaluating the energy at random points around
  /// `minPosition` with maximum perturbation magnitude `dxMin`.
  Future<num> get dEnergyEnd => _dEnergyEnd();

  /// Returns the energy at a point selected randomly
  /// from the region (`position - deltaPosition, position + deltaPosition`).
  /// * The quantity `deltaPosition` represents a vector. Each component specifies the
  /// max. perturbation magnitude along the corrsponding dimension.
  /// * The new position can be accessed via the getter
  /// `this.position`. The return value of `next()` can
  /// also be accessed via `this.value`.
  num perturb(List<num> position, List<num> deltaPosition) {
    _position = _searchSpace.perturb(position, deltaPosition);
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
  /// Note: The new position can be accessed via the getter
  /// `this.position`. The return value of `next()` can
  /// also be accessed via `this.value`.
  num next() {
    _position = _searchSpace.next();
    _value = energy(_position);
    if (_value < _minValue) {
      _minValue = _value;
      _minPosition = _position;
    }
    return _value;
  }

  /// Returns a list of energy values sampled from the entire search space.
  Future<List<num>> sampleField({int sampleSize = 100}) async =>
      List<num>.generate(sampleSize, (_) => next());

  /// Returns a list of energy values sampled from a neighbourhood
  /// around `x` using perturbation
  /// magnitudes `dx`.
  Future<List<num>> sampleNeighbourhood(
    List<num> x,
    List<num> dx, {
    int sampleSize = 100,
  }) async =>
      List<num>.generate(sampleSize, (_) => perturb(x, dx));

  /// Returns an estimate for the energy variation around `position`
  /// when perturbed with maximum magnitude `deltaPositionMin`.
  Future<num> _calculateEnergyEnd(List<num> position) async =>
      List<num>.generate(sampleSize, (_) {
        final e = energy(position);
        num result = double.negativeInfinity;
        do {
          result = e - perturb(position, deltaPositionMin);
        } while (result < 0.0);
        return result;
      }).stdDev();

  /// Returns the size of the energy field domain (the search space).
  List<num> get size => _searchSpace.size;

  @override
  String toString() {
    final b = StringBuffer();

    b.writeln('Energy Field: ');
    b.writeln('  $_searchSpace'.replaceAll('\n', '\n  '));
    return b.toString();
  }

  /// Returns a `String` containing object info.
  ///
  /// Note: The method calls asynchronous methods.
  Future<String> get info async {
    final b = StringBuffer();
    b.writeln('Energy Field: ');
    b.writeln('  minPosition: $minPosition');
    b.writeln('  energy min: $minValue');
    b.writeln('  energy mean: ${await mean}');
    b.writeln('  energy stdDev: ${await stdDev}');
    b.writeln('  dEnergyStart: ${await dEnergyStart}');
    b.writeln('  dEnergyEnd: ${await dEnergyEnd}');
    b.writeln('  $_searchSpace'.replaceAll('\n', '\n  '));
    return b.toString();
  }
}
