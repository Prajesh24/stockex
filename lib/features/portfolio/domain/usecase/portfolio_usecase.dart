// lib/features/portfolio/domain/usecases/portfolio_usecases.dart

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stockex/core/error/faliures.dart';
import 'package:stockex/features/portfolio/data/repository/portfolio_repo_impl.dart';
import 'package:stockex/features/portfolio/domain/repository/portfolio_repository.dart';
import '../entities/portfolio_entity.dart';

final portfolioUseCasesProvider = Provider<PortfolioUseCases>((ref) {
  return PortfolioUseCases(ref.read(portfolioRepositoryProvider));
});

class PortfolioUseCases {
  final IPortfolioRepository _repository;

  PortfolioUseCases(this._repository);

  Future<Either<Failure, List<PortfolioEntity>>> getPortfolio() {
    return _repository.getPortfolio();
  }

  Future<Either<Failure, PortfolioEntity>> addStock({
    required String symbol,
    required String name,
    String? sector,
    required String transactionType,
    required int units,
    required double buyPrice,
    required String buyDate,
    double? ltp, // ✅ added
  }) {
    return _repository.addStock(
      symbol: symbol,
      name: name,
      sector: sector,
      transactionType: transactionType,
      units: units,
      buyPrice: buyPrice,
      buyDate: buyDate,
      ltp: ltp, // ✅ added
    );
  }

  Future<Either<Failure, void>> removeStock(String stockId) {
    return _repository.removeStock(stockId);
  }

  Future<Either<Failure, SellResult>> sellStock({
    required String stockId,
    required int units,
    required double sellPrice,
    required String sellDate,
  }) {
    return _repository.sellStock(
      id: stockId,
      units: units,
      sellPrice: sellPrice,
      sellDate: sellDate,
    );
  }

  Future<Either<Failure, PortfolioOverview>> getOverview() {
    return _repository.getOverview();
  }

  Future<Either<Failure, List<Map<String, dynamic>>>> getSellHistory() {
    return _repository.getSellHistory();
  }
}