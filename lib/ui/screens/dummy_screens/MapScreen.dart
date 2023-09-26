import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

import '../default_appbar_scaffold.dart';

const smallSpacing = 10.0;
const defaultPadding = 16.0;

class MapScreen extends StatefulWidget {
  final String label;

  MapScreen(
      {required this.label,
      Key? key,
      required Map<String, String> queryParameters})
      : super(key: key) {}

  static const name = 'map';

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return DefaultAppbarScaffold(
        label: widget.label,
        body: SafeArea(
            child: Container(
                child: PhotoView(
          imageProvider: AssetImage("assets/images/atms.jpg"),
        ))));
  }
}
