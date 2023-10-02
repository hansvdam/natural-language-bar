import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../for_langbar_lib/langbar_states.dart';
import '../../utils.dart';

const smallSpacing = 10.0;
const defaultPadding = 16.0;

class SampleScreenTemplate extends StatelessWidget {
  final Map<String, String> queryParameters;

  SampleScreenTemplate(
      {required this.label,
      Key? key,
      required Map<String, String> queryParameters})
      : queryParameters = queryParameters,
        super(key: key) {}

  final String label;


  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    children.add(
      Text(
          "The $label is not implemented yet, but the navigation structure works."),
    );
    for(var key in queryParameters.keys) {
      children.add(Text("$key: ${queryParameters[key]}"));
    }
    return Scaffold(
        appBar: createAppBar(context, label, () {
          var langbar = Provider.of<LangBarState>(context, listen: false);
          langbar.toggleLangbar();
        }, leadingHamburger: false),
        body: Padding(
          padding: const EdgeInsets.only(
              left: defaultPadding, right: defaultPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ));
  }
}
