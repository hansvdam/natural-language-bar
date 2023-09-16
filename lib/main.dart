import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:langbar/ui/screens/details_screen.dart';
import 'package:langbar/ui/screens/dummy_screens/CreditCardScreen.dart';
import 'package:langbar/ui/screens/forecast_screen.dart';
import 'package:langbar/ui/screens/front_screen.dart';
import 'package:langbar/ui/screens/root_screen.dart';
import 'package:provider/provider.dart';

import 'for_langbar_lib/langbar_stuff.dart';
import 'for_langbar_lib/langbar_wrapper.dart';

// private navigators
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigator1Key = GlobalKey<NavigatorState>(debugLabel: 'shell1');
final _shellNavigatorAKey = GlobalKey<NavigatorState>(debugLabel: 'shellA');
final _shellNavigatorBKey = GlobalKey<NavigatorState>(debugLabel: 'shellB');

class GlobalContextService {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}

final goRouter = GoRouter(
  initialLocation: '/1',
  // * Passing a navigatorKey causes an issue on hot reload:
  // * https://github.com/flutter/flutter/issues/113757#issuecomment-1518421380
  // * However it's still necessary otherwise the navigator pops back to
  // * root on hot reload
  navigatorKey: _rootNavigatorKey,
  debugLogDiagnostics: true,
  routes: [
    GoRoute(
        name: CreditCardScreen.name,
        // Optional, add name to your routes. Allows you navigate by name instead of path
        path: "/${CreditCardScreen.name}",
        builder: (context, state) {
          return LangBarWrapper(
              body: CreditCardScreen(
                  label: 'Credit Card',
                  toggleLangbarFunction: () {
                    var langbar =
                        Provider.of<LangBarState>(context, listen: false);
                    langbar.toggleLangbar();
                  },
                  queryParameters: state.uri.queryParameters));
        }),
    // Stateful navigation based on:
    // https://github.com/flutter/packages/blob/main/packages/go_router/example/lib/stateful_shell_route.dart
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNestedNavigation(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          navigatorKey: _shellNavigator1Key,
          routes: [
            GoRoute(
              path: '/1',
              pageBuilder: (context, state) => NoTransitionPage(
                child: FrontScreen(
                  label: 'Front Screen',
                  toggleLangbarFunction: () {
                    var langbar =
                        Provider.of<LangBarState>(context, listen: false);
                    langbar.toggleLangbar();
                  },
                ),
              ),
              routes: [],
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorAKey,
          routes: [
            GoRoute(
              path: "/${ForecastScreen.name}",
              pageBuilder: (context, state) => NoTransitionPage(
                child: ForecastScreen(
                  label: 'Weather Forecast',
                  detailsPath: '/forecast/details',
                  queryParameters: state.uri.queryParameters,
                  toggleLangbarFunction: () {
                    var langbar =
                        Provider.of<LangBarState>(context, listen: false);
                    langbar.toggleLangbar();
                    // bottomsheet(_builderContext!);
                  },
                ),
              ),
              routes: [
                GoRoute(
                  path: 'details',
                  builder: (context, state) => const DetailsScreen(label: 'A'),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorBKey,
          routes: [
            // Shopping Cart
            GoRoute(
              path: '/b',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: RootScreen(label: 'B', detailsPath: '/b/details'),
              ),
              routes: [
                GoRoute(
                  path: 'details',
                  builder: (context, state) => const DetailsScreen(label: 'B'),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);

void main() {
  // turn off the # in the URLs on the web
  usePathUrlStrategy();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => ChatHistory(),
            // child: const MyApp(),
          ),
          ChangeNotifierProvider(
            create: (context) => LangBarState(),
            // child: const MyApp(),
          ),
        ],
        child: Consumer<ChatHistory>(builder: (context, cart, child) {
          return MaterialApp.router(
            routerConfig: goRouter,
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.indigo,
              useMaterial3: true,
            ),
          );
        }));
  }
}

// Stateful navigation based on:
// https://github.com/flutter/packages/blob/main/packages/go_router/example/lib/stateful_shell_route.dart
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
      // later re-add the navigation rail for larger screen. For now focus on MVP
      // if (constraints.maxWidth < 450) {
      return ScaffoldWithNavigationBar(
          body: navigationShell,
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: _goBranch);
    }
        // else {
        //   return ScaffoldWithNavigationRail(
        //     body: navigationShell,
        //     selectedIndex: navigationShell.currentIndex,
        //     onDestinationSelected: _goBranch,
        //   );
        // }
        // }
        );
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
        body: LangBarWrapper(body: body),
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            (NavigationBar(
              selectedIndex: selectedIndex,
              destinations: const [
                NavigationDestination(
                    label: 'Section 1', icon: Icon(Icons.home)),
                NavigationDestination(
                    label: 'Weather', icon: Icon(Icons.cloud)),
                NavigationDestination(
                    label: 'Section B', icon: Icon(Icons.settings)),
              ],
              onDestinationSelected: onDestinationSelected,
            ))
          ],
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
      // appBar: createAppBar(),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: selectedIndex,
            onDestinationSelected: onDestinationSelected,
            labelType: NavigationRailLabelType.all,
            destinations: const <NavigationRailDestination>[
              NavigationRailDestination(
                label: Text('Weather A'),
                icon: Icon(Icons.home),
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
            child: body,
          ),
        ],
      ),
    );
  }
}

/// Widget for the root/initial pages in the bottom navigation bar.
