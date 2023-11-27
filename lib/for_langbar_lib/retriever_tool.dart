import 'dart:async';

import 'package:langbar/for_langbar_lib/retrieval.dart';

import '../for_langchain/for_langchain.dart';

/// {@template forecasting_tool}
/// A for forecasting the weather from an api.
/// {@endtemplate}
final class RetrieverTool extends GenericTool {
  RetrieverTool(
      {super.name = "answer_general_question",
      super.description = "Answers general questions.",
      super.parameters = const [
        UIParameter(
          name: 'user_question',
          description:
              'The latest user message as a self contained message, given the chat history.',
          required: true,
        )
      ]})
      : super(returnDirect: true) {}

  @override
  FutureOr<String> runInternal(Map<String, dynamic> toolInput) {
    var userQuestion = toolInput['user_question'];
    var returnValue = conversationalRetrievalChain(userQuestion);
    return returnValue;
  }
}
