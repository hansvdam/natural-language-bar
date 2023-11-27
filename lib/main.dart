import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:langbar/ui/main_scaffolds.dart';
import 'package:provider/provider.dart';

import 'for_langbar_lib/langbar_states.dart';
import 'for_langbar_lib/platform_details.dart';
import 'routes.dart';

class GlobalContextService {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}
// private navigators

void main() {
  see:
  https: //codewithandrea.com/articles/flutter-navigation-gorouter-go-vs-push/
  GoRouter.optionURLReflectsImperativeAPIs = true;
  // turn off the # in the URLs on the web
  usePathUrlStrategy();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => ChatHistory(),
            // child: const MyApp(),
          ),
          ChangeNotifierProvider(
            create: (context) => LangBarState(
                enableSpeech:
                    PlatformDetails().isMobile || PlatformDetails().isWeb),
            // child: const MyApp(),
          ),
          ChangeNotifierProvider(
            create: (context) => WidthChanged(),
            // child: const MyApp(),
          ),
        ],
        child: Consumer<ChatHistory>(builder: (context, cart, child) {
          return LayoutBuilder(builder: (context, constraints) {
            Provider.of<LangBarState>(context).screenheight =
                constraints.maxHeight;
            return MaterialApp.router(
              routerConfig: goRouter,
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                primarySwatch: Colors.indigo,
                useMaterial3: true,
              ),
            );
          });
        }));
  }
}

/// Widget for the root/initial pages in the bottom navigation bar.
