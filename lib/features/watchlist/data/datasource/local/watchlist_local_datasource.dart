import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
// import '../../../../core/services/hive/hive_service.dart';
import '../../../../../core/services/hive/hive_service.dart';
import '../../model/watchlist_api_model.dart';
import '../watchlist_datasource.dart';

final watchlistLocalDatasourceProvider = Provider<IWatchlistLocalDatasource>((ref) {
  return WatchlistLocalDatasource(
    hiveService: ref.read(hiveServiceProvider),
  );
});

class WatchlistLocalDatasource implements IWatchlistLocalDatasource {
  final HiveService _hiveService;

  WatchlistLocalDatasource({required HiveService hiveService}) : _hiveService = hiveService;

  @override
  Future<List<WatchlistApiModel>> getWatchlist() async {
    try {
      final box = await Hive.openBox<WatchlistApiModel>('watchlistBox');
      return box.values.toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> saveWatchlist(List<WatchlistApiModel> models) async {
    final box = await Hive.openBox<WatchlistApiModel>('watchlistBox');
    await box.clear();
    await box.addAll(models);
  }

  @override
  Future<void> addToWatchlist(WatchlistApiModel model) async {
    final box = await Hive.openBox<WatchlistApiModel>('watchlistBox');
    await box.add(model);
  }

  @override
  Future<void> removeFromWatchlist(String symbol) async {
    final box = await Hive.openBox<WatchlistApiModel>('watchlistBox');
    final key = box.keys.firstWhere(
      (k) => box.get(k)?.symbol == symbol,
      orElse: () => null,
    );
    if (key != null) {
      await box.delete(key);
    }
  }

  @override
  Future<void> clearWatchlist() async {
    final box = await Hive.openBox<WatchlistApiModel>('watchlistBox');
    await box.clear();
  }
}