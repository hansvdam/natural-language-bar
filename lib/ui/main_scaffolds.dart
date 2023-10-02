// Stateful navigation based on:
// https://github.com/flutter/packages/blob/main/packages/go_router/example/lib/stateful_shell_route.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:langbar/ui/screens/default_appbar_scaffold.dart';
import 'package:langbar/ui/utils.dart';
import 'package:provider/provider.dart';

import '../for_langbar_lib/langbar_wrapper.dart';

const smallSpacing = 10.0;
const defaultPadding = 16.0;

var scaffoldKey = GlobalKey<ScaffoldState>();

class ScaffoldWithNestedNavigation extends StatelessWidget {
  ScaffoldWithNestedNavigation({
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

  bool? screenWiderThan450 = null;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth < 450) {
        if(screenWiderThan450 = true) {
          screenWiderThan450 = false;
          triggerWidthRebuild(context);
        }
        return ScaffoldWithNavigationBar(
            body: navigationShell,
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: _goBranch);
      } else {
        if(screenWiderThan450 = false) {
          screenWiderThan450 = true;
          triggerWidthRebuild(context);
        }
        return ScaffoldWithNavigationRail(
          body: navigationShell,
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: _goBranch,
        );
      }
    });
  }

  void triggerWidthRebuild(BuildContext context) {
    Future.delayed(Duration.zero, () {
      Provider.of<WidthChanged>(context, listen: false).trigger();
    });
  }
}

class WidthChanged extends ChangeNotifier {

  void trigger() {
    notifyListeners();
  }
}

const navBarDestinations = [
  NavigationDestination(label: 'Home', icon: Icon(Icons.home)),
  NavigationDestination(label: 'Accounts', icon: Icon(Icons.account_balance)),
  NavigationDestination(label: 'Map', icon: Icon(Icons.map_outlined)),
  NavigationDestination(label: 'Transfer', icon: Icon(Icons.monetization_on)),
  NavigationDestination(label: 'Contacts', icon: Icon(Icons.contacts)),
];

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
          destinations: navBarDestinations,
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
            destinations: navBarDestinations
                .map((destination) => NavigationRailDestination(
                      icon: destination.icon,
                      label: Text(destination.label),
                    ))
                .toList(),
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
