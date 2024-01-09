import 'package:trade_agent/entity/base.dart';

class Basic extends BaseObject {
  Basic(
    this.key,
    this.value, {
    super.id,
    super.createTime,
    super.updateTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'key': key,
      'value': value,
      'createTime': createTime,
      'updateTime': updateTime,
    };
  }

  String key;
  String value;
}
