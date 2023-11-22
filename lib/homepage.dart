import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:trade_agent_v2/layout/balance.dart';
import 'package:trade_agent_v2/layout/future_trade.dart';
import 'package:trade_agent_v2/layout/pick_stock.dart';
import 'package:trade_agent_v2/layout/strategy.dart';
import 'package:trade_agent_v2/layout/targets.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({required this.title, required this.db, super.key});
  final Database db;

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();
  int _page = 0;
  List pages = [];

  @override
  void initState() {
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
      // TSEPage(
      //   db: widget.db,
      // ),
      BalancePage(
        db: widget.db,
      ),
      // const SettingsPage(),
    ];
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
            // Icon(Icons.today_outlined, size: 30),
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
