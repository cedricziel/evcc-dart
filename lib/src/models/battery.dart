/// Home Battery-related models.
library;

/// Battery state.
class BatteryState {
  /// Battery SoC in %.
  final num soc;

  /// Buffer SoC in %.
  final num? bufferSoc;

  /// Buffer start SoC in %.
  final num? bufferStartSoc;

  /// Priority SoC in %.
  final num? prioritySoc;

  /// Grid charge limit.
  final num? gridChargeLimit;

  /// Creates a new battery state.
  BatteryState({
    required this.soc,
    this.bufferSoc,
    this.bufferStartSoc,
    this.prioritySoc,
    this.gridChargeLimit,
  });

  /// Creates a battery state from JSON.
  factory BatteryState.fromJson(Map<String, dynamic> json) {
    return BatteryState(
      soc: json['soc'] as num,
      bufferSoc: json['bufferSoc'] as num?,
      bufferStartSoc: json['bufferStartSoc'] as num?,
      prioritySoc: json['prioritySoc'] as num?,
      gridChargeLimit: json['gridChargeLimit'] as num?,
    );
  }
}
