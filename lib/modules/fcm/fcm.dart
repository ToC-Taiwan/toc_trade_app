import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:trade_agent/daos/database.dart';
import 'package:trade_agent/entity/entity.dart';
import 'package:trade_agent/modules/api/api.dart';

class FCM {
  static final GlobalKey<CurvedNavigationBarState> routingKey = GlobalKey();
  static final FirebaseMessaging messaging = FirebaseMessaging.instance;

  static bool _authorizationStatus = false;
  static bool _firstLaunch = false;
  static bool _allowPush = false;

  static String _token = '';

  static String get getToken {
    return _token;
  }

  static initialize() async {
    if (!Platform.isIOS && !Platform.isAndroid) {
      return;
    }
    await messaging.getToken().then((value) {
      _token = value!;
    }).then((value) async {
      await BasicDao.getBasicByKey("fcm_token").then((value) {
        if (value == null) {
          _firstLaunch = true;
          BasicDao.insertBasic(Basic("fcm_token", _token));
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
      _authorizationStatus = value.authorizationStatus == AuthorizationStatus.authorized;
    });
  }

  static postInit() async {
    if (!_authorizationStatus) {
      return;
    }
    FirebaseMessaging.instance.subscribeToTopic('announcement');
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      showNotification(routingKey.currentContext!, message);
    });
    if (_firstLaunch) {
      _allowPush = true;
    } else {
      _allowPush = await API.checkTokenStatus(_token);
    }
    API.sendToken(_allowPush, _token);
  }

  static set allowPushToken(bool value) {
    _allowPush = value;
  }

  static get getBottomNavigationKey {
    return routingKey;
  }

  static void goToPage(int page) {
    final CurvedNavigationBarState? navBarState = routingKey.currentState;
    navBarState?.setPage(page);
  }

  static void showNotification(BuildContext context, RemoteMessage msg) async {
    if (!_allowPush) {
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
