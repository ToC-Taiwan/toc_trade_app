import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:trade_agent_v2/daos/daos.dart';
import 'package:trade_agent_v2/entity/entity.dart';
import 'package:trade_agent_v2/generated/l10n.dart';
import 'package:trade_agent_v2/intro.dart';
import 'package:trade_agent_v2/version.dart';

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

  runApp(
    MyApp(
      dbLanguageSetup.value,
      db: database,
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp(this.languageSetup, {required this.db, super.key});
  final Database db;

  final String languageSetup;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late String language;
  late String languageScript;
  late String country;
  late Locale locale;

  @override
  void initState() {
    final splitLanguage = widget.languageSetup.split('_');
    switch (splitLanguage.length) {
      case 1:
        language = splitLanguage[0];
        locale = Locale.fromSubtags(languageCode: language);
        break;
      case 2:
        language = splitLanguage[0];
        country = splitLanguage[1];
        locale = Locale.fromSubtags(languageCode: language, countryCode: country);
        break;
      case 3:
        language = splitLanguage[0];
        languageScript = splitLanguage[1];
        country = splitLanguage[2];
        locale = Locale.fromSubtags(languageCode: language, countryCode: country, scriptCode: languageScript);
        break;
      default:
        locale = const Locale.fromSubtags(languageCode: 'en');
    }
    super.initState();
  }

  void hideKeyboard(BuildContext context) {
    final currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        theme: ThemeData(
          primarySwatch: createMaterialColor(const Color.fromARGB(255, 255, 255, 255)),
        ),
        home: IntroPage(
          db: widget.db,
        ),
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        locale: locale,
        supportedLocales: S.delegate.supportedLocales,
        builder: (context, child) => Scaffold(
          // Global GestureDetector that will dismiss the keyboard
          body: GestureDetector(
            onTap: () {
              hideKeyboard(context);
            },
            child: child,
          ),
        ),
      );
}

MaterialColor createMaterialColor(Color color) {
  final List strengths = <double>[.05];
  final swatch = <int, Color>{};

  final r = color.red;
  final g = color.green;
  final b = color.blue;

  for (var i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  for (final strength in strengths) {
    final ds = 0.5 - (strength as num);
    swatch[((strength as double) * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  }
  return MaterialColor(color.value, swatch);
}
