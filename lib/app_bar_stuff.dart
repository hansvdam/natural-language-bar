import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:langchain_openai/langchain_openai.dart';
import 'package:langchain/langchain.dart';

PreferredSizeWidget createAppBar(
    Function() showBottomSheet
    ) {
  return AppBar(
    title: const Text('Langbar'),
    actions:  [
      _BottomSheetButton(
        showBottomSheet: showBottomSheet,
      ),
    ]
  );
}

class _BottomSheetButton extends StatelessWidget {
  const _BottomSheetButton({
    required this.showBottomSheet,
    this.showTooltipBelow = true,
  });

  final Function showBottomSheet;
  final bool showTooltipBelow;

  @override
  Widget build(BuildContext context) {
    final isBright = Theme.of(context).brightness == Brightness.light;
    return Tooltip(
      preferBelow: showTooltipBelow,
      message: 'Toggle brightness',
      child: IconButton(
        icon: const Icon(Icons.short_text_outlined),
        onPressed: () => showBottomSheet(),
      ),
    );
  }
}

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

