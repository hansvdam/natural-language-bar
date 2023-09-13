import 'dart:async';

import 'package:flutter/src/widgets/framework.dart';
import 'package:go_router/go_router.dart';
import 'package:langchain/langchain.dart';

final class Parameter {
  final String name;

  final String description;

  final String type;

  const Parameter(
    this.name,
    this.type,
    this.description,
  );

  Map<String, dynamic> asFunctionParam() {
    return {
      name: {
        'description': description,
        'type': type,
      }
    };
  }
}

/// {@template calculator_tool}
/// A tool that can be used to calculate the result of a math expression.
/// {@endtemplate}
final class ForecastTool extends BaseTool {
  BuildContext context;

  /// {@macro calculator_tool}
  ForecastTool(BuildContext this.context)
      : super(
          name: 'forecast',
          description: 'get weatherforecast information for a place on earth',
          returnDirect: true,
          inputJsonSchema: {
            'type': 'object',
            'properties': {
              ...place.asFunctionParam(),
            },
            'required': ['input'],
          },
        ) {}

  static const place = Parameter('place', 'string', 'place on earth');

  @override
  FutureOr<String> runInternal(Map<String, dynamic> toolInput) {
    // TODO: implement runInternal
    print(name + "," + toolInput.toString());
    Uri uri = Uri(path: "/a", queryParameters: toolInput);
    var path = uri.toString();
    context.go(path);
    return toolInput.toString();
  }
}
