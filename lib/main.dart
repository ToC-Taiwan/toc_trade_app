import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:trade_agent/daos/daos.dart';
import 'package:trade_agent/daos/database.dart';
import 'package:trade_agent/entity/entity.dart';
import 'package:trade_agent/firebase_options.dart';
import 'package:trade_agent/locale.dart';
import 'package:trade_agent/login.dart';
import 'package:trade_agent/version.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

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

  await DB.initialize();

  await BasicDao.getBasicByKey('version').then((value) async {
    if (value != null) {
      if (value.value != appVersion) {
        value.value = appVersion;
        await BasicDao.updateBasic(value);
      }
    } else {
      await BasicDao.insertBasic(Basic('version', appVersion));
    }
  });

  await BasicDao.getBasicByKey('balance_high').then((value) async {
    if (value == null) {
      await BasicDao.insertBasic(Basic('balance_high', '1'));
    }
  });

  final balanceLow = await BasicDao.getBasicByKey('balance_low');
  if (balanceLow == null) {
    await BasicDao.insertBasic(Basic('balance_low', '-1'));
  }

  await BasicDao.getBasicByKey('time_period').then((value) async {
    if (value == null) {
      await BasicDao.insertBasic(Basic('time_period', '5'));
    }
  });

  Basic dbLanguageSetup = await BasicDao.getBasicByKey('language_setup').then((value) async {
    if (value != null) {
      return value;
    }
    Basic temp = Basic('language_setup', 'en');
    await BasicDao.insertBasic(temp);
    return temp;
  });

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FlutterAppBadger.isAppBadgeSupported().then((value) {
    if (value) {
      FlutterAppBadger.removeBadge();
    }
  });
  runApp(
    MyApp(
      dbLanguageSetup.value,
    ),
  );
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class MyApp extends StatefulWidget {
  const MyApp(this.languageSetup, {super.key});

  final String languageSetup;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Locale locale;

  @override
  void initState() {
    super.initState();
    locale = LocaleBloc.splitLanguage(widget.languageSetup);
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
                  screenHeight: MediaQuery.of(context).size.height,
                ),
          },
        );
      });
}
