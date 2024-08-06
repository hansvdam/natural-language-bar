import 'dart:async';

import 'package:langbar/for_langbar_lib/retrieval.dart';
import 'package:langchain/langchain.dart';

import '../for_langchain/for_langchain.dart';

const retriever_name = "answer_general_question";

/// {@template forecasting_tool}
/// A for forecasting the weather from an api.
/// {@endtemplate}
final class RetrieverTool
    extends GenericTool<Map<String, dynamic>, ToolOptions, String> {
  RetrieverTool(
      {super.name = retriever_name,
      super.description = "Answers general questions.",
      super.parameters = const [
        UIParameter(
          name: 'user_question',
          description:
              'The most recent user message as a self contained message, inferring context from previous messages if necessary.',
          required: true,
        )
      ]})
      : super(returnDirect: true) {}

  @override
  @override
  Future<String> invokeInternal(Map<String, dynamic> toolInput,
      {ToolOptions? options}) {
    var userQuestion = toolInput['user_question'];
    var returnValue = conversationalRetrievalChain(userQuestion);
    return returnValue;
  }

  @override
  Map<String, dynamic> getInputFromJson(Map<String, dynamic> json) {
    return json;
  }

// @override
// Future<String> invokeInternal(Map<String, dynamic> input, {ToolOptions? options}) {
//   // TODO: implement invokeInternal
//   throw UnimplementedError();
// }
}
