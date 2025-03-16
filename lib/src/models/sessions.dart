/// Sessions-related models.
library;

/// Charging session.
class ChargingSession {
  /// Session ID.
  final String id;

  /// Created timestamp.
  final DateTime created;

  /// Finished timestamp.
  final DateTime? finished;

  /// Loadpoint name.
  final String loadpoint;

  /// Vehicle name.
  final String? vehicle;

  /// Vehicle odometer reading in kilometers.
  final num? odometer;

  /// Meter reading at start of charging session.
  final num? meterStart;

  /// Meter reading at end of charging session.
  final num? meterStop;

  /// Charged energy in kWh.
  final num chargedEnergy;

  /// Duration of active charging.
  final num chargeDuration;

  /// Solar percentage of the session.
  final num solarPercentage;

  /// Total price of the session.
  final num? price;

  /// Average price per kWh.
  final num? pricePerKWh;

  /// Average CO₂ emissions per kWh.
  final num? co2PerKWh;

  /// Creates a new charging session.
  ChargingSession({
    required this.id,
    required this.created,
    this.finished,
    required this.loadpoint,
    this.vehicle,
    this.odometer,
    this.meterStart,
    this.meterStop,
    required this.chargedEnergy,
    required this.chargeDuration,
    required this.solarPercentage,
    this.price,
    this.pricePerKWh,
    this.co2PerKWh,
  });

  /// Creates a charging session from JSON.
  factory ChargingSession.fromJson(Map<String, dynamic> json) {
    return ChargingSession(
      id: json['id'].toString(),
      created: DateTime.parse(json['created'] as String),
      finished:
          json['finished'] != null
              ? DateTime.parse(json['finished'] as String)
              : null,
      loadpoint: json['loadpoint'] as String,
      vehicle: json['vehicle'] as String?,
      odometer: json['odometer'] as num?,
      meterStart: json['meterStart'] as num?,
      meterStop: json['meterStop'] as num?,
      chargedEnergy: json['chargedEnergy'] as num,
      chargeDuration: json['chargeDuration'] as num,
      solarPercentage: json['solarPercentage'] as num,
      price: json['price'] as num?,
      pricePerKWh: json['pricePerKWh'] as num?,
      co2PerKWh: json['co2PerKWh'] as num?,
    );
  }
}
