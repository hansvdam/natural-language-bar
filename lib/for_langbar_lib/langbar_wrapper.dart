import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'history_bottom_sheet.dart';
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
    return Consumer<LangBarState>(builder: (context, langbarState, child) {
      List<Widget> children = [];
      children.add(Expanded(child: Scaffold(body: Builder(builder: (context) {
        setBottomsheetBuilderContext(context);
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
