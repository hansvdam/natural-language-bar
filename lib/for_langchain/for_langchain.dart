import 'package:langchain/langchain.dart';

class LlmFunctionParameter {
  const LlmFunctionParameter({
    required this.name,
    required this.description,
    this.type = 'string',
    this.required = true,
    this.enumeration,
  });

  final String name;
  final String description;
  final String type;
  final bool required;
  final List<String>? enumeration;

  Map<String, dynamic> asFunctionParam() {
    Map<String, dynamic> map = {
      'description': description,
      'type': type,
    };
    if (enumeration != null) {
      map['enum'] = enumeration!;
    }
    return {name: map};
  }
}

abstract base class GenericTool extends BaseTool {
  GenericTool(
      {required super.name,
      required super.description,
      required List<LlmFunctionParameter> parameters,
      super.returnDirect})
      : super(
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
        );
}
