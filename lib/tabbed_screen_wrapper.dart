import 'package:flutter/material.dart';
import 'package:waitinator/screen_wrapper.dart';

/// See also `ScreenWrapper`
class TabbedScreenWrapper extends StatelessWidget {
  final List<Tab> _tabs;
  final List<Widget> _tabViews;
  final Null Function() _onClose;
  final int currentTabIndex;
  final void Function(int)? onTabChanged;

  /// The [children] will be rendered in a Column.
  TabbedScreenWrapper(
    List<Tab> tabs,
    List<Widget> tabViews,
    Null Function() onClose, {
    super.key,
    this.currentTabIndex = 0,
    this.onTabChanged,
  })  : _tabs = tabs,
        _tabViews = tabViews,
        _onClose = onClose {
    assert(_tabs.length == _tabViews.length,
        'The number of tabs must match the number of views');
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      initialIndex: currentTabIndex,
      child: Builder(
        builder: (context) {
          final TabController tabController = DefaultTabController.of(context);
          if (onTabChanged != null) {
            tabController.addListener(() {
              if (!tabController.indexIsChanging) {
                onTabChanged!(tabController.index);
              }
            });
          }
          final closeButton = IconButton(
            onPressed: () {
              if (tabController.index == 1) {
                tabController.index = 0;
                return;
              }
              _onClose();
            },
            icon: const Icon(Icons.close),
          );
          return Scaffold(
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
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
