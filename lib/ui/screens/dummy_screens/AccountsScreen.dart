import 'package:flutter/material.dart';

import '../default_appbar_scaffold.dart';

const smallSpacing = 10.0;
const defaultPadding = 16.0;

class AccountsScreen extends DefaultAppbarScreen {
  AccountsScreen(
      {required super.label,
      Key? key,
      required Map<String, String> queryParameters})
      : super(body: AccountsList(), key: key) {}

  static const name = 'accounts';
}

class AccountsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
            title: Text(
          'Checking Accounts',
        )),
        Card(
          child: AccountTile(name: "title", iban: "iban", balance: "balance"),
        ),
        ListTile(
            title: Text(
          'Saving Accounts',
          // style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
        )),
        Card(
          child: AccountTile(name: "title", iban: "iban", balance: "balance"),
        ),
      ],
    );
  }
}

class AccountTile extends StatelessWidget {
  final String name;
  final String iban;
  final String balance;

  const AccountTile({
    super.key,
    required this.name,
    required this.iban,
    required this.balance,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(name, style: Theme.of(context).textTheme.titleMedium),
      subtitle: Text(iban),
      trailing: Text(balance),
    );
  }
}
