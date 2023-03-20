import 'dart:math' show min, max, Random;
import 'package:lazy_memo/lazy_memo.dart';

import '../extensions/random_in_range.dart';

/// Function defining an interval start/end point.
typedef ParametricPoint = num Function();

typedef Next = num Function();
typedef Perturb = num Function(num position, num deltaPosition);

/// Abstract class representing a numerical interval.
abstract class Interval {
  Interval({this.inverseCdf, this.name = ''});

  /// Inverse cummulative distribution function.
  final InverseCdf? inverseCdf;

  /// The start of the numerical interval [start]...[end].
  num get start;

  /// The end of the numerical interval [start]...[end].
  num get end;

  /// Returns the name of interval.
  final String name;

  /// Returns the levels of a discrete interval.
  int get levels => _levels;

  /// The levels of a discrete interval.
  /// The initial value is zero indicating a continuous interval.
  int _levels = 0;

  /// Returns `true` if the interval is discrete (has at least 2 gridpoints).
  bool get isDiscrete => (_levels >= 2);

  /// Returns `true` if the interval is continuous.
  bool get isContinuous => (_levels < 2);

  /// Returns the grid points associated with the discrete interval.
  List<num> get gridPoints => List<num>.generate(_levels, (i) {
        return start + i * dx();
      });

  /// Step size between discrete levels.
  late final dx = Lazy<num>(
    () => _levels >= 2 ? (end - start) / (_levels - 1) : 0,
  );

  /// Sets the number of discrete levels (gridPoints).
  /// A value of zero indicates a continuous interval.
  set levels(int value) {
    if (value < 2) {
      _levels = 0;
      _next = _nextContinuous;
      _perturb = _perturbContinuous;
    } else {
      _levels = value;
      _next = _nextDiscrete;
      _perturb = _perturbDiscrete;
    }
    dx.updateCache();
  }

  num _nextContinuous() {
    if (_isUpToDate) {
      return _cache;
    } else {
      _isUpToDate = true;
      return _cache =
          Interval.random.nextInRange(start, end, inverseCdf: inverseCdf);
    }
  }

  /// Returns the next random number sampled from
  /// the interval `(start, end)`.
  /// * Note: The interval consists of
  /// [levels] gridPoints that are equidistantly distributed.
  /// * The first gridPoint coincides with [start] the last one with [end].
  /// * Returns a cached value if the cache is up-to-date.
  /// * If the cache is stale an new random number is returned and cached.
  num _nextDiscrete() {
    if (_isUpToDate) {
      return _cache;
    } else {
      _isUpToDate = true;
      final next = Interval.random.nextInRange(
        start,
        end,
        inverseCdf: inverseCdf,
      );
      // If dx == 0 => start == end.
      return _cache =
          (dx() == 0) ? start : start + dx() * ((next - start) / dx()).round();
    }
  }

  /// Internal variable storing the function [next].
  late Next _next = _nextContinuous;

  /// Returns the next random number sampled from
  /// the interval `(start, end)`.
  /// * Returns a cached value if the cache is up-to-date.
  /// * If the cache is stale an new random number is returned and cached.
  num next() => _next();

  num _perturbContinuous(
    num position,
    num deltaPosition,
  ) {
    deltaPosition = deltaPosition.abs();
    final startOverlap = max(position - deltaPosition, start);
    final endOverlap = min(position + deltaPosition, end);
    if (startOverlap > end || endOverlap < start) {
      _isUpToDate = false;
      return double.nan;
    } else {
      _isUpToDate = true;
      return _cache = random.nextInRange(
        startOverlap,
        endOverlap,
        inverseCdf: inverseCdf,
      );
    }
  }

  num _perturbDiscrete(
    num position,
    num deltaPosition,
  ) {
    deltaPosition = deltaPosition.abs();
    final startOverlap = max(position - deltaPosition, start);
    final endOverlap = min(position + deltaPosition, end);
    if (startOverlap > end || endOverlap < start) {
      _isUpToDate = false;
      return double.nan;
    } else {
      _isUpToDate = true;
      final next = random.nextInRange(
        startOverlap,
        endOverlap,
        inverseCdf: inverseCdf,
      );
      return _cache =
          dx() == 0 ? start : start + dx() * ((next - start) / dx()).round();
    }
  }

  /// Internal variable storing the function [perturb].
  late Perturb _perturb = _perturbContinuous;

