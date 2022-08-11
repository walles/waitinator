import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:intl/intl.dart';
import 'package:waitinator/eta_state.dart';

import 'observation.dart';
import 'compute_estimate.dart';
import 'estimate.dart';
import 'screen_wrapper.dart';

class EtaScreen extends StatefulWidget {
  final EtaState _state;
  final Null Function() _onClose;

  /// `onClose()` will be called when the top-left-corner-X is pressed, after
  /// the `EtaScreen` finishes shutting down.
  const EtaScreen(EtaState state, Null Function() onClose, {Key? key})
      : _state = state,
        _onClose = onClose,
        super(key: key);

  @override
  State<EtaScreen> createState() => _EtaScreenState();
}

class _EtaScreenState extends State<EtaScreen> {
  Estimate? _estimate;

  final _hhmmss = DateFormat.Hms();
  final _newObservationController = TextEditingController();
  final _newObservationFocus = FocusNode();

  late Timer _tickCurrentTimeText;

  @override
  void initState() {
    super.initState();

    // Tick the _currentTimeText() rendering
    _tickCurrentTimeText = Timer.periodic(
        const Duration(milliseconds: 500), (Timer t) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final Text estimateWidget;
    if (_estimate == null) {
      estimateWidget = const Text(""
          "Need more observations.\n"
          "\n"
          "Enter the next position once you get there and I'll start calculating!");
    } else {
      estimateWidget = Text(
        _estimate.toString(),
        textAlign: TextAlign.right,
      );
    }

    return ScreenWrapper(<Widget>[
      estimateWidget,
      const SizedBox(
          height:
              20 // FIXME: What is the unit here? How will this look on different devices?
          ),
      _renderObservations(),
    ], onClose: () {
      _tickCurrentTimeText.cancel();
      widget._onClose();
    });
  }

  Widget _renderObservations() {
    List<Widget> widgets = [
      Align(alignment: Alignment.centerRight, child: _currentTimeText()),
      _newObservationEntry(),
    ];

    for (final observation in widget._state.reversed) {
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

    return Expanded(
      child: SingleChildScrollView(
        child: LayoutGrid(
          columnSizes: [50.fr, 50.fr],
          rowSizes: List.filled(widgets.length ~/ 2, auto),
          rowGap: 10,
          columnGap: 10,
          children: widgets,
        ),
      ),
    );
  }

  TextField _newObservationEntry() {
    final lastPosition = widget._state.last.position;
    final examplePosition = (widget._state.target < lastPosition)
        ? lastPosition - 1
        : lastPosition + 1;
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
        if (lastPosition < widget._state.target && number < lastPosition) {
          // Counting up, but the new observation is lower than the last
          _newObservationFocus.requestFocus();
          return;
        }
        if (widget._state.target < lastPosition && number > lastPosition) {
          // Counting down, but the new observation is higher than the last
          _newObservationFocus.requestFocus();
          return;
        }

        setState(() {
          widget._state.add(Observation(DateTime.now(), number));
          _estimate = estimate(widget._state);
        });

        _newObservationController.clear();
        _newObservationFocus.requestFocus();
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
