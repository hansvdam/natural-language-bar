import 'package:flutter/material.dart';

class HistoryMessage {
  HistoryMessage(this.text, this.isHuman, {this.navUri});

  final String? navUri;
  final String text;
  final bool isHuman;
}

class ChatHistory extends ChangeNotifier {
  bool value = false;

  /// Internal, private state of the cart.
  final List<HistoryMessage> items = [HistoryMessage("Hello", false)];

  void add(HistoryMessage item) {
    items.add(item);
    notifyListeners();
  }
}

class LangBarState extends ChangeNotifier {
  bool historyShowing = false;
  bool showLangbar = true;

  void setHistoryShowing(bool value) {
    historyShowing = value;
    notifyListeners();
  }

  void setShowLangbar(bool value) {
    showLangbar = value;
    notifyListeners();
  }

  void toggleLangbar() {
    showLangbar = !showLangbar;
    notifyListeners();
  }
}
