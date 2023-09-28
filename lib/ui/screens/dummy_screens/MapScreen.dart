import 'package:flutter/material.dart';

import '../../param_change_detecting_screens.dart';
import '../default_appbar_scaffold.dart';

class MapScreen extends ChangeDetectingStatefulWidget {
  final String label;

  final String? atmOrOffice;

  MapScreen({required this.label, Key? key, this.atmOrOffice})
      : super(key: key) {}

  static const name = 'map';

  @override
  State<MapScreen> createState() => _MapScreenState();

  @override
  String value() {
    return atmOrOffice ?? "";
  }
}

class _MapScreenState extends UpdatingScreenState<MapScreen> {
  String _selectedLocation = 'atms';

  @override
  void initOrUpdateWidgetParams() {
    _selectedLocation = widget.atmOrOffice ?? 'atms';
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
