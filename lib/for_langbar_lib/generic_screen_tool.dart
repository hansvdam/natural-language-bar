import 'dart:async';

import 'package:go_router/go_router.dart';
import 'package:langbar/for_langbar_lib/utils.dart';
import 'package:langchain/langchain.dart';

import '../for_langchain/for_langchain.dart';

/// {@template forecasting_tool}
/// A for forecasting the weather from an api.
/// {@endtemplate}
final class GenericScreenTool
    extends GenericTool<Map<String, dynamic>, ToolOptions, String> {
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
  Future<String> invokeInternal(Map<String, dynamic> toolInput,
      {final ToolOptions? options}) async {
    Uri uri = Uri(
        path: path,
        queryParameters:
            toolInput.map((key, value) => MapEntry(key, value.toString())));
    var uriString = uri.toString();
    activateUri(uriString, push);
    return uriString;
  }

  @override
  Map<String, dynamic> getInputFromJson(Map<String, dynamic> json) {
    return json;
  }
}
