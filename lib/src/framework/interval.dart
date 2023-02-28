import 'dart:math' show min, max, Random;

import '../extensions/random_in_range.dart';

/// Function defining an interval start/end point.
typedef ParametricPoint = num Function();

/// Abstract class representing a numerical interval.
abstract class Interval {
  Interval({this.inverseCdf});

  /// Inverse cummulative distribution function.
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

  /// Returns the grid points associated with an interval.
  ///
  /// Returns an empty list if `nGrid < 2`.
  List<num> gridPoints(int nGrid);

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

/// A fixed numerical interval where the start point
/// coincides with the end point.
/// * The method `next()` returns the only point in the interval.
/// * The method `perturb(position, deltaPosition)`
///   returns the only point in the interval if it coincides with `position`.
/// ---
/// The class is used for example to specify the radius
/// of a surface of a sphere.
class SingularInterval extends FixedInterval {
  /// Constructs a singular fixed interval.
  SingularInterval(num value) : super._(value, value);

  SingularInterval.of(SingularInterval interval)
      : super._(
          interval.start,
          interval.end,
        );

  /// Returns the value stored in `start`.
  ///
  /// ---
  /// * `nGrid`: Number of grid points. If `nGrid > 1` the interval
  ///   is divided into an equidistant grid
  ///   with `nGrid` points: `[xMin + dx, xMin + 2 * dx, ..., xMax - dx]`
  ///   where `dx = (xMax - xMin) / nGrid` and any random number returned
  ///   coincides with a gridpoint.
  @override
  num next({int nGrid = 0}) => start;

  /// Returns the next random number sampled from the interval
  /// obtained by intersecting:
  /// `(start, start)` and `(position - deltaPosition, position + deltaPosition)`.
  /// * If the intersection is empty, `position` is returned unperturbed.
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
    if (start == position) {
      return start;
    } else {
      return position;
    }
  }

  @override
  String toString() {
    final b = StringBuffer();
    b.writeln('SingularInterval:');
    b.writeln('  start: $start');
    b.writeln('  end: $end');
    return b.toString();
  }

  /// Returns `true` if position coincides with `start`.
  @override
  bool contains(num position) => (position == start);

  /// Returns true if the interval defined by the points
  /// `left` and `right` overlaps `this`.
  @override
  bool overlaps(num left, num right) {
    if (left < start && right < start) return false;
    if (left > end && right > end) return false;
    return true;
  }

  /// Returns the only grid point coinciding with `start` and `end`.
  @override
  List<num> gridPoints(int nGrid) {
    return [start];
  }
}

/// A fixed numerical interval defined by
/// the start point `start` and the end point `end`.
class FixedInterval extends Interval {
  /// Constructs a fixed interval (`start`, `end`).
  FixedInterval._(num start, num end, {InverseCdf? inverseCdf})
      : start = min(start, end),
        end = max(start, end),
        super(inverseCdf: inverseCdf);

  /// Returns an instance of [FixedInterval].
  ///
  /// If `start == end` an instance of [SingularInterval] is returned.
  factory FixedInterval(
    num start,
    num end, {
    InverseCdf? inverseCdf,
  }) {
    return start == end
        ? SingularInterval(start)
        : FixedInterval._(start, end, inverseCdf: inverseCdf);
  }

  /// Constructs a copy of `interval`.
  ///
  /// Note: The cache is *not* copied. Each instance of [FixedInterval]
  /// manages its own cache.
  factory FixedInterval.of(FixedInterval interval) =>
      FixedInterval(interval.start, interval.end,
          inverseCdf: interval.inverseCdf);

  /// Start point of the numerical interval.
  final num start;

  /// End point of the numerical interval.
  final num end;

  /// Returns the size of the interval.
  @override
  late final num size = end - start;

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
    deltaPosition = deltaPosition.abs();
    final startOverlap = max(position - deltaPosition, start);
    final endOverlap = min(position + deltaPosition, end);
    if (startOverlap > end || endOverlap < start) {
      _isUpToDate = false;
      return position;
    } else {
      _isUpToDate = true;
      return _cache = Interval.random.nextInRange(
        startOverlap,
        endOverlap,
        inverseCdf: inverseCdf,
        nGrid: nGrid,
      );
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
  /// `(start <= position && position <= end)`.
  @override
  bool contains(num position) => start <= position && position <= end;

  /// Returns true if the interval defined by the points
  /// `left` and `right` overlaps `this`.
  @override
  bool overlaps(num left, num right) {
    final start = min(left, right);
    final end = max(left, right);
    if (end < this.start) return false;
    if (start > this.end) return false;
    return true;
  }

  @override
  List<num> gridPoints(int nGrid) {
    return Interval.random.gridPoints(start, end, nGrid);
  }
}

/// An interval that wraps around itself.
///
/// Usage: Defining the interval representing
/// the longitudinal angle of spherical coordinates.
/// Any angle may then be remapped to the interaval 0...2pi.
class PeriodicInterval extends FixedInterval {
  PeriodicInterval(super.start, super.end, {InverseCdf? inverseCdf})
      : super._(inverseCdf: inverseCdf);

  PeriodicInterval.of(FixedInterval interval)
      : super._(interval.start, interval.end, inverseCdf: interval.inverseCdf);

  @override
  num perturb(
    num position,
    num deltaPosition, {
    int nGrid = 0,
  }) {
    _isUpToDate = true;
    deltaPosition = deltaPosition.abs();
    final nextPoint = Interval.random.nextInRange(
      position - deltaPosition,
      position + deltaPosition,
      inverseCdf: inverseCdf,
      nGrid: nGrid,
    );

    if (nextPoint < start || nextPoint > end) {
      final remainder = nextPoint.remainder(size);
      return _cache =
          remainder.isNegative ? end + remainder : start + remainder;
    } else {
      return _cache = nextPoint;
    }
  }
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

  /// Returns the current size of the interval.
  ///
  /// Note: For parametric intervals the length may not be constant.
  @override
  num get size => (pEnd() - pStart()).abs();

  @override
  List<num> gridPoints(int nGrid) {
    return Interval.random.gridPoints(pStart(), pEnd(), nGrid);
  }
}
