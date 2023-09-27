import 'package:csv/csv.dart';
import 'package:flutter/services.dart';

class BankAccount {
  String name;
  String iban;

  BankAccount(this.name, this.iban);
}

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
  String iban;

  Contact(this.name, this.iban);
}

Future<List<Contact>> readContactsFromCsv(String path) async {
  final fileContent = await rootBundle.loadString('assets/data/contacts.csv');

  final csvRows = const CsvToListConverter().convert(fileContent, eol: "\n");

  // Skip the header row and map each row to a Contact object
  var list = csvRows.skip(1).map((row) {
    return Contact(row[0] as String, row[1] as String);
  }).toList();
  return list;
}
