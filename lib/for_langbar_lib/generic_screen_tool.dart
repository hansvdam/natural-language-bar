import 'dart:async';

import 'package:go_router/go_router.dart';
import 'package:langchain/langchain.dart';

import '../main.dart';

/// {@template forecasting_tool}
/// A for forecasting the weather from an api.
/// {@endtemplate}
final class GenericScreenTool extends BaseTool {
  final GoRouter goRouter;

  final String path;

  GenericScreenTool(
      {required this.goRouter,
      required super.name,
      required this.path,
      required super.description,
      required List<LlmGoRouteParam> parameters})
      : super(
          returnDirect: true,
          inputJsonSchema: {
            'type': 'object',
            'properties': {
              for (var param in parameters) ...param.asFunctionParam(),
            },
            'required': parameters
                .where((param) => param.required)
                .map((param) => param.name)
                .toList(),
          },
        ) {}

  @override
  FutureOr<String> runInternal(Map<String, dynamic> toolInput) {
    Uri uri = Uri(
        path: path,
        queryParameters:
            toolInput.map((key, value) => MapEntry(key, value.toString())));
    var uriString = uri.toString();
    goRouter.go(uriString);
    return uriString;
  }
}
