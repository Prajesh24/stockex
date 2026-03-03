import '../model/watchlist_api_model.dart';

abstract class IWatchlistRemoteDatasource {
  Future<List<WatchlistApiModel>> getWatchlist();
  Future<WatchlistApiModel> addToWatchlist(WatchlistApiModel model);
  Future<void> removeFromWatchlist(String symbol);
}

abstract class IWatchlistLocalDatasource {
  Future<List<WatchlistApiModel>> getWatchlist();
  Future<void> saveWatchlist(List<WatchlistApiModel> models);
  Future<void> addToWatchlist(WatchlistApiModel model);
  Future<void> removeFromWatchlist(String symbol);
  Future<void> clearWatchlist();
}