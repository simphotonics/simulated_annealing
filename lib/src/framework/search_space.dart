import 'dart:math';

import 'package:exception_templates/exception_templates.dart';
import 'package:simulated_annealing/src/exceptions/incompatible_vectors.dart';

import '../extensions/random_sample.dart';

/// Function defining an interval start/end point.
typedef ParametricPoint = num Function();

/// Abstract class representing a numerical interval.
abstract class Interval {
  Interval();

  /// Returns the next random number in the interval.
  num next({num? midPoint, num magnitude});

  /// Returns true if `point` belongs to the interval.
  bool contains(num point);

  /// Returns true if this and the interval defined by `start` and
  /// `end` overlap.
  bool overlaps(num start, num end);

  /// Returns the size of the interval.
  num get _size;

  /// Cached random number in interval (startPoint(), endPoint()).
  /// @nodoc
  late num _cache;

  /// Logical flag indicating if `_cache` is up to date.
  bool _isUpToDate = false;

  /// Clears the internal cache. After calling this function
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
  FixedInterval(this.start, this.end);

  /// Start point of the numerical interval.
  final num start;

  /// End point of the numerical interval.
  final num end;

  /// Returns the next random number that is larger than `start`
  /// inclusive, and smaller than `end`, exclusive.
  ///
  /// If `midPoint` is specified the method returns
  /// the next random number sampled from the interval
  /// obtained by intersecting:
  /// `(start, end)` and
  /// `(midPoint - magnitude, midPoint + magnitude)`.
  ///
  /// Note: If the intersection is empty, the input
  /// `midPoint` is returned unperturbed.
  @override
  num next({num? midPoint, num magnitude = 0}) {
    if (_isUpToDate) return _cache;
    if (midPoint == null) {
      _isUpToDate = true;
      return _cache = Interval.random.nextDoubleInRange(start, end);
    } else {
      final startM = midPoint - magnitude.abs();
      final endM = midPoint + magnitude.abs();
      if (!overlaps(startM, endM)) {
        return midPoint;
      }
      final _start = max(startM, start);
      final _end = min(endM, end);
      _isUpToDate = true;
      return _cache = Interval.random.nextDoubleInRange(_start, _end);
    }
  }

  @override
  String toString() =>
      _isUpToDate ? '[$start, $_cache, $end]' : '[$start, $end]';

  /// Returns true if x is safisfying
  /// `(x >= start && x<= end)`.
  @override
  bool contains(num x) => (x >= start && x <= end);

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
  ParametricInterval(this.pStart, this.pEnd);

  /// Start point of the numerical interval.
  final ParametricPoint pStart;

  /// End point of the numerical interval.
  final ParametricPoint pEnd;

  /// Returns the next random number that is larger
  /// than `pStart()` inclusive,
  /// and smaller than `pEnd()`, exclusive.
  ///
  ///
  /// If `midPoint` is specified the method returns
  /// the next random number sampled from the interval
  /// obtained by intersecting:
  /// `(pStart(), pEnd())` and
  /// `(midPoint - magnitude, midPoint + magnitude)`.
  ///
  /// Note: If the intersection is empty, the input
  /// `midPoint` is returned unperturbed.
  ///
  /// * Results are cached. To clear the cache call `clearCache()`.
  /// * Result caching enables defining parameterized bpeoples courtoundaries where some
  ///   intervals depend on other intervals.
  ///
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
  num next({num? midPoint, num magnitude = 0}) {
    if (_isUpToDate) return _cache;
    if (midPoint == null) {
      _isUpToDate = true;
      return _cache = Interval.random.nextDoubleInRange(pStart(), pEnd());
    } else {
      _isUpToDate = true;
      final startM = midPoint - magnitude.abs();
      final endM = midPoint + magnitude.abs();
      if (!overlaps(startM, endM)) {
        return _cache = midPoint;
      }
      final _start = max(startM, pStart());
      final _end = min(endM, pEnd());
      return _cache = Interval.random.nextDoubleInRange(_start, _end);
    }
  }

  /// Returns true if `x` is safisfying
  /// `(x >= pStart() && x<= pEnd()))`.
  @override
  bool contains(num x) => (x >= pStart() && x <= pEnd());

