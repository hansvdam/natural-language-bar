import 'package:flutter/material.dart';

import '../main.dart';

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

PreferredSizeWidget createAppBar(String title, Function() showBottomSheet,
    {bool leadingHamburger = true}) {
  return AppBar(
      title: Text(title),
      leading: leadingHamburger
          ? IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                var currentState = scaffoldKey.currentState;
                // if (currentState?.isEndDrawerOpen ?? false) {
                currentState?.openDrawer();
                // } else {
                //   currentState?.openEndDrawer();
                // }
              },
            )
          : null,
      actions: [
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
