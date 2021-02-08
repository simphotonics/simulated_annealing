##  Search Space - Example
[![Build Status](https://travis-ci.com/simphotonics/simulated_annealing.svg?branch=main)](https://travis-ci.com/simphotonics/simulated_annealing)

The class [`SearchSpace`][SearchSpace] is used to define a region from which points are
randomly sampled. A search space is defined in terms of intervals along each dimension.

The example below demonstrates how to define a ball shaped 3D
search space using cartesian coordinates. (The search space includes the
points situated on the spherical surface as well as the inner points).
The interval `x` is an object of type [`FixedInterval`][FixedInterval] that is
the left and right boundary are constant numbers.
The intervals `y` and `z` are objects of type [`ParametricInterval`][ParametricInterval]
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
// Note: dxMax defaults to the space size. If a smaller initial
//       perturbation magnitude is required it can be specified
//       as a constructor argument.
final space = SearchSpace([x, y, z], dxMin: [1e-6, 1e-6, 1e-6]);

void main() async {
  for (var i = 0; i < 10; i++) {
    print(space.estimateSize());
  }

  final xTest = [1.2, 1.0, 0.6];
  final dx = [0.6, 0.6, 0.6];

  final sample = List<List<num>>.generate(2000, (_) => space.next());

  final perturbation = List<List<num>>.generate(
      500, (_) => space.perturb(xTest, dx));

  await File('../data/spherical_search_space.dat').writeAsString(
    sample.export(),
  );
  await File('../data/spherical_search_space_perturbation.dat').writeAsString(
    perturbation.export(),
  );

  await File('../data/spherical_search_space_center_point.dat')
      .writeAsString('''
    # Perturbation Centerpoint
    ${[xTest].export()}''');

  // The search space can be visualized by navigating to the folder
  // 'example/gnuplot_scripts' and running the commands:
  // # gnuplot
  // gnuplot> load 'spherical_search_space.gp'
}


```
</details>

The figure below (left) shows 2000 random points sampled from the spherical search space.
The point were generated using the method `next` provided by the class [`SearchSpace`][SearchSpace].

The (red) test point **x**<sub>test</sub> has coordinates \[1.2, 1.0, 1.6\].
The green dots represent points sampled for a neighbourhood **x**<sub>test</sub> &pm; **dx** around **x**<sub>test</sub>,
where **dx**&nbsp;=&nbsp;\[0.6, 0.6, 0.6\] are the perturbation magnitudes along each dimension.
These points were generated using the method `perturb`.

Notice that the perturbation neighbourhood does not extend beyond the margins of the
search space. If the search space does not intersect the region **x**<sub>test</sub> &pm; **dx**,
**x**<sub>test</sub> is returned unperturbed.

![Spherical Search Space](https://raw.githubusercontent.com/simphotonics/simulated_annealing/main/example/plots/spherical_space.png)
![Hemispheric Search Space](https://raw.githubusercontent.com/simphotonics/simulated_annealing/main/example/plots/hemispherical_search_space.png)

The figure above (right) shows 2000 random points sampled from a hemispheric search space. The
program used to generate the data points is listed in the file [hemispheric_search_space_example.dart][hemispheric_search_space_example].


## Search Spaces With a Uniform Probability Distribution

When constructing a search space using parametric intervals the resulting multi-dimensional probability distribution function (PDF) should be carefully examined with respect to its uniformity.
In the context of simulated annealing, it is advisable to
use a search space where each point is equally likely to be chosen.

The examples below aim to demonstrate the problem and its solution.

### Triangular Search Space

A triangular search space can be defined with the following lines of code:
```Dart
final gradient = 15.0;
final x = FixedInterval(0, 10);
final y = ParametricInterval(
      () => gradient * x.next(), () => gradient * x.next());
// Defining a spherical search space.
final triangularSpace = SearchSpace([x, y], dxMin: [1e-6, 1e-6]);
```
The left figure in the image below shows 2000 points randomly selected from the triangular search space (magneta dots).
There is an aggreggation of points towards the left side of the search space boundary indicating that the 2D PDF of the search_space `triangularSpace`
is not uniform.

![Triangular Search Space](https://raw.githubusercontent.com/simphotonics/simulated_annealing/main/example/plots/triangular_search_space.png)
![Inverse CDF of a uniform PDF](https://raw.githubusercontent.com/simphotonics/simulated_annealing/main/example/plots/inverseCdfUniform.png)

The clustering of points on the left is a result of the uniform PDF of `x`. For a sufficiently large sample, the number of points with the x-coordinate between 0 and 1
is approximately equal to the number of points
with the x-coordinate between 9 and 10.

Whenever,
an `Interval` is constructed without providing an argument for the parameter: `inverseCdf`, it is implicitly assumed that the values are distributed uniformly between the left and right
interval boundaries and the inverse cummulative distribution function (iCDF) is of the form:

cdf<sup>-1</sup>(p,&nbsp;x<sub>min</sub>,&nbsp;x<sub>max</sub>) = x<sub>min</sub> + (x<sub>max</sub> - x<sub>min</sub>)&middot;p.

The graph on the right above shows the implicit iCDF of the interval `x` for different interval
boundaries.



In order to make the 2D-PDF of the triangular search space uniform we need to provide a suitable iCDF when creating the interval `x`.
It is clear that the PDF of `x` must satisfy the conditions: pdf(x <= x<sub>min</sub>) = 0 and  pdf(x > x<sub>max</sub>) = 0, since these are the limits of the interval.
Further, assuming that the PDF increases linearly from 0 and is normalized we arrive at:

pdf(x, x<sub>min</sub>, x<sub>max</sub>) = 2&middot;(x - x<sub>min</sub>)/(x<sub>max</sub> - x<sub>min</sub>)<sup>2</sup>.

From this it follows that the cummulative distribution function (CDF) is:
cdf(x, x<sub>min</sub>, x<sub>max</sub>)&nbsp;=&nbsp;(x&nbsp;-&nbsp;x<sub>min</sub>)<sup>2</sup>/(x<sub>max</sub> - x<sub>min</sub>)<sup>2</sup> and the
inverse cummulative distribution function is:

cdf<sup>-1</sup>(p, x<sub>min</sub>, x<sub>max</sub>) = x<sub>min</sub> + (x<sub>max</sub> - x<sub>min</sub>)&middot;&Sqrt;p.

The iCDF derived above is shown on the right in the image below. It ensures that values of `x` that are
closer to zero are less likely to be selected.
The corrected triangular space can be instantiated with the following lines of code:
```Dart
/// The inverse CDF of the interval x.
double inverseCDF(num p, num xMin, num xMax) => xMin + (xMax - xMin) * sqrt(p);

final gradient = 15.0;
final x = FixedInterval(0, 10, inverseCdf: inverseCdf);
final y = ParametricInterval(
      () => gradient * x.next(), () => gradient * x.next());
// Defining a spherical search space.
final triangularSpace = SearchSpace([x, y], dxMin: [1e-6, 1e-6]);
```
Inspecting the plot on the left in the figure below it is apparent that the random points are distributed uniformly across the search space.
![Triangular Search Space Uniform PDF](https://raw.githubusercontent.com/simphotonics/simulated_annealing/main/example/plots/triangular_search_space_uniform.png)
![Inverse CDF of a linear PDF](https://raw.githubusercontent.com/simphotonics/simulated_annealing/main/example/plots/inverseCdfLinear.png)


###  Spherical Search Space.

The first section showed how to use parametric intervals to define a ball shaped search space using
Cartesian coordinates. A spherical search space can also be defined in terms of
spherical coordinates. In that case we keep the radius constant and define one interval
for the azimuthal angle &phi; and one for the polar angle &theta;:
```Dart
// Define intervals.
final radius = 2;
final phi = FixedInterval(0, 2 * pi);
final theta = FixedInterval(0, pi);

// Defining a spherical search space.
final space = SearchSpace([phi, theta], dxMin: [1e-6, 1e-6, 1e-6]);
```
The figure below shows 2000 points randomly selected from the search space.
It is evident that there is an aggregation of points around the polar areas.
The graphs on the
right show the iCDF used for the interval &theta;.


![Spherical Surface](https://raw.githubusercontent.com/simphotonics/simulated_annealing/main/example/plots/spherical_space_surface.png)
![Inverse CDF of Theta](https://raw.githubusercontent.com/simphotonics/simulated_annealing/main/example/plots/inverseCdfThetaUniform.png)


 In order to correct the 2-dimensional spherical PDF we have to explicitly specify an iCDF when creating the interval `theta`. The corrected iCDF of theta take the form:

 cdf<sup>-1</sup>(p, theta<sub>min</sub>, theta<sub>max</sub>) = arccos( p &middot; ( cos(theta<sub>min</sub>) - cos(theta<sub>max</sub>) ) - cos(theta<sub>min</sub>) ).

 To derive the formula above one starts with the surface area: dA = d&phi; d&theta; sin(&theta;) of the sphere with unity radius to
 construct the PDF then the CDF and final the iCDF.


```Dart
double inverseCdf(num p, num thetaMin, num thetaMax) {
  final cosThetaMin = cos(thetaMin);
  return acos(-p * (cosThetaMin - cos(thetaMax)) + cosThetaMin);
}
// Define intervals.
final radius = 2;
final phi = FixedInterval(0, 2 * pi, inverseCdf: inverseCdf);
final theta = FixedInterval(0, pi);

// Defining a spherical search space.
final space = SearchSpace([phi, theta], dxMin: [1e-6, 1e-6, 1e-6]);
```

 The figure below shows 2000 points randomly selected from the search space with a uniform 2D PDF.
 The graphs on the right shows a plot of the iCDF for different boundaries theta<sub>min</sub>
 and theta<sub>max</sub>.

 ![Spherical Surface](https://raw.githubusercontent.com/simphotonics/simulated_annealing/main/example/plots/spherical_space_surface_uniform.png)
![Inverse CDF of Theta](https://raw.githubusercontent.com/simphotonics/simulated_annealing/main/example/plots/inverseCdfTheta.png)


## Features and bugs
Please file feature requests and bugs at the [issue tracker].

[issue tracker]: https://github.com/simphotonics/simulated_annealing/issues

[SearchSpace]: https://pub.dev/documentation/simulated_annealing/latest/simulated_annealing/SearchSpace-class.html

[FixedInterval]: https://pub.dev/documentation/simulated_annealing/latest/simulated_annealing/FixedInterval-class.html

[ParametricInterval]: https://pub.dev/documentation/simulated_annealing/latest/simulated_annealing/ParametricInterval-class.html

[hemispheric_search_space_example.dart]:bin/hemispheric_search_space_example.dart
