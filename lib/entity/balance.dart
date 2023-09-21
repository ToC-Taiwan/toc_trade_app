class Balance {
  Balance({
    this.stock,
    this.future,
  });

  Balance.fromJson(Map<String, dynamic> json) {
    if (json['stock'] != null) {
      stock = <BalanceDetail>[];
      for (final v in json['stock'] as List) {
        stock!.add(BalanceDetail.fromJson(v as Map<String, dynamic>));
      }
    }

    if (json['future'] != null) {
      future = <BalanceDetail>[];
      for (final v in json['future'] as List) {
        future!.add(BalanceDetail.fromJson(v as Map<String, dynamic>));
      }
    }
  }

  List<BalanceDetail>? stock;
  List<BalanceDetail>? future;
}

class BalanceDetail {
  BalanceDetail({
    this.id,
    this.tradeCount,
    this.forward,
    this.reverse,
    this.originalBalance,
    this.discount,
    this.total,
    this.tradeDay,
  });

  BalanceDetail.fromJson(Map<String, dynamic> json) {
    id = json['id'] as num;
    tradeCount = json['trade_count'] as num;
    forward = json['forward'] as num;
    reverse = json['reverse'] as num;
    originalBalance = json['original_balance'] as num?;
    discount = json['discount'] as num?;
    total = json['total'] as num;
    tradeDay = json['trade_day'] as String;
  }

  num? id;
  num? tradeCount;
  num? forward;
  num? reverse;
  num? originalBalance;
  num? discount;
  num? total;
  String? tradeDay;
}
