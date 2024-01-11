class Config {
  bool? simulation;
  bool? manualTrade;
  TradeStock? tradeStock;
  History? history;
  Quota? quota;
  TargetStock? targetStock;
  AnalyzeStock? analyzeStock;
  TradeFuture? tradeFuture;

  Config({this.simulation, this.manualTrade, this.tradeStock, this.history, this.quota, this.targetStock, this.analyzeStock, this.tradeFuture});

  Config.fromJson(Map<String, dynamic> json) {
    simulation = json['Simulation'];
    manualTrade = json['ManualTrade'];
    tradeStock = json['TradeStock'] != null ? TradeStock.fromJson(json['TradeStock']) : null;
    history = json['History'] != null ? History.fromJson(json['History']) : null;
    quota = json['Quota'] != null ? Quota.fromJson(json['Quota']) : null;
    targetStock = json['TargetStock'] != null ? TargetStock.fromJson(json['TargetStock']) : null;
    analyzeStock = json['AnalyzeStock'] != null ? AnalyzeStock.fromJson(json['AnalyzeStock']) : null;
    tradeFuture = json['TradeFuture'] != null ? TradeFuture.fromJson(json['TradeFuture']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Simulation'] = simulation;
    data['ManualTrade'] = manualTrade;
    if (tradeStock != null) {
      data['TradeStock'] = tradeStock!.toJson();
    }
    if (history != null) {
      data['History'] = history!.toJson();
    }
    if (quota != null) {
      data['Quota'] = quota!.toJson();
    }
    if (targetStock != null) {
      data['TargetStock'] = targetStock!.toJson();
    }
    if (analyzeStock != null) {
      data['AnalyzeStock'] = analyzeStock!.toJson();
    }
    if (tradeFuture != null) {
      data['TradeFuture'] = tradeFuture!.toJson();
    }
    return data;
  }
}

class TradeStock {
  bool? allowTrade;
  bool? subscribe;
  bool? odd;
  int? holdTimeFromOpen;
  int? totalOpenTime;
  int? tradeInEndTime;
  int? tradeInWaitTime;
  int? tradeOutWaitTime;
  int? cancelWaitTime;

  TradeStock(
      {this.allowTrade,
      this.subscribe,
      this.odd,
      this.holdTimeFromOpen,
      this.totalOpenTime,
      this.tradeInEndTime,
      this.tradeInWaitTime,
      this.tradeOutWaitTime,
      this.cancelWaitTime});

  TradeStock.fromJson(Map<String, dynamic> json) {
    allowTrade = json['AllowTrade'];
    subscribe = json['Subscribe'];
    odd = json['Odd'];
    holdTimeFromOpen = json['HoldTimeFromOpen'];
    totalOpenTime = json['TotalOpenTime'];
    tradeInEndTime = json['TradeInEndTime'];
    tradeInWaitTime = json['TradeInWaitTime'];
    tradeOutWaitTime = json['TradeOutWaitTime'];
    cancelWaitTime = json['CancelWaitTime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['AllowTrade'] = allowTrade;
    data['Subscribe'] = subscribe;
    data['Odd'] = odd;
    data['HoldTimeFromOpen'] = holdTimeFromOpen;
    data['TotalOpenTime'] = totalOpenTime;
    data['TradeInEndTime'] = tradeInEndTime;
    data['TradeInWaitTime'] = tradeInWaitTime;
    data['TradeOutWaitTime'] = tradeOutWaitTime;
    data['CancelWaitTime'] = cancelWaitTime;
    return data;
  }
}

class History {
  int? historyClosePeriod;
  int? historyTickPeriod;
  int? historyKbarPeriod;

  History({this.historyClosePeriod, this.historyTickPeriod, this.historyKbarPeriod});

  History.fromJson(Map<String, dynamic> json) {
    historyClosePeriod = json['HistoryClosePeriod'];
    historyTickPeriod = json['HistoryTickPeriod'];
    historyKbarPeriod = json['HistoryKbarPeriod'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['HistoryClosePeriod'] = historyClosePeriod;
    data['HistoryTickPeriod'] = historyTickPeriod;
    data['HistoryKbarPeriod'] = historyKbarPeriod;
    return data;
  }
}

class Quota {
  int? stockTradeQuota;
  double? stockFeeDiscount;
  int? futureTradeFee;

  Quota({this.stockTradeQuota, this.stockFeeDiscount, this.futureTradeFee});

  Quota.fromJson(Map<String, dynamic> json) {
    stockTradeQuota = json['StockTradeQuota'];
    stockFeeDiscount = json['StockFeeDiscount'];
    futureTradeFee = json['FutureTradeFee'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['StockTradeQuota'] = stockTradeQuota;
    data['StockFeeDiscount'] = stockFeeDiscount;
    data['FutureTradeFee'] = futureTradeFee;
    return data;
  }
}

class TargetStock {
  List<String>? blackStock;
  List<String>? blackCategory;
  int? realTimeRank;
  int? limitVolume;
  List<PriceLimit>? priceLimit;

  TargetStock({this.blackStock, this.blackCategory, this.realTimeRank, this.limitVolume, this.priceLimit});

  TargetStock.fromJson(Map<String, dynamic> json) {
    blackStock = json['BlackStock'].cast<String>();
    blackCategory = json['BlackCategory'].cast<String>();
    realTimeRank = json['RealTimeRank'];
    limitVolume = json['LimitVolume'];
    if (json['PriceLimit'] != null) {
      priceLimit = <PriceLimit>[];
      json['PriceLimit'].forEach((v) {
        priceLimit!.add(PriceLimit.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['BlackStock'] = blackStock;
    data['BlackCategory'] = blackCategory;
    data['RealTimeRank'] = realTimeRank;
    data['LimitVolume'] = limitVolume;
    if (priceLimit != null) {
      data['PriceLimit'] = priceLimit!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class PriceLimit {
  int? low;
  int? high;

  PriceLimit({this.low, this.high});

  PriceLimit.fromJson(Map<String, dynamic> json) {
    low = json['Low'];
    high = json['High'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Low'] = low;
    data['High'] = high;
    return data;
  }
}

class AnalyzeStock {
  int? maxHoldTime;
  int? closeChangeRatioLow;
  int? closeChangeRatioHigh;
  int? allOutInRatio;
  int? allInOutRatio;
  int? volumePRLimit;
  int? tickAnalyzePeriod;
  int? rSIMinCount;
  int? mAPeriod;

  AnalyzeStock(
      {this.maxHoldTime,
      this.closeChangeRatioLow,
      this.closeChangeRatioHigh,
      this.allOutInRatio,
      this.allInOutRatio,
      this.volumePRLimit,
      this.tickAnalyzePeriod,
      this.rSIMinCount,
      this.mAPeriod});

  AnalyzeStock.fromJson(Map<String, dynamic> json) {
    maxHoldTime = json['MaxHoldTime'];
    closeChangeRatioLow = json['CloseChangeRatioLow'];
    closeChangeRatioHigh = json['CloseChangeRatioHigh'];
    allOutInRatio = json['AllOutInRatio'];
    allInOutRatio = json['AllInOutRatio'];
    volumePRLimit = json['VolumePRLimit'];
    tickAnalyzePeriod = json['TickAnalyzePeriod'];
    rSIMinCount = json['RSIMinCount'];
    mAPeriod = json['MAPeriod'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['MaxHoldTime'] = maxHoldTime;
    data['CloseChangeRatioLow'] = closeChangeRatioLow;
    data['CloseChangeRatioHigh'] = closeChangeRatioHigh;
    data['AllOutInRatio'] = allOutInRatio;
    data['AllInOutRatio'] = allInOutRatio;
    data['VolumePRLimit'] = volumePRLimit;
    data['TickAnalyzePeriod'] = tickAnalyzePeriod;
    data['RSIMinCount'] = rSIMinCount;
    data['MAPeriod'] = mAPeriod;
    return data;
  }
}

class TradeFuture {
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

  TradeFuture(
      {this.allowTrade,
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
      this.tradeOutWaitTimes});

  TradeFuture.fromJson(Map<String, dynamic> json) {
    allowTrade = json['AllowTrade'];
    subscribe = json['Subscribe'];
    buySellWaitTime = json['BuySellWaitTime'];
    quantity = json['Quantity'];
    targetBalanceHigh = json['TargetBalanceHigh'];
    targetBalanceLow = json['TargetBalanceLow'];
    tradeTimeRange = json['TradeTimeRange'] != null ? TradeTimeRange.fromJson(json['TradeTimeRange']) : null;
    maxHoldTime = json['MaxHoldTime'];
    tickInterval = json['TickInterval'];
    rateLimit = json['RateLimit'];
    rateChangeRatio = json['RateChangeRatio'];
    outInRatio = json['OutInRatio'];
    inOutRatio = json['InOutRatio'];
    tradeOutWaitTimes = json['TradeOutWaitTimes'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['AllowTrade'] = allowTrade;
    data['Subscribe'] = subscribe;
    data['BuySellWaitTime'] = buySellWaitTime;
    data['Quantity'] = quantity;
    data['TargetBalanceHigh'] = targetBalanceHigh;
    data['TargetBalanceLow'] = targetBalanceLow;
    if (tradeTimeRange != null) {
      data['TradeTimeRange'] = tradeTimeRange!.toJson();
    }
    data['MaxHoldTime'] = maxHoldTime;
    data['TickInterval'] = tickInterval;
    data['RateLimit'] = rateLimit;
    data['RateChangeRatio'] = rateChangeRatio;
    data['OutInRatio'] = outInRatio;
    data['InOutRatio'] = inOutRatio;
    data['TradeOutWaitTimes'] = tradeOutWaitTimes;
    return data;
  }
}

class TradeTimeRange {
  int? firstPartDuration;
  int? secondPartDuration;

  TradeTimeRange({this.firstPartDuration, this.secondPartDuration});

  TradeTimeRange.fromJson(Map<String, dynamic> json) {
    firstPartDuration = json['FirstPartDuration'];
    secondPartDuration = json['SecondPartDuration'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['FirstPartDuration'] = firstPartDuration;
    data['SecondPartDuration'] = secondPartDuration;
    return data;
  }
}
