import 'package:go_router/go_router.dart';

import '../for_langchain/for_langchain.dart';

class LlmGoRoute extends GoRoute {
  final bool modal;

  LlmGoRoute({
    required this.name,
    required this.description,
    required super.path,
    this.parameters = const [],
    this.modal = false,
    super.builder,
    super.pageBuilder,
    super.parentNavigatorKey,
    super.routes = const <RouteBase>[],
  }) : super();

  final String name;
  final String description;
  final List<LlmFunctionParameter> parameters;
}
