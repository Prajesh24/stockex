// lib/features/portfolio/domain/entities/portfolio_entity.dart

class PortfolioEntity {
  final String? id;
  final String userId;
  final String symbol;
  final String name;
  final String? sector;
  final String transactionType;
  final int units;
  final int soldUnits;
  final double buyPrice;
  final double wacc;
  final double totalCost;
  final double ltp;
  final DateTime buyDate;
  final double? previousClose;
  final double? open;
  final FeeBreakdown? fees;
  final List<SellHistory>? sellHistory;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PortfolioEntity({
    this.id,
    required this.userId,
    required this.symbol,
    required this.name,
    this.sector,
    required this.transactionType,
    required this.units,
    this.soldUnits = 0,
    required this.buyPrice,
    required this.wacc,
    required this.totalCost,
    required this.ltp,
    required this.buyDate,
    this.previousClose,
    this.open,
    this.fees,
    this.sellHistory,
    this.createdAt,
    this.updatedAt,
  });

  int get remainingUnits => units - soldUnits;
  double get currentValue => remainingUnits * ltp;
  double get costBasis => remainingUnits * wacc;
  double get unrealizedPL => currentValue - costBasis;
  double get unrealizedPLPercent => costBasis > 0 ? (unrealizedPL / costBasis) * 100 : 0;
  bool get isProfit => unrealizedPL >= 0;
  double get totalFees => (fees?.brokerCommission ?? 0) + 
                         (fees?.nepseCommission ?? 0) + 
                         (fees?.sebonFee ?? 0) + 
                         (fees?.dpCharge ?? 0);
}

class FeeBreakdown {
  final double brokerCommission;
  final double nepseCommission;
  final double sebonFee;
  final double dpCharge;

  FeeBreakdown({
    this.brokerCommission = 0,
    this.nepseCommission = 0,
    this.sebonFee = 0,
    this.dpCharge = 0,
  });
}

class SellHistory {
  final String? id;
  final int unitsSold;
  final double sellPrice;
  final DateTime sellDate;
  final FeeBreakdown? sellFees;
  final double realizedPL;
  final DateTime? createdAt;

  SellHistory({
    this.id,
    required this.unitsSold,
    required this.sellPrice,
    required this.sellDate,
    this.sellFees,
    required this.realizedPL,
    this.createdAt,
  });
}

class PortfolioOverview {
  final int totalUnits;
  final int totalSoldUnits;
  final double totalInvestment;
  final double currentValue;
  final double unrealizedPL;
  final double realizedPL;
  final double totalPL;
  final double profitLoss;
  final double profitLossPercent;
  final double totalFees;
  final int totalStocks;

  PortfolioOverview({
    this.totalUnits = 0,
    this.totalSoldUnits = 0,
    this.totalInvestment = 0,
    this.currentValue = 0,
    this.unrealizedPL = 0,
    this.realizedPL = 0,
    this.totalPL = 0,
    this.profitLoss = 0,
    this.profitLossPercent = 0,
    this.totalFees = 0,
    this.totalStocks = 0,
  });
}

class SellResult {
  final PortfolioEntity stock;
  final double realizedPL;
  final double realizedPLPercent;
  final int soldUnits;
  final double sellPrice;
  final DateTime sellDate;

  SellResult({
    required this.stock,
    required this.realizedPL,
    required this.realizedPLPercent,
    required this.soldUnits,
    required this.sellPrice,
    required this.sellDate,
  });
}

class SymbolSummary {
  final String symbol;
  final String name;
  final int totalUnits;
  final int soldUnits;
  final int remainingUnits;
  final double wacc;
  final double avgBuyPrice;
  final double totalCost;
  final double currentLTP;
  final double currentValue;
  final double unrealizedPL;
  final double unrealizedPLPercent;
  final bool isProfit;
  final double totalFees;
  final List<String> stockIds;
  final List<PortfolioEntity> individualStocks;

  SymbolSummary({
    required this.symbol,
    required this.name,
    required this.totalUnits,
    required this.soldUnits,
    required this.remainingUnits,
    required this.wacc,
    required this.avgBuyPrice,
    required this.totalCost,
    required this.currentLTP,
    required this.currentValue,
    required this.unrealizedPL,
    required this.unrealizedPLPercent,
    required this.isProfit,
    required this.totalFees,
    required this.stockIds,
    required this.individualStocks,
  });
}