import 'package:flutter/material.dart';
import 'package:langbar/for_langbar_lib/platform_details.dart';
import 'package:langbar/for_langbar_lib/send_to_llm.dart';
import 'package:langbar/for_langbar_lib/speech.dart';
import 'package:langbar/for_langbar_lib/utils.dart';
import 'package:provider/provider.dart';

import 'langbar_states.dart';

class LangField extends StatefulWidget {
  final bool showHistoryButton;

  const LangField([this.showHistoryButton = false]);

  @override
  State<LangField> createState() => _LangFieldState();
}

class _LangFieldState extends State<LangField> {
  late TextEditingController _controllerOutlined;

  initState() {
    super.initState();
    var langbarState = context.read<LangBarState>();
    _controllerOutlined = langbarState.controllerOutlined;
  }

  @override
  Widget build(BuildContext context) =>
      Consumer<LangBarState>(builder: (context, langbarState, child) {
        return TextField(
          controller: _controllerOutlined,
          maxLines: null,
          textAlignVertical: TextAlignVertical.center,
          textInputAction: TextInputAction.send,
          onSubmitted: (final String value) {
            submit(context);
          },
          decoration: InputDecoration(
            hintText: 'Type here what you want',
            // prevent a line from appearing under the input field
            border: InputBorder.none,
            suffixIcon: createSuffixButtons(langbarState),
            // isDense: true,
            filled: true,
          ),
        );
      });

  Widget? createSuffixButtons(LangBarState langbarState) {
    var isLoading = langbarState.sendingToOpenAI;
    var speechEnabled = langbarState.speechEnabled;
    List<Widget> children = [];
    if (isLoading) {
      children.add(const SizedBox(
          width: 20,
          height: 20,
          child: Padding(
              padding: EdgeInsets.all(2.0),
              child: CircularProgressIndicator())));
    } else if (widget.showHistoryButton) {
      children.add(ShowHistoryButton(langbarState: langbarState));
    }
    if (speechEnabled) {
      children.add(SpeechButton(submit: () => submit(context)));
    }
    Row row = Row(mainAxisSize: MainAxisSize.min, children: children);
    return row;
  }

  void submit(BuildContext context) {
    submitToLLM(context);
  }
}

class ShowHistoryButton extends StatelessWidget {
  final LangBarState langbarState;

  const ShowHistoryButton({super.key, required this.langbarState});

  @override
  Widget build(BuildContext context) {
    bool showHistory = langbarState.historyShowing;
    return IconButton(
        icon: Icon(showHistory ? Icons.arrow_downward : Icons.arrow_upward),
        onPressed: () {
          langbarState.historyShowing = !showHistory;
        });
  }
}

class SpeechButton extends StatefulWidget {
  final Function() submit;

  const SpeechButton({Key? key, required this.submit}) : super(key: key);

  @override
  _SpeechButtonState createState() => _SpeechButtonState();
}

class _SpeechButtonState extends State<SpeechButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late ColorTween _colorTween;

  // make sure to only send the text once, when the user stops speaking:
  bool _alreadyStoppingSpeech = false;

  Future toggleRecording() {
    var langbarState = Provider.of<LangBarState>(context, listen: false);
    if (!langbarState.listeningForSpeech) {
      _controller.repeat(reverse: true);
    }

    onResult(String text) {
      if (!_alreadyStoppingSpeech) {
        langbarState.controllerOutlined.text = text;
      }
      print("result $text");
      langbarLogger.d("result $text");
    }

    onListening(bool isListening, String status) {
      if (isListening) {
        _alreadyStoppingSpeech = false;
        langbarState.listeningForSpeech = true;
      }
      langbarLogger.d("listening state $isListening, status $status");
      var resultComplete = resultCompletelyAvailable(status);
      if (resultComplete && !_alreadyStoppingSpeech) {
        _alreadyStoppingSpeech = true;
        var langbarState = Provider.of<LangBarState>(context, listen: false);
        if (langbarState.controllerOutlined.text.isNotEmpty) {
          widget.submit();
          langbarLogger.d("sending ${langbarState.controllerOutlined.text}");
        }
        langbarState.listeningForSpeech = false;
      }
    }

    return Speech.toggleRecording(onResult: onResult, onListening: onListening);
  }

  // on web the status is "notListening" when the user stops speaking, on mobile it is "done", or rather
  // on web the 'done' status still comes, but after a long time; way too long after. So on web we already respond
  // to the 'notListening' status, but we have to ignore the results after that, hence the _alreadyStoppingSpeech variable (ugh...).
  bool resultCompletelyAvailable(String status) {
    if (PlatformDetails().isWeb) {
      return status == "notListening";
    } else {
      return status == "done";
    }
  }

  VoidCallback? _listener;
  LangBarState? langbarState;

  @override
  void initState() {
    super.initState();
    langbarState = Provider.of<LangBarState>(context, listen: false);
    _listener = () {
      if (!langbarState!.listeningForSpeech) _controller.stop();
      langbarLogger.d("stop mic animation");
    };
    langbarState!.addListener(_listener!);
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    // following is necessary to make the color of the Iconbutton animate (since IconButton does not animate natively):
    _controller.addListener(() {
      setState(() {});
    });
    _colorTween = ColorTween(begin: Colors.lightGreen, end: Colors.greenAccent);
  }

  @override
  void dispose() {
    langbarState?.removeListener(_listener!);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LangBarState>(builder: (context, langbarState, child) {
      bool listeningForSpeech = langbarState.listeningForSpeech;
      var themeData = Theme.of(context);
      return IconButton(
        style: IconButton.styleFrom(
            backgroundColor:
                listeningForSpeech ? _colorTween.evaluate(_controller) : null),
        icon: listeningForSpeech ? Icon(Icons.hearing) : Icon(Icons.mic),
        color: listeningForSpeech
            ? themeData.colorScheme.primary
            : themeData.colorScheme.onSurface,
        onPressed: () {
          setState(() {
            toggleRecording();
          });
        },
      );
    });
  }
}
