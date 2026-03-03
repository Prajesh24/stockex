// lib/features/portfolio/data/repositories/portfolio_repository_impl.dart

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/error/faliures.dart';
import '../../../../core/services/connectivity/network_info.dart';
import '../../domain/entities/portfolio_entity.dart';
import '../../domain/repository/portfolio_repository.dart';
import '../datasource/local/portfolio_local_datasource.dart';
import '../datasource/remote/potfolio_remote_datasource.dart';

final portfolioRepositoryProvider = Provider<IPortfolioRepository>((ref) {
  return PortfolioRepositoryImpl(
    remoteDatasource: ref.read(portfolioRemoteDatasourceProvider),
    localDatasource: ref.read(portfolioLocalDatasourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

class PortfolioRepositoryImpl implements IPortfolioRepository {
  final IPortfolioRemoteDatasource _remoteDatasource;
  final IPortfolioLocalDatasource _localDatasource;
  final NetworkInfo _networkInfo;

  PortfolioRepositoryImpl({
    required IPortfolioRemoteDatasource remoteDatasource,
    required IPortfolioLocalDatasource localDatasource,
    required NetworkInfo networkInfo,
  })  : _remoteDatasource = remoteDatasource,
        _localDatasource = localDatasource,
        _networkInfo = networkInfo;

  @override
  Future<Either<Failure, List<PortfolioEntity>>> getPortfolio() async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _remoteDatasource.getPortfolio();
        return Right(result.map((model) => model.toEntity()).toList());
      } on Exception catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(ServerFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, PortfolioEntity>> addStock({
    required String symbol,
    required String name,
    String? sector,
    required String transactionType,
    required int units,
    required double buyPrice,
    required String buyDate,
    double? ltp, // ✅ added
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _remoteDatasource.addStock(
          symbol: symbol,
          name: name,
          sector: sector,
          transactionType: transactionType,
          units: units,
          buyPrice: buyPrice,
          buyDate: buyDate,
          ltp: ltp, // ✅ added
        );
        return Right(result.toEntity());
      } on Exception catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(ServerFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> removeStock(String id) async {
    if (await _networkInfo.isConnected) {
      try {
        await _remoteDatasource.removeStock(id);
        return const Right(null);
      } on Exception catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(ServerFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, SellResult>> sellStock({
    required String id,
    required int units,
    required double sellPrice,
    required String sellDate,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _remoteDatasource.sellStock(
          id: id,
          units: units,
          sellPrice: sellPrice,
          sellDate: sellDate,
        );
        return Right(result.toEntity());
      } on Exception catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(ServerFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, PortfolioOverview>> getOverview() async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _remoteDatasource.getOverview();
        return Right(result.toEntity());
      } on Exception catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(ServerFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getSellHistory() async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _remoteDatasource.getSellHistory();
        return Right(result);
      } on Exception catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(ServerFailure(message: 'No internet connection'));
    }
  }
}