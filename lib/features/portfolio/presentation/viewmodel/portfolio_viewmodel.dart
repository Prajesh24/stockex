// lib/features/portfolio/presentation/viewmodel/portfolio_viewmodel.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stockex/features/portfolio/domain/usecase/portfolio_usecase.dart';
import '../../domain/entities/portfolio_entity.dart';
import '../state/portfolio_state.dart';

final portfolioViewModelProvider =
    StateNotifierProvider<PortfolioViewModel, PortfolioState>((ref) {
  return PortfolioViewModel(ref.read(portfolioUseCasesProvider));
});

class PortfolioViewModel extends StateNotifier<PortfolioState> {
  final PortfolioUseCases _useCases;

  PortfolioViewModel(this._useCases) : super(PortfolioInitial());

  Future<void> loadPortfolio() async {
    state = PortfolioLoading();
    final result = await _useCases.getPortfolio();
    result.fold(
      (failure) => state = PortfolioError(failure.message),
      (stocks) async {
        final overviewResult = await _useCases.getOverview();
        overviewResult.fold(
          (failure) => state = PortfolioError(failure.message),
          (overview) {
            final summaries = _calculateSymbolSummaries(stocks);
            state = PortfolioLoaded(stocks: stocks, overview: overview, symbolSummaries: summaries);
          },
        );
      },
    );
  }

  // ltp added - passes market price from dialog to usecase/datasource/backend
  Future<void> addStock({
    required String symbol,
    required String name,
    String? sector,
    required String transactionType,
    required int units,
    required double buyPrice,
    required String buyDate,
    double? ltp,
  }) async {
    state = PortfolioActionLoading('Adding stock...');
    final result = await _useCases.addStock(
      symbol: symbol, name: name, sector: sector,
      transactionType: transactionType, units: units,
      buyPrice: buyPrice, buyDate: buyDate, ltp: ltp,
    );
    result.fold(
      (failure) => state = PortfolioActionError(failure.message),
      (stock) { state = PortfolioActionSuccess('Stock added successfully'); loadPortfolio(); },
    );
  }

  Future<void> removeStock(String id) async {
    state = PortfolioActionLoading('Removing stock...');
    final result = await _useCases.removeStock(id);
    result.fold(
      (failure) => state = PortfolioActionError(failure.message),
      (_) { state = PortfolioActionSuccess('Stock removed successfully'); loadPortfolio(); },
    );
  }

  Future<void> sellStock({
    required String id, required int units,
    required double sellPrice, required String sellDate,
  }) async {
    state = PortfolioActionLoading('Selling stock...');
    final result = await _useCases.sellStock(stockId: id, units: units, sellPrice: sellPrice, sellDate: sellDate);
    result.fold(
      (failure) => state = PortfolioActionError(failure.message),
      (result) {
        final plText = result.realizedPL >= 0 ? '+' : '';
        state = PortfolioActionSuccess('Sold ${result.soldUnits} units. P/L: $plText${result.realizedPL.toStringAsFixed(2)}');
        loadPortfolio();
      },
    );
  }

  Future<void> removeAllBySymbol(String symbol, List<String> ids) async {
    state = PortfolioActionLoading('Removing all $symbol entries...');
    for (final id in ids) {
      final result = await _useCases.removeStock(id);
      if (result.isLeft()) { state = PortfolioActionError('Failed to remove some entries'); return; }
    }
    state = PortfolioActionSuccess('All $symbol entries removed');
    loadPortfolio();
  }

  List<SymbolSummary> _calculateSymbolSummaries(List<PortfolioEntity> stocks) {
    final Map<String, _SummaryAccumulator> accMap = {};

    for (final stock in stocks) {
      final remaining = stock.remainingUnits;
      if (stock.units <= 0) continue;

      accMap.putIfAbsent(stock.symbol, () => _SummaryAccumulator(
        symbol: stock.symbol, name: stock.name, currentLTP: stock.ltp,
      ));

      final acc = accMap[stock.symbol]!;
      acc.totalUnits += stock.units;
      acc.soldUnits += stock.soldUnits;
      acc.remainingUnits += remaining;

      if (remaining > 0) {
        acc.totalCost += remaining * stock.wacc;   // wacc includes all fees
        acc.currentValue += remaining * stock.ltp; // ltp = market price from backend
      }

      acc.totalFees += stock.totalFees;
      acc.stockIds.add(stock.id!);
      acc.individualStocks.add(stock);
      acc.currentLTP = stock.ltp;
    }

    return accMap.values.map((acc) {
      final wacc = acc.remainingUnits > 0 ? acc.totalCost / acc.remainingUnits : 0.0;
      // P/L = (LTP - WACC) * units = currentValue - totalCost
      final unrealizedPL = acc.currentValue - acc.totalCost;
      final unrealizedPLPercent = acc.totalCost > 0 ? (unrealizedPL / acc.totalCost) * 100 : 0.0;

      return SymbolSummary(
        symbol: acc.symbol, name: acc.name,
        totalUnits: acc.totalUnits, soldUnits: acc.soldUnits,
        remainingUnits: acc.remainingUnits,
        wacc: wacc, avgBuyPrice: wacc,
        totalCost: acc.totalCost,
        currentLTP: acc.currentLTP, currentValue: acc.currentValue,
        unrealizedPL: unrealizedPL, unrealizedPLPercent: unrealizedPLPercent,
        isProfit: unrealizedPL >= 0,
        totalFees: acc.totalFees,
        stockIds: acc.stockIds, individualStocks: acc.individualStocks,
      );
    }).toList();
  }
}

class _SummaryAccumulator {
  final String symbol;
  final String name;
  int totalUnits = 0, soldUnits = 0, remainingUnits = 0;
  double totalCost = 0, currentValue = 0, totalFees = 0;
  double currentLTP;
  List<String> stockIds = [];
  List<PortfolioEntity> individualStocks = [];
  _SummaryAccumulator({required this.symbol, required this.name, required this.currentLTP});
}