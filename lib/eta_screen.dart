import 'package:flutter/material.dart';
import 'package:waitinator/screen_wrapper.dart';

class EtaScreen extends StatelessWidget {
  final int _target;
  const EtaScreen(int target, int current, {Key? key})
      : _target = target,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenWrapper(<Widget>[
      Flexible(
          child: Text(
        "You will get to $_target in\n"
        "between 13min, 12:34\n"
        "and 23min, 12:44",
        textAlign: TextAlign.right,
      )),
      const Flexible(child: Text("[Line with a timestamp and its number]")),
      const Flexible(child: Text("[...]")),
      const Flexible(child: Text("[Line with a timestamp and its number]")),
      const Flexible(
          child:
              Text("[Line with timestamp, number entry and an Enter button]")),
    ]);
  }
}
