import 'dart:convert';

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:trade_agent/constant/constant.dart';
import 'package:trade_agent/layout/balance.dart';
import 'package:trade_agent/layout/future_trade.dart';
import 'package:trade_agent/layout/pick_stock.dart';
import 'package:trade_agent/layout/strategy.dart';
import 'package:trade_agent/layout/targets.dart';
import 'package:trade_agent/modules/api/api.dart';
import 'package:trade_agent/modules/fcm/fcm.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Widget> pages = [
    const Targetspage(),
    const StrategyPage(),
    const FutureTradePage(),
    const PickStockPage(),
    const BalancePage(),
  ];

  @override
  void initState() {
    super.initState();
    checkNotification();
  }

  Future<String> refreshToken() async {
    final response = await http.get(
      Uri.parse('$tradeAgentURLPrefix/refresh'),
      headers: {
        "Authorization": API.token,
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to refresh token');
    }
    final result = jsonDecode(response.body) as Map<String, dynamic>;
    return result['token'];
  }

  void checkNotification() async {
    await FCM.initialize();
  }

  final _bottomNavigationKey = FCM.getBottomNavigationKey;
  DateTime _lastFreshTime = DateTime.now();
  int _page = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: pages[_page],
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
              refreshToken().then((value) {
                API.token = value;
              }).catchError((e) {
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
