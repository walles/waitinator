import 'package:intl/intl.dart';

class Estimate {
  final DateTime earliest;
  final DateTime latest;
  final int _target;

  final _hhmm = DateFormat.Hm();

  Estimate(this.earliest, this.latest, this._target);

  /// Returns a multiline description on when this will happen
  @override
  String toString() {
    final now = DateTime.now();

    // FIXME: What if we're already there?

    final remainingLow = earliest.difference(now);
    final remainingHigh = latest.difference(now);
    return "You will get to $_target in\n"
        "between ${_renderDuration(remainingLow)}, ${_hhmm.format(earliest)}\n"
        "and ${_renderDuration(remainingHigh)}, ${_hhmm.format(latest)}\n"

        // FIXME: Don't hard code this!
        "for a total queue time of 17-27min";
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
