import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:waitinator/estimator.dart';
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
  final _hhmmss = DateFormat.Hms();

  final _newObservationController = TextEditingController();
  final _newObservationFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _target = widget._target;
    _observations.add(_Observation(DateTime.now(), widget._firstObservation));

    // Tick the _currentTimeText() rendering
    Timer.periodic(
        const Duration(milliseconds: 500), (Timer t) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    // FIXME: Compute this estimate, don't just hardcode it a bit into the future
    final estimate = Estimate(DateTime.now().add(const Duration(minutes: 13)),
        DateTime.now().add(const Duration(minutes: 23)), _target);

    return ScreenWrapper(<Widget>[
      Flexible(
          child: Text(
        estimate.toString(),
        textAlign: TextAlign.right,
      )),
      const SizedBox(
          height:
              20 // FIXME: What is the unit here? How will this look on different devices?
          ),
      _renderObservations(),
    ]);
  }

  BoxScrollView _renderObservations() {
    List<Widget> widgets = [
      Align(alignment: Alignment.centerRight, child: _currentTimeText()),
      _newObservationEntry(),
    ];

    for (final observation in _observations) {
      widgets.add(Align(
        alignment: Alignment.centerRight,
        child: Text(
          _hhmmss.format(observation.timestamp),
          textAlign: TextAlign.right,
        ),
      ));

      // FIXME: Bold the position
      widgets.add(Align(
        alignment: Alignment.centerLeft,
        child: Text(
          observation.position.toString(),
          textAlign: TextAlign.left,
        ),
      ));
    }

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      shrinkWrap: true,
      childAspectRatio: 3.0,
      children: widgets,
    );
  }

  TextField _newObservationEntry() {
    final lastPosition = _observations.last.position;
    final examplePosition =
        (_target < lastPosition) ? lastPosition - 1 : lastPosition + 1;
    // FIXME: Disable this box if we're too close to the target

    return TextField(
      controller: _newObservationController,
      focusNode: _newObservationFocus,
      decoration: InputDecoration(
        labelText: "Updated position",
        hintText: "Example: $examplePosition",
      ),
      keyboardType: TextInputType.number,
      autofocus: true,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,

        // I don't expect more than three digits really, but if we allow up
        // to 5 we shouldn't be limiting anybody.
        LengthLimitingTextInputFormatter(5),
      ],
      onSubmitted: (String value) {
        if (value.isEmpty) {
          return;
        }

        // FIXME: How do we surface these validation results to the user?
        final number = int.parse(value);
        if (lastPosition < _target && number <= lastPosition) {
          // Counting up, but the new observation is lower than the last
          _newObservationFocus.requestFocus();
          return;
        }
        if (_target < lastPosition && number >= lastPosition) {
          // Counting down, but the new observation is higher than the last
          _newObservationFocus.requestFocus();
          return;
        }

        setState(() {
          _observations.add(_Observation(DateTime.now(), number));
        });

        _newObservationController.clear();
      },
    );
  }

  Text _currentTimeText() {
    // This is kept ticking using the Timer.periodic() call in initState()
    return Text(
      _hhmmss.format(DateTime.now()),
      textAlign: TextAlign.right,
    );
  }
}

class _Observation {
  final DateTime timestamp;
  final int position;

  // FIXME: Should we validate the input here?
  _Observation(this.timestamp, this.position);
}
