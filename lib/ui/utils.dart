import 'package:flutter/material.dart';

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


class ClearButton extends StatelessWidget {
  const ClearButton({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) => IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => controller.clear(),
      );
}

