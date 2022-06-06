import 'package:flutter/material.dart';
import 'package:waitinator/screen_wrapper.dart';

class EtaScreen extends StatelessWidget {
  const EtaScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const ScreenWrapper(<Widget>[
      Text("Imagine some ETA calculations here"),
    ]);
  }
}
