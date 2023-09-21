class TSE {
  TSE({
    this.snapTime,
    this.open,
    this.high,
    this.low,
    this.close,
    this.tickType,
    this.priceChg,
    this.pctChg,
    this.chgType,
    this.volume,
    this.volumeSum,
    this.amount,
    this.amountSum,
    this.yesterdayVolume,
    this.volumeRatio,
  });

  TSE.fromJson(Map<String, dynamic> json) {
    snapTime = json['snap_time'] as String;
    open = json['open'] as num;
    high = json['high'] as num;
    low = json['low'] as num;
    close = json['close'] as num;
    tickType = json['tick_type'] as String;
    priceChg = json['price_chg'] as num;
    pctChg = json['pct_chg'] as num;
    chgType = json['chg_type'] as String;
    volume = json['volume'] as int;
    volumeSum = json['volume_sum'] as int;
    amount = json['amount'] as num;
    amountSum = json['amount_sum'] as num;
    yesterdayVolume = json['yesterday_volume'] as int;
    volumeRatio = json['volume_ratio'] as num;
  }

  String? snapTime;
  num? open;
  num? high;
  num? low;
  num? close;
  String? tickType;
  num? priceChg;
  num? pctChg;
  String? chgType;
  num? volume;
  num? volumeSum;
  num? amount;
  num? amountSum;
  num? yesterdayVolume;
  num? volumeRatio;
}
