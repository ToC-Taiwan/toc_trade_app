import 'dart:convert';

import 'package:date_format/date_format.dart' as df;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:trade_agent/constant/constant.dart';
import 'package:trade_agent/entity/entity.dart';
import 'package:trade_agent/generated/l10n.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({required this.date, super.key});

  final String date;

  @override
  State<OrderPage> createState() => _OrderPage();
}

class _OrderPage extends State<OrderPage> {
  Future<FutureOrderArr?> futureOrder = Future.value();

  @override
  void initState() {
    super.initState();
    futureOrder = fetchOrders(widget.date);
  }

  Future<void> recalculateBalance() async {
    try {
      final response = await http.put(Uri.parse('$tradeAgentURLPrefix/order/date/${widget.date}'));
      if (response.statusCode == 200) {
        _showDialog('Recalculate Success');
      } else {
        _showDialog('Recalculate Failed');
      }
    } on Exception {
      _showDialog('Network Error');
    }
  }

  Future<String> moveOrderToLatestTradeday(String orderID) async {
    try {
      final response = await http.patch(Uri.parse('$tradeAgentURLPrefix/order/future/$orderID'));
      if (response.statusCode == 200) {
        return 'Move Success';
      } else {
        return 'Move Failed';
      }
    } on Exception {
      return 'Network Error';
    }
  }

  void _showDialog(String message) {
    if (message.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          iconColor: Colors.teal,
          icon: const Icon(
            Icons.notification_important_outlined,
            size: 40,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: Text(S.of(context).notification),
          content: Text(
            message,
            textAlign: TextAlign.center,
          ),
          actions: [
            Center(
              child: ElevatedButton(
                child: Text(
                  S.of(context).ok,
                  style: const TextStyle(color: Colors.black),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      );
    }
  }

  void _showConfirmDialog(String orderID) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        iconColor: Colors.teal,
        icon: const Icon(
          Icons.notification_important_outlined,
          size: 40,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        title: Text(S.of(context).notification),
        content: const Text(
          'Are you sure to move order to latest trade day?',
          textAlign: TextAlign.center,
        ),
        actions: [
          Center(
            child: ElevatedButton(
              child: Text(
                S.of(context).cancel,
                style: const TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          Center(
            child: ElevatedButton(
              child: Text(
                S.of(context).ok,
                style: const TextStyle(color: Colors.black),
              ),
              onPressed: () {
                Navigator.pop(context);
                moveOrderToLatestTradeday(orderID).then(_showDialog);
                setState(() {
                  futureOrder = fetchOrders(widget.date);
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0.5,
          automaticallyImplyLeading: false,
          centerTitle: false,
          title: Text(widget.date),
          actions: [
            IconButton(
              onPressed: recalculateBalance,
              icon: const Icon(Icons.refresh),
            ),
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
            child: FutureBuilder<FutureOrderArr?>(
              future: futureOrder,
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.orders != null && snapshot.data!.orders!.isNotEmpty) {
                  final orderList = snapshot.data!.orders!.reversed.toList();
                  final count = snapshot.data!.orders!.length;
                  return ListView.separated(
                    separatorBuilder: (context, index) => const Divider(
                      height: 0,
                      color: Colors.grey,
                    ),
                    itemCount: count,
                    itemBuilder: (context, index) {
                      final order = orderList[index].baseOrder!;
                      final code = orderList[index].code;
                      return ListTile(
                        onLongPress: () {
                          _showConfirmDialog(order.orderID!);
                        },
                        leading: Icon(Icons.book_outlined, color: (order.action == 1 || order.action == 4) ? Colors.red : Colors.green),
                        title: Text(code!),
                        subtitle: Text(
                          df.formatDate(
                            DateTime.parse(order.orderTime!).add(const Duration(hours: 8)),
                            [df.yyyy, '-', df.mm, '-', df.dd, ' ', df.HH, ':', df.nn, ':', df.ss],
                          ),
                        ),
                        trailing: Text(
                          '${order.price} x ${order.quantity}',
                          style: GoogleFonts.getFont(
                            'Source Code Pro',
                            fontStyle: FontStyle.normal,
                            fontSize: 20,
                            color: (order.action == 1 || order.action == 4) ? Colors.red : Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  );
                }
                return Center(
                  child: Text(
                    S.of(context).no_data,
                    style: GoogleFonts.getFont(
                      'Source Code Pro',
                      fontStyle: FontStyle.normal,
                      fontSize: 30,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );
}

Future<FutureOrderArr> fetchOrders(String date) async {
  try {
    final response = await http.get(Uri.parse('$tradeAgentURLPrefix/order/date/$date'));
    if (response.statusCode == 200) {
      return FutureOrderArr.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      return FutureOrderArr();
    }
  } on Exception {
    return FutureOrderArr();
  }
}
