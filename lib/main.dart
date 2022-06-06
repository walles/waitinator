import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const WaitinatorApp());
}

class WaitinatorApp extends StatelessWidget {
  const WaitinatorApp({Key? key}) : super(key: key);

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
                    _positionIWantToGetTo(),
                    _currentPosition(),
                    const SizedBox(
                        height:
                            30 // FIXME: What is the unit here? How will this look on different devices?
                        ),
                    _explanation(),
                  ],
                )),
          )),
    );
  }

  /// "Number I want to get to: ___"
  Widget _positionIWantToGetTo() {
    return Row(
      children: [
        const Text("Position I want to get to: "),
        Expanded(
            child: TextField(
          decoration: const InputDecoration(
              labelText:
                  "", // Intentionally blank to hide hintText until clicked
              hintText: "Can be 0 if counting down"),
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly,

            // I don't expect more than three digits really, but if we allow up
            // to 5 we shouldn't be limiting anybody.
            LengthLimitingTextInputFormatter(5),
          ], // Only numbers can be entered
        )),
      ],
    );
  }

  /// "Current position: ___"
  Widget _currentPosition() {
    return Row(
      children: [
        const Text("Current position: "),
        Expanded(
            child: TextField(
          decoration: const InputDecoration(
              labelText:
                  "", // Intentionally blank to hide hintText until clicked
              hintText: "123"),
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly,

            // I don't expect more than three digits really, but if we allow up
            // to 5 we shouldn't be limiting anybody.
            LengthLimitingTextInputFormatter(5),
          ], // Only numbers can be entered
        )),
      ],
    );
  }

  /// Text explaining what's needed to be able to start. Potentially multiline,
  /// will wrap automatically.
  Widget _explanation() {
    // FIXME: Explain if goal needs to be set
    // FIXME: Explain if current needs to be set
    // FIXME: Explain if currenct / goal are the same
    const text =
        "This text can potentially be longer than one line and therefore it should wrap automatically.";
    return const Flexible(child: Text(text));
  }
}
