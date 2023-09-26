import 'package:flutter/material.dart';

import '../default_appbar_scaffold.dart';

const smallSpacing = 10.0;
const defaultPadding = 16.0;

class MapScreen extends StatefulWidget {
  final String label;

  final String? atmOrOffice;

  MapScreen({required this.label, Key? key, this.atmOrOffice})
      : super(key: key) {}

  static const name = 'map';

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  String _selectedLocation = 'atms';

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.atmOrOffice ?? 'atms';
  }

  @override
  void didUpdateWidget(MapScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.atmOrOffice != widget.atmOrOffice) {
      _selectedLocation = widget.atmOrOffice ?? 'atms';
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return DefaultAppbarScaffold(
        label: widget.label,
        body: SafeArea(
            child: Column(mainAxisSize: MainAxisSize.max, children: [
          // Text("hoi")
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Flexible(
                  child: RadioListTile<String>(
                    title: const Text('ATMs'),
                value: 'atms',
                groupValue: _selectedLocation,
                onChanged: (String? value) {
                  setState(() {
                    _selectedLocation = value!;
                  });
                },
              )),
              Flexible(
                  child: RadioListTile<String>(
                    title: const Text('Offices'),
                value: 'offices',
                groupValue: _selectedLocation,
                onChanged: (String? value) {
                  setState(() {
                    _selectedLocation = value!;
                  });
                },
              )),
            ],
          ),
          Expanded(
              child: Image(
                  image: AssetImage("assets/images/" +
                      (_selectedLocation == "atms"
                          ? "atms.jpg"
                          : "offices.jpg")))),
        ])));
  }
}
