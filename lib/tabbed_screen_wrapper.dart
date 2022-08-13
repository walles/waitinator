import 'package:flutter/material.dart';
import 'package:waitinator/screen_wrapper.dart';

// FIXME: Merge this class with ScreenWrapper? They are similar.

class TabbedScreenWrapper extends StatelessWidget {
  final List<Tab> _tabs;
  final List<Widget> _tabViews;
  final Null Function() _onClose;

  /// The [children] will be rendered in a Column.
  TabbedScreenWrapper(
      List<Tab> tabs, List<Widget> tabViews, Null Function() onClose,
      {Key? key})
      : _tabs = tabs,
        _tabViews = tabViews,
        _onClose = onClose,
        super(key: key) {
    assert(_tabs.length == _tabViews.length,
        'The number of tabs must match the number of views');
  }

  @override
  Widget build(BuildContext context) {
    final closeButton =
        IconButton(onPressed: _onClose, icon: const Icon(Icons.close));

    return DefaultTabController(
        length: _tabs.length,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Waitinator'),
            bottom: TabBar(
              tabs: _tabs,
            ),
            leading: closeButton,
            actions: ScreenWrapper.actions(context),
          ),
          body: Container(
            alignment: Alignment.center,
            child: Container(
                padding: const EdgeInsets.all(20.0),
                constraints: const BoxConstraints(
                    maxWidth:
                        400 // FIXME: What is the unit here? How will this look on different devices?
                    ),
                child: TabBarView(
                  children: _tabViews,
                )),
          ),
        ));
  }
}
