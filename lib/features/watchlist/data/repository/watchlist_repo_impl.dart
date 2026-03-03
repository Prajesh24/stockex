import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// import '../../../../core/error/failures.dart';
import '../../../../core/error/faliures.dart';
import '../../../../core/services/connectivity/network_info.dart';
import '../../domain/entities/watchlist_entity.dart';
import '../../domain/repository/watchlist_repo.dart';
// import '../datasource/remote/watchlist_remote_datasource.dart';
import '../datasource/remote/watclist_remote_datasource.dart';
import '../model/watchlist_api_model.dart';

final watchlistRepositoryProvider = Provider<IWatchlistRepository>((ref) {
  return WatchlistRepositoryImpl(
    remoteDatasource: ref.read(watchlistRemoteDatasourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

class WatchlistRepositoryImpl implements IWatchlistRepository {
  final IWatchlistRemoteDatasource _remoteDatasource;
  final NetworkInfo _networkInfo;

  WatchlistRepositoryImpl({
    required IWatchlistRemoteDatasource remoteDatasource,
    required NetworkInfo networkInfo,
  })  : _remoteDatasource = remoteDatasource,
        _networkInfo = networkInfo;

  @override
  Future<Either<Failure, List<WatchlistEntity>>> getWatchlist() async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _remoteDatasource.getWatchlist();
        // No local caching - just return remote data
        return Right(WatchlistApiModel.toEntityList(result));
      } on Exception catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(ServerFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, WatchlistEntity>> addToWatchlist(
    String userId,
    WatchlistEntity entity,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final model = WatchlistApiModel.fromEntity(entity);
        final result = await _remoteDatasource.addToWatchlist(model);
        // No local caching
        return Right(result.toEntity());
      } on Exception catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(ServerFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> removeFromWatchlist(String symbol) async {
    if (await _networkInfo.isConnected) {
      try {
        await _remoteDatasource.removeFromWatchlist(symbol);
        // No local caching
        return const Right(null);
      } on Exception catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(ServerFailure(message: 'No internet connection'));
    }
  }
}