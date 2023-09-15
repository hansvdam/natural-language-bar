import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../for_langbar_lib/chatview.dart';
import '../for_langbar_lib/langbar_stuff.dart';

class _BottomSheetButton extends StatelessWidget {
  const _BottomSheetButton({
    required this.toggleLangbar,
    this.showTooltipBelow = true,
  });

  final Function toggleLangbar;
  final bool showTooltipBelow;

  @override
  Widget build(BuildContext context) {
    final isBright = Theme.of(context).brightness == Brightness.light;
    return Tooltip(
      preferBelow: showTooltipBelow,
      message: 'Toggle brightness',
      child: IconButton(
        icon: const Icon(Icons.short_text_outlined),
        onPressed: () {
          toggleLangbar();
        },
      ),
    );
  }
}

PreferredSizeWidget createAppBar(Function() showBottomSheet) {
  return AppBar(title: const Text('Langbar'), actions: [
    _BottomSheetButton(
      toggleLangbar: showBottomSheet,
    ),
  ]);
}

PersistentBottomSheetController? bottomsheetController;

class ClearButton extends StatelessWidget {
  const ClearButton({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) => IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => controller.clear(),
      );
}

void bottomsheet(BuildContext context, [bool? forceOpen]) {
  if (bottomsheetController != null && forceOpen == null) {
    bottomsheetController?.close();
    bottomsheetController = null;
    return;
  }
  bottomsheetController = showBottomSheet<void>(
    // showDragHandle: true,
    context: context,
    // TODO: Remove when this is in the framework https://github.com/flutter/flutter/issues/118619
    // constraints: const BoxConstraints(maxWidth: 640),
    builder: (context) {
      return Consumer<LangBarState>(builder: (context, langbarState, child) {
        List<Widget> children = [];
        if (langbarState.showHistory) {
          children.add(
            Consumer<ChatHistory>(builder: (context, chathistory, child) {
              return ChatHistoryView(messages: chathistory.items);
            }),
          );
        }
        // children.add(LangField());
        return Column(mainAxisSize: MainAxisSize.min, children: children);
      });
    },
  );
}
