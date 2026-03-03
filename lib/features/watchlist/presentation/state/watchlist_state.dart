import 'package:equatable/equatable.dart';
// import '../../../../domain/watchlist/entities/watchlist_entity.dart';
import '../../domain/entities/watchlist_entity.dart';
// import '../../../../data/nepse/models/stock_model.dart';
import '../../../../data/nepse/model/stock_model.dart';

enum WatchlistStatus { initial, loading, loaded, error }

class WatchlistState extends Equatable {
  final WatchlistStatus status;
  final List<WatchlistEntity> watchlist;
  final List<StockModel> searchResults;
  final String searchQuery;
  final String? errorMessage;

  const WatchlistState({
    this.status = WatchlistStatus.initial,
    this.watchlist = const [],
    this.searchResults = const [],
    this.searchQuery = '',
    this.errorMessage,
  });

  WatchlistState copyWith({
    WatchlistStatus? status,
    List<WatchlistEntity>? watchlist,
    List<StockModel>? searchResults,
    String? searchQuery,
    String? errorMessage,
  }) {
    return WatchlistState(
      status: status ?? this.status,
      watchlist: watchlist ?? this.watchlist,
      searchResults: searchResults ?? this.searchResults,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    watchlist,
    searchResults,
    searchQuery,
    errorMessage,
  ];
}
