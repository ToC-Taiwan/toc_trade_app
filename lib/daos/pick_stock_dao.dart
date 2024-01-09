import 'package:sqflite/sqflite.dart';
import 'package:trade_agent/entity/entity.dart';

class PickStockDao {
  PickStockDao({
    this.database,
  });

  Future<List<PickStock>> getAllPickStock() async {
    final List<Map<String, dynamic>> maps = await database!.query(
      'pick_stock',
    );

    return List.generate(maps.length, (i) {
      return PickStock(
        maps[i]['stock_num'] as String,
        maps[i]['stock_name'] as String,
        maps[i]['is_target'] as int,
        maps[i]['price_change'] as double,
        maps[i]['price_change_rate'] as double,
        maps[i]['price'] as double,
        id: maps[i]['id'] as int,
        createTime: maps[i]['createTime'] as int,
        updateTime: maps[i]['updateTime'] as int,
      );
    });
  }

  Future<void> deletePickStock(PickStock record) async {
    await database!.delete(
      'pick_stock',
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  Future<void> updatePickStock(PickStock record) async {
    await database!.update(
      'pick_stock',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  Future<void> deleteAllPickStock() async {
    await database!.delete(
      'pick_stock',
    );
  }

  Future<void> insertPickStock(PickStock record) async {
    await database!.insert(
      'pick_stock',
      record.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Database? database;
}
