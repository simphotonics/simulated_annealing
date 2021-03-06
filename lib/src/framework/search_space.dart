import 'dart:math';

import 'package:exception_templates/exception_templates.dart';
import 'package:lazy_memo/lazy_memo.dart';

import '../extensions/random_in_range.dart';
import '../exceptions/incompatible_vectors.dart';

/// Function defining an interval start/end point.
typedef ParametricPoint = num Function();

/// Abstract class representing a numerical interval.
abstract class Interval {
  Interval({this.inverseCdf});

  final InverseCdf? inverseCdf;

  /// Returns the next random number in the interval.
  ///
  /// If `nGrid > 1` the interval is divided in
  /// into a grid with `nGrid` points.
  num next({int nGrid = 0});

  /// Returns the next random number in the intersection of the intervals
  /// `(start, end)` and `(position - deltaPosition, position + deltaPosition)`.
  /// Returns `position` if the intersection is the empty interval.
  num perturb(num position, num deltaPosition, {int nGrid = 0});

  /// Returns true if `point` belongs to the interval.
  bool contains(num point);

  /// Returns true if this and the interval defined by `start` and
  /// `end` overlap.
  bool overlaps(num start, num end);

  /// Returns the size of the interval.
  num get size;

  /// Cached random number in interval.
  /// @nodoc
  late num _cache;

  /// Logical flag indicating if `_cache` is up to date.
  bool _isUpToDate = false;

  /// Clears the internal cache holding next. After calling this function
  /// the method `next` will return a new random number sampled from the
  /// interval `(start, end)`.
  void clearCache() {
    _isUpToDate = false;
  }

  /// The random number generator.
  static final random = Random();
}

/// A fixed numerical interval defined by
/// the start point `start` and the end point `end`.
class FixedInterval extends Interval {
  /// Constructs a fixed interval (`start`, `end`).
  FixedInterval(this.start, this.end, {InverseCdf? inverseCdf})
      : _size = (end - start).abs(),
        super(
          inverseCdf: inverseCdf,
        );

  /// Constructs a copy of `interval`.
  ///
  /// Note: The cache is *not* copied. Each instance of [FixedInterval]
  /// manages its own cache.
  FixedInterval.of(FixedInterval interval)
      : start = interval.start,
        end = interval.end,
        _size = interval._size,
        super(inverseCdf: interval.inverseCdf);

  /// Start point of the numerical interval.
  final num start;

  /// End point of the numerical interval.
  final num end;

  /// Size
  final _size;

  /// Returns the next random number sampled from
  /// the interval `(start, end)`.
  /// * Returns a cached value if the cache is up-to-date.
  /// * If the cache is stale an new random number is returned and cached.
  /// ---
  /// * `nGrid`: Number of grid points. If `nGrid > 1` the interval
  ///   is divided into an equidistant grid
  ///   with `nGrid` points: `[xMin + dx, xMin + 2 * dx, ..., xMax - dx]`
  ///   where `dx = (xMax - xMin) / nGrid` and any random number returned
  ///   coincides with a gridpoint.
  @override
  num next({int nGrid = 0}) {
    if (_isUpToDate) {
      return _cache;
    } else {
      _isUpToDate = true;
      return _cache = Interval.random.nextInRange(
        start,
        end,
        inverseCdf: inverseCdf,
        nGrid: nGrid,
      );
    }
  }

