import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:stockex/core/api/api_endpoints.dart';
import 'package:stockex/core/api/app_client.dart';
import 'package:stockex/features/watchlist/data/model/watchlist_api_model.dart';


final watchlistRemoteDatasourceProvider = Provider<IWatchlistRemoteDatasource>((ref) {
  return WatchlistRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
  );
});

abstract class IWatchlistRemoteDatasource {
  Future<List<WatchlistApiModel>> getWatchlist();
  Future<WatchlistApiModel> addToWatchlist(WatchlistApiModel model);
  Future<void> removeFromWatchlist(String symbol);
}

class WatchlistRemoteDatasource implements IWatchlistRemoteDatasource {
  final ApiClient _apiClient;

  WatchlistRemoteDatasource({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<List<WatchlistApiModel>> getWatchlist() async {
    final response = await _apiClient.get(ApiEndpoints.watchlist);
    
    if (response.statusCode == 200) {
      final List<dynamic> data = response.data;
      return data.map((json) => WatchlistApiModel.fromJson(json)).toList();
    }
    throw Exception('Failed to load watchlist');
  }

  @override
  Future<WatchlistApiModel> addToWatchlist(WatchlistApiModel model) async {
    final response = await _apiClient.post(
      ApiEndpoints.watchlist,
      data: model.toJson(),
    );
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      return WatchlistApiModel.fromJson(response.data);
    }
    throw Exception('Failed to add to watchlist');
  }

  @override
  Future<void> removeFromWatchlist(String symbol) async {
    final response = await _apiClient.delete(
      ApiEndpoints.removeFromWatchlist(symbol),
    );
    
    if (response.statusCode != 200) {
      throw Exception('Failed to remove from watchlist');
    }
  }
}