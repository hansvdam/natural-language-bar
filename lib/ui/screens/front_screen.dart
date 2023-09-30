import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'default_appbar_scaffold.dart';

const smallSpacing = 10.0;

const String _markdownData = """
# LangBar
app-'navigation' using natural language.

## What is the point of this app?

This is a fake banking app to demonstrate LangBar.
It is **NOT** a proposal for a banking app design,
but just shows that:\n
__You can get to any screen/functionality by typing what you want in the *LangBar* below__\n
(Although for the shear purposes of demo-ing it was not feasible to give it very wide coverage of things it can handle). The interaction principle can be built into any app.
for example type:\n
- 'debit card limit to 10000'
- 'nearest ATM'
- 'transfer 60 euros to John' (it will not execute but just propose)
- 'show my car insurance'
- 'save 1000 euros'
- 'show all transactions with wall mart'
- payment request 'nice dinner'

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
        body: const SafeArea(
            child: Markdown(
          // controller: controller,
          selectable: true,
          data: _markdownData,
          imageDirectory: 'https://raw.githubusercontent.com',
        )));
  }
}
