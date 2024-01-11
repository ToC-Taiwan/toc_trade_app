import 'dart:async';
import 'dart:convert';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:http/http.dart' as http;
import 'package:trade_agent/constant/constant.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({required this.screenHeight, super.key});
  final double screenHeight;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  late StreamSubscription<bool> keyboardSubscription;
  late AnimationController _controller;
  late Animation<double> _animation;

  String username = '';
  String email = '';
  String password = '';
  String confirmPassword = '';

  bool passwordIsObscure = true;
  bool confirmPasswordIsObscure = true;

  bool registering = false;
  bool success = false;
  bool bannerIsShown = false;

  @override
  void initState() {
    _controller = AnimationController(duration: const Duration(milliseconds: 200), vsync: this);
    _animation = Tween<double>(begin: widget.screenHeight * 0.15, end: widget.screenHeight * 0.05).animate(_controller);

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
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    keyboardSubscription.cancel();
    super.dispose();
  }

  Future<String> register(String userName, String password, String email) async {
    setState(() {
      registering = true;
    });

    try {
      var registerBody = {
        'username': userName,
        'password': password,
        'email': email,
      };

      final response = await http.post(
        Uri.parse('$tradeAgentURLPrefix/user'),
        body: jsonEncode(registerBody),
      );
      if (response.statusCode == 200) {
        return '';
      } else {
        final result = jsonDecode(response.body) as Map<String, dynamic>;
        return result['response'];
      }
    } on Exception {
      return 'unknown error';
    }
  }

  void removeBanner() {
    ScaffoldMessenger.of(context).removeCurrentMaterialBanner();
    setState(() {
      bannerIsShown = false;
    });
  }

  void showRegisterResultBanner(String result) {
    setState(() {
      bannerIsShown = true;
    });

    ScaffoldMessenger.of(context).showMaterialBanner(
      MaterialBanner(
        content: Text(
          success ? 'Register success' : result,
          style: const TextStyle(
            color: Colors.black,
          ),
        ),
        leading: success
            ? const Icon(
                Icons.check,
                color: Colors.green,
              )
            : const Icon(
                Icons.error,
                color: Colors.red,
              ),
        actions: [
          TextButton(
            onPressed: () {
              removeBanner();
            },
            child: const Text(
              "Dismiss",
              style: TextStyle(
                color: Colors.blueGrey,
              ),
            ),
          )
        ],
      ),
    );
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
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0.5,
                title: const Text(
                  "Register",
                  style: TextStyle(color: Colors.black),
                ),
                centerTitle: true,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: bannerIsShown ? Colors.grey : Colors.black),
                  onPressed: bannerIsShown
                      ? null
                      : () {
                          Navigator.pop(context);
                        },
                ),
              ),
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
                                  autofillHints: const [AutofillHints.newUsername],
                                  enableSuggestions: false,
                                  autocorrect: false,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Username cannot be empty';
                                    }
                                    if (value.length < 8) {
                                      return 'Username must be at least 8 characters';
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
                                  autofillHints: const [AutofillHints.newPassword],
                                  enableSuggestions: false,
                                  autocorrect: false,
                                  obscureText: passwordIsObscure,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Password cannot be empty';
                                    }
                                    if (value.length < 8) {
                                      return 'Password must be at least 8 characters';
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
                              Container(
                                margin: const EdgeInsets.only(left: 30, right: 30, bottom: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: TextFormField(
                                  autofillHints: const [AutofillHints.newPassword],
                                  enableSuggestions: false,
                                  autocorrect: false,
                                  obscureText: confirmPasswordIsObscure,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Confirm Password cannot be empty';
                                    }
                                    if (value != password) {
                                      return 'Confirm Password must be same as Password';
                                    }
                                    confirmPassword = value;
                                    return null;
                                  },
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  decoration: InputDecoration(
                                    hintText: "Confirm Password",
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.all(10),
                                    hintStyle: const TextStyle(color: Colors.blueGrey),
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          confirmPasswordIsObscure = !confirmPasswordIsObscure;
                                        });
                                      },
                                      icon: const Icon(Icons.visibility),
                                    ),
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
                                  autofillHints: const [AutofillHints.email],
                                  enableSuggestions: false,
                                  autocorrect: false,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Email Address cannot be empty';
                                    }
                                    if (!EmailValidator.validate(value)) {
                                      return 'Please enter a valid Email';
                                    }
                                    email = value;
                                    return null;
                                  },
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  decoration: const InputDecoration(
                                    hintText: "Email Address",
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.all(10),
                                    hintStyle: TextStyle(color: Colors.blueGrey),
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
                                  onPressed: success
                                      ? null
                                      : () {
                                          if (!_formkey.currentState!.validate()) {
                                            return;
                                          }
                                          register(username, password, email).then(
                                            (value) {
                                              setState(() {
                                                success = value.isEmpty;
                                                registering = false;
                                              });
                                              removeBanner();
                                              showRegisterResultBanner(value);
                                            },
                                          );
                                        },
                                  child: registering
                                      ? const CircularProgressIndicator(
                                          color: Colors.white60,
                                        )
                                      : Text(
                                          success ? "😁" : "Register",
                                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                                        ),
                                ),
                              )
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
