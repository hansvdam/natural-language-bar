import 'package:flutter/material.dart';
import 'package:langbar/for_langbar_lib/utils.dart';
import 'package:provider/provider.dart';

import '../routes.dart';
import 'langbar_states.dart';
import 'llm_go_route.dart';

ScrollController listScrollController = ScrollController();

class HistoryView extends StatelessWidget {
  HistoryView({required this.messages, super.key});

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
            var message = reversedMessages[index];
            return ListTile(
              title: Align(
                alignment: message.isHuman
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.fromLTRB(12, 15, 12, 5),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: message.isHuman
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
                    cursor: message.navUri != null
                        ? SystemMouseCursors.click
                        : MouseCursor.defer,
                    child: GestureDetector(
                      onTap: message.navUri != null
                          ? () {
                              var langbarState = Provider.of<LangBarState>(
                                  context,
                                  listen: false);
                              langbarState.historyShowing = false;
                              // modal routes are top-routes anyway, so no need dig in subroutes
                              var navUri = message.navUri;
                              var openModal = routes.any((route) {
                                var messagePath = navUri != null
                                    ? Uri.parse(navUri).path
                                    : null;
                                return route is LlmGoRoute &&
                                    route.path == messagePath &&
                                    route.modal;
                              });
                              activateUri(navUri!, openModal);
                            }
                          : null,
                      child: Text(
                        message.text,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: message.isHuman ? Colors.black : Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                          decoration: message.navUri != null
                              ? TextDecoration.underline
                              : null,
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
