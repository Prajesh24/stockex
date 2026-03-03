import 'package:json_annotation/json_annotation.dart';
import '../../../watchlist/domain/entities/watchlist_entity.dart';

part 'watchlist_api_model.g.dart';

@JsonSerializable()
class WatchlistApiModel {
  @JsonKey(name: '_id')
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

  WatchlistApiModel({
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

  factory WatchlistApiModel.fromJson(Map<String, dynamic> json) =>
      _$WatchlistApiModelFromJson(json);

  Map<String, dynamic> toJson() => _$WatchlistApiModelToJson(this);

  WatchlistEntity toEntity() {
    return WatchlistEntity(
      id: id,
      userId: userId,
      symbol: symbol,
      name: name,
      ltp: ltp,
      high: high,
      low: low,
      pointChange: pointChange,
      percentChange: percentChange,
      previousClose: previousClose,
      open: open,
    );
  }

  factory WatchlistApiModel.fromEntity(WatchlistEntity entity) {
    return WatchlistApiModel(
      id: entity.id,
      userId: entity.userId,
      symbol: entity.symbol,
      name: entity.name,
      ltp: entity.ltp,
      high: entity.high,
      low: entity.low,
      pointChange: entity.pointChange,
      percentChange: entity.percentChange,
      previousClose: entity.previousClose,
      open: entity.open,
    );
  }

  static List<WatchlistEntity> toEntityList(List<WatchlistApiModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
