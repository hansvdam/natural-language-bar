import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:langbar/ui/screens/AccountsScreen.dart';
import 'package:langbar/ui/screens/Contacts.dart';
import 'package:langbar/ui/screens/TransactionsScreen.dart';
import 'package:langbar/ui/screens/TransferScreen.dart';
import 'package:langbar/ui/screens/dummy_screens/RoutePlanner.dart';

import 'for_langbar_lib/langbar_wrapper.dart';
import 'for_langbar_lib/llm_go_route.dart';
import 'for_langchain/for_langchain.dart';
import 'ui/main_scaffolds.dart';
import 'ui/screens/CreditCardScreen.dart';
import 'ui/screens/MapScreen.dart';
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
    enumeration: ['replace', 'cancel'],
    required: false,
  ),
];

List<RouteBase> hamburgerRoutes = [
  LlmGoRoute(
      path: '/creditcard',
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
                    imageSrc:
                        "https://www.visa.com.ag/dam/VCOM/regional/lac/ENG/Default/Pay%20With%20Visa/Find%20a%20Card/Credit%20Cards/Classic/visaclassiccredit-400x225.jpg",
                    action: ActionOnCard.fromString(
                        state.uri.queryParameters['action']),
                    limit:
                        int.tryParse(state.uri.queryParameters['limit'] ?? ''),
                    queryParameters: state.uri.queryParameters)));
      }),
  LlmGoRoute(
      path: '/debitcard',
      name: 'debitcard',
      description: 'Show your debit card and maybe perform an action on it',
      parameters: cardparams,
      modal: true,
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) {
        return MaterialPage(
            fullscreenDialog: true,
            child: LangBarWrapper(
                body: CreditCardScreen(
                    label: 'Debit Card',
                    imageSrc:
                        "https://www.trustcobank.com/wp-content/uploads/2023/01/Trustco-Debit-Card-450.png",
                    action: ActionOnCard.fromString(
                        state.uri.queryParameters['action']),
                    limit:
                        int.tryParse(state.uri.queryParameters['limit'] ?? ''),
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
      }),
  LlmGoRoute(
      path: '/routeplanner',
      name: 'routeplanner',
      description:
          'Plan a public transport trip from A to B in the Netherlands.',
      parameters: const [
        LlmFunctionParameter(
          name: 'origin',
          description: 'origin address, train station or postal code.',
          required: true,
        ),
        LlmFunctionParameter(
          name: 'destination',
          description: 'destination address, train station or postal code.',
          required: true,
        ),
        LlmFunctionParameter(
          name: 'trip_date_time',
          description: 'Requested DateTime for the departure or arrival of the trip in \'YYYY-MM-DDTHH:MM:SS+02:00\' format. The user will use a time in a 12 hour system, make an intelligent guess about what the user is most likely to mean in terms of a 24 hour system, e.g. not planning for the past.',
          required: false,
        ),
        LlmFunctionParameter(
          name: 'departure',
          description: 'True to depart at the given time, False to arrive at the given time.',
          required: true,
        ),
        LlmFunctionParameter(
          name: 'language',
          description: 'Language of the input text',
          required: true,
        ),
      ],
      modal: true,
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) {
        return MaterialPage(
            fullscreenDialog: true,
            child: LangBarWrapper(
                body:
                    RoutePlanner(queryParameters: state.uri.queryParameters)));
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
                amount:
                    double.tryParse(state.uri.queryParameters['amount'] ?? ''),
                destinationName: state.uri.queryParameters['destinationName'],
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
