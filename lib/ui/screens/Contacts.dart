import 'package:flutter/material.dart';

import '../models/account.dart';
import '../param_change_detecting_screens.dart';
import 'default_appbar_scaffold.dart';

class ContactsScreen extends DefaultAppbarScreen {
  ContactsScreen({required super.label, Key? key, searchString})
      : super(body: ContactList(searchString: searchString), key: key) {}

  static const name = 'contacts';
}

class ContactList extends ChangeDetectingStatefulWidget {
  ContactList({Key? key, this.searchString}) : super(key: key) {}

  final String? searchString;

  @override
  _ContactListState createState() => _ContactListState();

  @override
  String value() => searchString ?? '';
}

class _ContactListState extends UpdatingScreenState<ContactList> {
  TextEditingController _searchController = TextEditingController();
  late Future<List<Contact>> _contacts;

  @override
  void initState() {
    super.initState();
    _contacts = readContactsFromCsv();
    initOrUpdateWidgetParams();
  }

  @override
  void initOrUpdateWidgetParams() {
    _searchController.text = widget.searchString ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Contact>>(
      future: _contacts,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          var filteredContacts = snapshot.data
              ?.where((contact) => contact.name
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
                        title: Text(contact?.name ?? '',
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          contact?.iban ?? '',
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
