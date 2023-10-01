import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:langbar/ui/screens/AccountsScreen.dart';
import 'package:langbar/ui/screens/Contacts.dart';
import 'package:langbar/ui/screens/TransactionsScreen.dart';
import 'package:langbar/ui/screens/TransferScreen.dart';
import 'package:provider/provider.dart';

import 'for_langbar_lib/langbar_wrapper.dart';
import 'for_langbar_lib/llm_go_route.dart';
import 'for_langchain/for_langchain.dart';
import 'ui/main_scaffolds.dart';
import 'ui/screens/dummy_screens/CreditCardScreen.dart';
import 'ui/screens/dummy_screens/DebitCardScreen.dart';
import 'ui/screens/dummy_screens/MapScreen.dart';
import 'ui/screens/forecast_screen.dart';
import 'ui/screens/front_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigator1Key = GlobalKey<NavigatorState>(debugLabel: 'shell1');
final _shellNavigatorAKey = GlobalKey<NavigatorState>(debugLabel: 'shellA');
final shellNavigatorTransfersKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellTransfer');
final _shellNavigatorMapKey = GlobalKey<NavigatorState>(debugLabel: 'shellB');
final _shellNavigatorContactsKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellContacts');

List<LlmFunctionParameter> cardparams = const [
  LlmFunctionParameter(
    name: 'limit',
    description: 'New limit for the credit card',
    type: 'integer',
    required: false,
  ),
  LlmFunctionParameter(
    name: 'action',
    description: 'action to perform on the card',
    type: 'string',
    enumeration: ['replace','cancel'],
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
                    action: state.uri.queryParameters['action'],
                    limit: int.tryParse(state.uri.queryParameters['limit'] ?? ''),
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
            path: '/home',
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
                      detailsPath:
                          '/${AccountsScreen.name}/${TransactionsScreen.name}',
                      queryParameters: state.uri.queryParameters));
            },
            routes: [
              LlmGoRoute(
                name: TransactionsScreen.name,
                description:
                    "Show transactions of an account, and maybe filter them",
                path: "${TransactionsScreen.name}",
                parameters: const [
                  LlmFunctionParameter(
                    name: 'filterString',
                    description: 'filter string for the list',
                    required: false,
                  ),
                ],
                builder: (context, state) => TransactionsScreen(
                    label: 'Transactions',
                    accountId: state.uri.queryParameters['accountid'],
                    filterString:
                        state.uri.queryParameters['filterString'] ?? ''),
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
        navigatorKey: shellNavigatorTransfersKey,
        routes: [
          LlmGoRoute(
            name: TransferScreen.name,
            description: "Make a bank transfer",
            path: "/${TransferScreen.name}",
            parameters: const [
              LlmFunctionParameter(
                name: 'amount',
                description: 'amount to transfer',
                type: 'number',
                required: false,
              ),
              LlmFunctionParameter(
                name: 'destinationName',
                description: 'destination account name to transfer money to',
                required: false,
              ),
              LlmFunctionParameter(
                name: 'description',
                description: 'description of the transfer',
                required: false,
              ),
            ],
            pageBuilder: (context, state) {
              return NoTransitionPage(
                  child: TransferScreen(
                      label: 'Bank Transfer',
                      amount: double.tryParse(
                          state.uri.queryParameters['amount'] ?? ''),
                      destinationName:
                          state.uri.queryParameters['destinationName'],
                    description: state.uri.queryParameters['description'],
                  ));
            },
          ),
        ],
      ),
      StatefulShellBranch(
        navigatorKey: _shellNavigatorContactsKey,
        routes: [
          LlmGoRoute(
            name: ContactsScreen.name,
            description: "Show address book of contacts and maybe filter them",
            path: "/${ContactsScreen.name}",
            parameters: const [
              LlmFunctionParameter(
                name: 'filterString',
                description: 'string for filtering the list',
                required: false,
              ),
            ],
            pageBuilder: (context, state) {
              return NoTransitionPage(
                  child: ContactsScreen(
                      label: 'Contacts',
                      searchString: state.uri.queryParameters['filterString']));
            },
          ),
        ],
      ),
    ],
  ),
];

List<RouteBase> routes = hamburgerRoutes + navBarRoutes;

final goRouter = GoRouter(
  initialLocation: '/home',
  // * Passing a navigatorKey causes an issue on hot reload:
  // * https://github.com/flutter/flutter/issues/113757#issuecomment-1518421380
  // * However it's still necessary otherwise the navigator pops back to
  // * root on hot reload
  navigatorKey: _rootNavigatorKey,
  debugLogDiagnostics: true,
  routes: routes,
);
