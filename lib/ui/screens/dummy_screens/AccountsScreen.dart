import 'package:flutter/material.dart';
import 'package:langbar/ui/screens/dummy_screens/SampleScreenTemplate.dart';

const smallSpacing = 10.0;
const defaultPadding = 16.0;

class AccountsScreen extends SampleScreenTemplate {
  AccountsScreen(
      {required String label,
      Key? key,
      required Map<String, String> queryParameters})
      : super(label: label, queryParameters: queryParameters, key: key) {}

  static const name = 'accounts';
}
