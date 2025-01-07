import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class NotificationDatabase {
  static final NotificationDatabase instance = NotificationDatabase._init();

  static Database? _database;

  NotificationDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('notifications.db');
    await     resetNotifications();
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const boolType = 'BOOLEAN NOT NULL';

    await db.execute('''
      CREATE TABLE notifications (
        id $idType,
        text $textType,
        is_read $boolType
      )
    ''');

    await db.insert('notifications', {'text': 'Test Notification 1', 'is_read': 0});
    await db.insert('notifications', {'text': 'Test Notification 2', 'is_read': 0});
  }

  Future<List<Map<String, dynamic>>> getNotifications() async {
    final db = await instance.database;
    return await db.query('notifications');
  }

  Future<void> markAsRead(int id) async {
    final db = await instance.database;
    await db.update('notifications', {'is_read': 1},
        where: 'id = ?', whereArgs: [id]);
  }
Future<void> markAsUnread(int id) async {
  final db = await instance.database;
  await db.update('notifications', {'is_read': 0},
      where: 'id = ?', whereArgs: [id]);
}
  Future<void> deleteNotification(int id) async {
    final db = await instance.database;
    await db.delete('notifications', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> resetNotifications() async {
    final db = await instance.database;
    await db.delete('notifications');
    await db.insert('notifications', {'text': 'Test Notification 1', 'is_read': 0});
    await db.insert('notifications', {'text': 'Test Notification 2', 'is_read': 0});
  }
}
