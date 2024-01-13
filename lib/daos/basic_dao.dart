import 'package:sqflite/sqflite.dart';
import 'package:trade_agent/entity/entity.dart';

class BasicDao {
  static Database? database;

  static set setDatabase(Database? db) {
    database = db;
  }

  static Future<Basic?> getBasicByKey(String key) async {
    final List<Map<String, dynamic>> maps = await database!.query(
      'basic',
      where: 'key = ?',
      whereArgs: [key],
    );

    if (maps.isNotEmpty) {
      return Basic(
        maps.first['key'] as String,
        maps.first['value'] as String,
        id: maps.first['id'] as int,
        createTime: maps.first['createTime'] as int,
        updateTime: maps.first['updateTime'] as int,
      );
    }
    return null;
  }

  static Future<void> insertBasic(Basic record) async {
    await database!.insert(
      'basic',
      record.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> updateBasic(Basic record) async {
    await database!.update(
      'basic',
      record.toMap(),
      where: 'key = ?',
      whereArgs: [record.key],
    );
  }
}
