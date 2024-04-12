import 'dart:convert';

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
import 'chat_messages.dart';
import 'llm_request_json_model2.dart';

// uses langchain and langchain_openai, and implicitly uses openai_dart
void submitToLLMNoLangchain(BuildContext context) {
  var langbarState = Provider.of<LangBarState>(context, listen: false);
  var apiKey = getOpenAIKey();
  var baseUrl = getLlmBaseUrl();
  langbarState.sendingToOpenAI = true;
  sendToLLMFlutter(context, baseUrl, apiKey);
}

var memory = ConversationBufferWindowMemory2(); // default window length is 5

Future<void> sendToLLMFlutter(
    BuildContext context, String baseUrl, String apiKey) async {
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
  try {
    ToolResponse futureFunctionCall =
        await sendToLLM(functionDescriptions, memory, query, trelis: false);
    print(jsonEncode(futureFunctionCall));
    // from tools select the one corresponding to futureFunctionCall.name
    BaseTool toolToTrigger =
        tools.firstWhere((element) => element.name == futureFunctionCall.name);
    String toolResult = await toolToTrigger.run(futureFunctionCall.arguments);
    if (toolToTrigger is RetrieverTool) {
      chatHistory.add(HistoryMessage(text: toolResult, isHuman: false));
      langbarState.historyExpansion = ChatSheetExpansion.full;
      langbarState.historyShowing = true;
    } else {
      langbarState.historyShowing = false;
      langbarState.historyExpansion = ChatSheetExpansion.part;
      chatHistory
          .add(HistoryMessage(text: query, isHuman: true, navUri: toolResult));
    }
  } catch (e) {
    memory
        .clear(); // make sure an error does not prevent the next query from being processed (strange things in the history may cause bad-request errors)
    chatHistory.add(HistoryMessage(text: e.toString(), isHuman: false));
    langbarState.historyExpansion = ChatSheetExpansion.full;
    langbarState.historyShowing = true;
    print("Error: $e");
  }
  langbarState.controllerOutlined.clear();
  langbarState.sendingToOpenAI = false;
}

functionDescriptionsFromTools(List<BaseTool> tools) {
  return tools.map((tool) {
    return FunctionDescription(
        name: tool.name,
        description: tool.description,
        parameters: tool.inputJsonSchema);
  }).toList();
}
