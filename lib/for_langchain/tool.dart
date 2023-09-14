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
