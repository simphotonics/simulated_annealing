import 'dart:math';

import 'search_space.dart';

/// Function representing the system energy (cost function).
typedef EnergyFunction = num Function(List<num> x);

/// Class representing the system *energy function*
/// and the *domain* over which it is defined (the *search space*).
///
class Energy {
  /// Constructs an object of type `Energy`.
  /// * `energyFunction`: Fnction representing the system energy.
  /// * `
  Energy(
    this.energyFunction,
    SearchSpace searchSpace, {
    this.sampleSize = 1000,
  }) : _searchSpace = SearchSpace.from(searchSpace) {
    /// Initializing late variables.
    _samplePoints =
        List<List<num>>.generate(sampleSize, (_) => _searchSpace.next());
    _e =
        List<num>.generate(sampleSize, (i) => energyFunction(_samplePoints[i]));
    mean = _e.reduce((sum, current) => sum += current) / sampleSize;
    stdDev = sqrt(
      _e.reduce((sum, current) => sum += pow(current - mean, 2)) /
          (sampleSize - 1),
    );

    sampleMax = _e.reduce((value, current) => max(value, current));
    sampleMin = _e.reduce((value, current) => min(value, current));
    xMin = List<num>.unmodifiable(_samplePoints[_e.indexOf(sampleMin)]);
  }

  /// Size of sample used to calculate:
  /// * `mean`, `stdDev`, `sampleMin`, `sampleMax`.
  final int sampleSize;

  /// Function representing the system energy
  final EnergyFunction energyFunction;

  /// The domain over which the `energy` function is defined.
  /// The simulated annealing algorithm will search this region for
  /// optimal solutions.
  final SearchSpace _searchSpace;

  /// Random points sampled from the search region.
  /// @nodoc
  late final List<List<num>> _samplePoints;

  /// Random points sampled from the search region.
  List<List<num>> get samplePoints => List<List<num>>.of(_samplePoints);

  /// Energy evaluated for each point in `samplePoints`.
  /// @nodoc
  late final List<num> _e;

  /// Energy evaluated for each point in `x`.
  List<num> get sample => List<num>.of(_e);

  /// Energy sample mean.
  late final num mean;

  /// Corrected standard deviation of the energy sample.
  late final num stdDev;

  /// Energy sample miniumum.
  late final num sampleMin;

  /// Energy sample maximum.
  late final num sampleMax;

  /// Point at which energy sample minimum occurs.
  late final List<num> xMin;

  /// Returns `0.5 * (stdDev + 0.25 * (mean - sampleMin).abs())`.
  ///
  /// The expression is
  num get dE0 => 0.5 * (stdDev + 0.25 * (mean - sampleMin).abs());

  /// Returns an new point in the search region by randomly
  /// perturbing the position vector `x` with a maximum magnitude of `dx`.
  ///
  /// Note: `dx` is a vector. Each component specifies the
  /// perturbation magnitude along the corrsponding dimension.
  List<num> perturb(List<num> x, List<num> dx) => _searchSpace.perturb(x, dx);

  /// Returns an estimate of the search region size.
  List<num> get size => _searchSpace.size;

  @override
  String toString() {
    final b = StringBuffer();
    b.writeln('System Energy: ');
    b.writeln('  xMin: $xMin');
    b.writeln('  energy min: $sampleMin');
    b.writeln('  energy max: $sampleMax');
    b.writeln('  energy mean: ${mean}');
    b.writeln('  energy stdDev: ${stdDev}');
    b.writeln('  energy variation: $dE0');
    return b.toString();
  }
}
