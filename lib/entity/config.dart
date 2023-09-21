class Config {
  Config({
    this.simulation,
    this.history,
    this.quota,
    this.targetStock,
    this.analyzeStock,
    this.tradeStock,
    this.tradeFuture,
    this.development,
    this.database,
    this.server,
    this.sinopac,
    this.fugle,
    this.rabbitMQ,
    this.slack,
  });

  Config.fromJson(Map<String, dynamic> json) {
    simulation = json['Simulation'] as bool?;
    history = json['History'] != null ? History.fromJson(json['History'] as Map<String, dynamic>) : null;
    quota = json['Quota'] != null ? Quota.fromJson(json['Quota'] as Map<String, dynamic>) : null;
    targetStock = json['TargetStock'] != null ? TargetStock.fromJson(json['TargetStock'] as Map<String, dynamic>) : null;
    analyzeStock = json['AnalyzeStock'] != null ? AnalyzeStock.fromJson(json['AnalyzeStock'] as Map<String, dynamic>) : null;
    tradeStock = json['TradeStock'] != null ? TradeStock.fromJson(json['TradeStock'] as Map<String, dynamic>) : null;
    tradeFuture = json['TradeFuture'] != null ? TradeFuture.fromJson(json['TradeFuture'] as Map<String, dynamic>) : null;
    development = json['Development'] as bool?;
    database = json['Database'] != null ? DB.fromJson(json['Database'] as Map<String, dynamic>) : null;
    server = json['Server'] != null ? Server.fromJson(json['Server'] as Map<String, dynamic>) : null;
    sinopac = json['Sinopac'] != null ? Sinopac.fromJson(json['Sinopac'] as Map<String, dynamic>) : null;
    fugle = json['Fugle'] != null ? Sinopac.fromJson(json['Fugle'] as Map<String, dynamic>) : null;
    rabbitMQ = json['RabbitMQ'] != null ? RabbitMQ.fromJson(json['RabbitMQ'] as Map<String, dynamic>) : null;
    slack = json['Slack'] != null ? Slack.fromJson(json['Slack'] as Map<String, dynamic>) : null;
  }

  bool? simulation;
  History? history;
  Quota? quota;
  TargetStock? targetStock;
  AnalyzeStock? analyzeStock;
  TradeStock? tradeStock;
  TradeFuture? tradeFuture;
  bool? development;
  DB? database;
  Server? server;
  Sinopac? sinopac;
  Sinopac? fugle;
  RabbitMQ? rabbitMQ;
  Slack? slack;
}

class History {
  History({
    this.historyClosePeriod,
    this.historyTickPeriod,
    this.historyKbarPeriod,
  });

  History.fromJson(Map<String, dynamic> json) {
    historyClosePeriod = json['history_close_period'] as int?;
    historyTickPeriod = json['history_tick_period'] as int?;
    historyKbarPeriod = json['history_kbar_period'] as int?;
  }

  Map<String, dynamic> toMap() {
    final data = <String, dynamic>{};
    data['history_close_period'] = historyClosePeriod;
    data['history_tick_period'] = historyTickPeriod;
    data['history_kbar_period'] = historyKbarPeriod;
    return data;
  }

  int? historyClosePeriod;
  int? historyTickPeriod;
  int? historyKbarPeriod;
}

class Quota {
  Quota({
    this.stockTradeQuota,
    this.stockFeeDiscount,
    this.futureTradeFee,
  });

  Quota.fromJson(Map<String, dynamic> json) {
    stockTradeQuota = json['stock_trade_quota'] as int?;
    stockFeeDiscount = json['stock_fee_discount'] as double?;
    futureTradeFee = json['future_trade_fee'] as int?;
  }

  Map<String, dynamic> toMap() {
    final data = <String, dynamic>{};
    data['stock_trade_quota'] = stockTradeQuota;
    data['stock_fee_discount'] = stockFeeDiscount;
    data['future_trade_fee'] = futureTradeFee;
    return data;
  }

