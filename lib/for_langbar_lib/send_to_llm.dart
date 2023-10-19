import 'package:dart_openai/dart_openai.dart' as dart_openai;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:langchain/langchain.dart';
import 'package:langchain_openai/langchain_openai.dart';
import 'package:provider/provider.dart';

import '../openAIKey.dart';
import '../routes.dart';
import 'generic_screen_tool.dart';
import 'langbar_states.dart';
import 'llm_go_route.dart';

void submitToLLM(BuildContext context) {
  var langbarState = Provider.of<LangBarState>(context, listen: false);
  var apiKey2 = getOpenAIKey();
  var client =
      OpenAIClient.instanceFor(apiKey: apiKey2, apiBaseUrl: getLlmBaseUrl());
  var sessionToken = getSessionToken();
  if (sessionToken != null) {
    dart_openai.OpenAI.includeHeaders({"session": sessionToken});
  }
  final llm =
      ChatOpenAI(apiClient: client, temperature: 0.0, model: 'gpt-3.5-turbo');
  langbarState.sendingToOpenAI = true;
  sendToOpenai(llm, context);
}

final memory = ConversationBufferMemory(returnMessages: true);

Future<void> sendToOpenai(ChatOpenAI llm, BuildContext context) async {
  // final forecastTool = ForecastScreen.getTool(GoRouter.of(context));
  // final creditCardTool = CreditCardScreen.getTool(GoRouter.of(context));
  var langbarState = Provider.of<LangBarState>(context, listen: false);
  langbarState.historyShowing = false;
  var tools = parseRouters(GoRouter.of(context), routes);

  DateTime now = DateTime.now();
  String formattedDate = DateFormat('yyyy-MM-ddTHH:mm:ssZ').format(now);
  final agent = OpenAIFunctionsAgent.fromLLMAndTools(
      systemChatMessage: SystemChatMessagePromptTemplate(
        prompt: PromptTemplate(
          inputVariables: {},
          template:
              'You are a helpful AI assistant. The current date and time is ${formattedDate}.',
        ),
      ),
      llm: llm,
      tools: tools,
      memory: memory);
  final executor = AgentExecutor(agent: agent);
  // final res = await executor.run('What is 40 raised to the 0.43 power?');
  var response;
  var query = langbarState.controllerOutlined.text;
  try {
    response = await executor.run(query);
  } catch (e) {
    response = e.toString();
  }
  langbarState.controllerOutlined.clear();
  langbarState.sendingToOpenAI = false;
  // if response contains spaces, we assume it is not a path, but a response from the AI (when this becomes too much of a hack, we should start responding from tools with more complex objects with fields etc.
  var chatHistory = Provider.of<ChatHistory>(context, listen: false);
  if (response.contains(' ')) {
    chatHistory.add(HistoryMessage(text: query, isHuman: true));
    chatHistory.add(HistoryMessage(text: response, isHuman: false));
    langbarState.historyShowing = true;
  } else // add the original query, but the navigation-uri-repsonse as the hyperlink when you click on it
    chatHistory
        .add(HistoryMessage(text: query, isHuman: true, navUri: response));
}

parseRouters(GoRouter, List<RouteBase> routes, {parentPath}) {
  var tools = <GenericScreenTool>[];
  for (var route in routes) {
    String? newPath = null;
    if (route is GoRoute) {
      // route.path is only the local path. If the route e.g. points to a details screen, we have to prepend the path of the parent:
      newPath = (parentPath != null ? parentPath + "/" : "") + route.path;
    }
    if (route is DocumentedGoRoute) {
      var tool = GenericScreenTool(
          goRouter: goRouter,
          name: route.name,
          push: route.modal,
          path: newPath!,
          description: route.description,
          parameters: route.parameters);
      tools.add(tool);
    }
    if (route.routes.isNotEmpty) {
      tools.addAll(parseRouters(goRouter, route.routes, parentPath: newPath));
    }
  }
  return tools;
}
