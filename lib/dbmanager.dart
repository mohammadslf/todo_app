import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DbTodoManager {
  Database _database;

  Future openDb() async {
    if (_database == null) {
      _database = await openDatabase(join(await getDatabasesPath(), "td.db"),
          version: 1, onCreate: (Database db, int version) async {
        await db.execute(
          "CREATE TABLE todo(id INTEGER PRIMARY KEY autoincrement, title TEXT, todoData TEXT)",
        );
      });
    }
  }

  Future<int> insertTodo(Todo todo) async {
    await openDb();
    return await _database.insert('todo', todo.toMap());
  }

  Future<List<Todo>> getTodoList() async {
    await openDb();
    final List<Map<String, dynamic>> maps = await _database.query('todo');
    return List.generate(maps.length, (i) {
      return Todo(
          id: maps[i]['id'],
          title: maps[i]['title'],
          todoData: maps[i]['todoData']);
    });
  }

  Future<int> updateTodo(Todo todo) async {
    await openDb();
    return await _database
        .update('todo', todo.toMap(), where: "id = ?", whereArgs: [todo.id]);
  }

  Future<void> deletetodo(int id) async {
    await openDb();
    await _database.delete('todo', where: "id = ?", whereArgs: [id]);
  }
}

class Todo {
  int id;
  String title;
  String todoData;
  Todo({@required this.title, @required this.todoData, this.id});
  Map<String, dynamic> toMap() {
    return {'title': title, 'todoData': todoData};
  }
}
