import 'package:equatable/equatable.dart';

class WatchlistEntity extends Equatable {
  final String? id;
  final String userId;
  final String symbol;
  final String name;
  final double ltp;
  final double high;
  final double low;
  final double pointChange;
  final double percentChange;
  final double previousClose;
  final double open;

  const WatchlistEntity({
    this.id,
    required this.userId,
    required this.symbol,
    required this.name,
    required this.ltp,
    required this.high,
    required this.low,
    required this.pointChange,
    required this.percentChange,
    required this.previousClose,
    required this.open,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        symbol,
        name,
        ltp,
        high,
        low,
        pointChange,
        percentChange,
        previousClose,
        open,
      ];
}