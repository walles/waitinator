import 'dart:math';

import 'package:meta/meta.dart';
import 'estimate.dart';
import 'observation.dart';

const _percentile = 90;
const _samples = 100;

/// Gets the last observation. If there are multiple observations at the end
/// with the same number though, pick the first of those.
///
/// This way our estimation algorithm of considering any observation being up to
/// almost one number off will still work. If we took the latest ones, that
/// won't hold any more.
@visibleForTesting
Observation? getLastObservation(List<Observation> observations) {
  if (observations.length < 2) {
    return null;
  }

  var lastIndex = observations.length - 1;
  while (true) {
    var nextToLastIndex = lastIndex - 1;
    if (nextToLastIndex < 0) {
      return null;
    }

    if (observations[nextToLastIndex].position !=
        observations[lastIndex].position) {
      return observations[lastIndex];
    }

    lastIndex--;
  }
}

Estimate? estimate(List<Observation> observations, int target) {
  final first = observations[0];
  final last = getLastObservation(observations);
  if (last == null) {
    return null;
  }

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
