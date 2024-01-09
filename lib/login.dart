import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:trade_agent_v2/constant/constant.dart';
import 'package:trade_agent_v2/homepage.dart';

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
  const LoginPage({required this.db, super.key});
  final Database db;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController usernameTextController = TextEditingController();
  bool usernameIsEmpty = false;

  TextEditingController passwordTextController = TextEditingController();
  bool passwordIsEmpty = false;
  bool passwordIsObscure = true;

  @override
  void dispose() {
    usernameTextController.dispose();
    passwordTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Material(
        child: DecoratedBox(
          decoration: const BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.fill,
              image: AssetImage(
                'assets/cover.png',
              ),
            ),
          ),
          // color: const Color.fromARGB(252, 153, 208, 218),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 75),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  margin: const EdgeInsets.only(left: 30, right: 30, bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    controller: usernameTextController,
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        setState(() {
                          usernameIsEmpty = false;
                        });
                      }
                    },
                    decoration: InputDecoration(
                      hintText: "Username",
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(10),
                      hintStyle: usernameIsEmpty ? const TextStyle(color: Colors.red) : const TextStyle(color: Colors.blueGrey),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 30, right: 30, bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    obscureText: passwordIsObscure,
                    enableSuggestions: false,
                    autocorrect: false,
                    controller: passwordTextController,
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        setState(() {
                          passwordIsEmpty = false;
                        });
                      }
                    },
                    decoration: InputDecoration(
                      hintText: "Password",
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(10),
                      hintStyle: passwordIsEmpty ? const TextStyle(color: Colors.red) : const TextStyle(color: Colors.blueGrey),
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
                      margin: const EdgeInsets.only(left: 30, right: 10, bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextButton(
                        onPressed: () {
                          if (usernameTextController.text.isEmpty) {
                            setState(() {
                              usernameIsEmpty = true;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Username is empty"),
                              ),
                            );
                          } else if (passwordTextController.text.isEmpty) {
                            setState(() {
                              passwordIsEmpty = true;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Password is empty"),
                              ),
                            );
                          } else {
                            login(usernameTextController.text, passwordTextController.text).then(
                              (value) {
                                if (value.isNotEmpty) {
                                  Navigator.of(context).pushAndRemoveUntil(
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation1, animation2) => MyHomePage(
                                        title: 'TradeAgentV2',
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
                                      content: Text("Login failed"),
                                    ),
                                  );
                                }
                              },
                            );
                          }
                        },
                        child: const Text(
                          "Login",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                    Container(
                      width: 115,
                      margin: const EdgeInsets.only(right: 30, bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextButton(
                        onPressed: () {},
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
        ),
      );
}
