import 'dart:async';

import 'package:flutter/src/widgets/framework.dart';
import 'package:go_router/go_router.dart';
import 'package:langchain/langchain.dart';

final class Parameter {
  final String name;

  final String description;

  final String type;

  final bool required;

  const Parameter(this.name, this.type, this.description,
      {this.required = true});

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

  static const place = Parameter('place', 'string', 'place on earth');
  static const daysAhead = Parameter(
      'num_days', 'integer', 'The number of days to forecast',
      required: false);

  var parameters = [place, daysAhead];

  /// {@macro calculator_tool}
  factory ForecastTool(BuildContext context) {
    var parameters = [place, daysAhead];
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

    return ForecastTool._internal(context, inputJsonSchema);
  }

  ForecastTool._internal(this.context, Map<String, dynamic> inputJsonSchema)
      : super(
          name: 'forecast',
          description: 'get weatherforecast information for a place on earth',
          returnDirect: true,
          inputJsonSchema: inputJsonSchema,
        );

  @override
  FutureOr<String> runInternal(Map<String, dynamic> toolInput) {
    // TODO: implement runInternal
    print(name + "," + toolInput.toString());
    Uri uri = Uri(
        path: "/a",
        queryParameters:
            toolInput.map((key, value) => MapEntry(key, value.toString())));
    var path = uri.toString();
    context.go(path);
    return toolInput.toString();
  }
}
