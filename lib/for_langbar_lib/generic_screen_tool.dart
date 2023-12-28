import 'dart:async';

import 'package:go_router/go_router.dart';
import 'package:langbar/for_langbar_lib/utils.dart';
import 'package:langchain/langchain.dart';

import '../for_langchain/for_langchain.dart';

/// {@template forecasting_tool}
/// A for forecasting the weather from an api.
/// {@endtemplate}
final class GenericScreenTool extends GenericTool<ToolOptions> {
  final GoRouter goRouter;

  final String path;

  final bool push;

  GenericScreenTool({
    required this.goRouter,
    required super.name,
    required this.path,
    required super.description,
    required super.parameters,
    this.push = false,
  }) : super(returnDirect: true) {}

  @override
  FutureOr<String> runInternal(Map<String, dynamic> toolInput,
      {final ToolOptions? options}) {
    Uri uri = Uri(
        path: path,
        queryParameters:
            toolInput.map((key, value) => MapEntry(key, value.toString())));
    var uriString = uri.toString();
    activateUri(uriString, push);
    return uriString;
  }
}
