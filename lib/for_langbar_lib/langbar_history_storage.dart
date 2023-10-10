import 'package:flutter/widgets.dart';
import 'package:langbar/for_langbar_lib/langbar_states.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

void initDB() async {
  WidgetsFlutterBinding.ensureInitialized();
// Open the database and store the reference.
  final database = openDatabase(
    // Set the path to the database. Note: Using the `join` function from the
    // `path` package is best practice to ensure the path is correctly
    // constructed for each platform.
    join(await getDatabasesPath(), 'langbar_database.db'),
    // When the database is first created, create a table to store dogs.
    onCreate: (db, version) {
      // Run the CREATE TABLE statement on the database.
      return db.execute(
        'CREATE TABLE history(id INTEGER PRIMARY KEY, navUri TEXT, text TEXT, isHuman INTEGER)',
      );
    },
    // Set the version. This executes the onCreate function and provides a
    // path to perform database upgrades and downgrades.
    version: 1,
  );
}

const String tableHistory = 'history';
const String columnId = '_id';
const String columnText = 'text';
const String columnNavUri = 'navuri';
const String columnTime = 'timestamp'; // seconds since epoch
const columnIsHuman = 'ishuman';

HistoryMessage historyMessagefromMap(Map map) {
  return HistoryMessage(
      text: map[columnText] as String,
      isHuman: map[columnIsHuman] == 1,
      navUri: map[columnNavUri] as String?,
      time: DateTime.fromMillisecondsSinceEpoch(map[columnTime] as int));
}

extension HistoryMessageExtension on HistoryMessage {
  Map<String, Object?> toMap() {
    final map = <String, Object?>{
      columnNavUri: navUri,
      columnText: text,
      columnIsHuman: isHuman ? 1 : 0,
      columnTime: time.millisecondsSinceEpoch
    };
    return map;
  }
}

class HistoryProvider {
  late Database db;

  Future open() async {
    WidgetsFlutterBinding.ensureInitialized();
    db = await openDatabase(
      // Set the path to the database. Note: Using the `join` function from the
      // `path` package is best practice to ensure the path is correctly
      // constructed for each platform.
      join(await getDatabasesPath(), 'langbar_database.db'),
      // When the database is first created, create a table to store dogs.
      onCreate: (db, version) {
        // Run the CREATE TABLE statement on the database.
        return db.execute(
          'CREATE TABLE $tableHistory($columnId INTEGER PRIMARY KEY autoincrement, $columnNavUri TEXT, $columnText TEXT not null, $columnIsHuman INTEGER, $columnTime INTEGER)',
        );
      },
      // Set the version. This executes the onCreate function and provides a
      // path to perform database upgrades and downgrades.
      version: 1,
    );
    // await clear();
  }

  insert(HistoryMessage historyMessage) async {
    var result = await db.insert(tableHistory, historyMessage.toMap());
    print('inserted: ' + result.toString());
  }

  Future<List<HistoryMessage>> getHistoryItems() async {
    final List<Map> maps = await db.query(tableHistory, columns: [
      columnId,
      columnNavUri,
      columnText,
      columnIsHuman,
      columnTime
    ]);
    if (maps.isNotEmpty) {
      List<HistoryMessage> map2 =
          maps.map((map) => historyMessagefromMap(map)).toList();
      return map2;
    }
    return [];
  }

  Future<int> delete(int id) async {
    return await db
        .delete(tableHistory, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> clear() async {
    return await db.delete(tableHistory);
  }

  // Future<int> update(Todo todo) async {
  //   return await db.update(tableTodo, todo.toMap(),
  //       where: '$columnId = ?', whereArgs: [todo.id]);
  // }

  Future close() async => db.close();
}

// // Create a Dog and add it to the dogs table
// var fido = const Dog(
//   id: 0,
//   name: 'Fido',
//   age: 35,
// );
//
// await insertDog(fido);
