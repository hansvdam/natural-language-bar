import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../for_langbar_lib/langbar_stuff.dart';
import 'default_appbar_scaffold.dart';

const smallSpacing = 10.0;

class FrontScreen extends StatefulWidget {
  /// Creates a RootScreen
  FrontScreen({required this.label, Key? key}) : super(key: key);

  /// The label
  final String label;

  @override
  State<FrontScreen> createState() => _FrontScreenState();
}

class _FrontScreenState extends State<FrontScreen> {
  _FrontScreenState();

  @override
  Widget build(BuildContext context) {
    return DefaultAppbarScaffold(
        label: widget.label,
        body: Consumer<ChatHistory>(
          builder: (context, chatHistory, child) {
            var lastMessage = chatHistory.items.isNotEmpty
                ? chatHistory.items.last
                : HistoryMessage("no message yet", false);
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
                child:
                    Text('This screen displays the last response by the LLM:'),
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
