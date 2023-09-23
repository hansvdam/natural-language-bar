import 'dart:async';

import 'package:go_router/go_router.dart';

import '../for_langchain/for_langchain.dart';

/// {@template forecasting_tool}
/// A for forecasting the weather from an api.
/// {@endtemplate}
final class GenericScreenTool extends GenericTool {
  final GoRouter goRouter;

  final String path;

  GenericScreenTool(
      {required this.goRouter,
      required super.name,
      required this.path,
      required super.description,
      required super.parameters})
      : super(returnDirect: true) {}

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
