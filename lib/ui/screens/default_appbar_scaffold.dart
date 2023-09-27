import 'package:flutter/material.dart';
import 'package:langbar/ui/screens/forecast_screen.dart';
import 'package:provider/provider.dart';

import '../../for_langbar_lib/langbar_stuff.dart';
import '../../routes.dart';
import '../main_scaffolds.dart';
import '../utils.dart';
import 'dummy_screens/CreditCardScreen.dart';
import 'dummy_screens/DebitCardScreen.dart';

class DefaultAppbarScreen extends StatelessWidget {
  final String label;

  final Widget body;

  DefaultAppbarScreen({required this.label, required this.body, Key? key})
      : super(key: key) {}

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return DefaultAppbarScaffold(
        label: label,
        body: SafeArea(
            child: Padding(
                padding: const EdgeInsets.only(
                    top: smallSpacing, left: smallSpacing, right: smallSpacing),
                child: body)));
  }
}

class DefaultAppbarScaffold extends StatelessWidget {
  final Widget body;

  DefaultAppbarScaffold({required this.body, required this.label});

  /// The label
  final String label;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: createAppBar(context, label, () {
          var langbar = Provider.of<LangBarState>(context, listen: false);
          langbar.toggleLangbar();
        }),
        // drawer: DefaultDrawer(),
        body: this.body);
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
          DrawerItem(
              selectedIndex: _selectedIndex,
              label: "Credit Card",
              path: '/${CreditCardScreen.name}'),
          DrawerItem(
              selectedIndex: _selectedIndex,
              label: "Debit Card",
              path: '/${DebitCardScreen.name}'),
          DrawerItem(
              selectedIndex: _selectedIndex,
              label: "Weather",
              path: '/${ForecastScreen.name}'),
        ],
      ),
    );
  }
}

class DrawerItem extends StatelessWidget {
  const DrawerItem({
    super.key,
    required int selectedIndex,
    required this.label,
    required this.path,
  }) : _selectedIndex = selectedIndex;

  final int _selectedIndex;

  final String label;
  final String path;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      selected: _selectedIndex == 0,
      onTap: () {
        goRouter.push(path);
        Navigator.pop(context);
      },
    );
  }
}
