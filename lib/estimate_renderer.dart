import 'package:intl/intl.dart';

class EstimateRenderer {
  final DateTime startedQueueing;
  final DateTime earliest;
  final DateTime latest;
  final DateTime? _now;
  final int _target;
  final Duration _fastIteration;
  final Duration _slowIteration;

  static final hhmm = DateFormat.Hm();

  /// The [startedQueueing] parameter is when the user first entered the queue.
  ///
  /// The [now] parameter overrides using DateTime.now() in toString(), and is
  /// used in testing.
  ///
  /// [earliest] and [latest] are the estimated time range when the user will
  /// reach the target.
  ///
  /// [_iterLow] and [_iterHigh] are the lowest and highest estimates for the
  /// per-iteration duration
  EstimateRenderer(this.startedQueueing, this.earliest, this.latest,
      this._target, this._fastIteration, this._slowIteration,
      {DateTime? now})
      : _now = now;

  /// Returns a multiline description on when this will happen
  @override
  String toString() {
    final now = _now ?? DateTime.now();

    if (earliest.isBefore(now) && now.isBefore(latest)) {
      return _toInBetweenString(now);
    }

    if (!now.isBefore(latest)) {
      return _toAfterString(now);
    }

    final remainingLow = earliest.difference(now);
    final remainingHigh = latest.difference(now);
    final totalLow = earliest.difference(startedQueueing);
    final totalHigh = latest.difference(startedQueueing);

    final renderedLow =
        "${renderDuration(remainingLow)}, at ${hhmm.format(earliest)}";
    final renderedHigh =
        "${renderDuration(remainingHigh)}, at ${hhmm.format(latest)}";
    var renderedArrival = "between $renderedLow\nand $renderedHigh";
    if (renderedLow == renderedHigh) {
      renderedArrival = renderedLow;
    }

    return "You will get to $_target in\n"
        "$renderedArrival\n"
        "for a total queue time of ${renderDurationRange(totalLow, totalHigh)}.\n"
        "Iteration time is ${renderDurationRange(_fastIteration, _slowIteration)}.";
  }

  /// We are in between the earliest and latest estimates, only present the
  /// latest one.
  String _toInBetweenString(DateTime now) {
    final remaining = latest.difference(now);
    final total = latest.difference(startedQueueing);
    return "You will get to $_target in\n"
        "${renderDuration(remaining)}, at ${hhmm.format(latest)}\n"
        "for a total queue time of ${renderDuration(total)}.\n"
        "Iteration time is ${renderDurationRange(_fastIteration, _slowIteration)}.";
  }

  /// We are past the latest estimate, present how far back that was.
  String _toAfterString(DateTime now) {
    final ago = now.difference(latest);
    final total = latest.difference(startedQueueing);
    return "You should have arrived at $_target\n"
        "${renderDuration(ago)} ago, at ${hhmm.format(latest)}\n"
        "for a total queue time of ${renderDuration(total)}.\n"
        "Iteration time was ${renderDurationRange(_fastIteration, _slowIteration)}.";
  }

  /// Either "1min-3min" or just "3min" if both render the same
  static String renderDurationRange(Duration low, Duration high) {
    if (low == high) {
      return renderDuration(low);
    }
    return "${renderDuration(low)}-${renderDuration(high)}";
  }

  // "3h2min", "14min" or "33s" depending on how long the duration is
  static String renderDuration(Duration duration) {
    var minutesLeft = duration.inMinutes;
    if (minutesLeft >= 60) {
      final int hoursLeft = minutesLeft ~/ 60;
      final int actualMinutesLeft = minutesLeft - hoursLeft * 60;
      final String paddedMinutes = actualMinutesLeft.toString().padLeft(2, '0');
      return "${hoursLeft}h${paddedMinutes}m";
    }

    if (minutesLeft >= 3) {
      return "${minutesLeft}min";
    }

    var secondsLeft = duration.inSeconds;
    if (secondsLeft >= 60) {
      final int actualSecondsLeft = secondsLeft - minutesLeft * 60;
      final String paddedSeconds = actualSecondsLeft.toString().padLeft(2, '0');
      return "${minutesLeft}m${paddedSeconds}s";
    }

    return "${duration.inSeconds}s";
  }
}
