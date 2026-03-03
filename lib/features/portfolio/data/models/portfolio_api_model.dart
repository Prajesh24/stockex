// lib/features/portfolio/data/models/portfolio_api_model.dart

import '../../domain/entities/portfolio_entity.dart';

class PortfolioApiModel {
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
  final double? ltp;
  final DateTime buyDate;
  final double? previousClose;
  final double? open;
  final FeeBreakdownModel? fees;
  final List<SellHistoryModel>? sellHistory;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PortfolioApiModel({
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
    this.ltp,
    required this.buyDate,
    this.previousClose,
    this.open,
    this.fees,
    this.sellHistory,
    this.createdAt,
    this.updatedAt,
  });

  factory PortfolioApiModel.fromJson(Map<String, dynamic> json) {
    return PortfolioApiModel(
      id: json['_id']?.toString(),
      userId: json['userId']?.toString() ?? '',
      symbol: json['symbol'] ?? '',
      name: json['name'] ?? '',
      sector: json['sector'],
      transactionType: json['transactionType'] ?? 'secondary',
      units: json['units'] ?? 0,
      soldUnits: json['soldUnits'] ?? 0,
      buyPrice: (json['buyPrice'] ?? 0).toDouble(),
      wacc: (json['wacc'] ?? json['buyPrice'] ?? 0).toDouble(),
      totalCost: (json['totalCost'] ?? 0).toDouble(),
      ltp: json['ltp']?.toDouble(),
      buyDate: json['buyDate'] != null 
          ? DateTime.tryParse(json['buyDate']) ?? DateTime.now()
          : DateTime.now(),
      previousClose: json['previousClose']?.toDouble(),
      open: json['open']?.toDouble(),
      fees: json['fees'] != null ? FeeBreakdownModel.fromJson(json['fees']) : null,
      sellHistory: json['sellHistory'] != null 
          ? (json['sellHistory'] as List).map((e) => SellHistoryModel.fromJson(e)).toList()
          : null,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'userId': userId,
      'symbol': symbol,
      'name': name,
      'sector': sector,
      'transactionType': transactionType,
      'units': units,
      'soldUnits': soldUnits,
      'buyPrice': buyPrice,
      'wacc': wacc,
      'totalCost': totalCost,
      'ltp': ltp,
      'buyDate': buyDate.toIso8601String(),
      'previousClose': previousClose,
      'open': open,
      'fees': fees?.toJson(),
    };
  }

