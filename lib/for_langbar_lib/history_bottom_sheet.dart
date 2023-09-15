import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'chatview.dart';
import 'langbar_stuff.dart';

PersistentBottomSheetController? bottomsheetController;

bool isBottomsheetOpen() {
  return bottomsheetController != null;
}

void setBottomsheetBuilderContext(BuildContext context) {
  _builderContext = context;
}

BuildContext? _builderContext;

void toggleChatHistoryBottomSheet() {
  if (bottomsheetController != null) {
    bottomsheetController?.close();
    bottomsheetController = null;
    return;
  }
  bottomsheetController = showBottomSheet<void>(
      // showDragHandle: true,
      context: _builderContext!,
      // TODO: Remove when this is in the framework https://github.com/flutter/flutter/issues/118619
      // constraints: const BoxConstraints(maxWidth: 640),
      builder: (context) {
        // children.add(LangField());
        return Column(mainAxisSize: MainAxisSize.min, children: [
          Consumer<ChatHistory>(builder: (context, chathistory, child) {
            return ChatHistoryView(messages: chathistory.items);
          }),
        ]);
      });
}
