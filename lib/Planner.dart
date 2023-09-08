import 'dart:async';

import 'package:langchain/langchain.dart';
import 'package:math_expressions/math_expressions.dart';

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

final class Planner extends BaseTool {
  Planner()
      : super(
          name: 'planner',
          description:
              'plans a train trip in the Netherlands from station to station',
          returnDirect: true,
          // handleToolError: false,
          inputJsonSchema: {
            'type': 'object',
            'properties': {
              ...origin,
              ...destination2.asFunctionParam(),
            },
            'required': ['input'],
          },
        ) {}

  static const origin = {
    'origin': {
      'type': 'string',
      'description': 'origin station of the trip',
    }
  };

  // static const origin = 'origin';
  static const destination = {
    'destination': {
      'type': 'string',
      'description': 'destination station of the trip',
    }
  };

  static const destination2 =
      Parameter('destination', 'string', 'destination station of the trip');


  final _parser = Parser();

  @override
  FutureOr<String> runInternal(Map<String, dynamic> toolInput) {
    // TODO: implement runInternal
    print(name + "," + toolInput.toString());
    return toolInput.toString();
  }
}
