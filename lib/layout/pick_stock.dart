import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:trade_agent/constant/constant.dart';
import 'package:trade_agent/daos/database.dart';
import 'package:trade_agent/entity/entity.dart';
import 'package:trade_agent/layout/kbar.dart';
import 'package:trade_agent/modules/api/api.dart';
import 'package:trade_agent/utils/app_bar.dart';
import 'package:web_socket_channel/io.dart';

class PickStockPage extends StatefulWidget {
  const PickStockPage({super.key});

  @override
  State<PickStockPage> createState() => _PickStockPageState();
}

class _PickStockPageState extends State<PickStockPage> {
  late IOWebSocketChannel? _channel;
  late Future<List<PickStock>> stockArray;

  TextEditingController textFieldController = TextEditingController();
  List<PickStock> stockList = [];

  @override
  void initState() {
    super.initState();
    stockArray = PickStockDao.getAllPickStock();
    initialWS();
  }

  @override
  void dispose() {
    textFieldController.dispose();
    _channel!.sink.close();
    super.dispose();
  }

  void initialWS() {
    _channel = IOWebSocketChannel.connect(
      Uri.parse(tradeAgentWSURLPrefix),
      pingInterval: const Duration(seconds: 1),
      headers: {
        "Authorization": API.token,
      },
    );
    _channel!.stream.listen(
      (message) {
        if (!mounted) {
          return;
        }

        for (final i in jsonDecode(message as String) as List<dynamic>) {
          for (final j in stockList) {
            if ((i as Map<String, dynamic>)['stock_num'] == j.stockNum) {
              if (i['price_change'] is int) {
                final tmp = i['price_change'] as int;
                i['price_change'] = tmp.toDouble();
              }
              if (i['price_change_rate'] is int) {
                final tmp = i['price_change_rate'] as int;
                i['price_change_rate'] = tmp.toDouble();
              }
              if (i['price'] is int) {
                final tmp = i['price'] as int;
                i['price'] = tmp.toDouble();
              }
              final tmp = PickStock(
                i['stock_num'] as String,
                i['stock_name'] as String,
                0,
                i['price_change'] as double,
                i['price_change_rate'] as double,
                i['price'] as double,
                id: j.id,
                createTime: j.createTime,
                updateTime: j.updateTime,
              );
              if (i['wrong'] as bool) {
                PickStockDao.deletePickStock(tmp);
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(AppLocalizations.of(context)!.warning),
                    content: Text('${tmp.stockNum} ${AppLocalizations.of(context)!.stock_dose_not_exist}'),
                    actions: [
                      ElevatedButton(
                        child: Text(
                          AppLocalizations.of(context)!.ok,
                          style: const TextStyle(color: Colors.black),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                );
              } else {
                PickStockDao.updatePickStock(tmp);
              }
              break;
            }
          }
        }
        setState(() {
          stockArray = PickStockDao.getAllPickStock();
        });
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

  @override
  Widget build(BuildContext context) {
    final actions = [
      IconButton(
        icon: const Icon(Icons.delete_forever),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(AppLocalizations.of(context)!.delete_all_pick_stock),
              content: Text(AppLocalizations.of(context)!.delete_all_pick_stock_confirm),
              actions: [
                ElevatedButton(
                  child: Text(
                    AppLocalizations.of(context)!.cancel,
                    style: const TextStyle(color: Colors.black),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                ElevatedButton(
                  child: Text(
                    AppLocalizations.of(context)!.delete,
                    style: const TextStyle(color: Colors.black),
                  ),
                  onPressed: () {
                    PickStockDao.deleteAllPickStock();
                    stockList = [];
                    _channel!.sink.add(
                      jsonEncode({
                        'pick_stock_list': [],
                      }),
                    );
                    setState(() {
                      stockArray = PickStockDao.getAllPickStock();
                    });
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          );
        },
      ),
      Padding(
        padding: const EdgeInsets.only(right: 10),
        child: IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(AppLocalizations.of(context)!.type_stock_number),
                content: TextField(
                  // onChanged: (value) {},
                  controller: textFieldController,
                  decoration: InputDecoration(
                    hintText: '${AppLocalizations.of(context)!.stock_number}(0050, 00878...)',
                  ),
                  keyboardType: TextInputType.number,
                  autofocus: true,
                ),
                actions: <Widget>[
                  ElevatedButton(
                    child: Text(
                      AppLocalizations.of(context)!.cancel,
                      style: const TextStyle(color: Colors.black),
                    ),
                    onPressed: () {
                      textFieldController.clear();
                      Navigator.pop(context);
                    },
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (textFieldController.text.isEmpty) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(AppLocalizations.of(context)!.warning),
                            content: Text(AppLocalizations.of(context)!.input_must_not_empty),
                            actions: [
                              ElevatedButton(
                                child: Text(
                                  AppLocalizations.of(context)!.ok,
                                  style: const TextStyle(color: Colors.black),
                                ),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          ),
                        );
                        return;
                      }
                      final t = PickStock(
                        textFieldController.text,
                        textFieldController.text,
                        1,
                        0,
                        0,
                        0,
                      );
                      final exist =
                          stockList.firstWhere((element) => element.stockNum == textFieldController.text, orElse: () => PickStock('', '', 0, 0, 0, 0));
                      if (exist.stockNum == '') {
                        PickStockDao.insertPickStock(t);
                        setState(() {
                          stockArray = PickStockDao.getAllPickStock();
                        });
                      }
                      textFieldController.clear();
                      Navigator.pop(context);
                    },
                    child: Text(
                      AppLocalizations.of(context)!.add,
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    ];
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: trAppbar(
        context,
        AppLocalizations.of(context)!.pick_stock,
        actions: actions,
      ),
      body: FutureBuilder<List<PickStock>>(
        future: stockArray,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.isEmpty) {
              _channel!.sink.add(
                jsonEncode({
                  'pick_stock_list': [],
                }),
              );
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.no_pick_stock,
                      style: const TextStyle(fontSize: 30),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        AppLocalizations.of(context)!.click_plus_to_add_stock,
                        style: const TextStyle(fontSize: 22, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              );
            } else {
              final numList = <String>[];
              stockList = [];
              for (final s in snapshot.data!) {
                stockList.add(s);
                numList.add(s.stockNum);
              }
              _channel!.sink.add(
                jsonEncode({
                  'pick_stock_list': numList,
                }),
              );
            }
            return ListView.separated(
              separatorBuilder: (context, index) => const Divider(
                height: 0,
                color: Colors.grey,
              ),
              shrinkWrap: true,
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var textColor = Colors.black;
                if (snapshot.data![index].priceChangeRate < 0) {
                  textColor = Colors.green;
                } else if (snapshot.data![index].priceChangeRate > 0) {
                  textColor = Colors.red;
                }
                var sign = '';
                if (snapshot.data![index].priceChangeRate > 0) {
                  sign = '+';
                }
                return ListTile(
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          snapshot.data![index].stockName,
                          style: TextStyle(fontSize: 23, color: textColor, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          snapshot.data![index].price.toString(),
                          textAlign: TextAlign.end,
                          style: TextStyle(fontSize: 23, color: textColor, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Row(
                    children: [
                      Expanded(
                        child: Text(
                          snapshot.data![index].stockNum,
                          // style: TextStyle(
                          //   color: textColor,
                          // ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '$sign${snapshot.data![index].priceChange}($sign${snapshot.data![index].priceChangeRate}%)',
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Kbar(
                          stockNum: snapshot.data![index].stockNum,
                          stockName: snapshot.data![index].stockName,
                        ),
                      ),
                    );
                  },
                  onLongPress: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(AppLocalizations.of(context)!.delete),
                        content: Text(AppLocalizations.of(context)!.delete_pick_stock_confirm),
                        actions: <Widget>[
                          ElevatedButton(
                            child: Text(
                              AppLocalizations.of(context)!.cancel,
                              style: const TextStyle(color: Colors.black),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          ElevatedButton(
                            child: Text(
                              AppLocalizations.of(context)!.ok,
                              style: const TextStyle(color: Colors.black),
                            ),
                            onPressed: () {
                              setState(() {
                                PickStockDao.deletePickStock(snapshot.data![index]);
                                stockArray = PickStockDao.getAllPickStock();
                              });
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          }
          return const Center(
            child: SpinKitWave(color: Colors.blueGrey, size: 35.0),
          );
        },
      ),
    );
  }
}
