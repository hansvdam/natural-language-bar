import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:langbar/for_langbar_lib/retriever_tool.dart';
import 'package:langchain/langchain.dart';
import 'package:langchain_openai/langchain_openai.dart';
import 'package:provider/provider.dart';

import '../openAIKey.dart';
import '../routes.dart';
import 'generic_screen_tool.dart';
import 'langbar_states.dart';
import 'llm_go_route.dart';
import 'my_conversation_buffer_memory.dart';
// uses langchain and langchain_openai, and implicitly uses openai_dart
void submitToLLM(BuildContext context) {
  var langbarState = Provider.of<LangBarState>(context, listen: false);
  var apiKey2 = getOpenAIKey();
  var baseUrl = getLlmBaseUrl();
  final llm = ChatOpenAI(
      apiKey: apiKey2,
      baseUrl: baseUrl ?? 'https://api.openai.com/v1',
      defaultOptions: const ChatOpenAIOptions(
          temperature: 0.0,
          model: 'gpt-4-1106-preview')); // model: 'gpt-4-1106-preview');
  // model: 'gpt-3.5-turbo');
  langbarState.sendingToOpenAI = true;
  sendToOpenai(llm, context);
}

final memory = MyConversationBufferWindowMemory(
    chatHistory: ChatMessageHistory(),
    returnMessages: true); // default window length is 5

Future<void> sendToOpenai(ChatOpenAI llm, BuildContext context) async {
  // final forecastTool = ForecastScreen.getTool(GoRouter.of(context));
  // final creditCardTool = CreditCardScreen.getTool(GoRouter.of(context));
  var langbarState = Provider.of<LangBarState>(context, listen: false);
  var tools = parseRouters(GoRouter.of(context), routes);

  var tool = RetrieverTool();

  tools.insert(0, tool);
  var chatHistory = Provider.of<ChatHistory>(context, listen: false);

  // ConversationBufferMemory memory = ConversationBufferMemory(returnMessages: true);;

  // DateTime now = DateTime.now();
  // String formattedDate = DateFormat('yyyy-MM-ddTHH:mm:ssZ').format(now);
  final agent = OpenAIFunctionsAgent.fromLLMAndTools(
      systemChatMessage: const SystemChatMessagePromptTemplate(
        prompt: PromptTemplate(
          inputVariables: {},
          template:
              'Never directly answer a question yourself, but always use a function call.',
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
    memory
        .clear(); // make sure an error does not prevent the next query from being processed (strange things in the history may cause bad-request errors)
  }
  await replace_retriever_function_call_with_assistant_response_in_history(
      response);
  print(response);
  langbarState.controllerOutlined.clear();
  langbarState.sendingToOpenAI = false;
  // if response contains spaces, we assume it is not a path, but a response from the AI (when this becomes too much of a hack, we should start responding from tools with more complex objects with fields etc.
  if (response.contains(' ')) {
    chatHistory.add(HistoryMessage(text: query, isHuman: true));
    chatHistory.add(HistoryMessage(text: response, isHuman: false));
    langbarState.historyExpansion = ChatSheetExpansion.full;
    langbarState.historyShowing = true;
  } else {
    // add the original query, but the navigation-uri-repsonse as the hyperlink when you click on it
    langbarState.historyShowing = false;
    langbarState.historyExpansion = ChatSheetExpansion.part;
    chatHistory
        .add(HistoryMessage(text: query, isHuman: true, navUri: response));
  }
}

/**
 * If the last message in the chat history is a retriever function call, replace it with the response
 * from the assistant. This is the case when the user asks a general question that is relayed to the
 * RAG functionality. In the history we do not want to see this intermediate step, but rather see
 * the result of the RAG call.
 */
Future<void> replace_retriever_function_call_with_assistant_response_in_history(
    response) async {
  var chatHistoryLLM = memory.chatHistory;
  var chatHistoryLLMItems = await chatHistoryLLM.getChatMessages();
  ChatMessage? lastChatMessage = chatHistoryLLMItems.lastOrNull;
  if (lastChatMessage is AIChatMessage &&
      lastChatMessage.functionCall != null &&
      lastChatMessage.functionCall!.name == retriever_name) {
    await chatHistoryLLM.removeLast();
    await chatHistoryLLM.addAIChatMessage(response);
  }
}

// converts the chat history (as shown to the user) to a memory object that can be used by the LLM
ConversationBufferMemory memoryFromChathistory(ChatHistory chatHistory) {
  var historyItems = chatHistory.items;
  final historyLength = 2;
  var lastHistoryItems = historyItems.length > historyLength
      ? historyItems.sublist(historyItems.length - historyLength)
      : historyItems;
  List<ChatMessage> historyMessages = lastHistoryItems.map((e) {
    if (e.isHuman) {
      return ChatMessage.human(ChatMessageContent.text(e.text));
    } else {
      return ChatMessage.ai(e.text);
    }
  }).toList();

  final memory2 = ConversationBufferMemory(
      chatHistory: ChatMessageHistory(messages: historyMessages),
      returnMessages: true);
  return memory2;
}

List<BaseTool> parseRouters(GoRouter, List<RouteBase> routes, {parentPath}) {
  var tools = <BaseTool>[];
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
