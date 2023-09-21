class Target {
  Target({
    this.stock,
    this.tradeDay,
    this.rank,
    this.volume,
  });

  Target.fromJson(Map<String, dynamic> json) {
    stock = json['stock'] != null ? Stock.fromJson(json['stock'] as Map<String, dynamic>) : null;
    tradeDay = json['trade_day'] as String;
    rank = json['rank'] as num;
    volume = json['volume'] as num;
  }

  Stock? stock;
  String? tradeDay;
  num? rank;
  num? volume;
}

class Stock {
  Stock({
    this.number,
    this.name,
    this.exchange,
    this.category,
    this.dayTrade,
    this.lastClose,
  });

  Stock.fromJson(Map<dynamic, dynamic> json) {
    number = json['number'] as String;
    name = json['name'] as String;
    exchange = json['exchange'] as String;
    category = json['category'] as String;
    dayTrade = json['day_trade'] as bool;
    lastClose = json['last_close'] as num;
  }

  String? number;
  String? name;
  String? exchange;
  String? category;
  bool? dayTrade;
  num? lastClose;
}
