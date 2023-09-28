import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
  _TransferMoneyScreenState createState() => _TransferMoneyScreenState();

  @override
  String value() => (amount.toString() ?? '') + (destinationName ?? '');
}

class _TransferMoneyScreenState
    extends UpdatingScreenState<TransferMoneyScreen> {
  final TextEditingController _destinationaccountNumberController =
      TextEditingController();
  final TextEditingController _destinationAccountNameController =
      TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  late BankAccount fromAccount;

  @override
  void initOrUpdateWidgetParams() {
    _amountController.text = widget.amount?.toString() ?? '';
    _destinationAccountNameController.text =
        widget.destinationName?.toString() ?? '';
    fromAccount = accounts[widget.fromAccountId]!;
    // TODO: implement initOrUpdateWidgetParams
  }

  void clear() {
    _amountController.clear();
    _destinationAccountNameController.clear();
    _destinationaccountNumberController.clear();
    _descriptionController.clear();
  }

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