  int? stockTradeQuota;
  double? stockFeeDiscount;
  int? futureTradeFee;
}

class TargetStock {
  TargetStock({
    this.blackStock,
    this.blackCategory,
    this.realTimeRank,
    this.limitVolume,
    this.priceLimit,
  });

  TargetStock.fromJson(Map<String, dynamic> json) {
    blackStock = <String>[];
    for (final v in json['black_stock'] as List<dynamic>) {
      blackStock!.add(v as String);
    }
    blackCategory = <String>[];
    for (final v in json['black_category'] as List<dynamic>) {
      blackCategory!.add(v as String);
    }
    realTimeRank = json['real_time_rank'] as int?;
    limitVolume = json['limit_volume'] as int?;
    if (json['price_limit'] != null) {
      priceLimit = <PriceLimit>[];
      for (final v in json['price_limit'] as List<dynamic>) {
        priceLimit!.add(PriceLimit.fromJson(v as Map<String, dynamic>));
      }
    }
  }

  Map<String, dynamic> toMap() {
    final data = <String, dynamic>{};
    data['black_category'] = blackCategory;
    data['real_time_rank'] = realTimeRank;
    data['limit_volume'] = limitVolume;
    return data;
  }

  List<String>? blackStock;
  List<String>? blackCategory;
  int? realTimeRank;
  int? limitVolume;
  List<PriceLimit>? priceLimit;
}

class PriceLimit {
  PriceLimit({
    this.low,
    this.high,
  });

  PriceLimit.fromJson(Map<String, dynamic> json) {
    low = json['low'] as int?;
    high = json['high'] as int?;
  }

  Map<String, dynamic> toMap() {
    final data = <String, dynamic>{};
    data['low'] = low;
    data['high'] = high;
    return data;
  }

  int? low;
  int? high;
}

class AnalyzeStock {
  AnalyzeStock({
    this.maxHoldTime,
    this.closeChangeRatioLow,
    this.closeChangeRatioHigh,
    this.allOutInRatio,
    this.allInOutRatio,
    this.volumePrLimit,
    this.tickAnalyzePeriod,
    this.rsiMinCount,
    this.maPeriod,
  });

  AnalyzeStock.fromJson(Map<String, dynamic> json) {
    maxHoldTime = json['max_hold_time'] as int?;
    closeChangeRatioLow = json['close_change_ratio_low'] as int?;
    closeChangeRatioHigh = json['close_change_ratio_high'] as int?;
    allOutInRatio = json['all_out_in_ratio'] as int?;
    allInOutRatio = json['all_in_out_ratio'] as int?;
    volumePrLimit = json['volume_pr_limit'] as int?;
    tickAnalyzePeriod = json['tick_analyze_period'] as int?;
    rsiMinCount = json['rsi_min_count'] as int?;
    maPeriod = json['ma_period'] as int?;
  }

  Map<String, dynamic> toMap() {
    final data = <String, dynamic>{};
    data['max_hold_time'] = maxHoldTime;
    data['close_change_ratio_low'] = closeChangeRatioLow;
    data['close_change_ratio_high'] = closeChangeRatioHigh;
    data['all_out_in_ratio'] = allOutInRatio;
    data['all_in_out_ratio'] = allInOutRatio;
    data['volume_pr_limit'] = volumePrLimit;
    data['tick_analyze_period'] = tickAnalyzePeriod;
    data['rsi_min_count'] = rsiMinCount;
    data['ma_period'] = maPeriod;
    return data;
  }

  int? maxHoldTime;
  int? closeChangeRatioLow;
  int? closeChangeRatioHigh;
  int? allOutInRatio;
  int? allInOutRatio;
  int? volumePrLimit;
  int? tickAnalyzePeriod;
  int? rsiMinCount;
  int? maPeriod;
}

class TradeStock {
  TradeStock({
    this.allowTrade,
    this.subscribe,
    this.holdTimeFromOpen,
    this.totalOpenTime,
    this.tradeInEndTime,
    this.tradeInWaitTime,
    this.tradeOutWaitTime,
    this.cancelWaitTime,
  });

