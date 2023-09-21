import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:trade_agent_v2/generated/l10n.dart';
import 'package:trade_agent_v2/homepage.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({required this.db, Key? key}) : super(key: key);
  final Database db;

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> with TickerProviderStateMixin {
  late AnimationController _lottieAnimation;

  final transitionDuration = const Duration(seconds: 1);

  @override
  void initState() {
    _lottieAnimation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    Future.delayed(
      const Duration(seconds: 1),
    ).then(
      (value) => _lottieAnimation.forward().then(
            (value) => Navigator.of(context).pushAndRemoveUntil(
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) => MyHomePage(
                  title: 'TradeAgentV2',
                  db: widget.db,
                ),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
              (route) => false,
            ),
          ),
    );
    super.initState();
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const CircularProgressIndicator(
                color: Colors.grey,
              ),
              const SizedBox(
                height: 30,
              ),
              Text(
                S.of(context).loading,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(
                height: 60,
              ),
            ],
          ),
        ),
      );
}
