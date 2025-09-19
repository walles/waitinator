import 'dart:math';

import 'package:meta/meta.dart';
import 'package:waitinator/eta_state.dart';
import 'estimate_renderer.dart';
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

class _Sample {
  final double msFromStart;
  final double msPerIteration;
  _Sample(this.msFromStart, this.msPerIteration);
}

EstimateRenderer? computeEstimate(EtaState state) {
  final firstObservation = state[0];
  final lastObservation = getLastObservation(state);
  if (lastObservation == null) {
    return null;
  }

  final firstLastDtMillis = lastObservation.timestamp
      .difference(firstObservation.timestamp)
      .inMilliseconds;

  // A list of estimates of how many milliseconds it will take to get from the
  // initial timestamp to the target number.
  final List<_Sample> msFromStartSamples = [];
  final random = Random();
  for (var i = 0; i < _samples; i = i + 1) {
    // Let's say we're going to 100, and the user reports 53. We still don't
    // know whether the number just switched to 53, or whether it was just about
    // to go to 54. Therefore we add a random bonus to the reported numbers.
    final firstPosition =
        firstObservation.position + random.nextDouble() * state.direction;
    final lastPosition =
        lastObservation.position + random.nextDouble() * state.direction;

    final velocityMillisecondsPerNumber =
        firstLastDtMillis / (lastPosition - firstPosition).abs();
    final positionsLeft = (state.target - lastPosition).abs();
    final msLeft = positionsLeft * velocityMillisecondsPerNumber;

    msFromStartSamples.add(
        _Sample(firstLastDtMillis + msLeft, velocityMillisecondsPerNumber));
  }

  msFromStartSamples.sort((a, b) => a.msFromStart.compareTo(b.msFromStart));
  final samplesToIgnore =
      ((100 - _percentile) * msFromStartSamples.length) ~/ 100;
  final samplesToIgnoreAtEachEnd = samplesToIgnore ~/ 2;
  final fast = msFromStartSamples[samplesToIgnoreAtEachEnd];
  final slowIndex = msFromStartSamples.length - 1 - samplesToIgnoreAtEachEnd;
  final slow = msFromStartSamples[slowIndex];

  return EstimateRenderer(
      firstObservation.timestamp,
      firstObservation.timestamp
          .add(Duration(milliseconds: fast.msFromStart.round())),
      firstObservation.timestamp
          .add(Duration(milliseconds: slow.msFromStart.round())),
      state.target,
      Duration(milliseconds: fast.msPerIteration.round()),
      Duration(milliseconds: slow.msPerIteration.round()));
}
