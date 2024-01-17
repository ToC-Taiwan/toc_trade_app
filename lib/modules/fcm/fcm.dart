import 'dart:convert';
import 'dart:io';

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

  static bool authorizationStatus = false;
  static bool firstLaunch = false;
  static String token = '';

  static initialize() async {
    if (!Platform.isIOS && !Platform.isAndroid) {
      return;
    }
    await messaging.getToken().then((value) {
      token = value!;
    }).then((value) async {
      await BasicDao.getBasicByKey("fcm_token").then((value) {
        if (value == null) {
          firstLaunch = true;
          BasicDao.insertBasic(Basic("fcm_token", token));
        }
      });
    });
    await messaging
        .requestPermission(
      alert: true,
      badge: true,
      sound: true,
    )
        .then((value) {
      authorizationStatus = value.authorizationStatus == AuthorizationStatus.authorized;
    });
  }

  static refresh() async {
    if (!authorizationStatus) {
      return;
    }
    FirebaseMessaging.instance.subscribeToTopic('announcement');
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      showNotification(routingKey.currentContext!, message);
    });
    if (firstLaunch) {
      sendToken(true);
    } else {
      sendToken(await checkTokenStatus());
    }
  }

  static get getBottomNavigationKey {
    return routingKey;
  }

  static bool allowPush = false;

  static Future<void> sendToken(bool enabled) async {
    if (token.isEmpty) {
      return;
    }

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
    allowPush = enabled;
  }

  static Future<bool> checkTokenStatus() async {
    if (token.isEmpty) {
      return false;
    }

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
    if (!allowPush) {
      return;
    }

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
