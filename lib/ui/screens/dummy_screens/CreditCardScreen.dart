import 'package:flutter/material.dart';
import 'package:langbar/ui/screens/dummy_screens/SampleScreenTemplate.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../for_langbar_lib/langbar_stuff.dart';
import '../../utils.dart';

class CreditCardScreen extends StatefulWidget {
  final Map<String, String> _queryParameters;

  CreditCardScreen(
      {required this.label,
      Key? key,
      required Map<String, String> queryParameters})
      : _queryParameters = queryParameters,
        super(key: key) {}

  final String label;

  static const name = 'creditcard';

  @override
  State<CreditCardScreen> createState() => _CreditCardScreenState();
}

class _CreditCardScreenState extends State<CreditCardScreen> {
  _CreditCardScreenState();

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    children.add(
      Text(
          "The ${widget.label} is not implemented yet, but the structure works."),
    );
    children.add(Image.network(
        "https://www.visa.com.ag/dam/VCOM/regional/lac/ENG/Default/Pay%20With%20Visa/Find%20a%20Card/Credit%20Cards/Classic/visaclassiccredit-400x225.jpg"));
    children.add(
      Text(
          "recieved parameters from llm function calling\n: ${widget._queryParameters}"),
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
