import 'package:json_annotation/json_annotation.dart';

part 'order_models.g.dart';

@JsonSerializable()
class OrderHistoryResponse {
  final String status;
  final List<Order> data;
  final OrderPagination pagination;

  const OrderHistoryResponse({
    required this.status,
    required this.data,
    required this.pagination,
  });

  factory OrderHistoryResponse.fromJson(Map<String, dynamic> json) =>
      _$OrderHistoryResponseFromJson(json);

  Map<String, dynamic> toJson() => _$OrderHistoryResponseToJson(this);
}

@JsonSerializable()
class Order {
  final int id;
  final int accountId;
  final String externalId;
  final String market;
  final String type;
  final String side;
  final String status;
  final String price;
  final String averagePrice;
  final String qty;
  final String filledQty;
  final OrderTwap twap;
  final bool reduceOnly;
  final bool postOnly;
  final int createdTime;
  final int updatedTime;
  final int expireTime;
  final String timeInForce;
  final String payedFee;

  const Order({
    required this.id,
    required this.accountId,
    required this.externalId,
    required this.market,
    required this.type,
    required this.side,
    required this.status,
    required this.price,
    required this.averagePrice,
    required this.qty,
    required this.filledQty,
    required this.twap,
    required this.reduceOnly,
    required this.postOnly,
    required this.createdTime,
    required this.updatedTime,
    required this.expireTime,
    required this.timeInForce,
    required this.payedFee,
  });

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);

  Map<String, dynamic> toJson() => _$OrderToJson(this);

  // Computed properties for easier access
  double get priceValue => double.parse(price);
  double get averagePriceValue => double.parse(averagePrice);
  double get qtyValue => double.parse(qty);
  double get filledQtyValue => double.parse(filledQty);
  double get payedFeeValue => double.parse(payedFee);

  bool get isBuy => side == 'BUY';
  bool get isSell => side == 'SELL';
  bool get isFilled => status == 'FILLED';
  bool get isPartiallyFilled => status == 'PARTIALLY_FILLED';
  bool get isCancelled => status == 'CANCELLED';
  bool get isPending => status == 'PENDING';

  DateTime get createdAtDateTime =>
      DateTime.fromMillisecondsSinceEpoch(createdTime);
  DateTime get updatedAtDateTime =>
      DateTime.fromMillisecondsSinceEpoch(updatedTime);
  DateTime get expireAtDateTime =>
      DateTime.fromMillisecondsSinceEpoch(expireTime);

  double get totalValue => qtyValue * averagePriceValue;
}

@JsonSerializable()
class OrderTwap {
  final int durationSeconds;
  final int frequencySeconds;
  final bool randomise;

  const OrderTwap({
    required this.durationSeconds,
    required this.frequencySeconds,
    required this.randomise,
  });

  factory OrderTwap.fromJson(Map<String, dynamic> json) =>
      _$OrderTwapFromJson(json);

  Map<String, dynamic> toJson() => _$OrderTwapToJson(this);
}

@JsonSerializable()
class OrderPagination {
  final int cursor;
  final int count;

  const OrderPagination({required this.cursor, required this.count});

  factory OrderPagination.fromJson(Map<String, dynamic> json) =>
      _$OrderPaginationFromJson(json);

  Map<String, dynamic> toJson() => _$OrderPaginationToJson(this);
}
