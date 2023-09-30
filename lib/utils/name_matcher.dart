
import 'dart:math';

import '../ui/models/account.dart';

double levenshtein(String a, String b) {
  final int lenA = a.length, lenB = b.length;
  final List<List<int>> dp = List.generate(lenA + 1,
          (_) => List.generate(lenB + 1, (_) => 0, growable: false),
      growable: false);

  for (int i = 0; i <= lenA; i++) {
    dp[i][0] = i;
  }

  for (int j = 0; j <= lenB; j++) {
    dp[0][j] = j;
  }

  for (int i = 1; i <= lenA; i++) {
    for (int j = 1; j <= lenB; j++) {
      final int cost = a[i - 1] == b[j - 1] ? 0 : 1;
      dp[i][j] = min(
          dp[i - 1][j] + 1,
          min(
              dp[i][j - 1] + 1,
              dp[i - 1][j - 1] +
                  cost)); // Take the minimum of deletion, insertion, and substitution
    }
  }

  return dp[lenA][lenB].toDouble();
}

Contact? findMatchingContact(List<Contact> contacts, String searchString) {
  searchString = searchString.toLowerCase();
  final searchTerms = searchString.toLowerCase().split(' ');
  final List<Contact> matchingContacts = [];

  var smallestDistance = double.infinity;
  for (final contact in contacts) {
    final contactName = contact.name.toLowerCase();
    final parts = contactName.split(' ');

    var distance = 0.0;
    // compare searchTerms to parts in zip-like sync, where the same index is compared. , averaging the levenstein distance per contact
    for (var i = 0; i < searchTerms.length; i++) {
      final searchTerm = searchTerms[i];
      final part = parts[i];

      distance += levenshtein(part, searchTerm);
    }
    distance /= searchTerms.length;
    if(distance < smallestDistance) {
      smallestDistance = distance;
      matchingContacts.clear();
      matchingContacts.add(contact);
    } else if (distance == smallestDistance) {
      matchingContacts.add(contact);
    }
  }
  print("smallest distance: $smallestDistance");
  if(smallestDistance >= 2) {
    matchingContacts.clear();
  }
  return matchingContacts.firstOrNull;
}
