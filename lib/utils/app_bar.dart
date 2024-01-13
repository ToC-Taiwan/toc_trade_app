import 'package:flutter/material.dart';
import 'package:trade_agent/layout/settings.dart';

AppBar trAppbar(BuildContext context, String title, {List<Widget>? actions}) {
  final normalAction = <Widget>[
    // IconButton(
    //   icon: const Icon(Icons.question_mark_outlined),
    //   onPressed: () {},
    // ),
    // IconButton(
    //   icon: const Icon(Icons.notification_important),
    //   onPressed: () {},
    // ),
    Padding(
      padding: const EdgeInsets.only(right: 10),
      child: IconButton(
        icon: const Icon(Icons.settings),
        onPressed: () {
          Navigator.of(context).push(_createRoute());
        },
      ),
    ),
  ];
  return AppBar(
    centerTitle: false,
    elevation: 0.5,
    title: Text(title),
    actions: actions ?? normalAction,
  );
}

Route _createRoute() => PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => const SettingsPage(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0, 1);
        const end = Offset.zero;
        const curve = Curves.ease;

        final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