  /// Returns the next random number sampled from the interval
  /// obtained by intersecting:
  /// `(start, end)` and `(position - deltaPosition, position + deltaPosition)`.
  /// * If the intersection is empty, `position` is returned unperturbed.
  /// * Returns a cached value if the cache is up-to-date.
  /// * If the cache is stale an new random number is returned and cached.
  /// ---
  /// * `nGrid`: Number of grid points. If `nGrid > 1` the interval
  ///   is divided into an equidistant grid
  ///   with `nGrid` points: `[xMin + dx, xMin + 2 * dx, ..., xMax - dx]`
  ///   where `dx = (xMax - xMin) / nGrid` and any random number returned
  ///   coincides with a gridpoint.
  @override
  num perturb(
    num position,
    num deltaPosition, {
    int nGrid = 0,
  }) {
    if (overlaps(position - deltaPosition, position + deltaPosition)) {
      _isUpToDate = true;
      return _cache = Interval.random.nextInRange(
        max(position - deltaPosition, start),
        min(position + deltaPosition, end),
        inverseCdf: inverseCdf,
        nGrid: nGrid,
      );
    } else {
      _isUpToDate = false;
      return position;
    }
  }

  @override
  String toString() {
    final b = StringBuffer();
    b.writeln('FixedInterval:');
    b.writeln('  start: $start');
    b.writeln('  end: $end');
    if (_isUpToDate) {
      b.write('  cached next: $_cache');
    } else {
      b.write('  cached next: not set');
    }

    return b.toString();
  }

  /// Returns true if position is safisfying
  /// `(position >= start && x<= end)`.
  @override
  bool contains(num position) =>
      (position >= start && position <= end) ||
      (position >= end && position <= start);

  /// Returns true if the interval defined by the points
  /// `left` and `right` overlaps `this`.
  @override
  bool overlaps(num left, num right) {
    if (left < start && right < start) return false;
    if (left > end && right > end) return false;
    return true;
  }

  /// Returns the length of the interval.
  @override
  num get size => _size;
}

/// A numerical interval defined by
/// the parametric start point function `pStart` and the end point `pEnd`.
class ParametricInterval extends Interval {
  /// Constructs a parametric interval.
  ParametricInterval(this.pStart, this.pEnd, {InverseCdf? inverseCdf})
      : super(
          inverseCdf: inverseCdf,
        );

  /// Start point of the numerical interval.
  final ParametricPoint pStart;

  /// End point of the numerical interval.
  final ParametricPoint pEnd;

  /// Returns the next random number that is larger
  /// than `pStart()` inclusive,
  /// and smaller than `pEnd()`, exclusive.
  /// * Returns a cached value if the cache is up-to-date.
  /// * To clear the cache call `clearCache()`.
  /// ---
  /// * `nGrid`: Number of grid points. If `nGrid > 1` the interval
  ///   is divided into an equidistant grid
  ///   with `nGrid` points: `[xMin + dx, xMin + 2 * dx, ..., xMax - dx]`
  ///   where `dx = (xMax - xMin) / nGrid` and any random number returned
  ///   coincides with a gridpoint.
  /// ---
  /// * Result caching enables defining parameterized intervals where some
  ///   intervals depend on other intervals.
  ///   ```
  ///   /// Defines a 2D circular sampling area centered at
  ///   /// (0, 0) with radius 2.75.
  ///   final r = 2.75;
  ///   final x = Interval(-r, r);
  ///   final y = ParametricInterval(
  ///     () => -sqrt(r**2 - pow(x.next(),2)),
  ///     () =>  sqrt(r**2 - pow(x.next(),2)),
  ///   );
  ///
  ///   final space = SearchSpace([x,y]);
  ///   ```
  @override
  num next({int nGrid = 0}) {
    if (_isUpToDate) {
      return _cache;
    } else {
      _isUpToDate = true;
      return _cache = Interval.random.nextInRange(
        pStart(),
        pEnd(),
        inverseCdf: inverseCdf,
        nGrid: nGrid,
      );
    }
  }

