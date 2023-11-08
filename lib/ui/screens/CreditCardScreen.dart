import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_network/image_network.dart';
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
  ActionOnCard _action = ActionOnCard.none;

  // is this the first time the screen is shown? (to be able to
  // animate values injected from the outside (by the router)):
  bool _initial = true;

  bool get initial => _initial;

  set initial(bool value) {
    _initial = value;
  }

  CardScreenSate({action, int? limit}) : _limit = limit {
    if (action != null) {
      _action = action;
    } else {
      _action = ActionOnCard.none;
    }
  }

  ActionOnCard get action => _action;

  set action(ActionOnCard action) {
    _action = action;
    _initial = false;
    notifyListeners();
  }

  int? _limit;

  int? get limit => _limit;

  set limit(int? limit) {
    _limit = limit;
    _initial = false;
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
      super.key,
      this.action,
      this.limit})
      : super() {}

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
      if (state.initial) {
        state.initial = false;
        if (state.action == ActionOnCard.none) {
          actionController.text = state.action.name;
        }
        animateFieldContent(
                (state.limit ?? '').toString(), textEditingController)
            .then((_) {
          if (state.action != ActionOnCard.none) {
            animateFieldContent(state.action.name, actionController);
          }
        });
      }
      //     // textEditingController.text = (state._limit ?? '').toString();
      // actionController.text = state.action.name;
      final List<DropdownMenuEntry<ActionOnCard>> actionEntries =
          <DropdownMenuEntry<ActionOnCard>>[];
      for (final ActionOnCard action in ActionOnCard.values) {
        actionEntries.add(
            DropdownMenuEntry<ActionOnCard>(value: action, label: action.name));
      }
      List<Widget> children = [];
      children.add(Center(
          child: ImageNetwork(
              image: imageSrc,
              height: 150,
              width: 300,
              fitWeb: BoxFitWeb.contain,
              fitAndroidIos: BoxFit.contain)));
      // children.add(Center(child: Image.network(imageSrc))); // has CORS problems
      var actionRow = Row(
        crossAxisAlignment: CrossAxisAlignment.end,
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
                  state.limit = int.tryParse(value);
                },
              )),
          DropdownMenu<ActionOnCard>(
              controller: actionController,
              label: const Text('Action'),
              dropdownMenuEntries: actionEntries,
              onSelected: (action) {
                state.action = action!;
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
