import 'package:trade_agent_v2/pb/app.pb.dart' as pb;

class RealTimeFutureTick {
  RealTimeFutureTick(
    this.code,
    this.tickTime,
    this.open,
    this.underlyingPrice,
    this.bidSideTotalVol,
    this.askSideTotalVol,
    this.avgPrice,
    this.close,
    this.high,
    this.low,
    this.amount,
    this.totalAmount,
    this.volume,
    this.totalVolume,
    this.tickType,
    this.chgType,
    this.priceChg,
    this.pctChg,
    this.simtrade,
  );

  RealTimeFutureTick.fromProto(pb.WSFutureTick tick) {
    code = tick.code;
    tickTime = DateTime.parse(tick.tickTime);
    open = tick.open;
    underlyingPrice = tick.underlyingPrice;
    bidSideTotalVol = tick.bidSideTotalVol.toInt();
    askSideTotalVol = tick.askSideTotalVol.toInt();
    avgPrice = tick.avgPrice;
    close = tick.close;
    high = tick.high;
    low = tick.low;
    amount = tick.amount;
    totalAmount = tick.totalAmount;
    volume = tick.volume.toInt();
    totalVolume = tick.totalVolume.toInt();
    tickType = tick.tickType.toInt();
    chgType = tick.chgType.toInt();
    priceChg = tick.priceChg;
    pctChg = tick.pctChg;
    if (tick.priceChg > 0) {
      changeType = '↗️';
    } else if (tick.priceChg < 0) {
      changeType = '↘️';
    } else {
      changeType = '';
    }
  }

  String? code;
  DateTime? tickTime;
  num? open;
  num? underlyingPrice;
  num? bidSideTotalVol;
  num? askSideTotalVol;
  num? avgPrice;
  num? close;
  num? high;
  num? low;
  num? amount;
  num? totalAmount;
  num? volume;
  num? totalVolume;
  num? tickType;
  num? chgType;
  num? priceChg;
  num? pctChg;
  num? simtrade;
  bool? combo = false;
  String? changeType;
}

class RealTimeFutureTickArr {
  void add(RealTimeFutureTick tick) => arr.add(tick);
  void process() {
    if (arr.length < 2) {
      return;
    }

    if (arr[arr.length - 1].tickTime!.difference(arr[arr.length - 2].tickTime!) > const Duration(seconds: 3)) {
      arr = [];
      return;
    }

    final totalTime = arr.last.tickTime!.difference(arr.first.tickTime!);

    if (totalTime > const Duration(seconds: 20)) {
      arr.removeAt(0);
    }

    if (totalTime < const Duration(seconds: 10)) {
      outInRatio = 0.0;
      rate = 0.0;
      return;
    }

    var outVolume = 0.0;
    var inVolume = 0.0;

    for (final element in arr) {
      switch (element.tickType) {
        case 1:
          outVolume += element.volume!.toDouble();
          break;
        case 2:
          inVolume += element.volume!.toDouble();
          break;
        default:
          outVolume += element.volume!.toDouble();
          break;
      }
    }

    outInRatio = outVolume / (outVolume + inVolume);
    rate = 1000 * 1000 * (outVolume + inVolume) / totalTime.inMicroseconds.toDouble();
  }

  List<RealTimeFutureTick> arr = [];

  num outInRatio = 0.0;
  num rate = 0.0;
}

class AssistStatus {
  AssistStatus.fromProto(pb.WSAssitStatus status) {
    running = status.running;
  }

  bool? running;
}

class ErrMessage {
  ErrMessage(this.errCode, this.response);

  ErrMessage.fromProto(pb.WSErrMessage err) {
    errCode = err.errCode.toInt();
    response = err.response;
  }

  num? errCode;
  String? response;
}

class TradeIndex {
  TradeIndex.fromProto(pb.WSTradeIndex index) {
    tse = IndexStatus.fromProto(index.tse);
    otc = IndexStatus.fromProto(index.otc);
    nasdaq = IndexStatus.fromProto(index.nasdaq);
    nf = IndexStatus.fromProto(index.nf);
  }

  IndexStatus? tse;
  IndexStatus? otc;
  IndexStatus? nasdaq;
  IndexStatus? nf;
}

class IndexStatus {
  IndexStatus.fromProto(pb.WSIndexStatus ws) {
    breakCount = ws.breakCount.toInt();
    priceChg = ws.priceChg;
  }

  num? breakCount;
  num? priceChg;
}

class FuturePosition {
  FuturePosition();

  FuturePosition.fromProto(pb.WSFuturePosition ws, String code) {
    for (final element in ws.position) {
      if (element.code == code) {
        code = element.code;
        direction = element.direction;
        quantity = element.quantity.toInt();
        price = element.price;
        lastPrice = element.lastPrice;
        pnl = element.pnl;
        break;
      }
    }
  }

  String? code;
  String? direction;
  num? quantity;
  num? price;
  num? lastPrice;
  num? pnl;
}

class FutureOrder {
  FutureOrder(
    this.code,
    this.baseOrder,
  );

  FutureOrder.fromProto(pb.WSFutureOrder ws) {
    code = ws.code;
    baseOrder = BaseOrder.fromProto(ws.baseOrder);
  }

  String? code;
  BaseOrder? baseOrder;
}

class BaseOrder {
  BaseOrder(
    this.orderID,
    this.status,
    this.orderTime,
    this.action,
    this.price,
    this.quantity,
  );

  BaseOrder.fromJson(Map<String, dynamic> json) {
    orderID = json['order_id'] as String;
    status = json['status'] as int;
    orderTime = json['order_time'] as String;
    action = json['action'] as int;
    price = json['price'] as int;
    quantity = json['quantity'] as int;
  }

  BaseOrder.fromProto(pb.WSOrder ws) {
    orderID = ws.orderId;
    status = ws.status.toInt();
    orderTime = ws.orderTime;
    action = ws.action.toInt();
    price = ws.price;
    quantity = ws.quantity.toInt();
  }

  String? orderID;
  num? status;
  String? orderTime;
  num? action;
  num? price;
  num? quantity;
}