  /// Returns the next random number sampled from the interval
  /// obtained by intersecting:
  /// `(start, end)` and `(position - deltaPosition, position + deltaPosition)`.
  /// * If the intersection is empty, `position` is returned unperturbed.
  /// * Returns a cached value if the cache is up-to-date.
  /// * If the cache is stale an new random number is returned and cached.
  /// ---
  /// * `nGrid`: Number of grid points. If `nGrid > 1` the interval
  ///   is divided into an equidistant grid
  ///   with `nGrid` points: `[xMin + dx, xMin + 2 * dx, ..., xMax - dx]`
  ///   where `dx = (xMax - xMin) / nGrid` and any random number returned
  ///   coincides with a gridpoint.
  @override
  num perturb(num position, num deltaPosition, {int nGrid = 0}) {
    if (overlaps(position - deltaPosition, position + deltaPosition)) {
      _isUpToDate = true;
      return _cache = Interval.random.nextInRange(
        max(position - deltaPosition, pStart()),
        min(position + deltaPosition, pEnd()),
        inverseCdf: inverseCdf,
        nGrid: nGrid,
      );
    } else {
      _isUpToDate = false;
      return position;
    }
  }

  /// Returns true if `position` is safisfying
  /// `(position >= pStart() && x<= pEnd()))`.
  @override
  bool contains(num position) => (position >= pStart() && position <= pEnd() ||
      position >= pEnd() && position <= pStart());

  /// Returns true if the interval defined by the points
  /// `left` and `right` overlaps with `this`.
  @override
  bool overlaps(num left, num right) {
    if (right < pStart() && left < pStart()) return false;
    if (left > pEnd() && right > pEnd()) return false;
    return true;
  }

  @override
  String toString() {
    final b = StringBuffer();
    b.writeln('ParametricInterval (current boundaries):');
    b.writeln('  start: ${pStart()}');
    b.writeln('  end: ${pEnd()}');
    if (_isUpToDate) {
      b.write('  cached next: $_cache');
    } else {
      b.write('  cached next: not set');
    }
    return b.toString();
  }

  /// Returns the current length of the interval.
  ///
  /// Note: For parametric intervals the length may not be constant.
  @override
  num get size => (pEnd() - pStart()).abs();
}

/// A search region with boundaries defined by
/// `intervals`.
class SearchSpace {
  /// Constructs an object of type `SearchSpace`.
  /// * `intervals`: A list of intervals defining the search space.
  /// *  Note: Parametric intervals must be listed
  ///    **after** all intervals they depend on.
  SearchSpace(List<Interval> intervals)
      : _intervals = List<Interval>.of(intervals),
        dimension = intervals.length,
        _nGrid0 = List<int>.filled(
          intervals.length,
          0,
        ) {
    _size = Lazy<List<num>>(() => estimateSize());
  }

  /// Search space dimension.
  /// * Is equal to the length of the constructor parameter `intervals`.
  int dimension;

  /// The default empty grid.
  final List<int> _nGrid0;

  /// Intervals defining the boundary of the sampling space.
  /// * The list `_intervals` must not be empty.
  final List<Interval> _intervals;

  /// Returns a random vector of length `dimension`. Each vector coordinate
  /// is generated by drawing samples from the corresponding
  /// interval.
  List<num> next({List<int> nGrid = const <int>[]}) {
    if (nGrid.isNotEmpty && nGrid.length != dimension) {
      throw ErrorOfType<IncompatibleVector>(
          message: 'Could not generate random point using method next().',
          invalidState: 'Dimension mismatch: $dimension != ${nGrid.length}.',
          expectedState: 'The vector \'grid\' must have length $dimension.');
    }
    _clearCache();
    return nGrid.isEmpty
        ? List<num>.generate(
            dimension,
            (i) => _intervals[i].next(),
          )
        : List<num>.generate(
            dimension,
            (i) => _intervals[i].next(nGrid: nGrid[i]),
          );
  }

