import 'package:flutter/material.dart';


PreferredSizeWidget createAppBar(
    Function() showBottomSheet
    ) {
  return AppBar(
    title: const Text('Langbar'),
    actions:  [
      _BottomSheetButton(
        showBottomSheet: showBottomSheet,
      ),
    ]
  );
}

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

