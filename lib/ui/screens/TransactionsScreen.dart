import 'package:flutter/material.dart';

import '../models/account.dart';
import 'default_appbar_scaffold.dart';

class TransactionsScreen extends DefaultAppbarScreen {
  TransactionsScreen({required super.label, Key? key, searchString})
      : super(body: TransactionsList(searchString: searchString), key: key) {}

  static const name = 'contacts';
}

class TransactionsList extends StatefulWidget {
  TransactionsList({Key? key, this.searchString}) : super(key: key) {}

  final String? searchString;

  @override
  _TransactionsListState createState() => _TransactionsListState();
}

class _TransactionsListState extends State<TransactionsList> {
  TextEditingController _searchController = TextEditingController();
  late Future<List<BankTransaction>> _transactions;

  @override
  void initState() {
    super.initState();
    _transactions = readTransactionsFromCsv();
    _searchController.text = widget.searchString ?? '';
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
          var filteredContacts = snapshot.data
              ?.where((transaction) => transaction.description
                  .toLowerCase()
                  .contains(_searchController.text.toLowerCase()))
              .toList();

          return Column(
            children: <Widget>[
              TextField(
                controller: _searchController,
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
