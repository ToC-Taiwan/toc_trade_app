import 'dart:async';

import 'package:date_format/date_format.dart' as df;
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:trade_agent/entity/entity.dart';
import 'package:trade_agent/modules/api/api.dart';
import 'package:trade_agent/pb/app.pb.dart' as pb;
import 'package:trade_agent/utils/app_bar.dart';
import 'package:wakelock/wakelock.dart';
import 'package:web_socket_channel/io.dart';

class FutureTradePage extends StatefulWidget {
  const FutureTradePage({super.key});

  @override
  State<FutureTradePage> createState() => _FutureTradePageState();
}

class _FutureTradePageState extends State<FutureTradePage> {
  late IOWebSocketChannel? _channel;

  String code = '';
  String delieveryDate = '';

  RealTimeFutureTickArr totalTickArr = RealTimeFutureTickArr();
  List<RealTimeFutureTick> tickArr = [];

  Future<TradeIndex?> tradeIndex = Future.value();
  Future<FuturePosition?> futurePosition = Future.value();
  Future<List<RealTimeFutureTick>?> realTimeFutureTickArr = Future.value([]);

  RealTimeFutureTick? lastTick;
  List<KbarData> kbarArr = [];
  int kbarMaxVolume = 0;

  @override
  void initState() {
    super.initState();
    Wakelock.enable();
    initialWS();
  }

  @override
  void dispose() {
    _channel!.sink.close();
    Wakelock.disable();
    super.dispose();
  }

  void initialWS() async {
    _channel = IOWebSocketChannel.connect(
      Uri.parse(backendFutureWSURLPrefix),
      pingInterval: const Duration(seconds: 1),
      headers: {
        "Authorization": API.authKey,
      },
    );
    await _channel!.ready;
    _channel!.stream.listen(
      (message) {
        if (!mounted) {
          return;
        }

        final msg = pb.WSMessage.fromBuffer(message as List<int>);
        switch (msg.type) {
          case pb.WSType.TYPE_FUTURE_TICK:
            updateTradeRate(msg.futureTick, totalTickArr);
            setState(() {
              lastTick = RealTimeFutureTick.fromProto(msg.futureTick);
              realTimeFutureTickArr = fillArr(msg.futureTick, tickArr);
            });
            return;

          case pb.WSType.TYPE_FUTURE_ORDER:
            return;

          case pb.WSType.TYPE_TRADE_INDEX:
            setState(() {
              tradeIndex = updateTradeIndex(msg.tradeIndex);
            });
            return;

          case pb.WSType.TYPE_FUTURE_POSITION:
            if (code.isNotEmpty) {
              futurePosition = updateFuturePosition(msg.futurePosition, code);
            }
            return;

          case pb.WSType.TYPE_ASSIST_STATUS:
            return;

          case pb.WSType.TYPE_KBAR_ARR:
            setState(() {
              final tmp = KbarArr.fromProto(msg.historyKbar);
              kbarArr = tmp.arr!;
              kbarMaxVolume = tmp.maxVolume!.toInt();
            });
            return;

          case pb.WSType.TYPE_ERR_MESSAGE:
            return;

          case pb.WSType.TYPE_FUTURE_DETAIL:
            setState(() {
              code = msg.futureDetail.code;
              delieveryDate = msg.futureDetail.deliveryDate;
            });
            return;
        }
      },
      onDone: () {
        if (mounted) {
          Future.delayed(const Duration(milliseconds: 1000)).then((value) {
            _channel!.sink.close();
            initialWS();
          });
        }
      },
      onError: (error) {},
    );
  }

  void updateTradeRate(pb.WSFutureTick ws, RealTimeFutureTickArr totalArr) {
    totalTickArr
      ..add(RealTimeFutureTick.fromProto(ws))
      ..process();
  }

