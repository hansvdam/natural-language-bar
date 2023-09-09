import 'package:flutter/material.dart';

import '../../app_bar_stuff.dart';
import '../utils.dart';

const smallSpacing = 10.0;

class ForecastScreen extends StatefulWidget {
  /// Creates a RootScreen
  const ForecastScreen(
      {required this.label,
      required this.detailsPath,
      required this.bottomSheetFunction,
      Key? key})
      : super(key: key);

  /// The label
  final String label;

  /// The path to the detail page
  final String detailsPath;

  final Function bottomSheetFunction;

  @override
  State<ForecastScreen> createState() => _ForecastScreenState();
}

class _ClearButton extends StatelessWidget {
  const _ClearButton({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) => IconButton(
    icon: const Icon(Icons.clear),
    onPressed: () => controller.clear(),
  );
}

class _ForecastScreenState extends State<ForecastScreen> {
  final TextEditingController _controllerOutlined = TextEditingController();

  _ForecastScreenState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: createAppBar(() {
        widget.bottomSheetFunction(context);
      }),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('Screen ${widget.label}',
                style: Theme.of(context).textTheme.titleLarge),
            const Padding(padding: EdgeInsets.all(4)),
            Padding(
              padding: const EdgeInsets.all(smallSpacing),
              child: TextField(
                controller: _controllerOutlined,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _ClearButton(controller: _controllerOutlined),
                  labelText: 'Outlined',
                  hintText: 'hint text',
                  helperText: 'supporting text',
                  border: const OutlineInputBorder(),
                ),
              ),
            ),          ],
        ),
      ),
    );
  }

  void bottomsheet(BuildContext context) {
    showModalBottomSheet<void>(
      showDragHandle: true,
      context: context,
      // TODO: Remove when this is in the framework https://github.com/flutter/flutter/issues/118619
      // constraints: const BoxConstraints(maxWidth: 640),
      builder: (context) {
        return LangField();
        // return SizedBox(
        //   height: 150,
        //   width: double.infinity,
        //   child: Padding(
        //     padding: const EdgeInsets.symmetric(horizontal: 32.0),
        //     child: ListView(
        //       shrinkWrap: true,
        //       scrollDirection: Axis.horizontal,
        //       children: buttonList,
        //     ),
        //   ),
        // );
      },
    );
  }
}

