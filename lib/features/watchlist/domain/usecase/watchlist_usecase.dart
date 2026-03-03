import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stockex/features/watchlist/data/repository/watchlist_repo_impl.dart';
import '../../../../core/error/faliures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/watchlist_entity.dart';
import '../repository/watchlist_repo.dart';

// ==================== GET WATCHLIST ====================

final getWatchlistUsecaseProvider = Provider<GetWatchlistUsecase>((ref) {
  final repository = ref.watch(watchlistRepositoryProvider);
  return GetWatchlistUsecase(repository);
});

class GetWatchlistUsecase implements UseCaseWithoutParams<List<WatchlistEntity>> {
  final IWatchlistRepository _repository;

  GetWatchlistUsecase(this._repository);

  @override
  Future<Either<Failure, List<WatchlistEntity>>> call() {
    return _repository.getWatchlist();
  }
}

// ==================== ADD TO WATCHLIST ====================

final addToWatchlistUsecaseProvider = Provider<AddToWatchlistUsecase>((ref) {
  final repository = ref.watch(watchlistRepositoryProvider);
  return AddToWatchlistUsecase(repository);
});

class AddToWatchlistParams extends Equatable {
  final String userId;
  final WatchlistEntity entity;

  const AddToWatchlistParams({
    required this.userId,
    required this.entity,
  });

  @override
  List<Object?> get props => [userId, entity];
}

class AddToWatchlistUsecase
    implements UseCaseWithParams<WatchlistEntity, AddToWatchlistParams> {
  final IWatchlistRepository _repository;

  AddToWatchlistUsecase(this._repository);

  @override
  Future<Either<Failure, WatchlistEntity>> call(AddToWatchlistParams params) {
    return _repository.addToWatchlist(params.userId, params.entity);
  }
}

// ==================== REMOVE FROM WATCHLIST ====================

final removeFromWatchlistUsecaseProvider = Provider<RemoveFromWatchlistUsecase>((ref) {
  final repository = ref.watch(watchlistRepositoryProvider);
  return RemoveFromWatchlistUsecase(repository);
});

class RemoveFromWatchlistParams extends Equatable {
  final String symbol;

  const RemoveFromWatchlistParams({required this.symbol});

  @override
  List<Object?> get props => [symbol];
}

class RemoveFromWatchlistUsecase
    implements UseCaseWithParams<void, RemoveFromWatchlistParams> {
  final IWatchlistRepository _repository;

  RemoveFromWatchlistUsecase(this._repository);

  @override
  Future<Either<Failure, void>> call(RemoveFromWatchlistParams params) {
    return _repository.removeFromWatchlist(params.symbol);
  }
}