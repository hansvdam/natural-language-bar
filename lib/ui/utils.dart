import 'package:flutter/material.dart';

import '../app_bar_stuff.dart';

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

PreferredSizeWidget createAppBar(
    Function() showBottomSheet) {
  return AppBar(
      title: const Text('Langbar'),
      actions: [
        _BottomSheetButton(
          showBottomSheet: showBottomSheet,
        ),
      ]
  );
}

void bottomsheet(BuildContext context) {
  showModalBottomSheet<void>(
    showDragHandle: true,
    context: context,
    // TODO: Remove when this is in the framework https://github.com/flutter/flutter/issues/118619
    // constraints: const BoxConstraints(maxWidth: 640),
    builder: (context) {
      return LangField();
      // return SizedBox(
      //   height: 150,
      //   width: double.infinity,
      //   child: Padding(
      //     padding: const EdgeInsets.symmetric(horizontal: 32.0),
      //     child: ListView(
      //       shrinkWrap: true,
      //       scrollDirection: Axis.horizontal,
      //       children: buttonList,
      //     ),
      //   ),
      // );
    },
  );
}

