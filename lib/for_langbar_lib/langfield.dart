import 'package:flutter/material.dart';
import 'package:langbar/ui/screens/dummy_screens/CreditCardScreen.dart';
import 'package:langchain/langchain.dart';
import 'package:langchain_openai/langchain_openai.dart';
import 'package:provider/provider.dart';

import '../openAIKey.dart';
import '../ui/screens/forecast_screen.dart';
import 'langbar_stuff.dart';

class LangField extends StatefulWidget {
  const LangField();

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
          var client = OpenAIClient.instanceFor(apiKey: apiKey2);
          final llm = ChatOpenAI(apiClient: client);
          sendToOpenai(llm, this._controllerOutlined.text, context);
          _controllerOutlined.clear();
        },
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search),
          suffixIcon: ShowHistoryButton(),
          filled: true,
        ),
      );

  Future<void> sendToOpenai(
      ChatOpenAI llm, String query, BuildContext context) async {
    final forecastTool = ForecastScreen.getTool(context);
    final creditCardTool = CreditCardScreen.getTool(context);
    final agent = OpenAIFunctionsAgent.fromLLMAndTools(
        llm: llm, tools: [forecastTool, creditCardTool]);
    final executor = AgentExecutor(agent: agent);
    // final res = await executor.run('What is 40 raised to the 0.43 power?');
    final path = await executor.run(query);
    print(path);
    Provider.of<ChatHistory>(context, listen: false)
        .add(HistoryMessage(query, true, navUri: path));
    //
    // Provider.of<ChatHistory>(context, listen: false)
    //     .add(HistoryMessage(path.trim(), false, navUri: path));
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
