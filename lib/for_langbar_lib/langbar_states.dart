import 'package:flutter/material.dart';

import 'langbar_history_storage.dart';

class HistoryMessage {
  HistoryMessage({required this.text, required this.isHuman, this.navUri, time})
      : this.time = time ?? DateTime.now();

  final String? navUri;
  final String text;
  final bool isHuman;
  final DateTime time;
}

class ChatHistory extends ChangeNotifier {
  ChatHistory() {
    init();
  }

  final List<HistoryMessage> items = [];

  late final HistoryProvider historyProvider;

  init() async {
    historyProvider = HistoryProvider();
    await historyProvider.open();
    var historyItemsFromDatabase = await historyProvider.getHistoryItems();
    items.addAll(historyItemsFromDatabase);
    notifyListeners();
  }

  void add(HistoryMessage item) {
    items.add(item);
    historyProvider.insert(item);
    notifyListeners();
  }
}

class LangBarState extends ChangeNotifier {
  bool _historyShowing = false;

  LangBarState({bool enableSpeech = true}) {
    _speechEnabled = enableSpeech;
  }

  bool get historyShowing => _historyShowing;

  bool _speechEnabled = true;

  bool get speechEnabled => _speechEnabled;

  set speechEnabled(bool value) {
    _speechEnabled = value;
    notifyListeners();
  }

  bool _isListeningForSpeech = false;

  bool get listeningForSpeech => _isListeningForSpeech;

  set listeningForSpeech(bool value) {
    _isListeningForSpeech = value;
    notifyListeners();
  }

  // do not use setter here, we use a local textcontroller initialized with this value:
  String text = '';

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
