import 'package:flutter/material.dart';
import 'package:langbar/ui/param_change_detecting_screens.dart';

import '../models/account.dart';
import 'default_appbar_scaffold.dart';

class TransactionsScreen extends DefaultAppbarScreen {
  TransactionsScreen({required super.label, Key? key, filterString, accountId})
      : super(
            body: TransactionsList(
                filterString: filterString, accountId: accountId = 1),
            key: key, leadingHamburger: false) {}

  static const name = 'transactions';
}

class TransactionsList extends ChangeDetectingStatefulWidget {
  TransactionsList({Key? key, this.filterString, required accountId})
      : super(key: key) {
  }

  final String? filterString;

  @override
  _TransactionsListState createState() => _TransactionsListState();

  @override
  String value() => filterString ?? '';
}

class _TransactionsListState extends UpdatingScreenState<TransactionsList> {
  TextEditingController _filterController = TextEditingController();
  late Future<List<BankTransaction>> _transactions;

  @override
  void initState() {
    super.initState();
    _transactions = readTransactionsFromCsv(context);
    initOrUpdateWidgetParams();
  }

  @override
  void initOrUpdateWidgetParams() {
    _filterController.text = widget.filterString ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<BankTransaction>>(
      future: _transactions,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          var filteredContacts = snapshot.data?.where((transaction) {
            var searchText = _filterController.text.toLowerCase();
            var description = transaction.description.toLowerCase();
            var destination = transaction.destinationName.toLowerCase();
            return description.contains(searchText) ||
                destination.contains(searchText);
          }).toList();

          return Column(
            children: <Widget>[
              TextField(
                controller: _filterController,
                decoration: InputDecoration(labelText: 'Search'),
                onChanged: (value) {
                  setState(() {});
                },
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredContacts?.length,
                  itemBuilder: (context, index) {
                    var contact = filteredContacts?[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: ListTile(
                        title: Text(contact?.description ?? '',
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          contact?.destinationName ?? '',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }
      },
    );
  }
}
