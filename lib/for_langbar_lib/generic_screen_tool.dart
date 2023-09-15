import 'dart:async';

import 'package:flutter/src/widgets/framework.dart';
import 'package:go_router/go_router.dart';
import 'package:langchain/langchain.dart';

import '../for_langchain/tool.dart';

/// {@template calculator_tool}
/// A for forecasting the weather from an api.
/// {@endtemplate}
final class GenericScreenTool extends BaseTool {
  final BuildContext context;

  /// {@macro calculator_tool}
  factory GenericScreenTool(BuildContext context, String name,
      String description, List<Parameter> parameters) {
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
        context, name, description, inputJsonSchema);
  }

  GenericScreenTool._internal(this.context, String name, String description,
      Map<String, dynamic> inputJsonSchema)
      : super(
          name: name,
          description: description,
          returnDirect: true,
          inputJsonSchema: inputJsonSchema,
        );

  @override
  FutureOr<String> runInternal(Map<String, dynamic> toolInput) {
    Uri uri = Uri(
        path: "/$name",
        queryParameters:
            toolInput.map((key, value) => MapEntry(key, value.toString())));
    var path = uri.toString();
    context.go(path);
    return path;
  }
}
