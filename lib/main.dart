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
      title: 'Queue Time Estimator',
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Queue Time Estimator'),
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
                    _topRow(),
                  ],
                )),
          )),
    );
  }

  /// "Number I want to get to: ___"
  Widget _topRow() {
    return Row(
      children: [
        const Text("Number I want to get to: "),
        Expanded(
            child: TextField(
          decoration: const InputDecoration(
              labelText: "", // Left blank to hide hintText until clicked
              hintText: "Can be 0 if counting down"),
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly
          ], // Only numbers can be entered
        )),
      ],
    );
  }
}
