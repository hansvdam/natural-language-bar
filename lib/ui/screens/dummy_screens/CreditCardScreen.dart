import 'package:flutter/material.dart';
import 'package:langbar/for_langchain/tool.dart';
import 'package:langbar/ui/screens/dummy_screens/SampleScreenTemplate.dart';

import '../../../for_langbar_lib/generic_screen_tool.dart';

const smallSpacing = 10.0;
const defaultPadding = 16.0;

class CreditCardScreen extends SampleScreenTemplate {
  CreditCardScreen(
      {required String label,
      required Function toggleLangbarFunction,
      Key? key,
      required Map<String, String> queryParameters})
      : super(
            label: label,
            toggleLangbarFunction: toggleLangbarFunction,
            queryParameters: queryParameters,
            key: key) {}

  static const _creditLimit = Parameter(
      'limit', 'string', 'new limit for the creditcard',
      required: false);
  static const _parameters = [_creditLimit];
  static const name = 'creditcard';

  static getTool(BuildContext context) {
    return GenericScreenTool(
        context,
        name,
        'raise the limit of the you creditcard or show the current limit',
        _parameters);
  }
}
