import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:langbar/ui/screens/dummy_screens/SampleScreenTemplate.dart';
import 'package:provider/provider.dart';

import '../../../for_langbar_lib/langbar_stuff.dart';
import '../../utils.dart';

class CardScreenSate extends ChangeNotifier {
  String? action;
  int? limit;

  CardScreenSate({this.action, this.limit});

  void setAction(String action) {
    this.action = action;
    notifyListeners();
  }

  void setLimit(int limit) {
    this.limit = limit;
    notifyListeners();
  }
}

class CreditCardScreen extends StatelessWidget {
  final String? action;
  final String label;
  final int? limit;

  CreditCardScreen(
      {required this.label,
      Key? key,
      required Map<String, String> queryParameters,
      this.action,
      this.limit})
      : super(key: key) {}

  static const name = 'creditcard';

  @override
  Widget build(final BuildContext context) {
    return ChangeNotifierProvider(
      create: (final _) => CardScreenSate(action: action, limit: limit),
      child: CreditCardScreenBody(label),
    );
  }
}

class CreditCardScreenBody extends StatelessWidget {
  final String label;

  CreditCardScreenBody(this.label, {super.key});

  final TextEditingController textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<CardScreenSate>(
        builder: (BuildContext context, CardScreenSate state, Widget? child) {
      textEditingController.text = state.limit.toString();
      List<Widget> children = [];
      children.add(TextField(
        controller: textEditingController,
        decoration: const InputDecoration(labelText: 'Limit'),
        keyboardType: TextInputType.number,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly
        ],
        onChanged: (value) {
          state.setLimit(int.parse(value));
        },
      ));
      children.add(Image.network(
          "https://www.visa.com.ag/dam/VCOM/regional/lac/ENG/Default/Pay%20With%20Visa/Find%20a%20Card/Credit%20Cards/Classic/visaclassiccredit-400x225.jpg"));
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
              children: children,
            ),
          ));
    });
  }
}
