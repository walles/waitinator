import 'package:flutter/material.dart';

class ScreenWrapper extends StatelessWidget {
  final List<Widget> _children;

  const ScreenWrapper(List<Widget> children, {Key? key})
      : _children = children,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              children: _children,
            )),
      ),
    );
  }
}
