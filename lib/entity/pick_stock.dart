import 'package:trade_agent_v2/entity/base.dart';

class PickStock extends BaseObject {
  PickStock(
    this.stockNum,
    this.stockName,
    this.isTarget,
    this.priceChange,
    this.priceChangeRate,
    this.price, {
    int? id,
    int? createTime,
    int? updateTime,
  }) : super(id: id, updateTime: updateTime, createTime: createTime);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'stock_num': stockNum,
      'stock_name': stockName,
      'is_target': isTarget,
      'price_change': priceChange,
      'price_change_rate': priceChangeRate,
      'price': price,
      'createTime': createTime,
      'updateTime': updateTime,
    };
  }

  final String stockNum;
  final String stockName;
  final double price;
  final double priceChangeRate;
  final double priceChange;
  final int isTarget;
}
