import 'package:floor/floor.dart';
import 'package:trade_agent_v2/entity/base.dart';

@Entity(tableName: 'basic')
class Basic extends BaseObject {
  Basic(
    this.key,
    this.value, {
    int? id,
    int? createTime,
    int? updateTime,
  }) : super(id: id, updateTime: updateTime, createTime: createTime);

  @ColumnInfo(name: 'key')
  String key;

  @ColumnInfo(name: 'value')
  String value;
}
