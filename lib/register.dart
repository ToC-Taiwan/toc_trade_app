import 'dart:async';
import 'dart:convert';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
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
    super.initState();
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
    final unknownErrMsg = AppLocalizations.of(context)!.unknown_error;
    try {
      var registerBody = {
        'username': userName,
        'password': password,
        'email': email,
      };

      final response = await http.post(
        Uri.parse('$tradeAgentURLPrefix/user'),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(registerBody),
      );
      if (response.statusCode == 200) {
        return '';
      } else {
        final result = jsonDecode(response.body) as Map<String, dynamic>;
        return result['response'];
      }
    } on Exception {
      return unknownErrMsg;
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
          success ? AppLocalizations.of(context)!.register_success : result,
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
            child: Text(
              AppLocalizations.of(context)!.dismiss,
              style: const TextStyle(
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
                title: Text(
                  AppLocalizations.of(context)!.register,
                  style: const TextStyle(color: Colors.black),
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
                                      return AppLocalizations.of(context)!.username_cannot_be_empty;
                                    }
                                    if (value.length < 8) {
                                      return AppLocalizations.of(context)!.username_minimum_length_is_8;
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
                                  autofillHints: const [AutofillHints.newPassword],
                                  enableSuggestions: false,
                                  autocorrect: false,
                                  obscureText: passwordIsObscure,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return AppLocalizations.of(context)!.password_cannot_be_empty;
                                    }
                                    if (value.length < 8) {
                                      return AppLocalizations.of(context)!.password_minimum_length_is_8;
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
                                      return AppLocalizations.of(context)!.confirm_password_cannot_be_empty;
                                    }
                                    if (value != password) {
                                      return AppLocalizations.of(context)!.confirm_password_is_not_same_as_password;
                                    }
                                    confirmPassword = value;
                                    return null;
                                  },
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  decoration: InputDecoration(
                                    hintText: AppLocalizations.of(context)!.confirm_password,
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
                                      return AppLocalizations.of(context)!.email_cannot_be_empty;
                                    }
                                    if (!EmailValidator.validate(value)) {
                                      return AppLocalizations.of(context)!.email_is_invalid;
                                    }
                                    email = value;
                                    return null;
                                  },
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  decoration: InputDecoration(
                                    hintText: AppLocalizations.of(context)!.email_address,
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.all(10),
                                    hintStyle: const TextStyle(color: Colors.blueGrey),
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
                                      ? const SpinKitWave(
                                          color: Colors.white60,
                                          size: 20,
                                        )
                                      : Text(
                                          success ? "😁" : AppLocalizations.of(context)!.register,
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
