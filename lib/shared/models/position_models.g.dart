// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'position_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PositionsResponse _$PositionsResponseFromJson(Map<String, dynamic> json) =>
    PositionsResponse(
      status: json['status'] as String,
      data: (json['data'] as List<dynamic>)
          .map((e) => Position.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PositionsResponseToJson(PositionsResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'data': instance.data,
    };

Position _$PositionFromJson(Map<String, dynamic> json) => Position(
      id: (json['id'] as num).toInt(),
      accountId: (json['accountId'] as num).toInt(),
      market: json['market'] as String,
      status: json['status'] as String,
      side: json['side'] as String,
      leverage: json['leverage'] as String,
      size: json['size'] as String,
      value: json['value'] as String,
      openPrice: json['openPrice'] as String,
      markPrice: json['markPrice'] as String,
      liquidationPrice: json['liquidationPrice'] as String,
      margin: json['margin'] as String,
      unrealisedPnl: json['unrealisedPnl'] as String,
      realisedPnl: json['realisedPnl'] as String,
      adl: (json['adl'] as num).toInt(),
      createdAt: (json['createdAt'] as num).toInt(),
      updatedAt: (json['updatedAt'] as num).toInt(),
    );

Map<String, dynamic> _$PositionToJson(Position instance) => <String, dynamic>{
      'id': instance.id,
      'accountId': instance.accountId,
      'market': instance.market,
      'status': instance.status,
      'side': instance.side,
      'leverage': instance.leverage,
      'size': instance.size,
      'value': instance.value,
      'openPrice': instance.openPrice,
      'markPrice': instance.markPrice,
      'liquidationPrice': instance.liquidationPrice,
      'margin': instance.margin,
      'unrealisedPnl': instance.unrealisedPnl,
      'realisedPnl': instance.realisedPnl,
      'adl': instance.adl,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };
