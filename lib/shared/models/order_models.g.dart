// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderHistoryResponse _$OrderHistoryResponseFromJson(
        Map<String, dynamic> json) =>
    OrderHistoryResponse(
      status: json['status'] as String,
      data: (json['data'] as List<dynamic>)
          .map((e) => Order.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination:
          OrderPagination.fromJson(json['pagination'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$OrderHistoryResponseToJson(
        OrderHistoryResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'data': instance.data,
      'pagination': instance.pagination,
    };

Order _$OrderFromJson(Map<String, dynamic> json) => Order(
      id: (json['id'] as num).toInt(),
      accountId: (json['accountId'] as num).toInt(),
      externalId: json['externalId'] as String,
      market: json['market'] as String,
      type: json['type'] as String,
      side: json['side'] as String,
      status: json['status'] as String,
      price: json['price'] as String,
      averagePrice: json['averagePrice'] as String,
      qty: json['qty'] as String,
      filledQty: json['filledQty'] as String,
      twap: OrderTwap.fromJson(json['twap'] as Map<String, dynamic>),
      reduceOnly: json['reduceOnly'] as bool,
      postOnly: json['postOnly'] as bool,
      createdTime: (json['createdTime'] as num).toInt(),
      updatedTime: (json['updatedTime'] as num).toInt(),
      expireTime: (json['expireTime'] as num).toInt(),
      timeInForce: json['timeInForce'] as String,
      payedFee: json['payedFee'] as String,
    );

Map<String, dynamic> _$OrderToJson(Order instance) => <String, dynamic>{
      'id': instance.id,
      'accountId': instance.accountId,
      'externalId': instance.externalId,
      'market': instance.market,
      'type': instance.type,
      'side': instance.side,
      'status': instance.status,
      'price': instance.price,
      'averagePrice': instance.averagePrice,
      'qty': instance.qty,
      'filledQty': instance.filledQty,
      'twap': instance.twap,
      'reduceOnly': instance.reduceOnly,
      'postOnly': instance.postOnly,
      'createdTime': instance.createdTime,
      'updatedTime': instance.updatedTime,
      'expireTime': instance.expireTime,
      'timeInForce': instance.timeInForce,
      'payedFee': instance.payedFee,
    };

OrderTwap _$OrderTwapFromJson(Map<String, dynamic> json) => OrderTwap(
      durationSeconds: (json['durationSeconds'] as num).toInt(),
      frequencySeconds: (json['frequencySeconds'] as num).toInt(),
      randomise: json['randomise'] as bool,
    );

Map<String, dynamic> _$OrderTwapToJson(OrderTwap instance) => <String, dynamic>{
      'durationSeconds': instance.durationSeconds,
      'frequencySeconds': instance.frequencySeconds,
      'randomise': instance.randomise,
    };

OrderPagination _$OrderPaginationFromJson(Map<String, dynamic> json) =>
    OrderPagination(
      cursor: (json['cursor'] as num).toInt(),
      count: (json['count'] as num).toInt(),
    );

Map<String, dynamic> _$OrderPaginationToJson(OrderPagination instance) =>
    <String, dynamic>{
      'cursor': instance.cursor,
      'count': instance.count,
    };
