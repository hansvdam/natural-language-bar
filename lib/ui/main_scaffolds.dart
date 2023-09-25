// Stateful navigation based on:
// https://github.com/flutter/packages/blob/main/packages/go_router/example/lib/stateful_shell_route.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:langbar/ui/screens/default_appbar_scaffold.dart';
import 'package:langbar/ui/utils.dart';

import '../for_langbar_lib/langbar_wrapper.dart';

var scaffoldKey = GlobalKey<ScaffoldState>();

class ScaffoldWithNestedNavigation extends StatelessWidget {
  const ScaffoldWithNestedNavigation({
    Key? key,
    required this.navigationShell,
  }) : super(
            key: key ?? const ValueKey<String>('ScaffoldWithNestedNavigation'));
  final StatefulNavigationShell navigationShell;

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth < 450) {
        return ScaffoldWithNavigationBar(
            body: navigationShell,
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: _goBranch);
      } else {
        return ScaffoldWithNavigationRail(
          body: navigationShell,
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: _goBranch,
        );
      }
    });
  }
}

class ScaffoldWithNavigationBar extends StatelessWidget {
  const ScaffoldWithNavigationBar({
    super.key,
    required this.body,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final Widget body;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldKey,
        drawer: DefaultDrawer(),
        body: LangBarWrapper(body: body),
        bottomNavigationBar: NavigationBar(
          selectedIndex: selectedIndex,
          destinations: const [
            NavigationDestination(label: 'Section 1', icon: Icon(Icons.home)),
            NavigationDestination(label: 'Weather', icon: Icon(Icons.cloud)),
            NavigationDestination(
                label: 'Section B', icon: Icon(Icons.settings)),
          ],
          onDestinationSelected: onDestinationSelected,
        ));
  }
}

class ScaffoldWithNavigationRail extends StatelessWidget {
  const ScaffoldWithNavigationRail({
    super.key,
    required this.body,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final Widget body;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      drawer: DefaultDrawer(),
      // appBar: createAppBar(),
      body: Row(
        children: [
          NavigationRail(
            leading: HamburgerMenu(scaffoldKey: scaffoldKey),
            selectedIndex: selectedIndex,
            onDestinationSelected: onDestinationSelected,
            labelType: NavigationRailLabelType.all,
            destinations: const <NavigationRailDestination>[
              NavigationRailDestination(
                label: Text('Weather A'),
                icon: Icon(Icons.home),
              ),
              NavigationRailDestination(
                label: Text('Weather'),
                icon: Icon(Icons.cloud),
              ),
              NavigationRailDestination(
                label: Text('Section B'),
                icon: Icon(Icons.settings),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          // This is the main content.
          Expanded(
            child: LangBarWrapper(body: body),
          ),
        ],
      ),
    );
  }
}
