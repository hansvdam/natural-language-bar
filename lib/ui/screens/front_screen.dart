import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'default_appbar_scaffold.dart';

const smallSpacing = 10.0;

const String _markdownData = """
# What is the point of this app?

This is a fake banking app to illustrate app-'navigation' using natural language. It is **NOT** a proposal for a banking app design,
but just illustrates that:\n
__You can get to any screen/functionality by typing what you want__\n
for example:\n
- 'debitcard limit to 10000'
- 'nearest ATM'
- 'transfer 60 euros to John' (it will not execute but just propose)
- 'show my car insurance'
- 'save a 1000 euros'
- 'show all transactions with wallmart'

After your first request, a **↑** button appears, that opens a clickable interaction history.
""";

class FrontScreen extends StatelessWidget {
  /// Creates a RootScreen
  FrontScreen({required this.label, Key? key}) : super(key: key);

  /// The label
  final String label;

  @override
  Widget build(BuildContext context) {
    return DefaultAppbarScaffold(
        label: label,
        body: SafeArea(
            child: Markdown(
          // controller: controller,
          selectable: true,
          data: _markdownData,
          imageDirectory: 'https://raw.githubusercontent.com',
        )));

    //   DefaultAppbarScaffold(
    //     label: label,
    //     body: PageWithDefaultMargin(child:BulletListWithParagraphWidget(
    //     title: 'What is the point of this app?',
    //     paragraph: "This is a fake banking app to illustrate app-'navigation' using natural language. It is NOT a proposal for a banking app, "
    //         "but just a vehicle to illustrate an interaction principle applicable to many different kinds of apps and applications:\n "
    //         "you can get to any screen in the app by typing what you want in bottom text field",
    //     items: [
    //     'Item 1',
    //     'Item 2',
    //     'Item 3',
    //     'A longer item that might span multiple lines.',
    //     ],
    // )));
  }
}
