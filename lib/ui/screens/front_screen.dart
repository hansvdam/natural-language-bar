import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../for_langbar_lib/langbar_stuff.dart';
import '../utils.dart';

const smallSpacing = 10.0;

class FrontScreen extends StatefulWidget {
  /// Creates a RootScreen
  FrontScreen(
      {required this.label, required this.toggleLangbarFunction, Key? key})
      : super(key: key);

  /// The label
  final String label;

  final Function toggleLangbarFunction;

  @override
  State<FrontScreen> createState() => _FrontScreenState();
}

class _FrontScreenState extends State<FrontScreen> {
  final TextEditingController _controllerOutlined = TextEditingController();

  _FrontScreenState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: createAppBar(() {
      widget.toggleLangbarFunction();
    }), body: Consumer<ChatHistory>(
      builder: (context, chatHistory, child) {
        var lastMessage = chatHistory.items.last;
        var children = <Widget>[
          TextButton(
              onPressed: () {
                // context.go("/a/:utrecht");
                context.go("/a?place=utrecht");
              },
              child: Text("test")),
          Text('Screen ${widget.label}',
              style: Theme.of(context).textTheme.titleLarge),
          const Padding(padding: EdgeInsets.all(4)),
          Padding(
            padding: const EdgeInsets.all(smallSpacing),
            child: Text('This screen displays the last response by the LLM:'),
          ),
        ];
        if (!lastMessage.isHuman) {
          children.add(Text(lastMessage.text,
              style: Theme.of(context).textTheme.titleLarge));
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: children,
        );
      },
    ));
  }
}