  /// Returns a random vector of length `dimension`
  /// sampled from the interval
  /// obtained by intersecting `this` with the generalized rectangle
  /// centred at `position` with edge lengths
  /// `(position - deltaPosition, position + deltaPosition)`.
  ///
  /// Note: If the intersection is empty, the input
  /// `position` is returned unperturbed.
  ///
  /// Throws an error of type `ErrorOfType<InCompatibleVector>` if the
  /// length of the `position` or `deltaPosition` does not match `this.dimension`.
  List<num> perturb(
    List<num> position,
    List<num> deltaPosition, {
    List<int> nGrid = const <int>[],
  }) {
    if (position.length != dimension) {
      throw ErrorOfType<IncompatibleVector>(
          message: 'Could not generate random point around $position.',
          invalidState: 'Dimension mismatch: $dimension != ${position.length}.',
          expectedState: 'The vector position must have length $dimension.');
    }
    if (deltaPosition.length != dimension) {
      throw ErrorOfType<IncompatibleVector>(
          message:
              'Could not generate perturbation using magnitudes $deltaPosition.',
          invalidState:
              'Dimension mismatch: $dimension != ${deltaPosition.length}.',
          expectedState:
              'The vector deltaPosition must have length $dimension.');
    }
    if (nGrid.isNotEmpty && nGrid.length != dimension) {
      throw ErrorOfType<IncompatibleVector>(
          message: 'Could not generate random point around $position.',
          invalidState: 'Dimension mismatch: $dimension != ${nGrid.length}.',
          expectedState: 'The vector \'grid\' must have length $dimension.');
    }
    _clearCache();
    // Generating the random sample.
    if (nGrid.isEmpty) {
      nGrid = _nGrid0;
    }
    final result = <num>[];
    num value = 0;
    for (var i = 0; i < dimension; ++i) {
      value = _intervals[i].perturb(
        position[i],
        deltaPosition[i],
        nGrid: nGrid[i],
      );
      if (!_intervals[i]._isUpToDate && value == position[i]) {
        /// Return early if any interval can not generate a new position
        /// that is within bounds.
        return position;
      } else {
        result.add(value);
      }
    }
    return result;
  }

  /// Clears the cached random numbers for each interval.
  void _clearCache() {
    _intervals.forEach((interval) {
      interval.clearCache();
    });
  }

  /// Lazy variable storing the search space size.
  late final Lazy<List<num>> _size;

  /// Returns an estimate of the search space size.
  ///
  /// Note: If all intervals are of type `FixedInterval` the reported interval
  /// sizes are exact.
  List<num> estimateSize() {
    if (_intervals.every((interval) => interval is FixedInterval)) {
      return List<num>.generate(dimension, (i) => _intervals[i].size);
    }

    final sizes = List<List<num>>.generate(50, (_) {
      _clearCache();
      return List<num>.generate(dimension, (i) => _intervals[i].size);
    });

    return sizes.reduce((value, current) {
      for (var i = 0; i < dimension; ++i) {
        value[i] = max(value[i], current[i]);
      }
      return value;
    });
  }

  /// Returns the search space size along each dimension.
  ///
  /// Note: For parametric intervals the size is estimated by sampling the
  /// interval 50 times and returning the difference between the sample
  /// maximum and the sample minimum.
  List<num> get size => List.of(_size());

  /// Returns true if the point `position` belongs to the search space `this`.
  bool contains(List<num> position) {
    if (position.length != dimension) {
      throw ErrorOfType<IncompatibleVector>(
          message: 'Error encountered in method: \'contains($position)\'.',
          invalidState: 'Space dimension $dimension != $position.length.',
          expectedState: 'The vector argument must have length $dimension.');
    }
    for (var i = 0; i < dimension; ++i) {
      if (!_intervals[i].contains(position[i])) {
        return false;
      }
    }
    return true;
  }

  @override
  String toString() {
    final b = StringBuffer();
    b.writeln('Search Space: ');
    b.writeln('  size: $size');
    b.writeln('  dimension: $dimension');
    for (var i = 0; i < dimension; ++i) {
      b.writeln('  ${_intervals[i]}'.replaceAll('\n', '\n  '));
    }
    return b.toString();
  }
}
