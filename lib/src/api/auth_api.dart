import '../client.dart';

/// Interface for Auth API endpoints.
abstract class AuthApi {
  /// Login with password.
  ///
  /// Returns an auth cookie required for all protected endpoints.
  Future<void> login(String password);

  /// Logout.
  ///
  /// Deletes the authorization cookie.
  Future<void> logout();

  /// Change admin password.
  Future<void> changePassword(String currentPassword, String newPassword);

  /// Get authentication status.
  ///
  /// Returns whether the current user is logged in.
  Future<bool> getStatus();
}

/// Implementation of the Auth API.
class AuthApiImpl implements AuthApi {
  final EvccClient _client;

  /// Creates a new Auth API implementation.
  AuthApiImpl(this._client);

  @override
  Future<void> login(String password) async {
    await _client.post<Map<String, dynamic>>(
      '/auth/login',
      body: {'password': password},
      includeAuth: false,
    );

    // Note: In a real implementation, we would extract the auth cookie
    // from the response headers and set it in the client
    // This is just a placeholder implementation
  }

  @override
  Future<void> logout() async {
    await _client.post<void>('/auth/logout');
    // Note: In a real implementation, we would clear the auth cookie
    // This is just a placeholder implementation
  }

  @override
  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    await _client.put<void>(
      '/auth/password',
      body: {'current': currentPassword, 'new': newPassword},
    );
  }

  @override
  Future<bool> getStatus() async {
    final result = await _client.get<String>(
      '/auth/status',
      converter: (json) => json.toString(),
    );
    return result == 'true';
  }
}
