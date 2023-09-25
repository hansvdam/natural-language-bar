import 'package:go_router/go_router.dart';

import '../for_langchain/for_langchain.dart';

class LlmGoRoute extends GoRoute {
  LlmGoRoute({
    required this.name,
    required this.description,
    required super.path,
    required this.parameters,
    super.builder,
    super.pageBuilder,
    super.parentNavigatorKey,
    super.routes = const <RouteBase>[],
  }) : super();

  final String name;
  final String description;
  final List<LlmFunctionParameter> parameters;
}
