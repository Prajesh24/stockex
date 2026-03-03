import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/storage/user_session_service.dart';

import '../../../../data/nepse/dummy/dummy_data.dart';

import '../../../../data/nepse/model/stock_model.dart';
import '../../domain/entities/watchlist_entity.dart';

import '../../domain/usecase/watchlist_usecase.dart';
import '../state/watchlist_state.dart';



final watchlistViewModelProvider = StateNotifierProvider<WatchlistViewModel, WatchlistState>((ref) {
  return WatchlistViewModel(
    getWatchlistUsecase: ref.read(getWatchlistUsecaseProvider),
    addToWatchlistUsecase: ref.read(addToWatchlistUsecaseProvider),
    removeFromWatchlistUsecase: ref.read(removeFromWatchlistUsecaseProvider),
    userSessionService: ref.read(userSessionServiceProvider),
  );
});

class WatchlistViewModel extends StateNotifier<WatchlistState> {
  final GetWatchlistUsecase _getWatchlistUsecase;
  final AddToWatchlistUsecase _addToWatchlistUsecase;
  final RemoveFromWatchlistUsecase _removeFromWatchlistUsecase;
  final UserSessionService _userSessionService;

  WatchlistViewModel({
    required GetWatchlistUsecase getWatchlistUsecase,
    required AddToWatchlistUsecase addToWatchlistUsecase,
    required RemoveFromWatchlistUsecase removeFromWatchlistUsecase,
    required UserSessionService userSessionService,
  })  : _getWatchlistUsecase = getWatchlistUsecase,
        _addToWatchlistUsecase = addToWatchlistUsecase,
        _removeFromWatchlistUsecase = removeFromWatchlistUsecase,
        _userSessionService = userSessionService,
        super(const WatchlistState());

  // Load watchlist
  Future<void> loadWatchlist() async {
    state = state.copyWith(status: WatchlistStatus.loading);
    
    final result = await _getWatchlistUsecase.call();
    
    result.fold(
      (failure) {
        state = state.copyWith(
          status: WatchlistStatus.error,
          errorMessage: failure.message,
        );
      },
      (watchlist) {
        state = state.copyWith(
          status: WatchlistStatus.loaded,
          watchlist: watchlist,
        );
      },
    );
  }

  // Search stocks
  void searchStocks(String query) {
    if (query.trim().isEmpty) {
      state = state.copyWith(searchResults: [], searchQuery: '');
      return;
    }

    final q = query.toLowerCase();
    final allStocks = DummyNepseData.stocks;
    
    final filtered = allStocks.where((s) {
      return s.symbol.toLowerCase().contains(q) || 
             s.name.toLowerCase().contains(q);
    }).toList();

    final watchedSymbols = state.watchlist.map((w) => w.symbol).toSet();
    final available = filtered.where((s) => !watchedSymbols.contains(s.symbol)).toList();

    state = state.copyWith(
      searchResults: available.take(6).toList(),
      searchQuery: query,
    );
  }

  // Add to watchlist
  Future<void> addToWatchlist(StockModel stock) async {
    final userId = await _userSessionService.getUserId();
    if (userId == null) {
      state = state.copyWith(errorMessage: 'User not logged in');
      return;
    }

    final entity = WatchlistEntity(
      userId: userId,
      symbol: stock.symbol,
      name: stock.name,
      ltp: stock.ltp,
      high: stock.high,
      low: stock.low,
      pointChange: stock.pointChange,
      percentChange: stock.percentChange,
      previousClose: stock.previousClose,
      open: stock.open,
    );

    final result = await _addToWatchlistUsecase.call(
      AddToWatchlistParams(userId: userId, entity: entity),
    );

    result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
      },
      (addedItem) {
        final newList = [...state.watchlist, addedItem];
        state = state.copyWith(
          watchlist: newList,
          searchResults: [],
          searchQuery: '',
        );
      },
    );
  }

  // Remove from watchlist
  Future<void> removeFromWatchlist(String symbol) async {
    final result = await _removeFromWatchlistUsecase.call(
      RemoveFromWatchlistParams(symbol: symbol),
    );

    result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
      },
      (_) {
        final newList = state.watchlist.where((s) => s.symbol != symbol).toList();
        state = state.copyWith(watchlist: newList);
      },
    );
  }

  // Clear search
  void clearSearch() {
    state = state.copyWith(searchResults: [], searchQuery: '');
  }

  // Clear error
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}