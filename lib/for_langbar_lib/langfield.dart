import 'package:dart_openai/dart_openai.dart' as dart_openai;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:langbar/for_langbar_lib/generic_screen_tool.dart';
import 'package:langchain/langchain.dart';
import 'package:langchain_openai/langchain_openai.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../openAIKey.dart';
import 'langbar_stuff.dart';

class LangField extends StatefulWidget {
  final bool showHistoryButton;

  const LangField([this.showHistoryButton = false]);

  @override
  State<LangField> createState() => _LangFieldState();
}

class _LangFieldState extends State<LangField> {
  final TextEditingController _controllerOutlined = TextEditingController();

  @override
  Widget build(BuildContext context) => TextField(
        controller: _controllerOutlined,
        onSubmitted: (final String value) {
          var apiKey2 = getOpenAIKey();
          var client = OpenAIClient.instanceFor(
              apiKey: apiKey2, apiBaseUrl: openAiApiBaseUrl());
          var sessionToken = getSessionToken();
          if (sessionToken != null) {
            dart_openai.OpenAI.includeHeaders({"session": sessionToken});
          }
          final llm = ChatOpenAI(
              apiClient: client, temperature: 0.0, model: 'gpt-3.5-turbo');
          sendToOpenai(llm, this._controllerOutlined.text, context);
          _controllerOutlined.clear();
        },
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search),
          suffixIcon: widget.showHistoryButton ? ShowHistoryButton() : null,
          filled: true,
        ),
      );

  final memory = ConversationBufferMemory(returnMessages: true);

  Future<void> sendToOpenai(
      ChatOpenAI llm, String query, BuildContext context) async {
    // final forecastTool = ForecastScreen.getTool(GoRouter.of(context));
    // final creditCardTool = CreditCardScreen.getTool(GoRouter.of(context));
    var tools = parseRouters(GoRouter.of(context), routes);
    final agent = OpenAIFunctionsAgent.fromLLMAndTools(
        llm: llm, tools: tools, memory: memory);
    final executor = AgentExecutor(agent: agent);
    // final res = await executor.run('What is 40 raised to the 0.43 power?');
    var response;
    try {
      response = await executor.run(query);
    } catch (e) {
      response = e.toString();
    }
    // if response contains spaces, we assume it is not a path, but a response from the AI (when this becomes too much of a hack, we should start responding from tools with more complex objects with fields etc.
    if (response.contains(' ')) {
      Provider.of<ChatHistory>(context, listen: false)
          .add(HistoryMessage(query, true));
      Provider.of<ChatHistory>(context, listen: false)
          .add(HistoryMessage(response, false));
      Provider.of<LangBarState>(context, listen: false).setHistoryShowing(true);
    } else // add the original query, but the navigation-uri-repsonse as the hyperlink when you click on it
      Provider.of<ChatHistory>(context, listen: false)
          .add(HistoryMessage(query, true, navUri: response));
  }

  parseRouters(GoRouter, List<RouteBase> routes, {parentPath}) {
    var tools = <GenericScreenTool>[];
    for (var route in routes) {
      String? newPath = null;
      if (route is GoRoute) {
        // route.path is only the local path. If the route e.g. points to a details screen, we have to prepend the path of the parent:
        newPath = (parentPath != null ? parentPath + "/" : "") + route.path;
      }
      if (route is LlmGoRoute) {
        var tool = GenericScreenTool(
            goRouter: goRouter,
            name: route.name,
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
}

class ShowHistoryButton extends StatelessWidget {
  const ShowHistoryButton({super.key});

  @override
  Widget build(BuildContext context) {
    var langbarState = Provider.of<LangBarState>(context, listen: false);
    bool showHistory = langbarState.historyShowing;
    return IconButton(
        icon: Icon(showHistory ? Icons.arrow_downward : Icons.arrow_upward),
        onPressed: () {
          langbarState.setHistoryShowing(!showHistory);
        });
  }
}
