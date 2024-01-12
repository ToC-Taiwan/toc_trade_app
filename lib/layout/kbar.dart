import 'dart:convert';

import 'package:candlesticks/candlesticks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:trade_agent/constant/constant.dart';
import 'package:trade_agent/entity/entity.dart';
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
    fetchCandles(widget.stockNum, startTime, '30').then((value) {
      if (mounted) {
        setState(() {
          candles = value;
        });
      }
    });
  }

  Future<List<Candle>> fetchCandles(String stockNum, String startDate, String interval) async {
    final candleArr = <Candle>[];
    try {
      final response = await http.get(
        Uri.parse('$tradeAgentURLPrefix/history/day-kbar/$stockNum/$startDate/$interval'),
        headers: {
          "Authorization": API.token,
        },
      );
      if (response.statusCode == 200) {
        for (final i in jsonDecode(response.body) as List<dynamic>? ?? <dynamic>[]) {
          final tmp = KbarData.fromJson(i as Map<String, dynamic>);
          final time = DateTime.parse(tmp.kbarTime!);
          candleArr.add(
            Candle(
              date: time.add(const Duration(hours: 8)),
              high: tmp.high!.toDouble(),
              low: tmp.low!.toDouble(),
              open: tmp.open!.toDouble(),
              close: tmp.close!.toDouble(),
              volume: tmp.volume!.toDouble(),
            ),
          );
        }
        if (candleArr.isEmpty) {
          return candleArr;
        }
        startTime = candleArr[candleArr.length - 1].date.add(const Duration(days: -1)).toString().substring(0, 10);
        return candleArr;
      } else {
        return candleArr;
      }
    } on Exception {
      return candleArr;
    }
  }

  Future<void> addCandles(String stockNum, String startDate, String interval) async {
    final newData = await fetchCandles(widget.stockNum, startTime, '30');
    if (mounted) {
      setState(() {
        candles += newData;
        startTime = candles[candles.length - 1].date.add(const Duration(days: -1)).toString().substring(0, 10);
      });
    }
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
              final newData = await fetchCandles(widget.stockNum, startTime, '30');
              if (mounted) {
                setState(() {
                  candles += newData;
                });
              }
            },
            actions: [
              ToolBarAction(
                child: const Icon(Icons.refresh),
                onPressed: () async {
                  final newData = await fetchCandles(widget.stockNum, startTime, '30');
                  if (mounted) {
                    setState(() {
                      candles += newData;
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
