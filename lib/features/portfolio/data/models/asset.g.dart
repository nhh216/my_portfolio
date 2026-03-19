// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'asset.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AssetImpl _$$AssetImplFromJson(Map<String, dynamic> json) => _$AssetImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  symbol: json['symbol'] as String,
  quantity: (json['quantity'] as num).toDouble(),
  buyPrice: (json['buyPrice'] as num).toDouble(),
  currentPrice: (json['currentPrice'] as num).toDouble(),
);

Map<String, dynamic> _$$AssetImplToJson(_$AssetImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'symbol': instance.symbol,
      'quantity': instance.quantity,
      'buyPrice': instance.buyPrice,
      'currentPrice': instance.currentPrice,
    };
