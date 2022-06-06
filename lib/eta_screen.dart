import 'package:flutter/material.dart';

class EtaScreen extends StatelessWidget {
  const EtaScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Waitinator"),
      ),
      body: const Text("Imagine some ETA calculations here"),
    );
  }
}
