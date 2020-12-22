##  Simulated Annealing - Example

Simulated annealing (SA) is typically used to solve discrete optimisation problems. But the algorithm can be adapted to minimize continuous functions. The example below demonstrates how
to find the global minimum of the function:

E(**x**) = 4.0 - 4.0&middot;e<sup>-4&middot;|**x** - **x**<sub>glob</sub>|</sup> - 2.0&middot; e<sup>-6*&middot;|**x** - **x**<sub>loc</sub>|</sup>

where the distance between the vectors **x** and **y** is given by |**x** - **y**| = &#8730; ( &sum;<sub> i</sub><sup>3</sup> (x<sub>i</sub> - y<sub>i</sub>)<sup>2</sup> ).

![Energy Function](https://raw.githubusercontent.com/simphotonics/simulated_annealing/main/example/plots/energy2d.svg?sanitize=true)


The figure above shows a projection of E onto the x-y plane. The global minimum of E
is situated at **x**<sub>glob</sub> = (0.5, 0.7, 0.8). A local minimum occurs at **x**<sub>loc</sub> = (-1, -1, -0.5).

<details><summary> Click to show source code.</summary>

```Dart

```
</details>


## Features and bugs
Please file feature requests and bugs at the [issue tracker].

[issue tracker]: https://github.com/simphotonics/simulated_annealing/issues

[SearchSpace]: https://pub.dev/documentation/simulated_annealing/latest/simulated_annealing/SearchSpaceClass.html

[FixedInterval]: https://pub.dev/documentation/simulated_annealing/latest/simulated_annealing/FixedIntervalClass.html

[ParametricInterval]: https://pub.dev/documentation/simulated_annealing/latest/simulated_annealing/ParametricIntervalClass.html
