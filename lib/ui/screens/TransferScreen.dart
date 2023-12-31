import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../utils/name_matcher.dart';
import '../models/account.dart';
import '../param_change_detecting_screens.dart';
import '../utils.dart';
import 'default_appbar_scaffold.dart';

class TransferScreen extends DefaultAppbarScreen {
  TransferScreen({required super.label,
      Key? key,
      fromAccountId = "1",
      amount,
      destinationName,
      description})
      : super(
            body: TransferMoneyScreen(
                amount, destinationName, description, fromAccountId),
            key: key) {}

  static const name = 'transfer_money';
}

class TransferMoneyScreen extends ChangeDetectingStatefulWidget {
  final double? amount;

  final String? destinationName;
  final String? description;

  final String fromAccountId;

  const TransferMoneyScreen(this.amount, this.destinationName, this.description, this.fromAccountId,
      {super.key});

  @override
  _TheFutureState createState() => _TheFutureState();

  @override
  String value() =>
      (amount.toString() ?? '') + (destinationName ?? '') + (description ?? '');
}

class _TheFutureState extends UpdatingScreenState<TransferMoneyScreen> {
  late Future<Contact?> mostLikelyDestinationAccountFuture;
  late BankAccount fromAccount;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Contact?>(
        future: mostLikelyDestinationAccountFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            var mostLikelyDestinationAccount = snapshot.data;
            return TransferContentWidget(
                widget.amount,
                mostLikelyDestinationAccount,
                widget.description,
                widget.fromAccountId);
          }
        });
  }

  @override
  void initOrUpdateWidgetParams() {
    if (widget.destinationName != null) {
      mostLikelyDestinationAccountFuture =
          findMostlikelyDestinationContact(widget.destinationName!);
    } else {
      mostLikelyDestinationAccountFuture = Future(() => null);
    }
    fromAccount = accounts[widget.fromAccountId]!;
  }

  Future<Contact?> findMostlikelyDestinationContact(String s) async {
    var contacts = await readContactsFromCsv(context);
    // insert a dummy iban if contact not in list; just for demo purposes (better than empty field):
    return findMatchingContact(contacts, s) ?? Contact(s, "GB33BUKB202015555");
  }
}

class TransferContentWidget extends ChangeDetectingStatefulWidget {
  final double? amount;

  final Contact? destinationContact;

  final String? description;

  final String fromAccountId;

  const TransferContentWidget(this.amount, this.destinationContact,
      this.description, this.fromAccountId,
      {super.key});

  @override
  TransferContentState createState() => TransferContentState();

  @override
  String value() =>
      (amount.toString() ?? '') +
          (destinationContact?.name ?? '') +
          (description ?? '');
}

class TransferContentState extends UpdatingScreenState<TransferContentWidget> {
  final TextEditingController _destinationaccountNumberController =
  TextEditingController();
  final TextEditingController _destinationAccountNameController =
  TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  late BankAccount fromAccount;

  @override
  void initState() {
    super.initState();
    initOrUpdateWidgetParams();
  }

  @override
  void initOrUpdateWidgetParams() {
    animateFieldContent(widget.amount?.toStringAsFixed(2), _amountController)
        .then((_) => animateFieldContent(
            widget.destinationContact?.name, _destinationAccountNameController))
        .then((_) => animateFieldContent(widget.destinationContact?.iban,
            _destinationaccountNumberController))
        .then((_) =>
            animateFieldContent(widget.description, _descriptionController));
    fromAccount = accounts[widget.fromAccountId]!;
  }

  void clear() {
    _amountController.clear();
    _destinationAccountNameController.clear();
    _destinationaccountNumberController.clear();
    _descriptionController.clear();
  }

  ///
  /// ******* look for flutter material autocomplete***********
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text("from:"),
        ListTile(
          title: Text(
            fromAccount.name,
          ),
          subtitle: Text(
            fromAccount.number,
          ),
        ),
        TextField(
          controller: _amountController,
          decoration: const InputDecoration(
            labelText: 'Amount',
            prefixText: '€ ',
          ),
        ),
        TextField(
          controller: _destinationAccountNameController,
          decoration: const InputDecoration(labelText: 'To'),
        ),
        TextField(
          controller: _destinationaccountNumberController,
          decoration: const InputDecoration(labelText: 'Account Number'),
        ),
        TextField(
          controller: _descriptionController,
          decoration: const InputDecoration(labelText: 'Description'),
        ),
        SizedBox(height: 20),
        Center(
            child: FilledButton(
              onPressed: () {
                // need to clear the transfer screen somehow:
                context.go("/" + TransferScreen.name);
            var goRouter = GoRouter.of(context);
            // ugly trick, but we need to clear the Transfer screen first.
            // tried many things, but this is the only thing that works.
            Future.delayed(Duration(milliseconds: 50), () {
              goRouter.go("/home");
            });
          },
              child: const Text('Transfer'),
            )),
      ],
    );
  }
}
