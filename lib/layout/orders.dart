import 'package:date_format/date_format.dart' as df;
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trade_agent/entity/entity.dart';
import 'package:trade_agent/modules/api/api.dart';

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
    futureOrder = API.fetchOrders(widget.date);
  }

  void _showDialog({int? errCode}) {
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
        title: Text(AppLocalizations.of(context)!.notification),
        content: Text(
          errCode == null ? 'Recalculate Success' : 'Recalculate Failed',
          textAlign: TextAlign.center,
        ),
        actions: [
          Center(
            child: ElevatedButton(
              child: Text(
                AppLocalizations.of(context)!.ok,
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
        title: Text(AppLocalizations.of(context)!.notification),
        content: const Text(
          'Are you sure to move order to latest trade day?',
          textAlign: TextAlign.center,
        ),
        actions: [
          Center(
            child: ElevatedButton(
              child: Text(
                AppLocalizations.of(context)!.cancel,
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
                AppLocalizations.of(context)!.ok,
                style: const TextStyle(color: Colors.black),
              ),
              onPressed: () {
                Navigator.pop(context);
                API
                    .moveOrderToLatestTradeday(orderID)
                    .then(
                      (_) => _showDialog(),
                    )
                    .catchError(
                      (e) => _showDialog(errCode: e),
                    );
                setState(() {
                  futureOrder = API.fetchOrders(widget.date);
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
              onPressed: () => API.recalculateBalance(widget.date),
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
                    AppLocalizations.of(context)!.no_data,
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
