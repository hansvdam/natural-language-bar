import 'package:flutter/material.dart';

import '../param_change_detecting_screens.dart';
import 'default_appbar_scaffold.dart';

class TransferScreen extends DefaultAppbarScreen {
  TransferScreen({required super.label, Key? key, amount, destinationName})
      : super(body: TransferMoneyScreen(amount, destinationName), key: key) {}

  static const name = 'transfer';
}

class TransferMoneyScreen extends ChangeDetectingStatefulWidget {
  final double? amount;

  final String? destinationName;

  const TransferMoneyScreen(this.amount, this.destinationName, {super.key});

  @override
  _TransferMoneyScreenState createState() => _TransferMoneyScreenState();

  @override
  String value() => (amount.toString() ?? '') + (destinationName ?? '');
}

class _TransferMoneyScreenState
    extends UpdatingScreenState<TransferMoneyScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _accountController = TextEditingController();

  @override
  void initOrUpdateWidgetParams() {
    _amountController.text = widget.amount?.toString() ?? '';
    _accountController.text = widget.destinationName?.toString() ?? '';
    // TODO: implement initOrUpdateWidgetParams
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transfer Money')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _accountController,
              decoration: const InputDecoration(labelText: 'Account Number'),
            ),
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
            ),
            ElevatedButton(
              onPressed: () {
                // Handle transfer logic here
              },
              child: const Text('Transfer'),
            ),
          ],
        ),
      ),
    );
  }
}