  PortfolioEntity toEntity() {
    return PortfolioEntity(
      id: id,
      userId: userId,
      symbol: symbol,
      name: name,
      sector: sector,
      transactionType: transactionType,
      units: units,
      soldUnits: soldUnits,
      buyPrice: buyPrice,
      wacc: wacc,
      totalCost: totalCost,
      ltp: ltp ?? buyPrice,
      buyDate: buyDate,
      previousClose: previousClose,
      open: open,
      fees: fees?.toEntity(),
      sellHistory: sellHistory?.map((e) => e.toEntity()).toList(),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static PortfolioApiModel fromEntity(PortfolioEntity entity) {
    return PortfolioApiModel(
      id: entity.id,
      userId: entity.userId,
      symbol: entity.symbol,
      name: entity.name,
      sector: entity.sector,
      transactionType: entity.transactionType,
      units: entity.units,
      soldUnits: entity.soldUnits,
      buyPrice: entity.buyPrice,
      wacc: entity.wacc,
      totalCost: entity.totalCost,
      ltp: entity.ltp,
      buyDate: entity.buyDate,
      previousClose: entity.previousClose,
      open: entity.open,
    );
  }
}

class FeeBreakdownModel {
  final double brokerCommission;
  final double nepseCommission;
  final double sebonFee;
  final double dpCharge;

  FeeBreakdownModel({
    this.brokerCommission = 0,
    this.nepseCommission = 0,
    this.sebonFee = 0,
    this.dpCharge = 0,
  });

  factory FeeBreakdownModel.fromJson(Map<String, dynamic> json) {
    return FeeBreakdownModel(
      brokerCommission: (json['brokerCommission'] ?? 0).toDouble(),
      nepseCommission: (json['nepseCommission'] ?? 0).toDouble(),
      sebonFee: (json['sebonFee'] ?? 0).toDouble(),
      dpCharge: (json['dpCharge'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'brokerCommission': brokerCommission,
      'nepseCommission': nepseCommission,
      'sebonFee': sebonFee,
      'dpCharge': dpCharge,
    };
  }

  FeeBreakdown toEntity() {
    return FeeBreakdown(
      brokerCommission: brokerCommission,
      nepseCommission: nepseCommission,
      sebonFee: sebonFee,
      dpCharge: dpCharge,
    );
  }
}

class SellHistoryModel {
  final String? id;
  final int unitsSold;
  final double sellPrice;
  final DateTime sellDate;
  final FeeBreakdownModel? sellFees;
  final double realizedPL;
  final DateTime? createdAt;

  SellHistoryModel({
    this.id,
    required this.unitsSold,
    required this.sellPrice,
    required this.sellDate,
    this.sellFees,
    required this.realizedPL,
    this.createdAt,
  });

  factory SellHistoryModel.fromJson(Map<String, dynamic> json) {
    return SellHistoryModel(
      id: json['_id']?.toString(),
      unitsSold: json['unitsSold'] ?? 0,
      sellPrice: (json['sellPrice'] ?? 0).toDouble(),
      sellDate: json['sellDate'] != null 
          ? DateTime.tryParse(json['sellDate']) ?? DateTime.now()
          : DateTime.now(),
      sellFees: json['sellFees'] != null ? FeeBreakdownModel.fromJson(json['sellFees']) : null,
      realizedPL: (json['realizedPL'] ?? 0).toDouble(),
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
    );
  }

  SellHistory toEntity() {
    return SellHistory(
      id: id,
      unitsSold: unitsSold,
      sellPrice: sellPrice,
      sellDate: sellDate,
      sellFees: sellFees?.toEntity(),
      realizedPL: realizedPL,
      createdAt: createdAt,
    );
  }
}

class PortfolioOverviewModel {
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

  PortfolioOverviewModel({
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

  factory PortfolioOverviewModel.fromJson(Map<String, dynamic> json) {
    return PortfolioOverviewModel(
      totalUnits: json['totalUnits'] ?? 0,
      totalSoldUnits: json['totalSoldUnits'] ?? 0,
      totalInvestment: (json['totalInvestment'] ?? 0).toDouble(),
      currentValue: (json['currentValue'] ?? 0).toDouble(),
      unrealizedPL: (json['unrealizedPL'] ?? 0).toDouble(),
      realizedPL: (json['realizedPL'] ?? 0).toDouble(),
      totalPL: (json['totalPL'] ?? 0).toDouble(),
      profitLoss: (json['profitLoss'] ?? 0).toDouble(),
      profitLossPercent: (json['profitLossPercent'] ?? 0).toDouble(),
      totalFees: (json['totalFees'] ?? 0).toDouble(),
      totalStocks: json['totalStocks'] ?? 0,
    );
  }

  PortfolioOverview toEntity() {
    return PortfolioOverview(
      totalUnits: totalUnits,
      totalSoldUnits: totalSoldUnits,
      totalInvestment: totalInvestment,
      currentValue: currentValue,
      unrealizedPL: unrealizedPL,
      realizedPL: realizedPL,
      totalPL: totalPL,
      profitLoss: profitLoss,
      profitLossPercent: profitLossPercent,
      totalFees: totalFees,
      totalStocks: totalStocks,
    );
  }
}

class SellResultModel {
  final PortfolioApiModel stock;
  final double realizedPL;
  final double realizedPLPercent;
  final int soldUnits;
  final double sellPrice;
  final DateTime sellDate;

  SellResultModel({
    required this.stock,
    required this.realizedPL,
    required this.realizedPLPercent,
    required this.soldUnits,
    required this.sellPrice,
    required this.sellDate,
  });

  factory SellResultModel.fromJson(Map<String, dynamic> json) {
    return SellResultModel(
      stock: PortfolioApiModel.fromJson(json['stock']),
      realizedPL: (json['realizedPL'] ?? 0).toDouble(),
      realizedPLPercent: (json['realizedPLPercent'] ?? 0).toDouble(),
      soldUnits: json['soldUnits'] ?? 0,
      sellPrice: (json['sellPrice'] ?? 0).toDouble(),
      sellDate: DateTime.tryParse(json['sellDate'] ?? '') ?? DateTime.now(),
    );
  }

  SellResult toEntity() {
    return SellResult(
      stock: stock.toEntity(),
      realizedPL: realizedPL,
      realizedPLPercent: realizedPLPercent,
      soldUnits: soldUnits,
      sellPrice: sellPrice,
      sellDate: sellDate,
    );
  }
}