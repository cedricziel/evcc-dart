/// Vehicles-related models.
library;

/// Repeating plan.
class RepeatingPlan {
  /// Whether the plan is active.
  final bool active;

  /// Target SoC in %.
  final num soc;

  /// Time in HH:MM format.
  final String time;

  /// Timezone in IANA format.
  final String tz;

  /// Weekdays (0: Sunday, 1: Monday, etc.).
  final List<int> weekdays;

  /// Creates a new repeating plan.
  RepeatingPlan({
    required this.active,
    required this.soc,
    required this.time,
    required this.tz,
    required this.weekdays,
  });

  /// Creates a repeating plan from JSON.
  factory RepeatingPlan.fromJson(Map<String, dynamic> json) {
    return RepeatingPlan(
      active: json['active'] as bool,
      soc: json['soc'] as num,
      time: json['time'] as String,
      tz: json['tz'] as String,
      weekdays:
          (json['weekdays'] as List<dynamic>).map((e) => e as int).toList(),
    );
  }

  /// Converts the model to JSON.
  Map<String, dynamic> toJson() => {
    'active': active,
    'soc': soc,
    'time': time,
    'tz': tz,
    'weekdays': weekdays,
  };
}

/// Repeating plans.
class RepeatingPlans {
  /// List of repeating plans.
  final List<RepeatingPlan> plans;

  /// Creates a new repeating plans.
  RepeatingPlans({required this.plans});

  /// Creates repeating plans from JSON.
  factory RepeatingPlans.fromJson(Map<String, dynamic> json) {
    return RepeatingPlans(
      plans:
          (json['plans'] as List<dynamic>)
              .map((e) => RepeatingPlan.fromJson(e as Map<String, dynamic>))
              .toList(),
    );
  }

  /// Converts the model to JSON.
  Map<String, dynamic> toJson() => {
    'plans': plans.map((e) => e.toJson()).toList(),
  };
}

/// Static SoC plan.
class StaticSocPlan {
  /// Target SoC in %.
  final num soc;

  /// Target time.
  final DateTime time;

  /// Creates a new static SoC plan.
  StaticSocPlan({required this.soc, required this.time});

  /// Creates a static SoC plan from JSON.
  factory StaticSocPlan.fromJson(Map<String, dynamic> json) {
    return StaticSocPlan(
      soc: json['soc'] as num,
      time: DateTime.parse(json['time'] as String),
    );
  }
}
