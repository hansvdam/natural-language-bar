import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:langbar/ui/main_scaffolds.dart';
import 'package:langbar/ui/screens/details_screen.dart';
import 'package:langbar/ui/screens/dummy_screens/CreditCardScreen.dart';
import 'package:langbar/ui/screens/forecast_screen.dart';
import 'package:langbar/ui/screens/front_screen.dart';
import 'package:langbar/ui/screens/root_screen.dart';
import 'package:provider/provider.dart';

import 'for_langbar_lib/langbar_stuff.dart';
import 'for_langbar_lib/langbar_wrapper.dart';
import 'for_langbar_lib/llm_go_route.dart';
import 'for_langchain/for_langchain.dart';

// private navigators
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigator1Key = GlobalKey<NavigatorState>(debugLabel: 'shell1');
final _shellNavigatorAKey = GlobalKey<NavigatorState>(debugLabel: 'shellA');
final _shellNavigatorBKey = GlobalKey<NavigatorState>(debugLabel: 'shellB');

class GlobalContextService {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}

var routes = [
  LlmGoRoute(
      path: '/${CreditCardScreen.name}',
      name: 'creditcard',
      description: 'Show your credit card and maybe raise the current limit',
      parameters: const [
        LlmFunctionParameter(
          name: 'limit',
          description: 'New limit for the credit card',
          type: 'integer',
        ),
      ],
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) {
        return MaterialPage(
            fullscreenDialog: true,
            child: LangBarWrapper(
                body: CreditCardScreen(
                    label: 'Credit Card',
                    queryParameters: state.uri.queryParameters)));
      }),
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
              ),
            ),
            routes: [],
          ),
        ],
      ),
      StatefulShellBranch(
        navigatorKey: _shellNavigatorAKey,
        routes: [
          LlmGoRoute(
            name: ForecastScreen.name,
            description:
                "get weather forecast information for a place on earth",
            parameters: const [
              LlmFunctionParameter(
                name: 'place',
                description: 'place on earth',
              ),
              LlmFunctionParameter(
                name: 'numDays',
                description: 'The number of days to forecast',
                type: 'integer',
                required: false,
              ),
            ],
            path: "/${ForecastScreen.name}",
            pageBuilder: (context, state) {
              return NoTransitionPage(
                child: ForecastScreen(
                  label: 'Weather Forecast',
                  detailsPath: '/forecast/details',
                  place: state.uri.queryParameters['place'],
                  numDays: int.tryParse(
                          state.uri.queryParameters['numDays'] ?? '') ??
                      1,
                ),
              );
            },
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
          GoRoute(
            path: '/b',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: RootScreen(label: 'B', detailsPath: '/b/details'),
            ),
            routes: [
              LlmGoRoute(
                  path: 'details',
                  name: 'zoo',
                  description: 'Show some information about the zoo',
                  parameters: const [
                    LlmFunctionParameter(
                      name: 'limit',
                      description: 'number of animals to show',
                      type: 'integer',
                    ),
                  ],
                  builder: (context, state) {
                    return DetailsScreen(label: 'B');
                  })
              // GoRoute(
              //   path: 'details',
              //   builder: (context, state) => const DetailsScreen(label: 'B'),
              // ),
            ],
          ),
        ],
      ),
    ],
  ),
];

final goRouter = GoRouter(
  initialLocation: '/1',
  // * Passing a navigatorKey causes an issue on hot reload:
  // * https://github.com/flutter/flutter/issues/113757#issuecomment-1518421380
  // * However it's still necessary otherwise the navigator pops back to
  // * root on hot reload
  navigatorKey: _rootNavigatorKey,
  debugLogDiagnostics: true,
  routes: routes,
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


/// Widget for the root/initial pages in the bottom navigation bar.
