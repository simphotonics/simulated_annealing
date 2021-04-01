#  Search Space - Example
[![Build Status](https://travis-ci.com/simphotonics/simulated_annealing.svg?branch=main)](https://travis-ci.com/simphotonics/simulated_annealing)

## Usage

The class [`SearchSpace`][SearchSpace] can be used to define multi-dimensional regions
from which points are randomly sampled.
A search space is defined in terms of intervals along each dimension.

The example below demonstrates how to define a ball shaped 3D
search space using cartesian coordinates. The search space includes the
points situated on the spherical surface as well as the inner points.

The interval representing the first dimension, `x`,
is an object of type [`FixedInterval`][FixedInterval] that is
the left and right boundary are constant numbers.
The intervals `y` and `z` are objects of type [`ParametricInterval`][ParametricInterval]
and their boundaries are specified in terms of a numerical function that depends on other
intervals.

**Important**: When constructing an object of type [`SearchSpace`][SearchSpace]
parameteric intervals must be listed in order of dependence. In the example shown
below interval `x` is independent, while `y` depends on `x` and `z` depends on `x` and `y`.
For this reason the variable `space` is initialized using the
following line of source code:
```Dart
final space = SearchSpace([x, y, z]);
```

<details><summary> Click to show source code.</summary>

```Dart
import 'dart:io';
import 'dart:math';

import 'package:list_operators/list_operators.dart';
import 'package:simulated_annealing/simulated_annealing.dart';

// Define intervals.
final radius = 2;
final x = FixedInterval(-radius, radius);

num yLimit() => sqrt(pow(radius, 2) - pow(x.next(), 2));
final y = ParametricInterval(() => -yLimit(), yLimit);

num zLimit() => sqrt(pow(radius, 2) - pow(y.next(), 2) - pow(x.next(), 2));
final z = ParametricInterval(() => -zLimit(), zLimit);
final space = SearchSpace([x, y, z]);

void main() async {
  final xTest = [1.2, 1.0, 0.6];
  final dPosition = [0.6, 0.6, 0.6];

  final sample = List<List<num>>.generate(2000, (_) => space.next());

  final perturbation = List<List<num>>.generate(
      500, (_) => space.perturb(xTest, dPosition));

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

The figure below (left) shows 2000 random points generated using the method `next` provided by the class [`SearchSpace`][SearchSpace].

The (red) test point **x**<sub>test</sub> has coordinates \[1.2, 1.0, 1.6\].
The green dots represent points sampled for a neighbourhood **x**<sub>test</sub> &pm; **dPosition** around **x**<sub>test</sub>,
where **dPosition**&nbsp;=&nbsp;\[0.6, 0.6, 0.6\] are the perturbation magnitudes along each dimension.
These points were generated using the method `perturb`.

Notice that the perturbation neighbourhood does not extend beyond the margins of the
search space. If the search space does not intersect the region **x**<sub>test</sub> &pm; **dPosition**,
**x**<sub>test</sub> is returned **unperturbed**.

![Spherical Search Space](https://raw.githubusercontent.com/simphotonics/simulated_annealing/main/example/plots/spherical_search_space.png)
![Hemispheric Search Space](https://raw.githubusercontent.com/simphotonics/simulated_annealing/main/example/plots/hemispherical_search_space.png)

The figure above (right) shows 2000 random points sampled from a hemispheric search space. The
program used to generate the points is listed in the file [hemispherical_search_space_example.dart][hemispherical_search_space_example.dart].


## Search Spaces With a Uniform Probability Distribution

In the context of simulated annealing, it is advisable to
use a search space where each point is equally likely to be chosen.

When constructing a search space using parametric intervals
the resulting multi-dimensional probability distribution
function (PDF) might be **non-uniform** even if the
intervals along each dimension have a uniform PDF.

The examples below aim to demonstrate the problem and its solution.

### Triangular Search Space

A simple triangular search space can be defined with the following lines of code:
```Dart
final gradient = 15.0;
final x = FixedInterval(0, 10);
final y = ParametricInterval(
      () => gradient * x.next(), () => gradient * x.next());
// Defining a spherical search space.
final triangularSpace = SearchSpace([x, y], dPositionMin: [1e-6, 1e-6]);
```
The left figure in the image below shows 2000 points randomly selected from the triangular search space (magenta coloured dots).
There is an aggreggation of points towards the left side of the search space boundary indicating that the 2D PDF of the search_space `triangularSpace` is non-uniform.

![Triangular Search Space](https://raw.githubusercontent.com/simphotonics/simulated_annealing/main/example/plots/triangular_search_space.png)
![Inverse CDF of a uniform PDF](https://raw.githubusercontent.com/simphotonics/simulated_annealing/main/example/plots/inverseCdfUniform.png)

The non-uniform distribution of points along the search space is related to the
uniform distribution of the interval `x`. For a sufficiently large sample, the number of points with x-coordinate between 0 and 1 is approximately equal to the number of points with x-coordinate between 9 and 10.
However, the size along the vertical dimension of the triangular space decreases linearly from the right to
the left leading to an clustering of points as x approaches 0.

---

NOTE: Whenever, an `Interval` is constructed without providing an argument for the parameter: `inverseCdf`, it is implicitly assumed that the values are distributed **uniformly** between the left and right
interval boundaries and the inverse cummulative distribution function (iCDF) is of the form:

cdf<sup>-1</sup>(p,&nbsp;x<sub>min</sub>,&nbsp;x<sub>max</sub>) = x<sub>min</sub> + (x<sub>max</sub> - x<sub>min</sub>)&middot;p &nbsp;&nbsp;&nbsp;where p &in; \[0, 1\].

The iCDF is the function used internally to select the next random value.
The graph on the right above shows the implicit iCDF of the interval `x` for different interval
boundaries.

---


In order to render the 2D-PDF of the triangular search space uniform we need to provide a suitable iCDF when creating the interval `x`.
It is clear that the PDF of `x` must satisfy the conditions: pdf(x < x<sub>min</sub>) = 0 and  pdf(x > x<sub>max</sub>) = 0, since these are the limits of the interval.
Further, assuming that the PDF increases linearly from 0 and is normalized we arrive at:

pdf(x, x<sub>min</sub>, x<sub>max</sub>) = 2&middot;(x - x<sub>min</sub>)/(x<sub>max</sub> - x<sub>min</sub>)<sup>2</sup>.

From this it follows that the cummulative distribution function (CDF) defined as cdf(x) = &int;<sup>&#8339;</sup><sub>-&infin;</sub> pdf(x&grave;) dx&grave; is:

cdf(x, x<sub>min</sub>, x<sub>max</sub>)&nbsp;=&nbsp;(x&nbsp;-&nbsp;x<sub>min</sub>)<sup>2</sup>/(x<sub>max</sub> - x<sub>min</sub>)<sup>2</sup>

and the inverse cummulative distribution function given by:

cdf<sup>-1</sup>(p, x<sub>min</sub>, x<sub>max</sub>) = x<sub>min</sub> + (x<sub>max</sub> - x<sub>min</sub>)&middot;&Sqrt;p &nbsp;&nbsp;&nbsp;where p &in; \[0, 1\].

![Triangular Search Space Uniform PDF](https://raw.githubusercontent.com/simphotonics/simulated_annealing/main/example/plots/triangular_search_space_uniform.png)
![Inverse CDF of a linear PDF](https://raw.githubusercontent.com/simphotonics/simulated_annealing/main/example/plots/inverseCdfLinear.png)

The iCDF for the x-coordinate is shown on the right in the image above. It ensures that values of `x` that are
closer to zero are less likely to be selected.

The triangular space can be instantiated with the following lines of code:
```Dart
/// The inverse CDF of the interval x.
double inverseCDF(num p, num xMin, num xMax) => xMin + (xMax - xMin) * sqrt(p);

final gradient = 15.0;
final x = FixedInterval(0, 10, inverseCdf: inverseCdf);
final y = ParametricInterval(
      () => gradient * x.next(), () => gradient * x.next());
// Defining a spherical search space.
final triangularSpace = SearchSpace([x, y], dPositionMin: [1e-6, 1e-6]);
```
The left figure above shows 2000 points randomly selected using the function `triangularSpace.next()`.
It is apparent that the random points are distributed uniformly across the search space.



###  Spherical Search Space.

The first section showed how to use parametric intervals to define a ball shaped search space using
Cartesian coordinates. A spherical search space can also be defined in terms of
spherical coordinates. In this case, we keep the radius constant and define one interval
for the azimuthal angle &phi; and one for the polar angle &theta;:
```Dart
// Define intervals.
final radius = 2;
final phi = FixedInterval(0, 2 * pi);
final theta = FixedInterval(0, pi);

// Defining a spherical search space.
final space = SearchSpace([phi, theta]);
```
The figure below shows 2000 points randomly selected from the search space.
It is evident that there is an aggregation of points around the polar areas.
The graphs on the
right show the iCDF used for the interval &theta;.


![Spherical Surface](https://raw.githubusercontent.com/simphotonics/simulated_annealing/main/example/plots/spherical_space_surface.png)
![Inverse CDF of Theta](https://raw.githubusercontent.com/simphotonics/simulated_annealing/main/example/plots/inverseCdfThetaUniform.png)


In order to correct the 2-dimensional spherical PDF we have to explicitly specify an iCDF when creating the interval `theta`. The corrected iCDF of theta takes the form:

cdf<sup>-1</sup>(p, theta<sub>min</sub>, theta<sub>max</sub>) = arccos( p &middot; ( cos(theta<sub>min</sub>) - cos(theta<sub>max</sub>) ) - cos(theta<sub>min</sub>) ).

To derive the formula above one starts with the surface area: dA = d&phi; d&theta; sin(&theta;) of the sphere with unity radius to
construct the PDF then the CDF and finally the iCDF.

The spherical search space can be constructed with the following lines of code:
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
final space = SearchSpace([phi, theta], dPositionMin: [1e-6, 1e-6, 1e-6]);
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

[hemispherical_search_space_example.dart]: bin/hemispherical_search_space_example.dart
