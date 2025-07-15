// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'position_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Position _$PositionFromJson(Map<String, dynamic> json) => Position(
      id: (json['id'] as num?)?.toInt(),
      accountId: (json['account_id'] as num?)?.toInt(),
      market: json['market'] as String?,
      side: json['side'] as String?,
      leverage: (json['leverage'] as num?)?.toDouble(),
      size: (json['size'] as num?)?.toDouble(),
      value: (json['value'] as num?)?.toDouble(),
      openPrice: (json['open_price'] as num?)?.toDouble(),
      markPrice: (json['mark_price'] as num?)?.toDouble(),
      liquidationPrice: (json['liquidation_price'] as num?)?.toDouble(),
      unrealisedPnl: (json['unrealised_pnl'] as num?)?.toDouble(),
      realisedPnl: (json['realised_pnl'] as num?)?.toDouble(),
      tpPrice: (json['tp_price'] as num?)?.toDouble(),
      slPrice: (json['sl_price'] as num?)?.toDouble(),
      adl: (json['adl'] as num?)?.toInt(),
      createdAt: (json['created_at'] as num?)?.toInt(),
      updatedAt: (json['updated_at'] as num?)?.toInt(),
      exitType: json['exit_type'] as String?,
      exitPrice: (json['exit_price'] as num?)?.toDouble(),
      createdTime: (json['created_time'] as num?)?.toInt(),
      closedTime: (json['closed_time'] as num?)?.toInt(),
    );

Map<String, dynamic> _$PositionToJson(Position instance) => <String, dynamic>{
      'id': instance.id,
      'account_id': instance.accountId,
      'market': instance.market,
      'side': instance.side,
      'leverage': instance.leverage,
      'size': instance.size,
      'value': instance.value,
      'open_price': instance.openPrice,
      'mark_price': instance.markPrice,
      'liquidation_price': instance.liquidationPrice,
      'unrealised_pnl': instance.unrealisedPnl,
      'realised_pnl': instance.realisedPnl,
      'tp_price': instance.tpPrice,
      'sl_price': instance.slPrice,
      'adl': instance.adl,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'exit_type': instance.exitType,
      'exit_price': instance.exitPrice,
      'created_time': instance.createdTime,
      'closed_time': instance.closedTime,
    };
