import 'package:intl/intl.dart';

class Estimate {
  final DateTime startedQueueing;
  final DateTime earliest;
  final DateTime latest;
  final DateTime? _now;
  final int _target;

  final _hhmm = DateFormat.Hm();

  /// The [startedQueueing] parameter is when the user first entered the queue.
  /// The [now] parameter overrides using DateTime.now() in toString(), and is
  /// used in testing.
  Estimate(this.startedQueueing, this.earliest, this.latest, this._target,
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
    return "You will get to $_target in\n"
        "between ${_renderDuration(remainingLow)}, at ${_hhmm.format(earliest)}\n"
        "and ${_renderDuration(remainingHigh)}, at ${_hhmm.format(latest)}\n"
        "for a total queue time of ${_renderDuration(totalLow)}-${_renderDuration(totalHigh)}";
  }

  String _toInBetweenString(DateTime now) {
    final remaining = latest.difference(now);
    final total = latest.difference(startedQueueing);
    return "You will get to $_target in\n"
        "${_renderDuration(remaining)}, at ${_hhmm.format(latest)}\n"
        "for a total queue time of ${_renderDuration(total)}";
  }

  String _toAfterString(DateTime now) {
    final ago = now.difference(latest);
    final total = latest.difference(startedQueueing);
    return "You should have arrived at $_target\n"
        "${_renderDuration(ago)} ago, at ${_hhmm.format(latest)}\n"
        "for a total queue time of ${_renderDuration(total)}";
  }

  String _renderDuration(Duration duration) {
    var minutesLeft = duration.inMinutes;
    var result = "";
    if (minutesLeft >= 60) {
      final int hoursLeft = minutesLeft ~/ 60;
      result = "${hoursLeft}h";
      minutesLeft -= hoursLeft * 60;
    }

    result = "$result${minutesLeft}min";
    return result;
  }
}
