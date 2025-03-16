/// Authentication-related models.
library;

/// Change password request.
class ChangePassword {
  /// Current password.
  final String current;

  /// New password.
  final String newPassword;

  /// Creates a new change password request.
  ChangePassword({required this.current, required this.newPassword});

  /// Converts the model to JSON.
  Map<String, dynamic> toJson() => {'current': current, 'new': newPassword};
}
