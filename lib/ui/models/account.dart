import 'package:csv/csv.dart';
import 'package:flutter/cupertino.dart';

class BankAccount {
  String id;
  String name;
  String number;
  double balance;
  AccountType type;

  BankAccount(this.id, this.type, this.name, this.number, this.balance);
}

enum AccountType {
  checking,
  saving,
}

var accounts = {
  "1": BankAccount(
      "1", AccountType.checking, "John Doe", "DE23498723474", 5000.0),
  "2": BankAccount(
      "2", AccountType.saving, "Orange Saving", "DE0987654321", 10000.0),
};

class BankTransaction {
  String sourceName;
  String sourceIban;
  String destinationName;
  String destinationIban;
  String description;
  double amount;
  DateTime date;

  BankTransaction(this.sourceName, this.sourceIban, this.destinationName,
      this.destinationIban, this.description, this.amount, this.date);
}

class Contact {
  String name;
  String? iban;

  Contact(this.name, this.iban);
}

Future<List<Contact>> readContactsFromCsv(BuildContext context) async {
  // do not use rootBundle.loadString, because it does not work on web (or you have to specify the assets folder as assets/assets)
  String fileContent = await DefaultAssetBundle.of(context)
      .loadString('assets/data/contacts.csv');
  // String fileContent = await webFriendlyLoadString('assets/data/contacts.csv');
  final csvRows = const CsvToListConverter().convert(fileContent, eol: "\n");

  // Skip the header row and map each row to a Contact object
  var list = csvRows.skip(1).map((row) {
    return Contact(row[0] as String, row[1] as String);
  }).toList();
  return list;
}

// // on web (on firebase deploy) stuff ends up in assets/assets. instead of just assets
// // also have to make sure firebase.json rewrites are as follows:
// // "rewrites": [
// // {
// // "source": "/assets/**",
// // "destination": "/assets/**"
// // },
// // {
// // "source": "**",
// // "destination": "/index.html"
// // }
// // ]
// Future<String> webFriendlyLoadString(String path) async {
//   String fileContent = "";
//   try {
//     fileContent = await rootBundle.loadString(path);
//   } catch (e) {
//     try {
//       fileContent = await rootBundle.loadString('assets/$path');
//     } catch (e) {
//     }
//   }
//   return fileContent;
// }

Future<List<BankTransaction>> readTransactionsFromCsv(
    BuildContext context) async {
  final fileContent = await await DefaultAssetBundle.of(context)
      .loadString('assets/data/transactions.csv');

  final csvRows = const CsvToListConverter().convert(fileContent, eol: "\n");

  // Skip the header row and map each row to a Contact object
  var list = csvRows.skip(1).map((row) {
    return BankTransaction(row[0] as String, row[1] as String, row[2] as String,
        row[3] as String, row[4] as String, row[5], DateTime.parse(row[6]));
  }).toList();
  return list;
}
