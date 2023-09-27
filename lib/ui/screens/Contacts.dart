import 'package:flutter/material.dart';

import '../models/account.dart';
import 'default_appbar_scaffold.dart';

class ContactsScreen extends StatefulWidget {
  final String? searchString;

  final String label;

  ContactsScreen({required this.label, Key? key, this.searchString})
      : super(key: key) {}

  static const name = 'contacts';

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  String _selectedLocation = 'atms';

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.searchString ?? 'atms';
  }

  @override
  void didUpdateWidget(ContactsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchString != widget.searchString) {
      _selectedLocation = widget.searchString ?? 'atms';
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultAppbarScreen(
        label: widget.label,
        body: ContactList(searchString: widget.searchString));
  } // Text("hoi")
}

class ContactList extends StatefulWidget {
  ContactList({Key? key, this.searchString}) : super(key: key) {}

  String? searchString;

  @override
  _ContactListState createState() => _ContactListState();
}

class _ContactListState extends State<ContactList> {
  TextEditingController _searchController = TextEditingController();
  late Future<List<Contact>> _contacts;

  @override
  void initState() {
    super.initState();
    _contacts = readContactsFromCsv('assets/data/contacts.csv');
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
                        title: Text(contact?.name ?? ''),
                        subtitle: Text(contact?.iban ?? ''),
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
