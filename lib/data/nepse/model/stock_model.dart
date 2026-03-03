class StockModel {
  final String symbol;
  final String name;
  final String sector;
  final double ltp;
  final double previousClose;
  final double open;
  final double high;
  final double low;
  final double pointChange;
  final double percentChange;
  final int volume;
  final double turnover;
  final int trades;

  StockModel({
    required this.symbol,
    required this.name,
    required this.sector,
    required this.ltp,
    required this.previousClose,
    required this.open,
    required this.high,
    required this.low,
    required this.pointChange,
    required this.percentChange,
    required this.volume,
    required this.turnover,
    required this.trades,
  });
}