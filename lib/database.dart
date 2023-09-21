import 'dart:async';

import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:trade_agent_v2/daos/basic_dao.dart';
import 'package:trade_agent_v2/daos/pick_stock_dao.dart';
import 'package:trade_agent_v2/entity/entity.dart';

part 'database.g.dart';

@Database(version: 1, entities: [PickStock, Basic])
abstract class AppDatabase extends FloorDatabase {
  PickStockDao get pickStockDao;
  BasickDao get basicDao;
}

// create migration
// final migration1to2 = Migration(1, 2, (database) async {
//   await database.execute('ALTER TABLE pick_stock ADD COLUMN test_a TEXT');
//   await database.execute('UPDATE pick_stock SET test_a="mirgration_empty" WHERE id!=0');
// });
