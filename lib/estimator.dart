import 'package:intl/intl.dart';

class Estimate {
  final DateTime startedQueueing;
  final DateTime earliest;
  final DateTime latest;
  final int _target;

  final _hhmm = DateFormat.Hm();

  /// The [startedQueueing] parameter is when the user first entered the queue
  Estimate(this.startedQueueing, this.earliest, this.latest, this._target);

  /// Returns a multiline description on when this will happen
  @override
  String toString() {
    final now = DateTime.now();

    // FIXME: What if we're already there? Or inside the earliest-latest span?

    final remainingLow = earliest.difference(now);
    final remainingHigh = latest.difference(now);
    final totalLow = earliest.difference(startedQueueing);
    final totalHigh = latest.difference(startedQueueing);
    return "You will get to $_target in\n"
        "between ${_renderDuration(remainingLow)}, ${_hhmm.format(earliest)}\n"
        "and ${_renderDuration(remainingHigh)}, ${_hhmm.format(latest)}\n"
        "for a total queue time of ${_renderDuration(totalLow)}-${_renderDuration(totalHigh)}";
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
