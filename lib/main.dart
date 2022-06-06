import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const WaitinatorApp());
}

class WaitinatorApp extends StatefulWidget {
  const WaitinatorApp({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _WaitinatorAppState();
  }
}

class _WaitinatorAppState extends State<WaitinatorApp> {
  String _positionIWantToGetTo = "";
  String _currentPosition = "";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Waitinator',
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Waitinator'),
          ),
          body: Container(
            alignment: Alignment.center,
            child: Container(
                padding: const EdgeInsets.all(40.0),
                constraints: const BoxConstraints(
                    maxWidth:
                        400 // FIXME: What is the unit here? How will this look on different devices?
                    ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    _positionIWantToGetToWidget(),
                    _currentPositionWidget(),
                    const SizedBox(
                        height:
                            20 // FIXME: What is the unit here? How will this look on different devices?
                        ),
                    _explanationWidget(),
                  ],
                )),
          )),
    );
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
      keyboardType: TextInputType.number,
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
      text = "You are already there!";
    } else {
      var from = int.parse(_currentPosition);
      var to = int.parse(_positionIWantToGetTo);
      if (to > 0 && from > to) {
        text = "NOTE: Counting down to $_positionIWantToGetTo (not zero) is "
            "uncommon, are you sure this is right?";
      } else {
        // FIXME: Enable the start-computing button
        text = "All set, let's go!";
      }
    }

    assert(text != "");
    return Flexible(child: Text(text));
  }
}
