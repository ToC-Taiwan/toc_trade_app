import 'package:trade_agent_v2/entity/base.dart';

class Basic extends BaseObject {
  Basic(
    this.key,
    this.value, {
    int? id,
    int? createTime,
    int? updateTime,
  }) : super(id: id, updateTime: updateTime, createTime: createTime);

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
