import 'package:flutter/material.dart';
import 'package:langbar/ui/screens/forecast_tool.dart';
import 'package:langchain/langchain.dart';
import 'package:langchain_openai/langchain_openai.dart';
import 'package:provider/provider.dart';

import 'openAIKey.dart';

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
          Provider.of<ChatHistory>(context, listen: false)
              .add(Message(value, true));
        },
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search),
          suffixIcon: ShowHistoryButton(),
          filled: true,
        ),
      );

  Future<void> sendToOpenai(
      ChatOpenAI llm, String query, BuildContext context) async {
    final tool = ForecastTool(context);
    final agent = OpenAIFunctionsAgent.fromLLMAndTools(llm: llm, tools: [tool]);
    final executor = AgentExecutor(agent: agent);
    // final res = await executor.run('What is 40 raised to the 0.43 power?');
    final res = await executor.run(query);
    print(res);

    Provider.of<ChatHistory>(context, listen: false)
        .add(Message(res.trim(), false));
  }
}

class ShowHistoryButton extends StatelessWidget {
  const ShowHistoryButton({super.key});

  @override
  Widget build(BuildContext context) {
    var langbarState = Provider.of<LangBarState>(context, listen: false);
    bool showHistory = langbarState.showHistory;
    return IconButton(
        icon: Icon(showHistory ? Icons.arrow_downward : Icons.arrow_upward),
        onPressed: () {
          langbarState.setShowHistory(!showHistory);
        });
  }
}

class Message {
  Message(this.text, this.isHuman);

  final String text;
  final bool isHuman;
}

class ChatHistory extends ChangeNotifier {
  bool value = false;

  /// Internal, private state of the cart.
  final List<Message> items = [Message("Hello", false)];

  void add(Message item) {
    items.add(item);
    notifyListeners();
  }
}

class LangBarState extends ChangeNotifier {
  bool showHistory = false;

  void setShowHistory(bool value) {
    showHistory = value;
    notifyListeners();
  }
}