  /// Returns the next random number sampled from the interval
  /// obtained by intersecting:
  /// `(start, end)` and `(position - deltaPosition, position + deltaPosition)`.
  /// * If the intersection is empty, `double.nan` is returned.
  /// * Returns a cached value if the cache is up-to-date.
  /// * If the cache is stale a new random number is returned and cached.
  num perturb(num position, num deltaPosition) => _perturb(
        position,
        deltaPosition,
      );

  /// Returns true if position is safisfying
  /// `(start <= position && position <= end)`.
  bool contains(num position) => start <= position && position <= end;

  /// Returns true if the interval defined by the points
  /// `left` and `right` overlaps `this`.
  bool overlaps(num left, num right) {
    final start = min(left, right);
    final end = max(left, right);
    if (end < this.start) return false;
    if (start > this.end) return false;
    return true;
  }

  /// Returns the size of the interval.
  num get size => end - start;

  /// Cached random number in interval.
  /// @nodoc
  late num _cache;

  /// Logical flag indicating if `_cache` is up to date.
  bool _isUpToDate = false;

  /// Returns `true` is the cached random numbers are up-to-date.
  bool get isUpToDate => _isUpToDate;

  /// Marks the internal cache as stale. After calling this function
  /// the methods [next] and [perturb] will return a new random number sampled
  /// from the interval `start...end`.
  void updateCache() {
    _isUpToDate = false;
  }

  @override
  String toString() {
    final b = StringBuffer();
    b.writeln('$runtimeType:');
    b.writeln('   name: $name');
    b.writeln('   start: $start');
    b.writeln('   end: $end');
    if (isDiscrete) {
      final gridPoints = this.gridPoints;
      b.write('   discrete: $levels levels: [');
      for (final gridPoint in gridPoints.take(2)) {
        b.write('${gridPoint.toStringAsPrecision(5)}, ');
      }
      if (levels > 2) {
        b.write('..., ${gridPoints.last.toStringAsPrecision(5)}];');
      } else {
        b.write('];');
      }
      b.write(' dx: ${dx().toStringAsPrecision(6)}\n');
    }

    if (_isUpToDate) {
      b.write('   cached next: $_cache');
    } else {
      b.write('   cached next: not set');
    }
    return b.toString();
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
  SingularInterval(num value, {String name = ''})
      : super._(
          value,
          value,
          name: name,
        );

  SingularInterval.of(SingularInterval interval)
      : super._(
          interval.start,
          interval.end,
          name: interval.name,
        );

  /// Returns the singular value `start.
  @override
  num next() => start;

  /// Returns `position` if `start == position`.
  /// Returns `double.nan` otherwise.
  @override
  num perturb(
    num position,
    num deltaPosition,
  ) {
    deltaPosition = deltaPosition.abs();
    if (overlaps(position - deltaPosition, position + deltaPosition)) {
      return start;
    } else {
      return double.nan;
    }
  }

  // @override
  // String toString() {
  //   final b = StringBuffer();
  //   b.writeln('SingularInterval:');
  //   b.writeln('  start: $start');
  //   b.write('  end: $end');
  //   return b.toString();
  // }

  /// Returns `true` if position coincides with `start`.
  @override
  bool contains(num position) => (position == start);
}

/// A fixed numerical interval defined by
/// the start point `start` and the end point `end`.
class FixedInterval extends Interval {
  /// Constructs a fixed interval (`start`, `end`).
  FixedInterval._(num start, num end, {super.inverseCdf, super.name})
      : start = min(start, end),
        end = max(start, end);

  /// Returns an instance of [FixedInterval].
  ///
  /// If `start == end` an instance of [SingularInterval] is returned.
  factory FixedInterval(
    num start,
    num end, {
    InverseCdf? inverseCdf,
    String name = '',
  }) {
    return start == end
        ? SingularInterval(start, name: name)
        : FixedInterval._(
            start,
            end,
            inverseCdf: inverseCdf,
            name: name,
          );
  }

  /// Constructs a copy of `interval`.
  ///
  /// Note: The cache is *not* copied. Each instance of [FixedInterval]
  /// manages its own cache.
  factory FixedInterval.of(FixedInterval interval) {
    if (interval is SingularInterval) {
      return SingularInterval.of(interval);
    } else if (interval is PeriodicInterval) {
      return PeriodicInterval.of(interval);
    } else {
      return FixedInterval(
        interval.start,
        interval.end,
        inverseCdf: interval.inverseCdf,
        name: interval.name,
      );
    }
  }

