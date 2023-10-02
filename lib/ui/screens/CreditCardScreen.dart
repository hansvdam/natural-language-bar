import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:langbar/ui/screens/dummy_screens/SampleScreenTemplate.dart';
import 'package:provider/provider.dart';

import '../../for_langbar_lib/langbar_states.dart';
import '../utils.dart';

enum ActionOnCard {
  cancel,
  replace,
  none;

  static ActionOnCard? fromString(String? title) {
    return ActionOnCard.values.firstWhere((element) => element.name == title,
        orElse: () => ActionOnCard.none);
  }
}

class CardScreenSate extends ChangeNotifier {
  ActionOnCard action = ActionOnCard.none;
  int? limit;

  CardScreenSate({action, this.limit}) {
    if (action != null) {
      this.action = action;
    } else {
      this.action = ActionOnCard.none;
    }
  }

  void setAction(ActionOnCard action) {
    this.action = action;
    notifyListeners();
  }

  void setLimit(int limit) {
    this.limit = limit;
    notifyListeners();
  }
}

class CreditCardScreen extends StatelessWidget {
  final ActionOnCard? action;
  final String label;
  final int? limit;
  final String imageSrc;

  CreditCardScreen(
      {required this.label,
      required this.imageSrc,
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
      child: CreditCardScreenBody(label, imageSrc),
    );
  }
}

class CreditCardScreenBody extends StatelessWidget {
  final String label;
  final String imageSrc;

  CreditCardScreenBody(this.label, this.imageSrc, {super.key});

  final TextEditingController textEditingController = TextEditingController();
  final TextEditingController actionController = TextEditingController();

  ActionOnCard? selectedIcon = ActionOnCard.none;

  @override
  Widget build(BuildContext context) {
    return Consumer<CardScreenSate>(
        builder: (BuildContext context, CardScreenSate state, Widget? child) {
      textEditingController.text = (state.limit ?? '').toString();
      actionController.text = state.action.name;
      final List<DropdownMenuEntry<ActionOnCard>> actionEntries =
          <DropdownMenuEntry<ActionOnCard>>[];
      for (final ActionOnCard action in ActionOnCard.values) {
        actionEntries.add(
            DropdownMenuEntry<ActionOnCard>(value: action, label: action.name));
      }
      List<Widget> children = [];
      children.add(Image.network(imageSrc));
      var actionRow = Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SizedBox(
              width: 100,
              child: TextField(
                controller: textEditingController,
                decoration: const InputDecoration(labelText: 'Limit'),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
                onChanged: (value) {
                  state.setLimit(int.parse(value));
                },
              )),
          DropdownMenu<ActionOnCard>(
              controller: actionController,
              leadingIcon: const Icon(Icons.search),
              label: const Text('Action'),
              dropdownMenuEntries: actionEntries,
              onSelected: (icon) {
                state.setAction(icon!);
              }),
        ],
      );
      children.add(const SizedBox(height: 20));
      children.add(actionRow);
      children.add(const SizedBox(height: 20));
      children.add(FilledButton(
          onPressed: () {
            Navigator.pop(context, state.action);
          },
          child: const Text('Submit')));
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
