import 'package:flutter/material.dart';
import 'package:langbar/for_langbar_lib/utils.dart';
import 'package:provider/provider.dart';

import '../routes.dart';
import 'langbar_states.dart';
import 'llm_go_route.dart';

ScrollController listScrollController = ScrollController();

class DividerWidget extends StatelessWidget {
  final Color color;

  final int thickness;

  const DividerWidget({
    Key? key,
    this.color = Colors.red,
    this.thickness = 5,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: thickness.toDouble(),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: color,
      ),
    );
  }
}

class HistoryView extends StatelessWidget {
  final double maxHeigth;

  HistoryView({required this.messages, super.key, required this.maxHeigth});

  final List<HistoryMessage> messages;

  late List<HistoryMessage> reversedMessages = messages.reversed.toList();

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: 0.0,
          maxHeight: maxHeigth.toDouble(),
        ),
        child: Column(children: <Widget>[
          GestureDetector(
              onTap: () {
                var langbarState =
                    Provider.of<LangBarState>(context, listen: false);
                langbarState.historyShowing = false;
              },
              child: Container(
                  // width: _size.width,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(20.0),
                        topLeft: Radius.circular(20.0),
                      ),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                            color: Colors.grey,
                            spreadRadius: 0.4,
                            blurRadius: 1.0),
                      ]),
                  height: 20,
                  child: SizedBox(
                    width: 40,
                    child: DividerWidget(
                      thickness: 5,
                      color: Colors.grey,
                    ),
                  ))),
          Expanded(child: getHistoryList())
        ]));
  }

  ListView getHistoryList() {
    return ListView.builder(
      reverse: true,
      controller: listScrollController,
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: messages.length,
      itemBuilder: (context, index) {
        var message = reversedMessages[index];
        return ListTile(
          title: Align(
            alignment:
                message.isHuman ? Alignment.centerRight : Alignment.centerLeft,
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
                          var langbarState =
                              Provider.of<LangBarState>(context, listen: false);
                          langbarState.historyShowing = false;
                          // modal routes are top-routes anyway, so no need dig in subroutes
                          var navUri = message.navUri;
                          var openModal = routes.any((route) {
                            var messagePath =
                                navUri != null ? Uri.parse(navUri).path : null;
                            return route is DocumentedGoRoute &&
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
    );
  }
}
