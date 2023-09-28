import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/account.dart';
import 'default_appbar_scaffold.dart';

const smallSpacing = 10.0;
const defaultPadding = 16.0;

class AccountsScreen extends DefaultAppbarScreen {
  AccountsScreen(
      {required super.label,
      Key? key,
      required Map<String, String> queryParameters,
      required detailsPath})
      : super(body: AccountsList(detailsPath), key: key) {}

  static const name = 'accounts';
}

var checkingAccounts = accounts.values
    .where((account) => account.type == AccountType.checking)
    .toList();
var savingAccounts = accounts.values
    .where((account) => account.type == AccountType.saving)
    .toList();

class AccountsList extends StatelessWidget {
  final String detailsPath;

  AccountsList(this.detailsPath);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
            title: Text(
          'Checking Accounts',
        )),
        ListView.builder(
          shrinkWrap: true,
          itemCount: checkingAccounts.length,
          itemBuilder: (context, index) {
            var account = checkingAccounts[index];
            return GestureDetector(
                onTap: () {
                  context.go(detailsPath + "?accountid=${account.id}");
                },
                child: Card(
                    child: AccountTile(
                        name: account.name,
                        iban: account.number,
                        balance: account.balance.toString())));
          },
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
      trailing: Text("€ $balance"),
    );
  }
}
