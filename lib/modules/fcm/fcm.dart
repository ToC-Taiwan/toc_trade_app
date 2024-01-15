import 'dart:convert';

import 'package:another_flushbar/flushbar.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:trade_agent/constant/constant.dart';
import 'package:trade_agent/daos/daos.dart';
import 'package:trade_agent/entity/basic.dart';
import 'package:trade_agent/modules/api/api.dart';

class FCM {
  static final GlobalKey<CurvedNavigationBarState> routingKey = GlobalKey();
  static final FirebaseMessaging messaging = FirebaseMessaging.instance;
  static String token = '';

  static initialize() async {
    bool firstLaunch = false;
    await messaging.getToken().then((value) => token = value!).then((value) async {
      await BasicDao.getBasicByKey("fcm_token").then((value) {
        if (value == null) {
          firstLaunch = true;
          BasicDao.insertBasic(Basic("fcm_token", token));
        }
      });
    });
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (firstLaunch) {
        await sendToken(true);
      } else {
        await sendToken(await checkTokenStatus());
      }
    }
  }

  static get getBottomNavigationKey {
    return routingKey;
  }

  static Future<void> sendToken(bool enabled) async {
    final resp = await http.put(
      Uri.parse('$tradeAgentURLPrefix/user/push-token'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": API.token,
      },
      body: jsonEncode({
        "push_token": token,
        "enabled": enabled,
      }),
    );

    if (resp.statusCode != 200) {
      return;
    }

    if (enabled) {
      await FirebaseMessaging.instance.subscribeToTopic('announcement');
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        showNotification(routingKey.currentContext!, message);
      });
    } else {
      await FirebaseMessaging.instance.unsubscribeFromTopic('announcement');
      FirebaseMessaging.onMessage.listen(null);
    }
  }

  static Future<bool> checkTokenStatus() async {
    final resp = await http.get(
      Uri.parse('$tradeAgentURLPrefix/user/push-token'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": API.token,
        "token": token,
      },
    );

    if (resp.statusCode != 200) {
      return false;
    }

    final result = jsonDecode(resp.body) as Map<String, dynamic>;
    return result['enabled'];
  }

  static void goToPage(int page) {
    final CurvedNavigationBarState? navBarState = routingKey.currentState;
    navBarState?.setPage(page);
  }

  static void showNotification(BuildContext context, RemoteMessage msg) async {
    await Flushbar(
      onTap: (flushbar) {
        if (msg.data['page_route'] == 'target') {
          goToPage(0);
        } else if (msg.data['page_route'] == 'strategy') {
          goToPage(1);
        } else if (msg.data['page_route'] == 'future_trade') {
          goToPage(2);
        } else if (msg.data['page_route'] == 'pick_stock') {
          goToPage(3);
        } else if (msg.data['page_route'] == 'balance') {
          goToPage(4);
        }
        flushbar.dismiss();
      },
      margin: const EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(8),
      duration: const Duration(milliseconds: 5000),
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
}
