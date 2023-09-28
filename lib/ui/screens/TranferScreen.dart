import 'package:flutter/material.dart';

import 'default_appbar_scaffold.dart';

class TransferScreen extends DefaultAppbarScreen {
  TransferScreen(
      {required super.label, Key? key, searchString, destinationName})
      : super(body: TransferMoneyScreen(), key: key) {}

  static const name = 'transfer';
}

class TransferMoneyScreen extends StatefulWidget {
  @override
  _TransferMoneyScreenState createState() => _TransferMoneyScreenState();
}

class _TransferMoneyScreenState extends State<TransferMoneyScreen> {
  TextEditingController _amountController = TextEditingController();
  TextEditingController _accountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Transfer Money')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _accountController,
              decoration: InputDecoration(labelText: 'Account Number'),
            ),
            TextField(
              controller: _amountController,
              decoration: InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
            ),
            ElevatedButton(
              onPressed: () {
                // Handle transfer logic here
              },
              child: Text('Transfer'),
            ),
          ],
        ),
      ),
    );
  }
}
