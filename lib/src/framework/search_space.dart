import 'dart:collection';
import 'dart:math';

import 'package:exception_templates/exception_templates.dart';
import 'package:lazy_memo/lazy_memo.dart';

import '../extensions/random_sample.dart';
import '../exceptions/incompatible_vectors.dart';

/// Function defining an interval start/end point.
typedef ParametricPoint = num Function();

/// Abstract class representing a numerical interval.
abstract class Interval {
  Interval({this.inverseCdf});

  final InverseCdf? inverseCdf;

  /// Returns the next random number in the interval.
  num next();

  /// Returns the next random number in the intersection of the intervals
  /// `(start, end)` and `(x - dx, x + dx)`.
  /// Returns `x` if the intersection is the empty interval.
  num perturb(num x, num dx);

  /// Returns true if `point` belongs to the interval.
  bool contains(num point);

  /// Returns true if this and the interval defined by `start` and
  /// `end` overlap.
  bool overlaps(num start, num end);

  /// Returns the size of the interval.
  num get _size;

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
      : super(
          inverseCdf: inverseCdf,
        );

  /// Start point of the numerical interval.
  final num start;

  /// End point of the numerical interval.
  final num end;

  /// Returns the next random number sampled from
  /// the interval `(start, end)`.
  /// * Returns a cached value if the cache is up-to-date.
  /// * If the cache is stale an new random number is returned and cached.
  @override
  num next() {
    if (_isUpToDate) {
      return _cache;
    } else {
      _isUpToDate = true;
      return _cache = Interval.random.nextInRange(
        start,
        end,
        inverseCdf,
      );
    }
  }

