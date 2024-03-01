import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:langbar/for_langbar_lib/function_calling_v3/send_to_llm_dart_only.dart';
import 'package:langbar/for_langbar_lib/retriever_tool.dart';
import 'package:langbar/for_langbar_lib/send_to_llm.dart';
import 'package:langchain/langchain.dart';
import 'package:provider/provider.dart';

import '../../openAIKey.dart';
import '../../routes.dart';
import '../langbar_states.dart';
import '../my_conversation_buffer_memory.dart';
import 'llm_request_json_model2.dart';

// uses langchain and langchain_openai, and implicitly uses openai_dart
void submitToLLM(BuildContext context) {
  var langbarState = Provider.of<LangBarState>(context, listen: false);
  var apiKey2 = getOpenAIKey();
  var baseUrl = getLlmBaseUrl();
  langbarState.sendingToOpenAI = true;
  sendToLLMFlutter(context);
}

final memory = MyConversationBufferWindowMemory(
    returnMessages: true); // default window length is 5

Future<void> sendToLLMFlutter(BuildContext context) async {
  // final forecastTool = ForecastScreen.getTool(GoRouter.of(context));
  // final creditCardTool = CreditCardScreen.getTool(GoRouter.of(context));
  var langbarState = Provider.of<LangBarState>(context, listen: false);
  String query = langbarState.controllerOutlined.text;
  List<BaseTool> tools = parseRouters(GoRouter.of(context), routes);

  var tool = RetrieverTool();

  tools.insert(0, tool);
  var chatHistory = Provider.of<ChatHistory>(context, listen: false);
  List<FunctionDescription> functionDescriptions =
      functionDescriptionsFromTools(tools);
  ToolResponse futureFunctionCall =
      await sendToLLM(functionDescriptions, query);
  print(futureFunctionCall.toJson());
  // from tools select the one corresponding to futureFunctionCall.name
  BaseTool toolToTrigger =
      tools.firstWhere((element) => element.name == futureFunctionCall.name);
  toolToTrigger.run(futureFunctionCall.parameters);
}

functionDescriptionsFromTools(List<BaseTool> tools) {
  return tools.map((tool) {
    return FunctionDescription(
        name: tool.name,
        description: tool.description,
        parameters: tool.inputJsonSchema);
  }).toList();
}
