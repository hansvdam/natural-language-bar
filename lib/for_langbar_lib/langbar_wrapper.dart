import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'history_view.dart';
import 'langbar_states.dart';
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
              bottomSheet: langbarState.historyShowing &&
                      langbarState.showLangbar &&
                      chatHistory.items.isNotEmpty
                  ? HistoryView(
                      messages: chatHistory.items,
                      maxHeigth: langbarState.historyHeight)
                  : null,
              body: Builder(builder: (context) {
                return body;
              }))));
      if (langbarState.showLangbar) {
        children.add(Material(child: LangField(chatHistory.items.isNotEmpty)));
      }
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: children,
      );
    });
  }
}
