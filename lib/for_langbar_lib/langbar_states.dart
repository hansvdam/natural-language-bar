import 'package:flutter/material.dart';

class HistoryMessage {
  HistoryMessage(this.text, this.isHuman, {this.navUri});

  final String? navUri;
  final String text;
  final bool isHuman;
}

class ChatHistory extends ChangeNotifier {
  final List<HistoryMessage> items = [];

  void add(HistoryMessage item) {
    items.add(item);
    notifyListeners();
  }
}

class LangBarState extends ChangeNotifier {
  bool _historyShowing = false;

  bool get historyShowing => _historyShowing;

  set historyShowing(bool value) {
    _historyShowing = value;
    notifyListeners();
  }

  bool _showLangbar = true;
  bool _sendingToOpenAI = false;

  bool get sendingToOpenAI => _sendingToOpenAI;
  bool get showLangbar => _showLangbar;

  set showLangbar(bool value) {
    _showLangbar = value;
    notifyListeners();
  }

  set sendingToOpenAI(bool value) {
    _sendingToOpenAI = value;
    notifyListeners();
  }

  void toggleLangbar() {
    showLangbar = !showLangbar;
  }
}
