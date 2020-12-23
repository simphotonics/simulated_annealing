import 'dart:math';

import 'search_space.dart';

/// Function representing the system energy (cost function).
typedef Energy = num Function(List<num> x);

/// Class representing the anneling system. It includes the energy function
/// and the domain over which it is defined (the search space).
/// 
class AnnealingSystem {
  AnnealingSystem(
    this.energy,
    SearchSpace searchSpace, {
    this.sampleSize = 1000,
  }) : _searchSpace = SearchSpace.from(searchSpace) {
    /// Initializing late variables.
    _x = List<List<num>>.generate(sampleSize, (_) => _searchSpace.next());
    _e = List<num>.generate(sampleSize, (i) => energy(_x[i]));
    eMean = _e.reduce((sum, current) => sum += current) / sampleSize;
    eStdDev = sqrt(
      _e.reduce((sum, current) => sum += pow(current - eMean, 2)) /
          (sampleSize - 1),
    );

    eMax0 = _e.reduce((value, current) => max(value, current));
    eMin0 = _e.reduce((value, current) => min(value, current));
    xMin0 = List<num>.unmodifiable(_x[_e.indexOf(eMin0)]);
  }

  /// Size of sample used to calculate:
  /// * `eMean`, `eStdDev`, `eMin`, `eMax`,  `xMin`.
  final int sampleSize;

  /// Function representing the system energy
  final Energy energy;

  /// The domain over which the `energy` function is defined.
  /// The simulated annealing algorithm will search this region for
  /// optimal solutions.
  final SearchSpace _searchSpace;

  /// Random points sampled from the search region.
  late final List<List<num>> _x;

  /// Random points sampled from the search region.
  List<List<num>> get x => List<List<num>>.of(_x);

  /// Energy evaluated for each point in `x`.
  late final List<num> _e;

  /// Energy evaluated for each point in `x`.
  List<num> get e => List<num>.of(_e);

  /// Energy sample mean.
  late final num eMean;

  /// Corrected energy sample standard deviation.
  late final num eStdDev;

  /// Energy sample miniumum.
  late final num eMin0;

  /// Energy sample maximum.
  late final num eMax0;

  /// Point at which energy sample minimum occurs.
  late final List<num> xMin0;

  /// Returns `0.5 * (eStdDev + 0.25 * (eMean - eMin0).abs())`.
  ///
  /// The expression is
  num get dE0 => 0.5 * (eStdDev + 0.25 * (eMean - eMin0).abs());

  /// Returns an new point in the search region by randomly
  /// perturbing `xMin` with maximum magnitude `dx`.
  List<num> perturb(List<num> xMin, List<num> dx) =>
      _searchSpace.perturb(xMin, dx);

  /// Returns an estimation of the search region size.
  List<num> get size => _searchSpace.size;

  @override
  String toString() {
    final b = StringBuffer();
    b.writeln('System: ');
    b.writeln('  xMin: $xMin0');
    b.writeln('  energy min: $eMin0');
    b.writeln('  energy max: $eMax0');
    b.writeln('  energy mean: ${eMean}');
    b.writeln('  energy stdDev: ${eStdDev}');
    b.writeln('  energy variation: $dE0');
    return b.toString();
  }
}
