import 'package:candlesticks/candlesticks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:trade_agent/modules/api/api.dart';

class Kbar extends StatefulWidget {
  const Kbar({required this.stockNum, required this.stockName, super.key});

  final String stockNum;
  final String stockName;

  @override
  State<Kbar> createState() => _KbarState();
}

class _KbarState extends State<Kbar> {
  List<Candle> candles = [];
  String startTime = DateTime.now().toString().substring(0, 10);

  @override
  void initState() {
    super.initState();
    API.fetchCandles(widget.stockNum, startTime, '30').then((value) {
      if (value.isEmpty) {
        return;
      }
      startTime = value.last.date.add(const Duration(days: -1)).toString().substring(0, 10);
      if (mounted) {
        setState(() {
          candles = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (candles.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0.5,
          automaticallyImplyLeading: false,
          centerTitle: false,
          title: Text('${widget.stockNum} ${widget.stockName}'),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.close),
            ),
          ],
        ),
        body: Center(
          child: SafeArea(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) => Kbar(
                      stockNum: widget.stockNum,
                      stockName: widget.stockName,
                    ),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
              },
              child: Text(
                AppLocalizations.of(context)!.display,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.5,
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: Text('${widget.stockNum} ${widget.stockName}'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: Center(
        child: SafeArea(
          child: Candlesticks(
            candles: candles,
            onLoadMoreCandles: () async {
              await API.fetchCandles(widget.stockNum, startTime, '30').then((value) {
                if (value.isEmpty) {
                  return;
                }
                startTime = value.last.date.add(const Duration(days: -1)).toString().substring(0, 10);
                if (mounted) {
                  setState(() {
                    candles += value;
                  });
                }
              });
            },
            actions: [
              ToolBarAction(
                child: const Icon(Icons.refresh),
                onPressed: () async {
                  await API.fetchCandles(widget.stockNum, startTime, '30').then((value) {
                    if (value.isEmpty) {
                      return;
                    }
                    startTime = value.last.date.add(const Duration(days: -1)).toString().substring(0, 10);
                    if (mounted) {
                      setState(() {
                        candles += value;
                      });
                    }
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
