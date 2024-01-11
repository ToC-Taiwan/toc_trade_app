import 'dart:convert';

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
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

  Future<void> putToken(String token) async {
    await http.put(
      Uri.parse('$tradeAgentURLPrefix/user/push-token'),
      headers: {
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
    }
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
            setState(() {
              _page = index;
            });
          },
          letIndexChange: (index) => true,
        ),
      );
}
