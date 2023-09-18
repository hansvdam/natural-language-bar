import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'chatview.dart';
import 'langbar_stuff.dart';
import 'langfield.dart';

class LangBarWrapper extends StatelessWidget {
  final Widget body;

  const LangBarWrapper({
    super.key,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer2<LangBarState, ChatHistory>(
        builder: (context, langbarState, chatHistory, child) {
      List<Widget> children = [];
      children.add(Expanded(
          child: Scaffold(
              bottomSheet: langbarState.historyShowing
                  ? Column(mainAxisSize: MainAxisSize.min, children: [
                      Consumer<ChatHistory>(
                          builder: (context, chathistory, child) {
                        return ChatHistoryView(messages: chathistory.items);
                      }),
                    ])
                  : null,
              body: Builder(builder: (context) {
                return body;
              }))));
      if (langbarState.showLangbar) {
        children.add(Material(child: LangField()));
      }
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: children,
      );
    });
  }
}
