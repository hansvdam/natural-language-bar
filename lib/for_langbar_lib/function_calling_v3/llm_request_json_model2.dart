

class Model {
  String model;
  List<Message> messages;
  bool stream;
  double temperature;
  List<FunctionDescription> functions;

  Model({
    required this.model,
    required this.messages,
    required this.stream,
    required this.temperature,
    required this.functions,
  });

  Map<String, dynamic> toJson() => {
        'model': model,
        'messages': messages.map((x) => x.toJson()).toList(),
        'stream': stream,
        'temperature': temperature,
        'functions': functions.map((x) => x.toJson()).toList(),
      };
}

class Message {
  String role;
  String content;

  Message({
    required this.role,
    required this.content,
  });

  Map<String, dynamic> toJson() => {
        'role': role,
        'content': content,
      };
}

class FunctionDescription {
  String name;
  String description;
  final Map<String, dynamic> parameters;

  FunctionDescription({
    required this.name,
    required this.description,
    required this.parameters,
  });

  Map<String, dynamic> toV3Json() => {
        'type': 'function',
        'name': name,
        'description': description,
        'parameters': parameters,
      };

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'parameters': parameters,
      };
}

class Parameters {
  String type = "object";
  Map<String, Property> properties;
  List<String> required;

  Parameters({
    required this.properties,
    required this.required,
  });

  Map<String, dynamic> toJson() => {
        'type': type,
        'properties': properties.map((k, v) => MapEntry(k, v.toJson())),
        'required': required,
      };
}

class Property {
  String description;
  String type;
  List<String>? enumValues;

  Property({
    required this.description,
    required this.type,
    this.enumValues,
  });

  Map<String, dynamic> toJson() => {
        'description': description,
        'type': type,
        if (enumValues != null) 'enum': enumValues,
      };
}