  TradeStock.fromJson(Map<String, dynamic> json) {
    allowTrade = json['allow_trade'] as bool?;
    subscribe = json['subscribe'] as bool?;
    holdTimeFromOpen = json['hold_time_from_open'] as int?;
    totalOpenTime = json['total_open_time'] as int?;
    tradeInEndTime = json['trade_in_end_time'] as int?;
    tradeInWaitTime = json['trade_in_wait_time'] as int?;
    tradeOutWaitTime = json['trade_out_wait_time'] as int?;
    cancelWaitTime = json['cancel_wait_time'] as int?;
  }

  Map<String, dynamic> toMap() {
    final data = <String, dynamic>{};
    data['allow_trade'] = allowTrade;
    data['subscribe'] = subscribe;
    data['hold_time_from_open'] = holdTimeFromOpen;
    data['total_open_time'] = totalOpenTime;
    data['trade_in_end_time'] = tradeInEndTime;
    data['trade_in_wait_time'] = tradeInWaitTime;
    data['trade_out_wait_time'] = tradeOutWaitTime;
    data['cancel_wait_time'] = cancelWaitTime;
    return data;
  }

  bool? allowTrade;
  bool? subscribe;
  int? holdTimeFromOpen;
  int? totalOpenTime;
  int? tradeInEndTime;
  int? tradeInWaitTime;
  int? tradeOutWaitTime;
  int? cancelWaitTime;
}

class TradeFuture {
  TradeFuture({
    this.allowTrade,
    this.subscribe,
    this.buySellWaitTime,
    this.quantity,
    this.targetBalanceHigh,
    this.targetBalanceLow,
    this.tradeTimeRange,
    this.maxHoldTime,
    this.tickInterval,
    this.rateLimit,
    this.rateChangeRatio,
    this.outInRatio,
    this.inOutRatio,
    this.tradeOutWaitTimes,
  });

  TradeFuture.fromJson(Map<String, dynamic> json) {
    allowTrade = json['allow_trade'] as bool?;
    subscribe = json['subscribe'] as bool?;
    buySellWaitTime = json['buy_sell_wait_time'] as int?;
    quantity = json['quantity'] as int?;
    targetBalanceHigh = json['target_balance_high'] as int?;
    targetBalanceLow = json['target_balance_low'] as int?;
    tradeTimeRange = json['trade_time_range'] != null ? TradeTimeRange.fromJson(json['trade_time_range'] as Map<String, dynamic>) : null;
    maxHoldTime = json['max_hold_time'] as int?;
    tickInterval = json['tick_interval'] as int?;
    rateLimit = json['rate_limit'] as int?;
    rateChangeRatio = json['rate_change_ratio'] as int?;
    outInRatio = json['out_in_ratio'] as int?;
    inOutRatio = json['in_out_ratio'] as int?;
    tradeOutWaitTimes = json['trade_out_wait_times'] as int?;
  }

  Map<String, dynamic> toMap() {
    final data = <String, dynamic>{};
    data['allow_trade'] = allowTrade;
    data['subscribe'] = subscribe;
    data['buy_sell_wait_time'] = buySellWaitTime;
    data['quantity'] = quantity;
    data['target_balance_high'] = targetBalanceHigh;
    data['target_balance_low'] = targetBalanceLow;
    if (tradeTimeRange != null) {
      data['trade_time_range'] = tradeTimeRange!.toMap();
    }
    data['max_hold_time'] = maxHoldTime;
    data['tick_interval'] = tickInterval;
    data['rate_limit'] = rateLimit;
    data['rate_change_ratio'] = rateChangeRatio;
    data['out_in_ratio'] = outInRatio;
    data['in_out_ratio'] = inOutRatio;
    data['trade_out_wait_times'] = tradeOutWaitTimes;
    return data;
  }

