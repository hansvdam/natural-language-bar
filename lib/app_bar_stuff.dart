import 'package:flutter/material.dart';
import 'package:langchain/langchain.dart';
import 'package:langchain_openai/langchain_openai.dart';

class LangField extends StatefulWidget {
  const LangField();

  @override
  State<LangField> createState() => _LangFieldState();
}

class _LangFieldState extends State<LangField> {
  final TextEditingController _controllerOutlined =TextEditingController();

  @override
  Widget build(BuildContext context) => TextField(
    // maxLength: 10,
    // maxLengthEnforcement: MaxLengthEnforcement.none,
    controller: _controllerOutlined,
    onSubmitted: (final String value) {
      var apiKey2 = "";
      var client = OpenAIClient.instanceFor(apiKey: apiKey2);
      final llm = ChatOpenAI(apiClient: client);
      sendToOpenai(llm, this._controllerOutlined.text);

      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text('You typed: $value'),
      //     duration: const Duration(seconds: 1),
      //   ),
      // );
    },
    decoration: InputDecoration(
      prefixIcon: const Icon(Icons.search),
      suffixIcon: _ClearButton(controller: _controllerOutlined),
      // labelText: 'Filled',
      // hintText: 'hint text',
      // helperText: 'supporting text',
      filled: true,
      // errorText: 'error text',
    ),
  );

  Future<void> sendToOpenai(ChatOpenAI llm, String query) async {
    final result = await llm([ChatMessage.human(query)]);
    setState(() {
      _controllerOutlined.text = result.content.trim();
    });
  }
}


class _ClearButton extends StatelessWidget {
  const _ClearButton({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) => IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => controller.clear(),
      );
}

class CartModel extends ChangeNotifier {
  bool value = false;

  // /// Internal, private state of the cart.
  // final List<Item> _items = [];
  //
  // /// An unmodifiable view of the items in the cart.
  // UnmodifiableListView<Item> get items => UnmodifiableListView(_items);
  //
  // /// The current total price of all items (assuming all items cost $42).
  // int get totalPrice => _items.length * 42;

  /// Adds [item] to cart. This and [removeAll] are the only ways to modify the
  /// cart from the outside.
  void show(bool value) {
    this.value = value;
    notifyListeners();
  }

  void toggle() {
    this.value = !value;
    notifyListeners();
  }

  /// Removes all items from the cart.
// void removeAll() {
//   _items.clear();
//   // This call tells the widgets that are listening to this model to rebuild.
//   notifyListeners();
// }
}
