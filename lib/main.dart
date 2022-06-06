import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    _positionIWantToGetTo(),
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
              labelText: "", // Left blank to hide hintText until clicked
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
}
