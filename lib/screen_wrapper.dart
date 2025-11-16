import 'dart:developer' as developer;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// See also `TabbedScreenWrapper`
import 'eta_state.dart';

class ScreenWrapper extends StatelessWidget {
  final List<Widget> _children;
  final EtaState? etaState;

  /// The [children] will be rendered in a Column.
  const ScreenWrapper({
    required List<Widget> children,
    this.etaState,
    super.key,
  }) : _children = children;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Waitinator'),
        actions: actions(context, etaState),
      ),
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
          ),
        ),
      ),
    );
  }

  static List<Widget> actions(BuildContext context, EtaState? etaState) {
    return [
      PopupMenuButton<String>(
        icon: const Icon(Icons.menu),
        onSelected: (value) {
          if (value == 'about') {
            showAboutDialog(
              context: context,
              applicationLegalese: "© 2022 johan.walles@gmail.com",
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: infoText(),
                ),
              ],
            );
            return;
          }

          if (value == 'change-target') {
            if (etaState == null) {
              return;
            }

            showDialog(
              context: context,
              builder: (context) {
                final controller =
                    TextEditingController(text: etaState.target.toString());
                return AlertDialog(
                  title: const Text('Change target'),
                  content: TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Target number',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('OK'),
                    ),
                  ],
                );
              },
            );
            return;
          }
        },
        itemBuilder: (context) {
          return [
            PopupMenuItem<String>(
              value: 'change-target',
              enabled: etaState != null,
              child: Row(
                children: const [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Change target'),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'about',
              child: Row(
                children: const [
                  Icon(Icons.info_outline),
                  SizedBox(width: 8),
                  Text('About'),
                ],
              ),
            ),
          ];
        },
      ),
    ];
  }

  static Text infoText() {
    return Text.rich(TextSpan(children: [
      const TextSpan(
          text: "Calculates how long is left before you get to the"
              " front of the queue. "),
      _link("Source code available",
          Uri.parse("https://github.com/walles/waitinator")),
      const TextSpan(text: "!"),
    ]));
  }

  static TextSpan _link(String text, Uri destination) {
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
