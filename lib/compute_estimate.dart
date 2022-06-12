import 'dart:math';

import 'estimate.dart';
import 'observation.dart';

const _percentile = 90;
const _samples = 100;

Estimate estimate(List<Observation> observations, int target) {
  final first = observations[0];
  final last = observations.last;
  final firstLastDtMillis =
      last.timestamp.difference(first.timestamp).inMilliseconds;
  final direction = first.position < target ? 1 : -1;

  final List<double> msLeftSamples = [];
  final random = Random();
  for (var i = 0; i < _samples; i = i + 1) {
    // Let's say we're going to 100, and the user reports 53. We still don't
    // know whether the number just switched to 53, or whether it was just about
    // to go to 54. Therefore we add a random bonus to the reported numbers.
    final firstPosition = first.position + random.nextDouble() * direction;
    final lastPosition = last.position + random.nextDouble() * direction;

    final velocityMillisecondsPerNumber =
        firstLastDtMillis / (lastPosition - firstPosition).abs();
    final distanceLeft = (target - lastPosition).abs();
    final msLeft = distanceLeft * velocityMillisecondsPerNumber;

    msLeftSamples.add(msLeft);
  }

  msLeftSamples.sort();
  final samplesToIgnore = ((100 - _percentile) * msLeftSamples.length) ~/ 100;
  final samplesToIgnoreAtEachEnd = samplesToIgnore ~/ 2;
  final lowSample = msLeftSamples[samplesToIgnoreAtEachEnd];
  final highIndex = msLeftSamples.length - 1 - samplesToIgnoreAtEachEnd;
  final highSample = msLeftSamples[highIndex];

  return Estimate(
      observations[0].timestamp,
      DateTime.now().add(Duration(milliseconds: lowSample.round())),
      DateTime.now().add(Duration(milliseconds: highSample.round())),
      target);
}
