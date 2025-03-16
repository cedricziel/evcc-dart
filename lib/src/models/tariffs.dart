/// Tariffs-related models.
library;

/// Tariff rate.
class TariffRate {
  /// Start time.
  final DateTime start;

  /// End time.
  final DateTime end;

  /// Price or emission value.
  final num price;

  /// Creates a new tariff rate.
  TariffRate({required this.start, required this.end, required this.price});

  /// Creates a tariff rate from JSON.
  factory TariffRate.fromJson(Map<String, dynamic> json) {
    return TariffRate(
      start: DateTime.parse(json['start'] as String),
      end: DateTime.parse(json['end'] as String),
      price: json['price'] as num,
    );
  }
}

/// Tariff type.
enum TariffType {
  /// Grid tariff.
  grid,

  /// Feed-in tariff.
  feedin,

  /// CO2 tariff.
  co2,

  /// Planner tariff.
  planner,
}
