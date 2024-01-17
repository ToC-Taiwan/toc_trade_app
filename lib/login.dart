import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:trade_agent/constant/constant.dart';
import 'package:trade_agent/homepage.dart';
import 'package:trade_agent/modules/api/api.dart';
import 'package:trade_agent/modules/fcm/fcm.dart';
import 'package:trade_agent/register.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({required this.screenHeight, super.key});
  static const routeName = '/';

  final double screenHeight;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  late StreamSubscription<bool> keyboardSubscription;
  late AnimationController _controller;
  late Animation<double> _animation;

  String username = '';
  String password = '';

  bool passwordIsObscure = true;
  bool logining = false;

  Future<String> login(String userName, String password) async {
    try {
      var loginBody = {
        'username': userName,
        'password': password,
      };
      final response = await http.post(
        Uri.parse('$tradeAgentURLPrefix/login'),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(loginBody),
      );
      final result = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200) {
        return result['token'];
      } else {
        throw codeToLoginFailMsg(result['code'] as int);
      }
    } catch (e) {
      rethrow;
    }
  }

  String codeToLoginFailMsg(int code) {
    switch (code) {
      case -1001:
        return AppLocalizations.of(context)!.user_not_found;
      case -1002:
        return AppLocalizations.of(context)!.password_not_match;
      case -1003:
        return AppLocalizations.of(context)!.email_not_verified;
      default:
        return AppLocalizations.of(context)!.login_failed;
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 200), vsync: this);
    _animation = Tween<double>(begin: widget.screenHeight * 0.7, end: widget.screenHeight * 0.3).animate(_controller);

    var keyboardVisibilityController = KeyboardVisibilityController();
    keyboardSubscription = keyboardVisibilityController.onChange.listen((bool visible) {
      setState(() {
        if (visible) {
          _controller.forward();
        } else {
          _controller.reverse();
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    keyboardSubscription.cancel();
    super.dispose();
  }

  Future<void> checkNotification() async {
    await FCM.initialize();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args != null && args is String) {
      return Stack(
        children: <Widget>[
          Image.asset(
            "assets/cover.png",
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.cover,
          ),
          AlertDialog(
            title: Text(AppLocalizations.of(context)!.warning),
            content: Text(args),
            actions: [
              ElevatedButton(
                child: Text(
                  AppLocalizations.of(context)!.ok,
                  style: const TextStyle(color: Colors.black),
                ),
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/',
                    (route) => false,
                  );
                },
              ),
            ],
          )
        ],
      );
    }

    return Stack(
      children: <Widget>[
        Image.asset(
          "assets/cover.png",
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          fit: BoxFit.cover,
        ),
        GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
          child: Scaffold(
            backgroundColor: Colors.transparent,
            resizeToAvoidBottomInset: false,
            body: AutofillGroup(
              child: Form(
                key: _formkey,
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: const Offset(0, 0),
                      child: Padding(
                        padding: EdgeInsets.only(top: _animation.value),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(left: 30, right: 30, bottom: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: TextFormField(
                                autofillHints: const [AutofillHints.username],
                                enableSuggestions: false,
                                autocorrect: false,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return AppLocalizations.of(context)!.username_cannot_be_empty;
                                  }
                                  username = value;
                                  return null;
                                },
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                decoration: InputDecoration(
                                  hintText: AppLocalizations.of(context)!.username,
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.all(10),
                                  hintStyle: const TextStyle(color: Colors.blueGrey),
                                ),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(left: 30, right: 30, bottom: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: TextFormField(
                                autofillHints: const [AutofillHints.password],
                                enableSuggestions: false,
                                autocorrect: false,
                                obscureText: passwordIsObscure,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return AppLocalizations.of(context)!.password_cannot_be_empty;
                                  }
                                  password = value;
                                  return null;
                                },
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                decoration: InputDecoration(
                                  hintText: AppLocalizations.of(context)!.password,
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.all(10),
                                  hintStyle: const TextStyle(color: Colors.blueGrey),
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        passwordIsObscure = !passwordIsObscure;
                                      });
                                    },
                                    icon: const Icon(Icons.visibility),
                                  ),
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 115,
                                  margin: const EdgeInsets.only(left: 10, right: 5, bottom: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.blueGrey,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: TextButton(
                                    onPressed: () {
                                      if (!_formkey.currentState!.validate()) {
                                        return;
                                      }
                                      setState(() {
                                        logining = true;
                                      });
                                      FocusScopeNode currentFocus = FocusScope.of(context);
                                      currentFocus.unfocus();
                                      login(username, password).then(
                                        (value) {
                                          API.token = value;
                                          checkNotification().then((_) {
                                            Navigator.of(context).pushAndRemoveUntil(
                                              PageRouteBuilder(
                                                pageBuilder: (context, animation1, animation2) => const MyHomePage(),
                                                transitionDuration: Duration.zero,
                                                reverseTransitionDuration: Duration.zero,
                                              ),
                                              (route) => false,
                                            );
                                          });
                                        },
                                      ).catchError((e) {
                                        setState(() {
                                          logining = false;
                                        });
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              e.toString(),
                                              style: const TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        );
                                      });
                                    },
                                    child: logining
                                        ? const SpinKitWave(
                                            color: Colors.white60,
                                            size: 20,
                                          )
                                        : Text(
                                            AppLocalizations.of(context)!.login,
                                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                                          ),
                                  ),
                                ),
                                Container(
                                  width: 115,
                                  margin: const EdgeInsets.only(right: 10, left: 5, bottom: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.blueGrey,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: TextButton(
                                    onPressed: logining
                                        ? null
                                        : () {
                                            Navigator.of(context).push(PageRouteBuilder(
                                              pageBuilder: (context, animation, secondaryAnimation) => RegisterPage(screenHeight: widget.screenHeight),
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
                                            ));
                                          },
                                    child: logining
                                        ? const SpinKitWave(
                                            color: Colors.white60,
                                            size: 20,
                                          )
                                        : Text(
                                            AppLocalizations.of(context)!.register,
                                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
