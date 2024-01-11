import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:trade_agent/constant/constant.dart';
import 'package:trade_agent/homepage.dart';
import 'package:trade_agent/modules/api/api.dart';
import 'package:trade_agent/register.dart';

Future<String> login(String userName, String password) async {
  try {
    var loginBody = {
      'username': userName,
      'password': password,
    };

    var loginBodyJson = jsonEncode(loginBody);
    final response = await http.post(
      Uri.parse('$tradeAgentURLPrefix/login'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: loginBodyJson,
    );
    if (response.statusCode == 200) {
      final result = jsonDecode(response.body) as Map<String, dynamic>;
      return result['token'];
    } else {
      return '';
    }
  } on Exception {
    return '';
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({required this.db, required this.screenHeight, super.key});
  final Database db;
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
  bool inputing = false;

  @override
  void initState() {
    _controller = AnimationController(duration: const Duration(milliseconds: 200), vsync: this);
    _animation = Tween<double>(begin: widget.screenHeight * 0.7, end: widget.screenHeight * 0.3).animate(_controller);

    var keyboardVisibilityController = KeyboardVisibilityController();
    keyboardSubscription = keyboardVisibilityController.onChange.listen((bool visible) {
      setState(() {
        inputing = visible;
        if (visible) {
          _controller.forward();
        } else {
          _controller.reverse();
        }
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    keyboardSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Stack(
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
                                      return 'Username cannot be empty';
                                    }
                                    username = value;
                                    return null;
                                  },
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  decoration: const InputDecoration(
                                    hintText: "Username",
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.all(10),
                                    hintStyle: TextStyle(color: Colors.blueGrey),
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
                                      return 'Password cannot be empty';
                                    }
                                    password = value;
                                    return null;
                                  },
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  decoration: InputDecoration(
                                    hintText: "Password",
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
                                        login(username, password).then(
                                          (value) {
                                            if (value.isNotEmpty) {
                                              API.token = value;
                                              Navigator.of(context).pushAndRemoveUntil(
                                                PageRouteBuilder(
                                                  pageBuilder: (context, animation1, animation2) => MyHomePage(
                                                    db: widget.db,
                                                  ),
                                                  transitionDuration: Duration.zero,
                                                  reverseTransitionDuration: Duration.zero,
                                                ),
                                                (route) => false,
                                              );
                                            } else {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    "Login failed",
                                                    style: TextStyle(
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                        );
                                      },
                                      child: const Text(
                                        "Login",
                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
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
                                      onPressed: () {
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
                                      child: const Text(
                                        "Register",
                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
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
