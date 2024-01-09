import 'package:trade_agent/pb/app.pb.dart' as pb;

class KbarData {
  KbarData({
    this.kbarTime,
    this.close,
    this.open,
    this.high,
    this.low,
    this.volume,
  });

  KbarData.fromJson(Map<String, dynamic> json) {
    kbarTime = json['kbar_time'] as String;
    close = json['close'] as num;
    open = json['open'] as num;
    high = json['high'] as num;
    low = json['low'] as num;
    volume = json['volume'] as int;
  }

  String? kbarTime;
  num? close;
  num? open;
  num? high;
  num? low;
  int? volume;
}

class KbarArr {
  KbarArr.fromProto(pb.WSHistoryKbarMessage ws) {
    arr = [];
    maxVolume = 0;

    for (final element in ws.arr) {
      arr!.add(
        KbarData(
          kbarTime: element.kbarTime,
          high: element.high,
          low: element.low,
          open: element.open,
          close: element.close,
          volume: element.volume.toInt(),
        ),
      );

      if (maxVolume == 0) {
        maxVolume = element.volume.toInt();
      } else {
        if (element.volume > maxVolume!) {
          maxVolume = element.volume.toInt();
        }
      }
    }
  }

  List<KbarData>? arr;
  num? maxVolume;
}
