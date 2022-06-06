import 'package:flutter/material.dart';
import 'package:waitinator/screen_wrapper.dart';

class EtaScreen extends StatefulWidget {
  final int _target;
  final int _firstObservation;

  const EtaScreen(int target, int current, {Key? key})
      : _target = target,
        _firstObservation = current,
        super(key: key);

  @override
  State<EtaScreen> createState() => _EtaScreenState();
}

class _EtaScreenState extends State<EtaScreen> {
  int _target = 0;
  final List<_Observation> _observations = [];

  @override
  void initState() {
    super.initState();
    _target = widget._target;
    _observations.add(_Observation(DateTime.now(), widget._firstObservation));
  }

  @override
  Widget build(BuildContext context) {
    return ScreenWrapper(<Widget>[
      Flexible(
          child: Text(
        "You will get to $_target in\n"
        "between 13min, 12:34\n"
        "and 23min, 12:44\n"
        "for a total queue time of 17-27min",
        textAlign: TextAlign.right,
      )),
      const Flexible(child: Text("[Line with a timestamp and its number]")),
      Flexible(
          child: Text(
              "... list of ${_observations.length.toString()} entries...")),
      const Flexible(child: Text("[Line with a timestamp and its number]")),
      const Flexible(
          child:
              Text("[Line with timestamp, number entry and an Enter button]")),
    ]);
  }
}

class _Observation {
  final DateTime timestamp;
  final int position;

  // FIXME: Should we validate the input here?
  _Observation(this.timestamp, this.position);
}
