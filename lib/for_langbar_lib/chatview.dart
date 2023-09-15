import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'langbar_stuff.dart';

ScrollController listScrollController = ScrollController();

class ChatHistoryView extends StatelessWidget {
  ChatHistoryView({required this.messages, super.key});

  List<HistoryMessage> messages = [];

  late List<HistoryMessage> reversedMessages = messages.reversed.toList();

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: 0.0,
          maxHeight: 300.0,
        ),
        child: ListView.builder(
          reverse: true,
          controller: listScrollController,
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: messages.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Align(
                alignment: reversedMessages[index].isHuman
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.fromLTRB(12, 15, 12, 5),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: reversedMessages[index].isHuman
                        ? Colors.blue[50]
                        : const Color.fromARGB(255, 17, 110, 187),
                    borderRadius: const BorderRadius.only(
                      bottomRight: Radius.circular(15.0),
                      topRight: Radius.circular(15.0),
                      topLeft: Radius.circular(15.0),
                      bottomLeft: Radius.circular(15.0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 3,
                        blurRadius: 7,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        var langbarState =
                            Provider.of<LangBarState>(context, listen: false);
                        langbarState.toggleHistoryShowing();
                        context.go(reversedMessages[index].navUri!);
                      },
                      child: Text(
                        reversedMessages[index].text,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: reversedMessages[index].isHuman
                              ? Colors.black
                              : Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ));
  }
}
