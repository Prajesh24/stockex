import 'package:dartz/dartz.dart';
import '../../../../core/error/faliures.dart';
import '../entities/watchlist_entity.dart';

abstract class IWatchlistRepository {
  Future<Either<Failure, List<WatchlistEntity>>> getWatchlist();
  Future<Either<Failure, WatchlistEntity>> addToWatchlist(
    String userId,
    WatchlistEntity entity,
  );
  Future<Either<Failure, void>> removeFromWatchlist(String symbol);
}