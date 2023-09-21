class Event {
  Event(
    this.stockNum,
    this.stockName,
  );

  final String stockNum;
  final String stockName;
}

class Strategy {
  Strategy({this.date, this.stocks});

  Strategy.fromJson(Map<String, dynamic> json) {
    date = json['date'] as String;
    if (json['stocks'] != null) {
      stocks = <Stocks>[];
      for (final v in json['stocks'] as List) {
        stocks!.add(Stocks.fromJson(v as Map<String, dynamic>));
      }
    }
  }

  String? date;
  List<Stocks>? stocks;
}

class Stocks {
  Stocks({
    this.number,
    this.name,
    this.exchange,
    this.category,
    this.dayTrade,
    this.lastClose,
  });

  Stocks.fromJson(Map<String, dynamic> json) {
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
