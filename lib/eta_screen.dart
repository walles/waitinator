import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:waitinator/screen_wrapper.dart';
import 'package:intl/intl.dart';

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
  final hhmmss = DateFormat.Hms();

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
      const SizedBox(
          height:
              20 // FIXME: What is the unit here? How will this look on different devices?
          ),
      _enterNewObservationRow(),
      Expanded(
          child: ListView(
        children: _renderObservations(),
      )),
    ]);
  }

  List<Widget> _renderObservations() {
    List<Widget> widgets = [];

    for (var observation in _observations) {
      // FIXME: Bold the position
      widgets.add(Text(
        "${hhmmss.format(observation.timestamp)} | ${observation.position}",
        textAlign: TextAlign.center,
      ));
    }

    return widgets;
  }

  Widget _enterNewObservationRow() {
    // FIXME: Put current time ticking on the left of this TextField
    // FIXME: On Enter, add new observation to our list
    return TextField(
      decoration: const InputDecoration(
        labelText: "Updated position",
        // FIXME: hintText: Example number between latest observation and target
      ),
      keyboardType: TextInputType.number,
      autofocus: true,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,

        // I don't expect more than three digits really, but if we allow up
        // to 5 we shouldn't be limiting anybody.
        LengthLimitingTextInputFormatter(5),
      ],
    );
  }
}

class _Observation {
  final DateTime timestamp;
  final int position;

  // FIXME: Should we validate the input here?
  _Observation(this.timestamp, this.position);
}
