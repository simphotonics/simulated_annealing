import 'dart:io';

import 'package:simulated_annealing/simulated_annealing.dart';

void main() async {
  // The sampling space is assumed to be 3-dimensional with sizes [2.0, 2.0, 2.0].
  final dxMax = [2.0, 2.0, 2.0];

  // The neighbourhood size at the end of the annealing process.
  final dxMin = [1e-6, 1e-6, 1e-6];

  // Defining an annealing schedule.
  // The initial temperature is 100, the final temperature is 1e-8.
  final schedule = AnnealingSchedule(
    exponentialSequence(100, 1e-8, n: 750),
    dxMax,
    dxMin,
  );

  // The perturbation magnitudes as a function of the temperature.
  // Calculated here and exported to a file in order to visualize them.
  final dx =
      schedule.temperatures.map<List<num>>((t) => schedule.dx(t)).toList();

  await File('../data/dx.dat').writeAsString(
    dx.export(),
  );

  await File('../data/temperatures.dat')
      .writeAsString(schedule.temperatures.export(label: '# Temperatures'));
}
