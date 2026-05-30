// lib/features/auth/domain/entities/session_entity.dart

enum LoginType { credentials, google }

class SessionEntity {
  final LoginType loginType;
  final String? username;    // solo si loginType = credentials
  final String? password;    // solo si loginType = credentials
  final String? email;       // solo si loginType = google
  final DateTime expiresAt;
  final bool rememberMe;

  const SessionEntity({
    required this.loginType,
    required this.expiresAt,
    this.rememberMe = false,
    this.username,
    this.password,
    this.email,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  bool get isGoogle => loginType == LoginType.google;
}