class BaseObject {
  BaseObject({
    this.id,
    int? createTime,
    int? updateTime,
  })  : createTime = createTime ?? DateTime.now().microsecondsSinceEpoch,
        updateTime = updateTime ?? DateTime.now().microsecondsSinceEpoch;

  final int? id;
  final int createTime;
  final int updateTime;

  List<Object> get props => [];
}
