import 'package:flutter/material.dart';
import 'package:langbar/for_langbar_lib/platform_details.dart';

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

  HistoryProvider? historyProvider;

  init() async {
    if (!PlatformDetails().isWeb) {
      // sqlite does not wrk on web (maybe move to sharedprefs at some point)
      historyProvider = HistoryProvider();
      await historyProvider?.open();
      var historyItemsFromDatabase =
          await historyProvider?.getHistoryItems() ?? <HistoryMessage>[];
      items.addAll(historyItemsFromDatabase);
      notifyListeners();
    }
  }

  void add(HistoryMessage item) {
    items.add(item);
    historyProvider?.insert(item);
    notifyListeners();
  }
}

enum ChatSheetExpansion { part, full }

var screenheight =
    1000; // store the current screen height, so we can adjust the history height accordingly

class LangBarState extends ChangeNotifier {
  final TextEditingController controllerOutlined = TextEditingController();

  // states changes when the user sends a message:
  // - last item by the system: action/function -> hide history after typing
  // - last item by the system: text -> show full history after typing
  bool _historyShowing = false;

  var _historyHeight = 1000;

  LangBarState({bool enableSpeech = true}) {
    _speechEnabled = enableSpeech;
  }

  bool get historyShowing => _historyShowing;

  set historyShowing(bool value) {
    _historyShowing = value;
    notifyListeners();
  }

  bool _speechEnabled = true;

  bool get speechEnabled => _speechEnabled;

  int get historyHeight => _historyHeight;

  set historyExpansion(ChatSheetExpansion value) {
    switch (value) {
      case ChatSheetExpansion.part:
        _historyHeight = screenheight ~/ 3;
        break;
      case ChatSheetExpansion.full:
        _historyHeight = screenheight;
        break;
    }
    notifyListeners();
  }

  set speechEnabled(bool value) {
    _speechEnabled = value;
    notifyListeners();
  }

  bool _isListeningForSpeech = false;

  bool get listeningForSpeech => _isListeningForSpeech;

  set listeningForSpeech(bool value) {
    if (_isListeningForSpeech != value) {
      _isListeningForSpeech = value;
      notifyListeners();
    }
  }

  // do not use setter here, we use a local textcontroller initialized with this value:
  String text = '';

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
