import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:langbar/ui/screens/Contacts.dart';
import 'package:langbar/ui/screens/dummy_screens/AccountsScreen.dart';

import 'for_langbar_lib/langbar_wrapper.dart';
import 'for_langbar_lib/llm_go_route.dart';
import 'for_langchain/for_langchain.dart';
import 'ui/main_scaffolds.dart';
import 'ui/screens/details_screen.dart';
import 'ui/screens/dummy_screens/CreditCardScreen.dart';
import 'ui/screens/dummy_screens/DebitCardScreen.dart';
import 'ui/screens/dummy_screens/MapScreen.dart';
import 'ui/screens/forecast_screen.dart';
import 'ui/screens/front_screen.dart';
import 'ui/screens/root_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigator1Key = GlobalKey<NavigatorState>(debugLabel: 'shell1');
final _shellNavigatorAKey = GlobalKey<NavigatorState>(debugLabel: 'shellA');
final _shellNavigatorBKey = GlobalKey<NavigatorState>(debugLabel: 'shellB');
final _shellNavigatorMapKey = GlobalKey<NavigatorState>(debugLabel: 'shellB');
final _shellNavigatorContactsKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellB');

List<LlmFunctionParameter> cardparams = const [
  LlmFunctionParameter(
    name: 'limit',
    description: 'New limit for the credit card',
    type: 'integer',
    required: false,
  ),
  LlmFunctionParameter(
    name: 'replace',
    description: 'should the card be replaced?',
    type: 'boolean',
    required: false,
  ),
];

List<RouteBase> hamburgerRoutes = [
  LlmGoRoute(
      path: '/${CreditCardScreen.name}',
      name: 'creditcard',
      description: 'Show your credit card and maybe perform an action on it',
      parameters: cardparams,
      modal: true,
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) {
        return MaterialPage(
            fullscreenDialog: true,
            child: LangBarWrapper(
                body: CreditCardScreen(
                    label: 'Credit Card',
                    queryParameters: state.uri.queryParameters)));
      }),
  LlmGoRoute(
      path: '/${DebitCardScreen.name}',
      name: 'debitcard',
      description: 'Show your debit card and maybe perform an action on it',
      parameters: cardparams,
      modal: true,
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) {
        return MaterialPage(
            fullscreenDialog: true,
            child: LangBarWrapper(
                body: DebitCardScreen(
                    label: 'Debit Card',
                    queryParameters: state.uri.queryParameters)));
      }),
  LlmGoRoute(
      name: ForecastScreen.name,
      modal: true,
      parentNavigatorKey: _rootNavigatorKey,
      description: "get weather forecast information for a place on earth",
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
        return MaterialPage(
            fullscreenDialog: true,
            child: LangBarWrapper(
              body: ForecastScreen(
                label: 'Weather Forecast',
                detailsPath: '/forecast/details',
                place: state.uri.queryParameters['place'],
                numDays:
                    int.tryParse(state.uri.queryParameters['numDays'] ?? '') ??
                        1,
              ),
            ));
      })
];

List<RouteBase> navBarRoutes = [
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
                label: 'Lang Bank Sample',
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
            name: AccountsScreen.name,
            description: "Show all accounts",
            path: "/${AccountsScreen.name}",
            pageBuilder: (context, state) {
              return NoTransitionPage(
                  child: AccountsScreen(
                      label: 'Accounts',
                      queryParameters: state.uri.queryParameters));
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
        navigatorKey: _shellNavigatorMapKey,
        routes: [
          LlmGoRoute(
            name: MapScreen.name,
            description: "Show ATMs or Bank offices on map",
            path: "/${MapScreen.name}",
            parameters: const [
              LlmFunctionParameter(
                name: 'atmOrOffice',
                description: 'show atms or offices',
                type: 'string',
                enumeration: ["atms", "offices"],
                required: false,
              ),
            ],
            pageBuilder: (context, state) {
              return NoTransitionPage(
                  child: MapScreen(
                      label: 'ATMS and Offices',
                      atmOrOffice: state.uri.queryParameters['atmOrOffice']));
            },
          ),
        ],
      ),
      StatefulShellBranch(
        navigatorKey: _shellNavigatorContactsKey,
        routes: [
          LlmGoRoute(
            name: ContactsScreen.name,
            description: "Show contacts and maybe search in them",
            path: "/${ContactsScreen.name}",
            parameters: const [
              LlmFunctionParameter(
                name: 'searchString',
                description: 'search string for searching in the contacts list',
                type: 'string',
                required: false,
              ),
            ],
            pageBuilder: (context, state) {
              return NoTransitionPage(
                  child: ContactsScreen(
                      label: 'Contacs',
                      searchString: state.uri.queryParameters['searchString']));
            },
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
                      required: false,
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

List<RouteBase> routes = hamburgerRoutes + navBarRoutes;

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
