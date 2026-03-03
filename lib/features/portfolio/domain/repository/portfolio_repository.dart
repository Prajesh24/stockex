// lib/features/portfolio/domain/repositories/portfolio_repository.dart

import 'package:dartz/dartz.dart';
import 'package:stockex/core/error/faliures.dart';
import '../entities/portfolio_entity.dart';

abstract class IPortfolioRepository {
  Future<Either<Failure, List<PortfolioEntity>>> getPortfolio();

  Future<Either<Failure, PortfolioEntity>> addStock({
    required String symbol,
    required String name,
    String? sector,
    required String transactionType,
    required int units,
    required double buyPrice,
    required String buyDate,
    double? ltp, // ✅ added
  });

  Future<Either<Failure, void>> removeStock(String id);

  Future<Either<Failure, SellResult>> sellStock({
    required String id,
    required int units,
    required double sellPrice,
    required String sellDate,
  });

  Future<Either<Failure, PortfolioOverview>> getOverview();

  Future<Either<Failure, List<Map<String, dynamic>>>> getSellHistory();
}