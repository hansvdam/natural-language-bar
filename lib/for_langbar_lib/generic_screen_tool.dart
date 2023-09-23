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

  /// {@macro calculator_tool}
  factory GenericScreenTool(GoRouter goRouter, String name, path,
      String description, List<LlmGoRouteParam> parameters) {
    var inputJsonSchema = {
      'type': 'object',
      'properties': {
        for (var param in parameters) ...param.asFunctionParam(),
      },
      'required': parameters
          .where((param) => param.required)
          .map((param) => param.name)
          .toList(),
    };

    return GenericScreenTool._internal(
        goRouter, name, path, description, inputJsonSchema);
  }

  GenericScreenTool._internal(this.goRouter, String name, this.path,
      description, Map<String, dynamic> inputJsonSchema)
      : super(
          name: name,
          description: description,
          returnDirect: true,
          inputJsonSchema: inputJsonSchema,
        );

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
