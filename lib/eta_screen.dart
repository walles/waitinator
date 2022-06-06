import 'package:flutter/material.dart';
import 'package:waitinator/screen_wrapper.dart';

class EtaScreen extends StatelessWidget {
  const EtaScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const ScreenWrapper(<Widget>[
      Flexible(
          child: Text("Earliest in 13min, 12:34\n"
              "Latest in 23min, 12:44")),
      Flexible(child: Text("[Line with a timestamp and its number]")),
      Flexible(child: Text("[...]")),
      Flexible(child: Text("[Line with a timestamp and its number]")),
      Flexible(
          child:
              Text("[Line with timestamp, number entry and an Enter button]")),
    ]);
  }
}
