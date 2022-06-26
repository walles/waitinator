import 'dart:developer' as developer;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ScreenWrapper extends StatelessWidget {
  final List<Widget> _children;

  /// The [children] will be rendered in a Column.
  const ScreenWrapper(List<Widget> children, {Key? key})
      : _children = children,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Waitinator'), actions: [
        IconButton(
          icon: const Icon(Icons.info),
          onPressed: () {
            showAboutDialog(
                context: context,
                applicationLegalese: "© 2022 johan.walles@gmail.com",
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _infoText(),
                  ),
                ]);
          },
          tooltip: 'About',
        ),
      ]),
      body: Container(
        alignment: Alignment.center,
        child: Container(
            padding: const EdgeInsets.all(20.0),
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

  Text _infoText() {
    return Text.rich(TextSpan(children: [
      const TextSpan(
          text: "Calculates how long is left before you get to the"
              " front of the queue. "),
      _link("Source code available",
          Uri.parse("https://github.com/walles/waitinator")),
      const TextSpan(text: "!"),
    ]));
  }

  TextSpan _link(String text, Uri destination) {
    return TextSpan(
        style: const TextStyle(
            color: Colors.blue, decoration: TextDecoration.underline),
        text: text,
        recognizer: TapGestureRecognizer()
          ..onTap = () async {
            var urllaunchable = await canLaunchUrl(destination);
            if (urllaunchable) {
              await launchUrl(destination,
                  mode: LaunchMode.externalApplication);
            } else {
              developer.log("URI can't be launched: $destination");
            }
          });
  }
}
