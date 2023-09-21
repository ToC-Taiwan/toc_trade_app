import 'package:floor/floor.dart';
import 'package:trade_agent_v2/entity/entity.dart';

@dao
abstract class PickStockDao {
  @Query('SELECT * FROM pick_stock')
  Future<List<PickStock>> getAllPickStock();

  @Query('SELECT * FROM pick_stock WHERE stock_num = :stockNum')
  Future<PickStock?> getPickStockByStockNum(String stockNum);

  @Query('DELETE FROM pick_stock WHERE id !=0')
  Future<void> deleteAllPickStock();

  @Update(onConflict: OnConflictStrategy.replace)
  Future<void> updatePickStock(PickStock record);

  @update
  Future<int> updatePickStocks(List<PickStock> record);

  @delete
  Future<void> deletePickStock(PickStock record);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertPickStock(PickStock record);
}
