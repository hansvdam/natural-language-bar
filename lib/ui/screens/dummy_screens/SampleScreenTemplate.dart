import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../for_langbar_lib/langbar_stuff.dart';
import '../../utils.dart';

const smallSpacing = 10.0;
const defaultPadding = 16.0;

class SampleScreenTemplate extends StatefulWidget {
  final Map<String, String> _queryParameters;

  SampleScreenTemplate(
      {required this.label,
      Key? key,
      required Map<String, String> queryParameters})
      : _queryParameters = queryParameters,
        super(key: key) {}

  final String label;


  @override
  State<SampleScreenTemplate> createState() => _SampleScreenTemplateState();
}

class _SampleScreenTemplateState extends State<SampleScreenTemplate> {
  _SampleScreenTemplateState();


  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    children.add(
      Text("recieved parameters: ${widget._queryParameters}"),
    );
    return Scaffold(
        appBar: createAppBar(context, widget.label, () {
          var langbar = Provider.of<LangBarState>(context, listen: false);
          langbar.toggleLangbar();
        }, leadingHamburger: false),
        body: Padding(
          padding: const EdgeInsets.only(
              left: defaultPadding, right: defaultPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: children,
          ),
        ));
  }
}
