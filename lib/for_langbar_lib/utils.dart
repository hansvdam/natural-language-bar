import '../routes.dart';
import 'llm_go_route.dart';

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

