import 'package:logger/logger.dart';

import '../routes.dart';

// filtering in logviewer:
// -kind:flutter.frame,gc,provider:provider_changed,provider:provider_list_changed,debugger,Flutter.FrameworkInitialization,Flutter.FirstFrame
class DemoFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    // if(event.level == Level.error || event.level == Level.warning) {
    return true;
    // }

    return false;
  }
}

var langbarLogger = Logger(
    filter: DemoFilter(),
    printer: SimplePrinter(printTime: true),
    output: ConsoleOutput());

extension UriExtension on Uri {
  bool hasSamePathAs(String otherUri) {
    Uri other = Uri.parse(otherUri);
    return this.path == other.path;
  }
}

void activateUri(String navUri, bool openModal) {
  if (openModal) {
    var currentUri =
        goRouter.routeInformationProvider.value.uri;
    if (currentUri.hasSamePathAs(navUri)) {
      goRouter.pop();
      goRouter.push(navUri);
    } else {
      goRouter.push(navUri);
    }
  } else {
    goRouter.go(navUri);
  }
}

