import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:trade_agent/daos/daos.dart';
import 'package:trade_agent/entity/entity.dart';
import 'package:trade_agent/firebase_options.dart';
import 'package:trade_agent/locale.dart';
import 'package:trade_agent/login.dart';
import 'package:trade_agent/version.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final libDic = Platform.isAndroid ? await getApplicationSupportDirectory() : await getLibraryDirectory();
  final database = await openDatabase(
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

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // adsense
  await MobileAds.instance.initialize();
  if (kDebugMode) {
    await MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(
        testDeviceIds: ['kGADSimulatorID'],
      ),
    );
  }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final basicDao = BasicDao(database: database);
  final version = await basicDao.getBasicByKey('version');
  if (version == null) {
    await basicDao.insertBasic(Basic('version', appVersion));
  } else {
    version.value = appVersion;
    await basicDao.updateBasic(version);
  }

  final balanceHigh = await basicDao.getBasicByKey('balance_high');
  if (balanceHigh == null) {
    await basicDao.insertBasic(Basic('balance_high', '1'));
  }

  final balanceLow = await basicDao.getBasicByKey('balance_low');
  if (balanceLow == null) {
    await basicDao.insertBasic(Basic('balance_low', '-1'));
  }

  final timePeriod = await basicDao.getBasicByKey('time_period');
  if (timePeriod == null) {
    await basicDao.insertBasic(Basic('time_period', '5'));
  }

  var dbLanguageSetup = await basicDao.getBasicByKey('language_setup');
  if (dbLanguageSetup == null) {
    final defaultLocale = Platform.localeName;
    Basic tmp;
    final splitLocale = defaultLocale.split('_');
    switch (splitLocale.length) {
      case 1:
        tmp = Basic('language_setup', splitLocale[0]);
        break;
      case 2:
        tmp = Basic('language_setup', '${splitLocale[0]}_${splitLocale[1]}');
        break;
      case 3:
        tmp = Basic('language_setup', '${splitLocale[0]}_${splitLocale[1]}_${splitLocale[2]}');
        break;
      default:
        tmp = Basic('language_setup', 'en');
        break;
    }
    await basicDao.insertBasic(tmp);
    dbLanguageSetup = tmp;
  }

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(
    MyApp(
      dbLanguageSetup.value,
      db: database,
    ),
  );
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class MyApp extends StatefulWidget {
  const MyApp(this.languageSetup, {required this.db, super.key});
  final Database db;

  final String languageSetup;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Locale locale;

  @override
  void initState() {
    locale = LocaleBloc.splitLanguage(widget.languageSetup);
    super.initState();
  }

  @override
  void dispose() {
    LocaleBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => StreamBuilder(
      stream: LocaleBloc.localeStream,
      initialData: locale,
      builder: (context, snapshot) {
        return MaterialApp(
          theme: ThemeData(
            useMaterial3: true,
          ),
          debugShowCheckedModeBanner: false,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: snapshot.data,
          initialRoute: LoginPage.routeName,
          routes: {
            LoginPage.routeName: (context) => LoginPage(
                  db: widget.db,
                  screenHeight: MediaQuery.of(context).size.height,
                ),
          },
        );
      });
}
