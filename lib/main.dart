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
        _positionIWantToGetTo = text;
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
        _currentPosition = text;
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
    // FIXME: Explain if goal needs to be set
    // FIXME: Explain if current needs to be set
    // FIXME: Explain if currenct / goal are the same
    const text =
        "This text can potentially be longer than one line and therefore it should wrap automatically.";
    return const Flexible(child: Text(text));
  }
}
