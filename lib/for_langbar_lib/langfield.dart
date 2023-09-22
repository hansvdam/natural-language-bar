import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:langbar/ui/screens/dummy_screens/CreditCardScreen.dart';
import 'package:langchain/langchain.dart';
import 'package:langchain_openai/langchain_openai.dart';
import 'package:provider/provider.dart';

import '../openAIKey.dart';
import '../ui/screens/forecast_screen.dart';
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
              apiKey: apiKey2, apiBaseUrl: apiBaseUrl());
          final llm =
              ChatOpenAI(apiClient: client, temperature: 0.0, model: 'gpt-4');
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
    final forecastTool = ForecastScreen.getTool(GoRouter.of(context));
    final creditCardTool = CreditCardScreen.getTool(GoRouter.of(context));
    final agent = OpenAIFunctionsAgent.fromLLMAndTools(
        llm: llm, tools: [forecastTool, creditCardTool], memory: memory);
    final executor = AgentExecutor(agent: agent);
    // final res = await executor.run('What is 40 raised to the 0.43 power?');
    final response = await executor.run(query);
    print(response);
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
