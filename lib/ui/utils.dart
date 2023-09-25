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

class HamburgerMenu extends StatelessWidget {
  const HamburgerMenu({
    required this.scaffoldKey,
  });

  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.menu),
      onPressed: () {
        // open drawer on outer scaffold:
        var currentState = scaffoldKey.currentState;
        currentState?.openDrawer();
      },
    );
  }
}

PreferredSizeWidget createAppBar(
    BuildContext context, String title, Function() showBottomSheet,
    {bool leadingHamburger = true}) {
  ScaffoldWithNavigationBar? parentNavigationbarHolder =
      context.findAncestorWidgetOfExactType<ScaffoldWithNavigationBar>();
  var leadingHamburgerAndNoNavigationRail =
      parentNavigationbarHolder != null && leadingHamburger;
  return AppBar(
      title: Text(title),
      leading: leadingHamburgerAndNoNavigationRail
          ? HamburgerMenu(scaffoldKey: scaffoldKey)
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
