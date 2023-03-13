#  Search Space - Example
[![Dart](https://github.com/simphotonics/simulated_annealing/actions/workflows/dart.yml/badge.svg)](https://github.com/simphotonics/simulated_annealing/actions/workflows/dart.yml)


## Introduction

[Simulated annealing][SA-Wiki] (SA) is an algorithm aimed at finding
the *global* minimum
of a function E(x<sub>0</sub>,&nbsp;x<sub>1</sub>,&nbsp;...,&nbsp;x<sub>n</sub>)
for a given region &omega;(x<sub>0</sub>,&nbsp;x<sub>1</sub>,&nbsp;...,&nbsp;x<sub>n</sub>).

SA relies heavily on sampling random points from the region &omega;.
In the sections below show how to construct objects of type
[`SearchSpace`][SearchSpace].

## Terminology

An **interval** is a numerical interval defined by a its boundaries.
The base class of all intervals is ['Interval'][Interval].
- **start**: The left boundary of an interval.
- **end**: The right boundary of an interval.
- **continuous** interval: An interval that includes *start*, *end*, and
all points *between* the boundaries.
- **discrete** interval: An interval that includes *start*, *end*,
as well as a fixed number of points between the boundaries located along an
equidistant grid. To make an interval discrete one has to set the instance
variable `levels` to an integer larger than two.
- **fixed** interval: An interval with numerical boundaries,
see [`FixedInterval`][FixedInterval].
- **singular** interval: A fixed interval that includes a single point, see
[`SingularInterval`][SingularInterval].
- **periodic** interval: A fixed interval that wraps around itself. Periodic
intervals are useful when defining intervals representing angles
e.g. the polar angle of spherical
coordinates or the azimuth of cylindrical coordinates.
- **parametric** interval: An interval with boundaries that depend on other
interval boundaries: see [`ParametricInterval`][ParametricInterval].

A **search space** consists of one or several *intervals*. A *point* belonging
to a search space is defined as a list of coordinates.
The class [`SearchSpace`][SearchSpace] provides methods
for sampling random points from the entire space or
from a region surrounding a given point.

The example below demonstrates how to define a ball shaped 3D
search space using spherical coordinates. The search space includes the
points situated on the spherical surface as well as the inner points.
Note: The function shown below is available as a static function of
the class [`SearchSpace`][SearchSpace].

<details><summary> Click to show source code.</summary>

```Dart
SearchSpace sphere({
    num rMin = 0,
    num rMax = 1,
    num thetaMin = 0,
    num thetaMax = pi,
    num phiMin = 0,
    num phiMax = 2 * pi,
}) {
  // Define intervals.
  final r = FixedInterval(rMin, rMax, name: 'radius <r>');
  final theta = FixedInterval(
    thetaMin,
    thetaMax,
    inverseCdf: InverseCdfs.polarAngle,
    name: 'polar angle <theta>',
  );
  final phi = (phiMin == phiMax)
      ? SingularInterval(phiMin, name: 'azimuth <phi>')
      : PeriodicInterval(phiMin, phiMax, name: 'azimuth <phi>');
  // Defining a spherical search space.
  return SearchSpace.fixed([r, theta, phi],name: 'sphere');
}

```
</details>

The figure below (left) shows 2000 random points generated using the
method `next()` provided by the class [`SearchSpace`][SearchSpace].

The (red) test point **x**<sub>test</sub> has coordinates \[1.2, 1.0, 1.6\].
The green dots represent points sampled for a
neighbourhood **x**<sub>test</sub> &pm; **deltaPosition** around **x**<sub>test</sub>,
where **deltaPosition**&nbsp;=&nbsp;\[0.6, 0.6, 0.6\] are the perturbation magnitudes along each dimension.
These points were generated using the method `perturb`.

Notice that the perturbation neighbourhood does not extend beyond the margins of the
search space. If the search space does not intersect the region **x**<sub>test</sub> &pm; **deltaPosition**,
**x**<sub>test</sub> is returned **unperturbed**.

![Spherical Search Space](https://raw.githubusercontent.com/simphotonics/simulated_annealing/main/images/spherical_space.png)
![Hemispheric Search Space](https://raw.githubusercontent.com/simphotonics/simulated_annealing/main/images/hemispherical_space.png)

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
final triangularSpace = SearchSpace([x, y]);
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

NOTE: When an `Interval` is constructed without providing an argument for the parameter: `inverseCdf`, it is implicitly assumed that the values are distributed **uniformly** between the left and right
interval boundaries and the inverse cummulative distribution function (iCDF) is of the form:

cdf<sup>-1</sup>(p,&nbsp;x<sub>min</sub>,&nbsp;x<sub>max</sub>) = x<sub>min</sub> + (x<sub>max</sub> - x<sub>min</sub>)&middot;p &nbsp;&nbsp;&nbsp;where p &in; \[0, 1\].

The function iCDF maps a number in the interval \[0, 1\) to a number in the interval \[x<sub>min</sub>, x<sub>max</sub>\).
The graph on the right above shows the *implicit* iCDF of the interval `x` for different interval
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

A triangular space with uniformly distributed points can be instantiated with the following lines of code:
```Dart
/// The inverse CDF of the interval x.
double inverseCDF(num p, num xMin, num xMax) => xMin + (xMax - xMin) * sqrt(p);

final gradient = 15.0;
final x = FixedInterval(0, 10, inverseCdf: inverseCdf);
final y = ParametricInterval(
      () => gradient * x.next(), () => gradient * x.next());
// Defining a spherical search space.
final triangularSpace = SearchSpace([x, y]);
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
final space = SearchSpace([phi, theta]);
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

[SingularInterval]: https://pub.dev/documentation/simulated_annealing/latest/simulated_annealing/SingularInterval-class.html


[ParametricInterval]: https://pub.dev/documentation/simulated_annealing/latest/simulated_annealing/ParametricInterval-class.html

[hemispherical_search_space_example.dart]: bin/hemispherical_search_space_example.dart

[SA-Wiki]: https://en.wikipedia.org/wiki/Simulated_annealing