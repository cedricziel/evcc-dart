/// General models.
library;

/// System state.
class SystemState {
  /// The complete state of the system.
  final Map<String, dynamic> data;

  /// Creates a new system state.
  SystemState(this.data);

  /// Creates a system state from JSON.
  factory SystemState.fromJson(Map<String, dynamic> json) {
    return SystemState(json);
  }
}
