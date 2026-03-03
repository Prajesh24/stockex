// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'watchlist_api_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WatchlistApiModel _$WatchlistApiModelFromJson(Map<String, dynamic> json) =>
    WatchlistApiModel(
      id: json['_id'] as String?,
      userId: json['userId'] as String,
      symbol: json['symbol'] as String,
      name: json['name'] as String,
      ltp: (json['ltp'] as num).toDouble(),
      high: (json['high'] as num).toDouble(),
      low: (json['low'] as num).toDouble(),
      pointChange: (json['pointChange'] as num).toDouble(),
      percentChange: (json['percentChange'] as num).toDouble(),
      previousClose: (json['previousClose'] as num).toDouble(),
      open: (json['open'] as num).toDouble(),
    );

Map<String, dynamic> _$WatchlistApiModelToJson(WatchlistApiModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'userId': instance.userId,
      'symbol': instance.symbol,
      'name': instance.name,
      'ltp': instance.ltp,
      'high': instance.high,
      'low': instance.low,
      'pointChange': instance.pointChange,
      'percentChange': instance.percentChange,
      'previousClose': instance.previousClose,
      'open': instance.open,
    };
