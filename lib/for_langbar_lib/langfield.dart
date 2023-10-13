import 'package:dart_openai/dart_openai.dart' as dart_openai;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:langbar/for_langbar_lib/generic_screen_tool.dart';
import 'package:langbar/for_langbar_lib/speech.dart';
import 'package:langchain/langchain.dart';
import 'package:langchain_openai/langchain_openai.dart';
import 'package:provider/provider.dart';

import '../openAIKey.dart';
import '../routes.dart';
import 'langbar_states.dart';
import 'llm_go_route.dart';

class LangField extends StatefulWidget {
  final bool showHistoryButton;

  const LangField([this.showHistoryButton = false]);

  @override
  State<LangField> createState() => _LangFieldState();
}

class _LangFieldState extends State<LangField> {
  final TextEditingController _controllerOutlined = TextEditingController();

  initState() {
    super.initState();
    var langbarText = context.read<LangBarState>().text;
    _controllerOutlined.text = langbarText;
    _controllerOutlined.addListener(() {
      context.read<LangBarState>().text = _controllerOutlined.text;
    });
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
            submit(langbarState, context);
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
      children.add(SpeechButton(toggleRecording: toggleRecording));
    }
    Row row = Row(mainAxisSize: MainAxisSize.min, children: children);
    return row;
  }

  void submit(LangBarState langbarState, BuildContext context) {
    var apiKey2 = getOpenAIKey();
    var client = OpenAIClient.instanceFor(
        apiKey: apiKey2, apiBaseUrl: openAiApiBaseUrl());
    var sessionToken = getSessionToken();
    if (sessionToken != null) {
      dart_openai.OpenAI.includeHeaders({"session": sessionToken});
    }
    final llm =
        ChatOpenAI(apiClient: client, temperature: 0.0, model: 'gpt-3.5-turbo');
    langbarState.sendingToOpenAI = true;
    sendToOpenai(llm, this._controllerOutlined.text, context);
  }

  final memory = ConversationBufferMemory(returnMessages: true);

  Future toggleRecording() {
    var langbarState = Provider.of<LangBarState>(context, listen: false);
    langbarState.listeningForSpeech = true;
    return Speech.toggleRecording(onResult: (String text) {
      _controllerOutlined.text = text;
      print("result $text");
    }, onListening: (bool isListening, String status) {
      print("listening state $isListening, status $status");
      if (status == "done") {
        var langbarState = Provider.of<LangBarState>(context, listen: false);
        submit(langbarState, context);
        langbarState.listeningForSpeech = false;
        print("sending ${_controllerOutlined.text}");
      }
    });
  }

  Future<void> sendToOpenai(
      ChatOpenAI llm, String query, BuildContext context) async {
    // final forecastTool = ForecastScreen.getTool(GoRouter.of(context));
    // final creditCardTool = CreditCardScreen.getTool(GoRouter.of(context));
    var langbarState = Provider.of<LangBarState>(context, listen: false);
    langbarState.historyShowing = false;
    var tools = parseRouters(GoRouter.of(context), routes);

    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-ddTHH:mm:ssZ').format(now);
    final agent = OpenAIFunctionsAgent.fromLLMAndTools(
        systemChatMessage: SystemChatMessagePromptTemplate(
          prompt: PromptTemplate(
            inputVariables: {},
            template:
                'You are a helpful AI assistant. The current date and time is ${formattedDate}.',
          ),
        ),
        llm: llm,
        tools: tools,
        memory: memory);
    final executor = AgentExecutor(agent: agent);
    // final res = await executor.run('What is 40 raised to the 0.43 power?');
    var response;
    try {
      response = await executor.run(query);
    } catch (e) {
      response = e.toString();
    }
    _controllerOutlined.clear();
    langbarState.sendingToOpenAI = false;
    // if response contains spaces, we assume it is not a path, but a response from the AI (when this becomes too much of a hack, we should start responding from tools with more complex objects with fields etc.
    var chatHistory = Provider.of<ChatHistory>(context, listen: false);
    if (response.contains(' ')) {
      chatHistory.add(HistoryMessage(text: query, isHuman: true));
      chatHistory.add(HistoryMessage(text: response, isHuman: false));
      langbarState.historyShowing = true;
    } else // add the original query, but the navigation-uri-repsonse as the hyperlink when you click on it
      chatHistory
          .add(HistoryMessage(text: query, isHuman: true, navUri: response));
  }

  parseRouters(GoRouter, List<RouteBase> routes, {parentPath}) {
    var tools = <GenericScreenTool>[];
    for (var route in routes) {
      String? newPath = null;
      if (route is GoRoute) {
        // route.path is only the local path. If the route e.g. points to a details screen, we have to prepend the path of the parent:
        newPath = (parentPath != null ? parentPath + "/" : "") + route.path;
      }
      if (route is LlmGoRoute) {
        var tool = GenericScreenTool(
            goRouter: goRouter,
            name: route.name,
            push: route.modal,
            path: newPath!,
            description: route.description,
            parameters: route.parameters);
        tools.add(tool);
      }
      if (route.routes.isNotEmpty) {
        tools.addAll(parseRouters(goRouter, route.routes, parentPath: newPath));
      }
    }
    return tools;
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
  final Function() toggleRecording;

  const SpeechButton({Key? key, required this.toggleRecording})
      : super(key: key);

  @override
  _SpeechButtonState createState() => _SpeechButtonState();
}

class _SpeechButtonState extends State<SpeechButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late ColorTween _colorTween;

  @override
  void initState() {
    super.initState();
    Provider.of<LangBarState>(context, listen: false).addListener(() {
      if (!Provider.of<LangBarState>(context, listen: false).listeningForSpeech)
        _controller.stop();
    });
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
            _controller.repeat(reverse: true);
            widget.toggleRecording();
          });
        },
      );
    });
  }
}
