import 'package:trade_agent/entity/trade.dart';

class FutureOrderArr {
  FutureOrderArr({this.orders});

  FutureOrderArr.fromJson(Map<String, dynamic> json) {
    if (json['orders'] != null) {
      orders = <Orders>[];
      for (final v in json['orders'] as List) {
        orders!.add(Orders.fromJson(v as Map<String, dynamic>));
      }
    }
  }
  List<Orders>? orders;
}

class Orders {
  Orders({
    this.baseOrder,
    this.code,
  });

  Orders.fromJson(Map<String, dynamic> json) {
    baseOrder = json['base_order'] != null ? BaseOrder.fromJson(json['base_order'] as Map<String, dynamic>) : null;
    code = json['code'] as String;
  }

  BaseOrder? baseOrder;
  String? code;
}
