import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'main_scaffolds.dart';

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
      message: 'Toggle Langbar',
      child: IconButton(
        icon: const Icon(Icons.short_text_outlined),
        onPressed: () {
          toggleLangbar();
        },
      ),
    );
  }
}

Future<void> animateFieldContent(
    String? injectedContent, TextEditingController textController) async {
  if (injectedContent == null || injectedContent.isEmpty) {
    return;
  }

  var length = injectedContent.length;
  var periodLength = (500 / length).toInt();
  var completer = Completer();

  Timer.periodic(Duration(milliseconds: periodLength), (timer) {
    if (textController.text.length < length) {
      textController.text =
          injectedContent.substring(0, textController.text.length + 1);
    } else {
      timer.cancel();
      textController.notifyListeners();
      if (!completer.isCompleted) {
        completer.complete();
      }
    }
  });
  await completer.future;
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
  // trigger when screen goes from and to navigation rail:
  Provider.of<WidthChanged>(context, listen: true);
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
