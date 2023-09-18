import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../for_langbar_lib/langbar_stuff.dart';
import '../utils.dart';

const smallSpacing = 10.0;

class FrontScreen extends StatefulWidget {
  /// Creates a RootScreen
  FrontScreen(
      {required this.label, required this.toggleLangbarFunction, Key? key})
      : super(key: key);

  /// The label
  final String label;

  final Function toggleLangbarFunction;

  @override
  State<FrontScreen> createState() => _FrontScreenState();
}

class _FrontScreenState extends State<FrontScreen> {
  final TextEditingController _controllerOutlined = TextEditingController();

  _FrontScreenState();

  int _selectedIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> _widgetOptions = <Widget>[
    Text(
      'Index 0: Home',
      style: optionStyle,
    ),
    Text(
      'Index 1: Business',
      style: optionStyle,
    ),
    Text(
      'Index 2: School',
      style: optionStyle,
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: createAppBar(widget.label, () {
          widget.toggleLangbarFunction();
        }),
        drawer: Drawer(
          // Add a ListView to the drawer. This ensures the user can scroll
          // through the options in the drawer if there isn't enough vertical
          // space to fit everything.
          child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: Text('Drawer Header'),
              ),
              ListTile(
                title: const Text('Creditcard'),
                selected: _selectedIndex == 0,
                onTap: () {
                  // Update the state of the app
                  context.go("/creditcard");
                  // Then close the drawer
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Business'),
                selected: _selectedIndex == 1,
                onTap: () {
                  // Update the state of the app
                  // _onItemTapped(1);
                  // Then close the drawer
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('School'),
                selected: _selectedIndex == 2,
                onTap: () {
                  // Update the state of the app
                  // _onItemTapped(2);
                  // Then close the drawer
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
        body: Consumer<ChatHistory>(
          builder: (context, chatHistory, child) {
            var lastMessage = chatHistory.items.isNotEmpty
                ? chatHistory.items.last
                : HistoryMessage("no message yet", false);
            var children = <Widget>[
              TextButton(
                  onPressed: () {
                    // context.go("/a/:utrecht");
                    context.go("/a?place=utrecht");
                  },
                  child: Text("test")),
              Text('Screen ${widget.label}',
                  style: Theme.of(context).textTheme.titleLarge),
              const Padding(padding: EdgeInsets.all(4)),
              Padding(
            padding: const EdgeInsets.all(smallSpacing),
            child: Text('This screen displays the last response by the LLM:'),
          ),
        ];
        if (!lastMessage.isHuman) {
          children.add(Text(lastMessage.text,
              style: Theme.of(context).textTheme.titleLarge));
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: children,
        );
      },
    ));
  }
}