  bool? allowTrade;
  bool? subscribe;
  int? buySellWaitTime;
  int? quantity;
  int? targetBalanceHigh;
  int? targetBalanceLow;
  TradeTimeRange? tradeTimeRange;
  int? maxHoldTime;
  int? tickInterval;
  int? rateLimit;
  int? rateChangeRatio;
  int? outInRatio;
  int? inOutRatio;
  int? tradeOutWaitTimes;
}

class TradeTimeRange {
  TradeTimeRange({
    this.firstPartDuration,
    this.secondPartDuration,
  });

  TradeTimeRange.fromJson(Map<String, dynamic> json) {
    firstPartDuration = json['first_part_duration'] as int?;
    secondPartDuration = json['second_part_duration'] as int?;
  }

  Map<String, dynamic> toMap() {
    final data = <String, dynamic>{};
    data['first_part_duration'] = firstPartDuration;
    data['second_part_duration'] = secondPartDuration;
    return data;
  }

  int? firstPartDuration;
  int? secondPartDuration;
}

class DB {
  DB({
    this.dBName,
    this.uRL,
    this.poolMax,
  });

  DB.fromJson(Map<String, dynamic> json) {
    dBName = json['DBName'] as String?;
    uRL = json['URL'] as String?;
    poolMax = json['PoolMax'] as int?;
  }

  Map<String, dynamic> toMap() {
    final data = <String, dynamic>{};
    data['DBName'] = dBName;
    data['PoolMax'] = poolMax;
    return data;
  }

  String? dBName;
  String? uRL;
  int? poolMax;
}

class Server {
  Server({
    this.hTTP,
    this.routerDebugMode,
    this.disableSwaggerHTTPHandler,
  });

  Server.fromJson(Map<String, dynamic> json) {
    hTTP = json['HTTP'] as String?;
    routerDebugMode = json['RouterDebugMode'] as String?;
    disableSwaggerHTTPHandler = json['DisableSwaggerHTTPHandler'] as String?;
  }

  Map<String, dynamic> toMap() {
    final data = <String, dynamic>{};
    data['HTTP'] = hTTP;
    data['RouterDebugMode'] = routerDebugMode;
    data['DisableSwaggerHTTPHandler'] = disableSwaggerHTTPHandler;
    return data;
  }

  String? hTTP;
  String? routerDebugMode;
  String? disableSwaggerHTTPHandler;
}

class Sinopac {
  Sinopac({
    this.poolMax,
    this.uRL,
  });

  Sinopac.fromJson(Map<String, dynamic> json) {
    poolMax = json['PoolMax'] as int?;
    uRL = json['URL'] as String?;
  }

  Map<String, dynamic> toMap() {
    final data = <String, dynamic>{};
    data['PoolMax'] = poolMax;
    return data;
  }

  int? poolMax;
  String? uRL;
}

class RabbitMQ {
  RabbitMQ({
    this.uRL,
    this.exchange,
    this.waitTime,
    this.attempts,
  });

  RabbitMQ.fromJson(Map<String, dynamic> json) {
    uRL = json['URL'] as String?;
    exchange = json['Exchange'] as String?;
    waitTime = json['WaitTime'] as int?;
    attempts = json['Attempts'] as int?;
  }

  Map<String, dynamic> toMap() {
    final data = <String, dynamic>{};
    data['Exchange'] = exchange;
    data['WaitTime'] = waitTime;
    data['Attempts'] = attempts;
    return data;
  }

  String? uRL;
  String? exchange;
  int? waitTime;
  int? attempts;
}

class Slack {
  Slack({
    this.token,
    this.channelID,
  });

  Slack.fromJson(Map<String, dynamic> json) {
    token = json['Token'] as String?;
    channelID = json['ChannelID'] as String?;
  }

  Map<String, dynamic> toMap() {
    final data = <String, dynamic>{};
    data['Token'] = token;
    data['ChannelID'] = channelID;
    return data;
  }

  String? token;
  String? channelID;
}
