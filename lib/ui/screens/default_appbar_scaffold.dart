import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../for_langbar_lib/langbar_stuff.dart';
import '../../routes.dart';
import '../utils.dart';

class DefaultAppbarScaffold extends StatefulWidget {
  final Widget body;

  DefaultAppbarScaffold({required this.body, required this.label});

  /// The label
  final String label;

  @override
  State<DefaultAppbarScaffold> createState() => _DefaultAppbarScaffoldState();
}

class _DefaultAppbarScaffoldState extends State<DefaultAppbarScaffold> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: createAppBar(context, widget.label, () {
          var langbar = Provider.of<LangBarState>(context, listen: false);
          langbar.toggleLangbar();
        }),
        // drawer: DefaultDrawer(),
        body: this.widget.body);
  }
}

class DefaultDrawer extends StatefulWidget {
  DefaultDrawer({
    super.key,
  });

  @override
  State<DefaultDrawer> createState() => _DefaultDrawerState();
}

class _DefaultDrawerState extends State<DefaultDrawer> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
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
            title: const Text('Credit card'),
            selected: _selectedIndex == 0,
            onTap: () {
              // Update the state of the app
              goRouter.push("/creditcard");
              // context.push("/creditcard");
              // context.pushReplacement("/creditcard");
              Navigator.pop(context);
              // Then close the drawer
            },
          ),
          ListTile(
            title: const Text('Debit card'),
            selected: _selectedIndex == 0,
            onTap: () {
              // Update the state of the app
              goRouter.push("/debitcard");
              // context.push("/creditcard");
              // context.pushReplacement("/creditcard");
              Navigator.pop(context);
              // Then close the drawer
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
    );
  }
}
