import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:intl/intl.dart';
import 'package:waitinator/eta_graph.dart';

import 'observation.dart';
import 'compute_estimate.dart';
import 'estimate.dart';
import 'tabbed_screen_wrapper.dart';

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
  final List<Observation> _observations = [];
  Estimate? _estimate;

  final _hhmmss = DateFormat.Hms();
  final _newObservationController = TextEditingController();
  final _newObservationFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _target = widget._target;
    _observations.add(Observation(DateTime.now(), widget._firstObservation));

    // Tick the _currentTimeText() rendering
    Timer.periodic(
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

    var numbersTab =
        Column(mainAxisAlignment: MainAxisAlignment.start, children: [
      estimateWidget,
      const SizedBox(
          height:
              20 // FIXME: What is the unit here? How will this look on different devices?
          ),
      _renderObservations(),
    ]);

    var graphTab = const EtaGraph();

    return TabbedScreenWrapper(const [
      Tab(icon: Icon(Icons.format_list_numbered)),
      Tab(icon: Icon(Icons.show_chart)),
    ], [
      numbersTab,
      graphTab,
    ]);
  }

  Widget _renderObservations() {
    List<Widget> widgets = [
      Align(alignment: Alignment.centerRight, child: _currentTimeText()),
      _newObservationEntry(),
    ];

    for (final observation in _observations.reversed) {
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
        if (lastPosition < _target && number < lastPosition) {
          // Counting up, but the new observation is lower than the last
          _newObservationFocus.requestFocus();
          return;
        }
        if (_target < lastPosition && number > lastPosition) {
          // Counting down, but the new observation is higher than the last
          _newObservationFocus.requestFocus();
          return;
        }

        setState(() {
          _observations.add(Observation(DateTime.now(), number));
          _estimate = estimate(_observations, _target);
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
