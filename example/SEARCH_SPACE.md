##  Search Space - Example
[![Build Status](https://travis-ci.com/simphotonics/simulated_annealing.svg?branch=main)](https://travis-ci.com/simphotonics/simulated_annealing)

The class [`SearchSpace`][SearchSpace] is used to define a region from which points are
randomly sampled. A search space is defined in terms of intervals along each dimension.

The example below demonstrates how to define a
**spherical** search space using cartesian coordinates.
The interval `x` is an object of type [`FixedInterval`][FixedInterval] that is
the left and right boundary are constant numbers. The intervals `y` and `z` are objects of type [`ParametricInterval`][ParametricInterval]
and their boundaries are specified in terms of a numerical function that depends on other
intervals.

<details><summary> Click to show source code.</summary>

```Dart
import 'dart:io';
import 'dart:math';

import 'package:list_operators/list_operators.dart';
import 'package:simulated_annealing/simulated_annealing.dart';

// Define intervals.
final radius = 2;
var x = FixedInterval(-radius, radius);
final y = ParametricInterval(
  () => -sqrt(pow(radius, 2) - pow(x.next(), 2)),
  () => sqrt(pow(radius, 2) - pow(x.next(), 2)),
);
final z = ParametricInterval(
  () => -sqrt(pow(radius, 2) - pow(y.next(), 2) - pow(x.next(), 2)),
  () => sqrt(pow(radius, 2) - pow(y.next(), 2) - pow(x.next(), 2)),
);

// Defining a spherical search space.
final space = SearchSpace([x, y, z], dxMin: [1e-6, 1e-6, 1e-6]);

void main() async {
  for (var i = 0; i < 10; i++) {
    print(space.estimateSize());
  }

  final testPoint = [1.2, 1.0, 0.6];
  final magnitudes = [0.6, 0.6, 0.6];

  final sample = List<List<num>>.generate(2000, (_) => space.next());

  final perturbation = List<List<num>>.generate(
      500, (_) => space.perturb(testPoint, magnitudes));

  await File('../data/spherical_search_space.dat').writeAsString(
    sample.export(),
  );
  await File('../data/spherical_search_space_perturbation.dat').writeAsString(
    perturbation.export(),
  );

  await File('../data/spherical_search_space_center_point.dat')
      .writeAsString('''
    # Perturbation Centerpoint
    ${[testPoint].export()}''');

  // The search space can be visualized by navigating to the folder
  // 'example/gnuplot_scripts' and running the commands:
  // # gnuplot
  // gnuplot> load 'spherical_search_space.gp'
}


```
</details>

![Spherical Search Space](https://raw.githubusercontent.com/simphotonics/simulated_annealing/main/example/plots/spherical_space.jpg)


The figure below shows 2000 random points sampled from the spherical search space.
The point were generated using the method `next` provided by the class [`SearchSpace`][SearchSpace].

The (red) test point T<sub>test</sub> has coordinates (1.2, 1.0, 1.6).
The green dots represent points sampled for a neighbourhood T<sub>test</sub> &pm; m around T<sub>test</sub>, where m&nbsp;=&nbsp;(0.4, 0.4, 0.4) are the perturbation magnitudes along each dimension.
These points were generated using the method `perturb`.

Notice that the perturbation neighbourdood does not extend beyond the margins of the
search space. If the search space does not intersect the region T<sub>test</sub> &pm; m,
T<sub>test</sub> is returned unperturbed.


## Features and bugs
Please file feature requests and bugs at the [issue tracker].

[issue tracker]: https://github.com/simphotonics/simulated_annealing/issues

[SearchSpace]: https://pub.dev/documentation/simulated_annealing/latest/simulated_annealing/SearchSpace-class.html

[FixedInterval]: https://pub.dev/documentation/simulated_annealing/latest/simulated_annealing/FixedInterval-class.html

[ParametricInterval]: https://pub.dev/documentation/simulated_annealing/latest/simulated_annealing/ParametricInterval-class.html
