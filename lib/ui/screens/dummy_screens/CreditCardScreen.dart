import 'package:flutter/material.dart';
import 'package:langbar/ui/screens/dummy_screens/SampleScreenTemplate.dart';

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

  static const name = 'creditcard';
}
