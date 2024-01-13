import 'dart:convert';

import 'package:another_flushbar/flushbar.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:trade_agent/constant/constant.dart';
import 'package:trade_agent/layout/balance.dart';
import 'package:trade_agent/layout/future_trade.dart';
import 'package:trade_agent/layout/pick_stock.dart';
import 'package:trade_agent/layout/strategy.dart';
import 'package:trade_agent/layout/targets.dart';
import 'package:trade_agent/modules/api/api.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({required this.db, super.key});

  final Database db;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();
  int _page = 0;
  List pages = [];
  DateTime _lastFreshTime = DateTime.now();

  @override
  void initState() {
    checkNotification();
    super.initState();
    pages = [
      Targetspage(
        db: widget.db,
      ),
      StrategyPage(
        db: widget.db,
      ),
      FutureTradePage(
        db: widget.db,
      ),
      PickStockPage(
        db: widget.db,
      ),
      BalancePage(
        db: widget.db,
      ),
    ];
  }

  Future<void> refreshToken() async {
    final response = await http.get(
      Uri.parse('$tradeAgentURLPrefix/refresh'),
      headers: {
        "Authorization": API.token,
      },
    );
    if (response.statusCode != 200) {
      throw 'Failed to refresh token';
    }
  }

  Future<void> putToken(String token) async {
    await http.put(
      Uri.parse('$tradeAgentURLPrefix/user/push-token'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": API.token,
      },
      body: jsonEncode({
        "push_token": token,
      }),
    );
  }

  void checkNotification() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      await FirebaseMessaging.instance.subscribeToTopic('announcement');
      messaging.getToken().then((value) {
        putToken(value!);
      });
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _showNotification(context, message);
      });
    }
  }

  void _showNotification(BuildContext context, RemoteMessage msg) async {
    await Flushbar(
      onTap: (flushbar) {
        if (msg.data['page_route'] == 'balance') {
          goToPage(4);
        } else if (msg.data['page_route'] == 'target') {
          goToPage(0);
        } else if (msg.data['page_route'] == 'strategy') {
          goToPage(1);
        } else if (msg.data['page_route'] == 'future_trade') {
          goToPage(2);
        } else if (msg.data['page_route'] == 'pick_stock') {
          goToPage(3);
        }
        flushbar.dismiss();
      },
      margin: const EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(8),
      duration: const Duration(milliseconds: 2000),
      titleColor: Colors.grey,
      flushbarPosition: FlushbarPosition.TOP,
      flushbarStyle: FlushbarStyle.FLOATING,
      reverseAnimationCurve: Curves.easeInToLinear,
      forwardAnimationCurve: Curves.easeInToLinear,
      backgroundColor: Colors.white,
      leftBarIndicatorColor: Colors.blueGrey,
      isDismissible: true,
      icon: const Icon(
        Icons.notifications,
        color: Colors.blueGrey,
        size: 30,
      ),
      titleText: Text(
        msg.notification!.title!,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18.0,
          color: Colors.grey,
        ),
      ),
      messageText: Text(
        msg.notification!.body!,
        style: const TextStyle(
          fontSize: 16.0,
          color: Colors.black,
        ),
      ),
      boxShadows: const [
        BoxShadow(
          color: Colors.grey,
          offset: Offset(0.0, 5.0),
          blurRadius: 10.0,
        )
      ],
    ).show(context);
  }

  void goToPage(int page) {
    final CurvedNavigationBarState? navBarState = _bottomNavigationKey.currentState;
    navBarState?.setPage(page);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: pages[_page] as Widget,
        bottomNavigationBar: CurvedNavigationBar(
          key: _bottomNavigationKey,
          height: 70,
          items: const <Widget>[
            Icon(Icons.assignment_outlined, size: 30),
            Icon(Icons.call_to_action_rounded, size: 30),
            Icon(Icons.account_balance_outlined, size: 30),
            Icon(Icons.dashboard_customize, size: 30),
            Icon(Icons.money, size: 30),
          ],
          color: Colors.blueGrey,
          buttonBackgroundColor: Colors.greenAccent,
          backgroundColor: Colors.white,
          animationCurve: Curves.easeInCubic,
          animationDuration: const Duration(milliseconds: 150),
          onTap: (index) {
            if (DateTime.now().difference(_lastFreshTime).inMinutes > 1) {
              refreshToken().catchError((e) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                  (route) => false,
                  arguments: AppLocalizations.of(context)!.please_login_again,
                );
              });
              _lastFreshTime = DateTime.now();
            }
            setState(() {
              _page = index;
            });
          },
          letIndexChange: (index) => true,
        ),
      );
}
