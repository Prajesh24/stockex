import 'nepse_index_model.dart';

class MarketSummaryModel {
  final String date;
  final String time;
  final String status;
  final NepseIndexModel nepse;
  final double turnoverInArba;
  final int totalTrades;
  final int totalVolume;
  final double totalTurnover;
  final int advance;
  final int decline;
  final int unchanged;

  MarketSummaryModel({
    required this.date,
    required this.time,
    required this.status,
    required this.nepse,
    required this.turnoverInArba,
    required this.totalTrades,
    required this.totalVolume,
    required this.totalTurnover,
    required this.advance,
    required this.decline,
    required this.unchanged,
  });
}
