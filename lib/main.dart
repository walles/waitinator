import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:waitinator/eta_state.dart';
import 'package:waitinator/observation.dart';

import 'main_ui.dart';
import 'screen_wrapper.dart';

const persistentStateKey = "etaState";

void main() async {
  await GetStorage.init();

  const baseColor = Color(0xff0175C2);

  runApp(MaterialApp(
    title: "Waitinator",
    home: const WaitinatorApp(),

    // Ref:
    // * https://stackoverflow.com/a/71136199/473672
    // * https://stackoverflow.com/a/62607827/473672
    theme: ThemeData(colorScheme: const ColorScheme.light(primary: baseColor)),
    darkTheme:
        ThemeData(colorScheme: const ColorScheme.dark(primary: baseColor)),
    themeMode: ThemeMode.system,
  ));
}

class WaitinatorApp extends StatefulWidget {
  const WaitinatorApp({super.key});

  @override
  State<StatefulWidget> createState() {
    return _WaitinatorAppState();
  }
}

class _WaitinatorAppState extends State<WaitinatorApp> {
  String _positionIWantToGetTo = "";
  String _currentPosition = "";
  EtaState? _state;

  @override
  void initState() {
    super.initState();

    String? serializedState = GetStorage().read(persistentStateKey);
    if (serializedState != null) {
      _state = EtaState.deserialize(serializedState);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_state == null) {
      return ScreenWrapper(<Widget>[
        _positionIWantToGetToWidget(),
        _currentPositionWidget(),
        const SizedBox(
            height:
                20 // FIXME: What is the unit here? How will this look on different devices?
            ),
        _explanationWidget(),
        const SizedBox(
            height:
                20 // FIXME: What is the unit here? How will this look on different devices?
            ),
        _startButton(),
      ]);
    }

    return MainUi(_state!, () {
      GetStorage().remove(persistentStateKey);
      setState(() {
        _state = null;
      });
    });
  }

  /// "Number I want to get to: ___"
  Widget _positionIWantToGetToWidget() {
    return TextField(
      onChanged: (text) {
        setState(() {
          _positionIWantToGetTo = text;
        });
      },
      decoration: const InputDecoration(
          labelText: "Position I want to get to",
          hintText: "Can be 0 if counting down"),
      textInputAction: TextInputAction.next,
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

  /// "Current position: ___"
  Widget _currentPositionWidget() {
    return TextField(
      onChanged: (text) {
        setState(() {
          _currentPosition = text;
        });
      },
      decoration:
          const InputDecoration(labelText: "Current position", hintText: "123"),
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,

        // I don't expect more than three digits really, but if we allow up
        // to 5 we shouldn't be limiting anybody.
        LengthLimitingTextInputFormatter(5),
      ], // Only numbers can be entered
    );
  }

  /// Text explaining what's needed to be able to start. Potentially multiline,
  /// will wrap automatically.
  Widget _explanationWidget() {
    String text = "";
    if (_positionIWantToGetTo == "") {
      text =
          "Please set the number you want to get to. Can be 0 if you want to "
          "count down, or some higher number if you're in a ticketing queue.";
    } else if (_currentPosition == "") {
      text =
          "Please set the current position. Can be your current ticket number, "
          "or how far you have left if you're counting down.";
    } else if (_currentPosition == _positionIWantToGetTo) {
      text = "You are already there!\n";
    } else {
      var from = int.parse(_currentPosition);
      var to = int.parse(_positionIWantToGetTo);
      if (to > 0 && from > to) {
        text = "NOTE: Counting down to $_positionIWantToGetTo (not zero) is "
            "uncommon, are you sure this is right?";
      } else {
        var direction = "up";
        if (from > to) {
          direction = "down";
        }

        // Trailing linefeed makes the UI skip around less when going from the
        // long explanations above to this short explanation.
        text = "Counting $direction from $from, let's go!\n";
      }
    }

    assert(text != "");
    return Flexible(child: Text(text));
  }

  Widget _startButton() {
    // FIXME: The enable-disable logic in here is almost identical to the one in
    // _explanationWidget(). Merge them somehow?

    const goText = Text("Go!");
    const disabled = ElevatedButton(onPressed: null, child: goText);
    if (_positionIWantToGetTo == "") {
      return disabled;
    }
    if (_currentPosition == "") {
      return disabled;
    }
    var from = int.parse(_currentPosition);
    var to = int.parse(_positionIWantToGetTo);
    if (from == to) {
      return disabled;
    }

    return ElevatedButton(
      onPressed: () {
        var target = int.parse(_positionIWantToGetTo);
        var current = int.parse(_currentPosition);

        final newState = EtaState(target);
        newState.add(Observation(DateTime.now(), current));

        setState(() {
          _state = newState;
          GetStorage().write(persistentStateKey, newState.serialize());
        });
      },
      child: goText,
    );
  }
}