  Future<TradeIndex> updateTradeIndex(pb.WSTradeIndex ws) async => TradeIndex.fromProto(ws);
  Future<FuturePosition> updateFuturePosition(pb.WSFuturePosition ws, String code) async => FuturePosition.fromProto(ws, code);
  Future<List<RealTimeFutureTick>> fillArr(pb.WSFutureTick wsTick, List<RealTimeFutureTick> originalArr) async {
    final tmp = RealTimeFutureTick.fromProto(wsTick);
    if (originalArr.isNotEmpty && originalArr.last.close == tmp.close && originalArr.last.tickType == tmp.tickType) {
      originalArr.last.volume = originalArr.last.volume! + tmp.volume!;
      originalArr.last.tickTime = tmp.tickTime;
      originalArr.last.combo = true;
    } else {
      originalArr.add(tmp);
      if (originalArr.length > 3) {
        originalArr.removeAt(0);
      }
    }
    return originalArr.reversed.toList();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        // backgroundColor: Colors.white,
        appBar: trAppbar(
          context,
          AppLocalizations.of(context)!.future_trade,
        ),
        body: SizedBox(
          child: Column(
            children: [
              Expanded(
                flex: 5,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: SizedBox(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: SizedBox(
                                child: Column(
                                  children: [
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        code,
                                        style: GoogleFonts.getFont(
                                          'Source Code Pro',
                                          fontStyle: FontStyle.normal,
                                          fontSize: 40,
                                          color: Colors.blueGrey,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Padding(
                                        padding: const EdgeInsets.only(right: 30),
                                        child: FutureBuilder<FuturePosition?>(
                                          future: futurePosition,
                                          builder: (context, snapshot) {
                                            if (snapshot.hasData) {
                                              if (snapshot.data!.direction == 'Buy') {
                                                return Text(
                                                  '${AppLocalizations.of(context)!.buy}: ${snapshot.data!.quantity}\n${AppLocalizations.of(context)!.avg}: ${snapshot.data!.price}',
                                                  style: GoogleFonts.getFont(
                                                    'Source Code Pro',
                                                    fontStyle: FontStyle.normal,
                                                    fontSize: 15,
                                                    color: Colors.grey,
                                                  ),
                                                );
                                              }
                                              if (snapshot.data!.direction == 'Sell') {
                                                return Text(
                                                  '${AppLocalizations.of(context)!.sell}: ${snapshot.data!.quantity}\n${AppLocalizations.of(context)!.avg}: ${snapshot.data!.price}',
                                                  style: GoogleFonts.getFont(
                                                    'Source Code Pro',
                                                    fontStyle: FontStyle.normal,
                                                    fontSize: 15,
                                                    color: Colors.grey,
                                                  ),
                                                );
                                              }
                                            }
                                            return Text(
                                              delieveryDate,
                                              style: GoogleFonts.getFont('Source Code Pro', fontStyle: FontStyle.normal, fontSize: 15, color: Colors.grey),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: FutureBuilder<TradeIndex?>(
                                future: tradeIndex,
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return SizedBox(
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: Column(
                                              children: [
                                                Align(
                                                  alignment: Alignment.centerLeft,
                                                  child: Text(
                                                    'NASDAQ:',
                                                    style: GoogleFonts.getFont(
                                                      'Source Code Pro',
                                                      fontStyle: FontStyle.normal,
                                                      fontSize: 15,
                                                      color: Colors.blueGrey,
                                                    ),
                                                  ),
                                                ),
                                                Align(
                                                  alignment: Alignment.centerLeft,
                                                  child: Text(
                                                    'NQ=F:',
                                                    style: GoogleFonts.getFont(
                                                      'Source Code Pro',
                                                      fontStyle: FontStyle.normal,
                                                      fontSize: 15,
                                                      color: Colors.blueGrey,
                                                    ),
                                                  ),
                                                ),
                                                Align(
                                                  alignment: Alignment.centerLeft,
                                                  child: Text(
                                                    'TSE:',
                                                    style: GoogleFonts.getFont(
                                                      'Source Code Pro',
                                                      fontStyle: FontStyle.normal,
                                                      fontSize: 15,
                                                      color: Colors.blueGrey,
                                                    ),
                                                  ),
                                                ),
                                                Align(
                                                  alignment: Alignment.centerLeft,
                                                  child: Text(
                                                    'OTC:',
                                                    style: GoogleFonts.getFont(
                                                      'Source Code Pro',
                                                      fontStyle: FontStyle.normal,
                                                      fontSize: 15,
                                                      color: Colors.blueGrey,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            flex: 3,
                                            child: Column(
                                              children: [
                                                SizedBox(
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        flex: 2,
                                                        child: Align(
                                                          alignment: Alignment.centerRight,
                                                          child: Text(
                                                            snapshot.data!.nasdaq!.priceChg!.toStringAsFixed(2),
                                                            style: GoogleFonts.getFont(
                                                              'Source Code Pro',
                                                              fontStyle: FontStyle.normal,
                                                              fontSize: 15,
                                                              color: snapshot.data!.nasdaq!.priceChg! == 0
                                                                  ? Colors.blueGrey
                                                                  : snapshot.data!.nasdaq!.priceChg! > 0
                                                                      ? Colors.red
                                                                      : Colors.green,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Align(
                                                          alignment: Alignment.centerRight,
                                                          child: Text(
                                                            '!${snapshot.data!.nasdaq!.breakCount!.abs()}',
                                                            style: GoogleFonts.getFont(
                                                              'Source Code Pro',
                                                              fontStyle: FontStyle.normal,
                                                              fontSize: 15,
                                                              color: snapshot.data!.nasdaq!.breakCount! == 0
                                                                  ? Colors.blueGrey
                                                                  : snapshot.data!.nasdaq!.breakCount! > 0
                                                                      ? Colors.red
                                                                      : Colors.green,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        flex: 2,
                                                        child: Align(
                                                          alignment: Alignment.centerRight,
                                                          child: Text(
                                                            snapshot.data!.nf!.priceChg!.toStringAsFixed(2),
                                                            style: GoogleFonts.getFont(
                                                              'Source Code Pro',
                                                              fontStyle: FontStyle.normal,
                                                              fontSize: 15,
                                                              color: snapshot.data!.nf!.priceChg! == 0
                                                                  ? Colors.blueGrey
                                                                  : snapshot.data!.nf!.priceChg! > 0
                                                                      ? Colors.red
                                                                      : Colors.green,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Align(
                                                          alignment: Alignment.centerRight,
                                                          child: Text(
                                                            '!${snapshot.data!.nf!.breakCount!.abs()}',
                                                            style: GoogleFonts.getFont(
                                                              'Source Code Pro',
                                                              fontStyle: FontStyle.normal,
                                                              fontSize: 15,
                                                              color: snapshot.data!.nf!.breakCount! == 0
                                                                  ? Colors.blueGrey
                                                                  : snapshot.data!.nf!.breakCount! > 0
                                                                      ? Colors.red
                                                                      : Colors.green,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        flex: 2,
                                                        child: Align(
                                                          alignment: Alignment.centerRight,
                                                          child: Text(
                                                            snapshot.data!.tse!.priceChg!.toStringAsFixed(2),
                                                            style: GoogleFonts.getFont(
                                                              'Source Code Pro',
                                                              fontStyle: FontStyle.normal,
                                                              fontSize: 15,
                                                              color: snapshot.data!.tse!.priceChg! == 0
                                                                  ? Colors.blueGrey
                                                                  : snapshot.data!.tse!.priceChg! > 0
                                                                      ? Colors.red
                                                                      : Colors.green,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Align(
                                                          alignment: Alignment.centerRight,
                                                          child: Text(
                                                            '!${snapshot.data!.tse!.breakCount!.abs()}',
                                                            style: GoogleFonts.getFont(
                                                              'Source Code Pro',
                                                              fontStyle: FontStyle.normal,
                                                              fontSize: 15,
                                                              color: snapshot.data!.tse!.breakCount! == 0
                                                                  ? Colors.blueGrey
                                                                  : snapshot.data!.tse!.breakCount! > 0
                                                                      ? Colors.red
                                                                      : Colors.green,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        flex: 2,
                                                        child: Align(
                                                          alignment: Alignment.centerRight,
                                                          child: Text(
                                                            snapshot.data!.otc!.priceChg!.toStringAsFixed(2),
                                                            style: GoogleFonts.getFont(
                                                              'Source Code Pro',
                                                              fontStyle: FontStyle.normal,
                                                              fontSize: 15,
                                                              color: snapshot.data!.otc!.priceChg! == 0
                                                                  ? Colors.blueGrey
                                                                  : snapshot.data!.otc!.priceChg! > 0
                                                                      ? Colors.red
                                                                      : Colors.green,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Align(
                                                          alignment: Alignment.centerRight,
                                                          child: Text(
                                                            '!${snapshot.data!.otc!.breakCount!.abs()}',
                                                            style: GoogleFonts.getFont(
                                                              'Source Code Pro',
                                                              fontStyle: FontStyle.normal,
                                                              fontSize: 15,
                                                              color: snapshot.data!.otc!.breakCount! == 0
                                                                  ? Colors.blueGrey
                                                                  : snapshot.data!.otc!.breakCount! > 0
                                                                      ? Colors.red
                                                                      : Colors.green,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                  return Center(
                                    child: Text(
                                      '${AppLocalizations.of(context)!.loading}...',
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: SizedBox(
                        child: Row(
                          children: [
                            Expanded(
                              child: Center(
                                child: lastTick == null
                                    ? null
                                    : Text(
                                        lastTick!.close!.toStringAsFixed(0),
                                        style: GoogleFonts.getFont(
                                          'Source Code Pro',
                                          fontStyle: FontStyle.normal,
                                          fontSize: 50,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                            Expanded(
                              child: Center(
                                child: lastTick == null
                                    ? null
                                    : Text(
                                        '${lastTick!.changeType} ${lastTick!.priceChg!.abs().toStringAsFixed(0)}',
                                        style: GoogleFonts.getFont(
                                          'Source Code Pro',
                                          fontStyle: FontStyle.normal,
                                          fontSize: 50,
                                          color: lastTick!.priceChg! == 0
                                              ? Colors.blueGrey
                                              : lastTick!.priceChg! > 0
                                                  ? Colors.red
                                                  : Colors.green,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 40, right: 20),
                      child: SizedBox(
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                '${totalTickArr.rate.toStringAsFixed(1)}/s',
                                style: GoogleFonts.getFont(
                                  'Source Code Pro',
                                  fontStyle: FontStyle.normal,
                                  fontSize: 25,
                                  color: totalTickArr.rate > 10 ? Colors.red : Colors.grey,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: LinearPercentIndicator(
                                barRadius: const Radius.circular(10),
                                animateFromLastPercent: true,
                                width: 220,
                                lineHeight: 50,
                                percent: totalTickArr.outInRatio.toDouble(),
                                center: Text(
                                  (100 * totalTickArr.outInRatio).toStringAsFixed(1),
                                  style: GoogleFonts.getFont(
                                    'Source Code Pro',
                                    fontStyle: FontStyle.normal,
                                    fontSize: 25,
                                    color: totalTickArr.outInRatio != 0 ? Colors.white : Colors.transparent,
                                  ),
                                ),
                                progressColor: Colors.redAccent,
                                backgroundColor: totalTickArr.outInRatio != 0 ? Colors.greenAccent : Colors.transparent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: FutureBuilder<List<RealTimeFutureTick>?>(
                    future: realTimeFutureTickArr,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data!.isEmpty) {
                          return Container();
                        }

                        final value = snapshot.data!;
                        return ListView.builder(
                          itemCount: value.length,
                          itemBuilder: (context, index) {
                            final tickType = value[index].tickType;
                            var volumeFontSize = 14;
                            if (value[index].combo!) {
                              volumeFontSize = 20;
                            }
                            return Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 30,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: tickType! == 1 ? Colors.red : Colors.green,
                                  width: 1.1,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: ListTile(
                                dense: true,
                                leading: Text(
                                  '${value[index].volume!}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: volumeFontSize.toDouble(),
                                    color: tickType == 1 ? Colors.red : Colors.green,
                                  ),
                                ),
                                title: Text(
                                  value[index].close!.toStringAsFixed(0),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: volumeFontSize.toDouble(),
                                    color: tickType == 1 ? Colors.red : Colors.green,
                                  ),
                                ),
                                trailing: Text(df.formatDate(value[index].tickTime!, [df.HH, ':', df.nn, ':', df.ss])),
                              ),
                            );
                          },
                        );
                      }
                      return Center(
                        child: Container(),
                      );
                    },
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: SfCartesianChart(
                    enableSideBySideSeriesPlacement: false,
                    plotAreaBorderWidth: 0,
                    primaryYAxis: NumericAxis(
                      isVisible: false,
                    ),
                    primaryXAxis: DateTimeAxis(
                      majorGridLines: const MajorGridLines(width: 0),
                    ),
                    axes: [
                      NumericAxis(
                        isVisible: false,
                        name: 'price',
                      ),
                      NumericAxis(
                        maximum: kbarMaxVolume.toDouble() * 3,
                        isVisible: false,
                        opposedPosition: true,
                        name: 'volume',
                      ),
                    ],
                    series: <CartesianSeries>[
                      CandleSeries(
                        yAxisName: 'price',
                        showIndicationForSameValues: true,
                        enableSolidCandles: true,
                        bearColor: Colors.green,
                        bullColor: Colors.red,
                        dataSource: kbarArr,
                        xValueMapper: (datum, index) => DateTime.parse((datum as KbarData).kbarTime!),
                        lowValueMapper: (datum, index) => (datum as KbarData).low,
                        highValueMapper: (datum, index) => (datum as KbarData).high,
                        openValueMapper: (datum, index) => (datum as KbarData).open,
                        closeValueMapper: (datum, index) => (datum as KbarData).close,
                        trendlines: <Trendline>[
                          Trendline(
                            type: TrendlineType.polynomial,
                            dashArray: <double>[5, 5],
                          ),
                        ],
                      ),
                      ColumnSeries(
                        yAxisName: 'volume',
                        dataSource: kbarArr,
                        xValueMapper: (datum, index) => DateTime.parse((datum as KbarData).kbarTime!),
                        yValueMapper: (datum, index) => (datum as KbarData).volume!,
                        pointColorMapper: (datum, index) => (datum as KbarData).close! > datum.open! ? Colors.redAccent : Colors.greenAccent,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