  /// Returns true if the interval defined by the points
  /// `left` and `right` overlaps with `this`.
  @override
  bool overlaps(num left, num right) {
    if (left < pStart() && right < pStart()) return false;
    if (left > pEnd() && right > pEnd()) return false;
    return true;
  }

  @override
  String toString() => _isUpToDate
      ? '[${pStart()}, $_cache, ${pEnd()}]'
      : '[${pStart()}, ${pEnd()}]';

  /// Returns the length of the interval.
  @override
  num get _size => (pEnd() - pStart()).abs();
}

/// A search region with boundaries defined by
/// `intervals`.
class SearchSpace {
  /// Constructs an object of type `SearchSpace`.
  SearchSpace(List<Interval> intervals)
      : _intervals = List<Interval>.of(intervals);

  /// Copy constructor.
  factory SearchSpace.from(SearchSpace region) {
    return SearchSpace(region._intervals);
  }

  /// Search region dimension.
  /// * Is equal to the length of the constructor parameter `intervals`.
  /// * Corresponds to the number of variables being sampled.
  int get dimension => _intervals.length;

  /// Intervals defining the boundary of the sampling space.
  /// * The list `_intervals` must not be empty.
  final List<Interval> _intervals;

  /// Returns a random vector of length `dimension`. Each vector coordinate
  /// is generated by drawing samples from the corresponding
  /// interval.
  List<num> next() {
    final result = List<num>.generate(
      dimension,
      (i) => _intervals[i].next(),
    );
    // Clearing the function table of the memoized method perturb.
    _intervals.forEach((interval) {
      interval.clearCache();
    });
    return result;
  }

  /// Returns a random vector of length `dimension`
  /// sampled from the interval
  /// obtained by intersecting `this` with the generalized rectangle
  /// centred at `midPoint` with edge lengths `(midPoint - dx, midPoint + dx)`.
  ///
  /// Note: If the intersection is empty, the input
  /// `midPoint` is returned unperturbed.
  ///
  /// Throws an error of type `ErrorOfType<InCompatibleVector>` if the
  /// length of the `midPoint` or `dx` does not match `this.dimension`.
  List<num> perturb(List<num> midPoint, List<num> dx) {
    if (midPoint.length != dimension) {
      throw ErrorOfType<IncompatibleVector>(
          message: 'Could not generate perturbation around $midPoint.',
          invalidState: 'Dimension mismatch: $dimension != ${midPoint.length}.',
          expectedState: 'The vector midPoint must have length $dimension.');
    }
    if (dx.length != dimension) {
      throw ErrorOfType<IncompatibleVector>(
          message: 'Could not generate perturbation using magnitudes $dx.',
          invalidState: 'Dimension mismatch: $dimension != ${dx.length}.',
          expectedState: 'The vector dx must have length $dimension.');
    }
    // Generating the random sample.
    num mid = 0;
    final result = <num>[];
    for (var i = 0; i < dimension; ++i) {
      mid = _intervals[i].next(
        midPoint: midPoint[i],
        magnitude: dx[i],
      );
      if (!_intervals[i].overlaps(
        midPoint[i] - dx[i].abs(),
        midPoint[i] + dx[i].abs(),
      )) {
        clearCache();
        return midPoint;
      } else {
        result.add(mid);
      }
    }
    clearCache();
    return result;
  }

  /// Cleas the cached random numbers for each interval.
  void clearCache() {
    _intervals.forEach((interval) {
      interval.clearCache();
    });
  }

  /// Returns the sample space size along each dimension.
  ///
  /// Note:
  /// Parametric interval sizes are sampled
  /// 50 times and the maximum values are returned.
  List<num> get size {
    final sizes = List<List<num>>.generate(50, (_) {
      clearCache();
      return List<num>.generate(dimension, (i) => _intervals[i]._size);
    });
    return sizes.reduce((maxSize, current) {
      for (var i = 0; i < dimension; ++i) {
        maxSize[i] = max(maxSize[i], current[i]);
      }
      return maxSize;
    });
  }
}
