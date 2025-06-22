import 'package:json_annotation/json_annotation.dart';

part 'position_models.g.dart';

@JsonSerializable()
class PositionsResponse {
  final String status;
  final List<Position> data;

  const PositionsResponse({required this.status, required this.data});

  factory PositionsResponse.fromJson(Map<String, dynamic> json) =>
      _$PositionsResponseFromJson(json);
  Map<String, dynamic> toJson() => _$PositionsResponseToJson(this);
}

@JsonSerializable()
class Position {
  final int id;
  final int accountId;
  final String market;
  final String status;
  final String side;
  final String leverage;
  final String size;
  final String value;
  final String openPrice;
  final String markPrice;
  final String liquidationPrice;
  final String margin;
  final String unrealisedPnl;
  final String realisedPnl;
  final int adl;
  final int createdAt;
  final int updatedAt;

  const Position({
    required this.id,
    required this.accountId,
    required this.market,
    required this.status,
    required this.side,
    required this.leverage,
    required this.size,
    required this.value,
    required this.openPrice,
    required this.markPrice,
    required this.liquidationPrice,
    required this.margin,
    required this.unrealisedPnl,
    required this.realisedPnl,
    required this.adl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Position.fromJson(Map<String, dynamic> json) =>
      _$PositionFromJson(json);
  Map<String, dynamic> toJson() => _$PositionToJson(this);

  // Computed properties for easier UI use
  double get sizeValue => double.tryParse(size) ?? 0.0;
  double get valueValue => double.tryParse(value) ?? 0.0;
  double get openPriceValue => double.tryParse(openPrice) ?? 0.0;
  double get markPriceValue => double.tryParse(markPrice) ?? 0.0;
  double get liquidationPriceValue => double.tryParse(liquidationPrice) ?? 0.0;
  double get marginValue => double.tryParse(margin) ?? 0.0;
  double get unrealisedPnlValue => double.tryParse(unrealisedPnl) ?? 0.0;
  double get realisedPnlValue => double.tryParse(realisedPnl) ?? 0.0;
  double get leverageValue => double.tryParse(leverage) ?? 1.0;

  bool get isLong => side.toUpperCase() == 'LONG';
  bool get isShort => side.toUpperCase() == 'SHORT';
  bool get isOpened => status.toUpperCase() == 'OPENED';
  bool get isProfitable => unrealisedPnlValue >= 0;

  DateTime get createdAtDateTime =>
      DateTime.fromMillisecondsSinceEpoch(createdAt);
  DateTime get updatedAtDateTime =>
      DateTime.fromMillisecondsSinceEpoch(updatedAt);

  // Calculate price change percentage
  double get priceChangePercentage {
    if (openPriceValue == 0) return 0.0;
    final priceChange = markPriceValue - openPriceValue;
    return (priceChange / openPriceValue) * 100;
  }

  // Calculate return on investment percentage
  double get roiPercentage {
    if (marginValue == 0) return 0.0;
    final roi = (unrealisedPnlValue * 100);
    return double.parse(roi.toStringAsFixed(2));
  }
}
