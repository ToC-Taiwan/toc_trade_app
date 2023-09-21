import 'package:floor/floor.dart';

class BaseObject {
  BaseObject({
    this.id,
    int? createTime,
    int? updateTime,
  })  : createTime = createTime ?? DateTime.now().microsecondsSinceEpoch,
        updateTime = updateTime ?? DateTime.now().microsecondsSinceEpoch;

  @PrimaryKey(autoGenerate: true)
  final int? id;

  @ColumnInfo(name: 'create_time')
  final int createTime;

  @ColumnInfo(name: 'update_time')
  final int updateTime;

  List<Object> get props => [];
}
