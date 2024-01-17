import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:trade_agent/daos/basic_dao.dart';
import 'package:trade_agent/daos/pick_stock_dao.dart';

export 'basic_dao.dart';
export 'pick_stock_dao.dart';

class DB {
  static Database? db;

  static Future<void> initialize() async {
    final libDic = Platform.isAndroid ? await getApplicationSupportDirectory() : await getLibraryDirectory();
    db = await openDatabase(
      join(libDic.path, 'toc_sqlite.db'),
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE IF NOT EXISTS basic(
          id INTEGER PRIMARY KEY,
          key TEXT,
          value TEXT,
          createTime INTEGER,
          updateTime INTEGER)
        ''');
        await db.execute(
          '''
        CREATE TABLE IF NOT EXISTS pick_stock(
          id INTEGER PRIMARY KEY,
          stock_num TEXT,
          stock_name TEXT,
          price REAL,
          price_change_rate REAL,
          price_change REAL,
          is_target INTEGER,
          createTime INTEGER,
          updateTime INTEGER)
        ''',
        );
      },
      version: 1,
    );

    BasicDao.setDatabase = db;
    PickStockDao.setDatabase = db;
  }
}