  /// Returns the next random number sampled from the interval
  /// obtained by intersecting:
  /// `(start, end)` and `(x - dx, x + dx)`.
  /// * If the intersection is empty, `x` is returned unperturbed.
  /// * Returns a cached value if the cache is up-to-date.
  /// * If the cache is stale an new random number is returned and cached.
  @override
  num perturb(num x, num dx) {
    if (overlaps(x - dx, x + dx)) {
      _isUpToDate = true;
      return _cache = Interval.random.nextInRange(
        max(x - dx, start),
        min(x + dx, end),
        inverseCdf,
      );
    } else {
      _isUpToDate = false;
      return x;
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

  /// Returns true if x is safisfying
  /// `(x >= start && x<= end)`.
  @override
  bool contains(num x) => (x >= start && x <= end) || (x >= end && x <= start);

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
  num get _size => (end - start).abs();
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
  /// * Result caching enables defining parameterized intervals where some
  ///   intervals depend on other intervals.
  ///   ```
  ///   /// Defines a 2D circular sampling area centered at
  ///   /// (0, 0) with radius 2.75.
  ///   final r = 2.75;
  ///   final x = Interval(-r, r);
  ///   final y = ParametricInterval(
  ///     () => -sqrt(r**2 - x.next()**2),
  ///     () =>  sqrt(r**2 - x.next()**2),
  ///   );
  ///
  ///   final space = ParametricSpace([x,y]);
  ///   ```
  @override
  num next() {
    if (_isUpToDate) {
      return _cache;
    } else {
      _isUpToDate = true;
      return _cache = Interval.random.nextInRange(
        pStart(),
        pEnd(),
        inverseCdf,
      );
    }
  }

  /// Returns the next random number sampled from the interval
  /// obtained by intersecting:
  /// `(start, end)` and `(x - dx, x + dx)`.
  /// * If the intersection is empty, `x` is returned unperturbed.
  /// * Returns a cached value if the cache is up-to-date.
  /// * If the cache is stale an new random number is returned and cached.
  @override
  num perturb(num x, num dx) {
    if (overlaps(x - dx, x + dx)) {
      _isUpToDate = true;
      return _cache = Interval.random.nextInRange(
        max(x - dx, pStart()),
        min(x + dx, pEnd()),
        inverseCdf,
      );
    } else {
      _isUpToDate = false;
      return x;
    }
  }

  /// Returns true if `x` is safisfying
  /// `(x >= pStart() && x<= pEnd()))`.
  @override
  bool contains(num x) =>
      (x >= pStart() && x <= pEnd() || x >= pEnd() && x <= pStart());

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
  num get _size => (pEnd() - pStart()).abs();
}

/// A search region with boundaries defined by
/// `intervals`.
class SearchSpace {
  /// Constructs an object of type `SearchSpace`.
  /// * `intervals`: A list of intervals defining the search space.
  ///    Note: Parametric intervals must be listed
  ///    after the intervals they depend on.
  /// * `dxMin`: The smallest perturbation magnitudes used with
  ///    the method `perturb`. For a discrete search space
  ///    it corresponds to the solution precision.
  /// * `dxMax`: The largest perturbation magnitudes used with
  ///    the method `perturb`. This parameter is optional. It
  ///    defaults to the search space `size`.
  SearchSpace(
    List<Interval> intervals, {
    required List<num> dxMin,
    List<num>? dxMax,
  })  : _intervals = List<Interval>.of(intervals),
        dxMin = UnmodifiableListView<num>(dxMin),
        dimension = intervals.length {
    _size = Lazy<List<num>>(() => estimateSize());
    this.dxMax = (dxMax == null)
        ? UnmodifiableListView(size)
        : UnmodifiableListView(dxMax);
  }

  /// Search space dimension.
  /// * Is equal to the length of the constructor parameter `intervals`.
  int dimension;

  /// Intervals defining the boundary of the sampling space.
  /// * The list `_intervals` must not be empty.
  final List<Interval> _intervals;

  // Maximum size of the search neighbourhood.
  late final UnmodifiableListView<num> dxMax;

  /// Minimum size of the search neighbourhood.
  ///
  /// For continuous problems this parameter determines the solution precision.
  final UnmodifiableListView<num> dxMin;

  /// Returns a random vector of length `dimension`. Each vector coordinate
  /// is generated by drawing samples from the corresponding
  /// interval.
  List<num> next() {
    _clearCache();
    return List<num>.generate(
      dimension,
      (i) => _intervals[i].next(),
    );
  }

  /// Returns a random vector of length `dimension`
  /// sampled from the interval
  /// obtained by intersecting `this` with the generalized rectangle
  /// centred at `x` with edge lengths `(x - dx, x + dx)`.
  ///
  /// Note: If the intersection is empty, the input
  /// `x` is returned unperturbed.
  ///
  /// Throws an error of type `ErrorOfType<InCompatibleVector>` if the
  /// length of the `x` or `dx` does not match `this.dimension`.
  List<num> perturb(List<num> x, List<num> dx) {
    if (x.length != dimension) {
      throw ErrorOfType<IncompatibleVector>(
          message: 'Could not generate random point around $x.',
          invalidState: 'Dimension mismatch: $dimension != ${x.length}.',
          expectedState: 'The vector x must have length $dimension.');
    }
    if (dx.length != dimension) {
      throw ErrorOfType<IncompatibleVector>(
          message: 'Could not generate perturbation using magnitudes $dx.',
          invalidState: 'Dimension mismatch: $dimension != ${dx.length}.',
          expectedState: 'The vector dx must have length $dimension.');
    }
    _clearCache();
    // Generating the random sample.
    final result = <num>[];
    num value = 0;
    for (var i = 0; i < dimension; ++i) {
      value = _intervals[i].perturb(x[i], dx[i]);
      if (!_intervals[i]._isUpToDate && value == x[i]) {
        return x;
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
      return List<num>.generate(dimension, (i) => _intervals[i]._size);
    }

    final sizes = List<List<num>>.generate(50, (_) {
      _clearCache();
      return List<num>.generate(dimension, (i) => _intervals[i]._size);
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
  UnmodifiableListView<num> get size => UnmodifiableListView(_size());

  /// Returns true if the point `x` belongs to the search space `this`.
  bool contains(List<num> x) {
    if (x.length != dimension) {
      throw ErrorOfType<IncompatibleVector>(
          message: 'Error encountered in method: \'contains($x)\'.',
          invalidState: 'Space dimension $dimension != $x.length.',
          expectedState: 'The vector argument must have length $dimension.');
    }
    for (var i = 0; i < dimension; ++i) {
      if (!_intervals[i].contains(x[i])) {
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
    b.writeln('  dxMin: $dxMin');
    b.writeln('  dxMax: $dxMax');
    b.writeln('  dimension: $dimension');
    for (var i = 0; i < dimension; ++i) {
      b.writeln('  ${_intervals[i]}'.replaceAll('\n', '\n  '));
    }
    return b.toString();
  }
}