  /// Start point of the numerical interval.
  @override
  final num start;

  /// End point of the numerical interval.
  @override
  final num end;

  /// Returns the size of the interval.
  @override
  late final num size = end - start;
}

/// An interval that wraps around itself.
///
/// Usage: Defining the interval representing
/// the longitudinal angle of spherical coordinates.
/// Any angle may then be remapped to the interval 0...2pi.
class PeriodicInterval extends FixedInterval {
  PeriodicInterval(super.start, super.end, {super.inverseCdf, super.name})
      : super._();

  PeriodicInterval.of(FixedInterval interval)
      : super._(
          interval.start,
          interval.end,
          inverseCdf: interval.inverseCdf,
          name: interval.name,
        );

  @override
  num _perturbContinuous(
    num position,
    num deltaPosition,
  ) {
    _isUpToDate = true;
    deltaPosition = deltaPosition.abs();
    final next = Interval.random.nextInRange(
      position - deltaPosition,
      position + deltaPosition,
      inverseCdf: inverseCdf,
    );

    if (next < start || next > end) {
      final remainder = next.remainder(size);
      return _cache =
          remainder.isNegative ? end + remainder : start + remainder;
    } else {
      return _cache = next;
    }
  }

  @override
  num _perturbDiscrete(
    num position,
    num deltaPosition,
  ) {
    _isUpToDate = true;
    deltaPosition = deltaPosition.abs();
    var next = Interval.random.nextInRange(
      position - deltaPosition,
      position + deltaPosition,
      inverseCdf: inverseCdf,
    );

    if (next < start || next > end) {
      final remainder = next.remainder(size);
      next = remainder.isNegative ? end + remainder : start + remainder;
    }
    return _cache = start + dx() * ((next - start) / dx()).round();
  }

  @override
  bool overlaps(num left, num right) {
    if (left.isNaN || right.isNaN) {
      return false;
    } else {
      return true;
    }
  }
}

/// A numerical interval defined by
/// the parametric start point function `startFunc` and the end
/// point `endFunc`.
class ParametricInterval extends Interval {
  /// Constructs a parametric interval defined by
  /// the parametric start point function `startFunc` and the end
  /// point function `endFunc`.
  ParametricInterval(
    this.startFunc,
    this.endFunc, {
    super.inverseCdf,
    super.name,
  });

  /// Constructs a copy of [interval].
  ///
  /// Note: Cached variables are not copied.
  ParametricInterval.of(ParametricInterval interval)
      : startFunc = interval.startFunc,
        endFunc = interval.endFunc,
        super(inverseCdf: interval.inverseCdf);

  /// Start point of the numerical interval.
  final ParametricPoint startFunc;

  /// End point of the numerical interval.
  final ParametricPoint endFunc;

  /// Lazy variable with initializer of type [ParametricPoint].
  late final _start = Lazy<num>(startFunc);

  /// Lazy variable with initializer of type [ParametricPoint].
  late final _end = Lazy<num>(endFunc);

  @override
  num get start => min(_start(), _end());

  @override
  num get end => max(_start(), _end());

  @override
  void updateCache() {
    super.updateCache();

    /// Re-initialize lazy variables.
    _start.updateCache();
    _end.updateCache();
    dx.updateCache();
  }

  @override
  String toString() {
    final b = StringBuffer();
    b.writeln('ParametricInterval:');
    b.writeln('   name: $name');
    b.writeln('   current boundaries:');
    b.writeln('   start: ${startFunc()}');
    b.writeln('   end: ${endFunc()}');
    if (isDiscrete) {
      final gridPoints = this.gridPoints;
      b.write('   discrete: $levels levels: [');
      for (final gridPoint in gridPoints.take(2)) {
        b.write('${gridPoint.toStringAsPrecision(5)}, ');
      }
      if (levels > 2) {
        b.write('..., ${gridPoints.last.toStringAsPrecision(5)}];');
      } else {
        b.write('];');
      }
      b.write(' dx: ${dx().toStringAsPrecision(6)}\n');
    }
    if (_isUpToDate) {
      b.write('   cached next: $_cache');
    } else {
      b.write('   cached next: not set');
    }
    return b.toString();
  }
}
