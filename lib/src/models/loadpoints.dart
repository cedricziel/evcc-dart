/// Loadpoints-related models.
library;

/// Charging mode.
enum ChargingMode {
  /// Off mode.
  off,

  /// Now mode.
  now,

  /// Min PV mode.
  minpv,

  /// PV mode.
  pv,
}

/// Charging rate.
class ChargingRate {
  /// Start time.
  final DateTime start;

  /// End time.
  final DateTime end;

  /// Price.
  final num price;

  /// Creates a new charging rate.
  ChargingRate({required this.start, required this.end, required this.price});

  /// Creates a charging rate from JSON.
  factory ChargingRate.fromJson(Map<String, dynamic> json) {
    return ChargingRate(
      start: DateTime.parse(json['start'] as String),
      end: DateTime.parse(json['end'] as String),
      price: json['price'] as num,
    );
  }
}

/// Charging plan.
class ChargingPlan {
  /// Plan ID.
  final int planId;

  /// Duration in seconds.
  final int? duration;

  /// Plan rates.
  final List<ChargingRate>? rates;

  /// Plan time.
  final DateTime? planTime;

  /// Power in watts.
  final num? power;

  /// Creates a new charging plan.
  ChargingPlan({
    required this.planId,
    this.duration,
    this.rates,
    this.planTime,
    this.power,
  });

  /// Creates a charging plan from JSON.
  factory ChargingPlan.fromJson(Map<String, dynamic> json) {
    return ChargingPlan(
      planId: json['planId'] as int,
      duration: json['duration'] as int?,
      rates:
          json['plan'] != null
              ? (json['plan'] as List<dynamic>)
                  .map((e) => ChargingRate.fromJson(e as Map<String, dynamic>))
                  .toList()
              : null,
      planTime:
          json['planTime'] != null
              ? DateTime.parse(json['planTime'] as String)
              : null,
      power: json['power'] as num?,
    );
  }
}

/// Vehicle title.
class VehicleTitle {
  /// Vehicle title.
  final String title;

  /// Creates a new vehicle title.
  VehicleTitle({required this.title});

  /// Creates a vehicle title from JSON.
  factory VehicleTitle.fromJson(Map<String, dynamic> json) {
    return VehicleTitle(title: json['vehicle'] as String);
  }
}
