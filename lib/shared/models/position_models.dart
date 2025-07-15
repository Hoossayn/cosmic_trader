import 'package:json_annotation/json_annotation.dart';

part 'position_models.g.dart';

@JsonSerializable()
class Position {
  final int? id;
  @JsonKey(name: 'account_id')
  final int? accountId;
  final String? market;
  final String? side;
  final double? leverage;
  final double? size;
  final double? value;
  @JsonKey(name: 'open_price')
  final double? openPrice;
  @JsonKey(name: 'mark_price')
  final double? markPrice;
  @JsonKey(name: 'liquidation_price')
  final double? liquidationPrice;
  @JsonKey(name: 'unrealised_pnl')
  final double? unrealisedPnl;
  @JsonKey(name: 'realised_pnl')
  final double? realisedPnl;
  @JsonKey(name: 'tp_price')
  final double? tpPrice;
  @JsonKey(name: 'sl_price')
  final double? slPrice;
  final int? adl;
  @JsonKey(name: 'created_at')
  final int? createdAt;
  @JsonKey(name: 'updated_at')
  final int? updatedAt;

  const Position({
    this.id,
    this.accountId,
    this.market,
    this.side,
    this.leverage,
    this.size,
    this.value,
    this.openPrice,
    this.markPrice,
    this.liquidationPrice,
    this.unrealisedPnl,
    this.realisedPnl,
    this.tpPrice,
    this.slPrice,
    this.adl,
    this.createdAt,
    this.updatedAt,
  });

  factory Position.fromJson(Map<String, dynamic> json) =>
      _$PositionFromJson(json);
  Map<String, dynamic> toJson() => _$PositionToJson(this);

  // Computed properties for easier UI use
  double get sizeValue => size ?? 0.0;
  double get valueValue => value ?? 0.0;
  double get openPriceValue => openPrice ?? 0.0;
  double get markPriceValue => markPrice ?? 0.0;
  double get liquidationPriceValue => liquidationPrice ?? 0.0;
  double get unrealisedPnlValue => unrealisedPnl ?? 0.0;
  double get realisedPnlValue => realisedPnl ?? 0.0;
  double get leverageValue => leverage ?? 1.0;

  bool get isLong => (side ?? '').toUpperCase() == 'LONG';
  bool get isShort => (side ?? '').toUpperCase() == 'SHORT';
  bool get isOpened => true; // This will be handled by endpoint
  bool get isProfitable => unrealisedPnlValue >= 0;

  DateTime? get createdAtDateTime => createdAt != null
      ? DateTime.fromMillisecondsSinceEpoch(createdAt!)
      : null;
  DateTime? get updatedAtDateTime => updatedAt != null
      ? DateTime.fromMillisecondsSinceEpoch(updatedAt!)
      : null;

  // Calculate price change percentage
  double get priceChangePercentage {
    if (openPriceValue == 0) return 0.0;
    final priceChange = markPriceValue - openPriceValue;
    return (priceChange / openPriceValue) * 100;
  }

  // Calculate return on investment percentage
  double get roiPercentage {
    if (valueValue == 0) return 0.0;
    final roi = (unrealisedPnlValue * 100);
    return double.parse(roi.toStringAsFixed(2));
  }
}
