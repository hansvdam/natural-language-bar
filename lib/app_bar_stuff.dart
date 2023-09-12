import 'package:flutter/material.dart';
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
        // maxLength: 10,
        // maxLengthEnforcement: MaxLengthEnforcement.none,
        controller: _controllerOutlined,
        onSubmitted: (final String value) {
          var apiKey2 = getOpenAIKey();
          var client = OpenAIClient.instanceFor(apiKey: apiKey2);
          final llm = ChatOpenAI(apiClient: client);
          sendToOpenai(llm, this._controllerOutlined.text);
          _controllerOutlined.clear();
          Provider.of<ChatHistory>(context, listen: false)
              .add(Message(value, true));

          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(
          //     content: Text('You typed: $value'),
          //     duration: const Duration(seconds: 1),
          //   ),
          // );
        },
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search),
          suffixIcon: ShowHistoryButton(),
          filled: true,
        ),
      );

  Future<void> sendToOpenai(ChatOpenAI llm, String query) async {
    final result = await llm([ChatMessage.human(query)]);
    Provider.of<ChatHistory>(context, listen: false)
        .add(Message(result.content.trim(), false));
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

  //
  // /// The current total price of all items (assuming all items cost $42).
  // int get totalPrice => _items.length * 42;

  /// Adds [item] to cart. This and [removeAll] are the only ways to modify the
  /// cart from the outside.
  ///
  void add(Message item) {
    items.add(item);
    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }

  // void show(bool value) {
  //   this.value = value;
  //   notifyListeners();
  // }
  //
  // void toggle() {
  //   this.value = !value;
  //   notifyListeners();
  // }

  // Removes all items from the cart.
  void removeAll() {
    items.clear();
    // This call tells the widgets that are listening to this model to rebuild.
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
