import 'dart:math';

import 'package:meta/meta.dart';
import 'package:waitinator/eta_state.dart';
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
Observation? getLastObservation(EtaState state) {
  if (state.length < 2) {
    return null;
  }

  var lastIndex = state.length - 1;
  while (true) {
    var nextToLastIndex = lastIndex - 1;
    if (nextToLastIndex < 0) {
      return null;
    }

    if (state[nextToLastIndex].position != state[lastIndex].position) {
      return state[lastIndex];
    }

    lastIndex--;
  }
}

Estimate? computeEstimate(EtaState state) {
  final first = state[0];
  final last = getLastObservation(state);
  if (last == null) {
    return null;
  }

  final firstLastDtMillis =
      last.timestamp.difference(first.timestamp).inMilliseconds;

  final List<double> msFromStartSamples = [];
  final random = Random();
  for (var i = 0; i < _samples; i = i + 1) {
    // Let's say we're going to 100, and the user reports 53. We still don't
    // know whether the number just switched to 53, or whether it was just about
    // to go to 54. Therefore we add a random bonus to the reported numbers.
    final firstPosition =
        first.position + random.nextDouble() * state.direction;
    final lastPosition = last.position + random.nextDouble() * state.direction;

    final velocityMillisecondsPerNumber =
        firstLastDtMillis / (lastPosition - firstPosition).abs();
    final distanceFromStart = (state.target - firstPosition).abs();
    final msFromStart = distanceFromStart * velocityMillisecondsPerNumber;

    msFromStartSamples.add(msFromStart);
  }

  msFromStartSamples.sort();
  final samplesToIgnore =
      ((100 - _percentile) * msFromStartSamples.length) ~/ 100;
  final samplesToIgnoreAtEachEnd = samplesToIgnore ~/ 2;
  final lowMsFromStart = msFromStartSamples[samplesToIgnoreAtEachEnd];
  final highIndex = msFromStartSamples.length - 1 - samplesToIgnoreAtEachEnd;
  final highMsFromStart = msFromStartSamples[highIndex];

  return Estimate(
      state[0].timestamp,
      state[0].timestamp.add(Duration(milliseconds: lowMsFromStart.round())),
      state[0].timestamp.add(Duration(milliseconds: highMsFromStart.round())),
      state.target);
}
