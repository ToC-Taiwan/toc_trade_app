import 'package:floor/floor.dart';
import 'package:trade_agent_v2/entity/entity.dart';

@dao
abstract class BasickDao {
  @Query('SELECT * FROM basic')
  Future<List<Basic>> getAllBasic();

  @Query('SELECT * FROM basic WHERE key = :key')
  Future<Basic?> getBasicByKey(String key);

  @Query('DELETE FROM basic WHERE id !=0')
  Future<void> deleteAllBasic();

  @Update(onConflict: OnConflictStrategy.replace)
  Future<void> updateBasic(Basic record);

  @update
  Future<int> updateBasics(List<Basic> record);

  @delete
  Future<void> deleteBasic(Basic record);

  @Insert(onConflict: OnConflictStrategy.abort)
  Future<void> insertBasic(Basic record);
}
