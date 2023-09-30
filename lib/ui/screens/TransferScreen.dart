import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../utils/name_matcher.dart';
import '../models/account.dart';
import '../param_change_detecting_screens.dart';
import 'default_appbar_scaffold.dart';

class TransferScreen extends DefaultAppbarScreen {
  TransferScreen(
      {required super.label,
      Key? key,
      fromAccountId = "1",
      amount,
      destinationName})
      : super(
            body: TransferMoneyScreen(amount, destinationName, fromAccountId),
            key: key) {}

  static const name = 'transfer';
}

class TransferMoneyScreen extends ChangeDetectingStatefulWidget {
  final double? amount;

  final String? destinationName;

  final String fromAccountId;

  const TransferMoneyScreen(
      this.amount, this.destinationName, this.fromAccountId,
      {super.key});

  @override
  _TheFutureState createState() => _TheFutureState();

  @override
  String value() => (amount.toString() ?? '') + (destinationName ?? '');
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
            return TransferContentWidget(widget.amount,
                mostLikelyDestinationAccount, widget.fromAccountId);
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
    return findMatchingContact(contacts, s);
  }
}

class TransferContentWidget extends ChangeDetectingStatefulWidget {
  final double? amount;

  final Contact? destinationContact;

  final String fromAccountId;

  const TransferContentWidget(
      this.amount, this.destinationContact, this.fromAccountId,
      {super.key});

  @override
  TransferContentState createState() => TransferContentState();

  @override
  String value() =>
      (amount.toString() ?? '') + (destinationContact?.name ?? '');
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
    _amountController.text = widget.amount?.toString() ?? '';
    _destinationAccountNameController.text =
        widget.destinationContact?.name.toString() ?? '';
    _destinationaccountNumberController.text =
        widget.destinationContact?.iban ?? '';
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
      children: [
        Text("from:"),
        ListTile(
          title: Text(
            fromAccount.name,
          ),
          subtitle: Text(
            fromAccount.number,
          ),
          trailing: Text(
            "€ ${fromAccount.balance.toString()}",
          ),
        ),
        TextField(
          controller: _amountController,
          decoration: const InputDecoration(labelText: 'Amount'),
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
        ElevatedButton(
          onPressed: () {
            clear();
            context.go("/home");
          },
          child: const Text('Transfer'),
        ),
      ],
    );
  }
}
