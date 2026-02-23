// lib/features/auth/data/models/session_model.dart

import 'package:app_crm/features/auth/domain/entities/session_entity.dart';

class SessionModel {
  final LoginType loginType;
  final String? username;
  final String? password;
  final String? email;
  final DateTime expiresAt;

  const SessionModel({
    required this.loginType,
    required this.expiresAt, 
    this.username,
    this.password,
    this.email,
  });

  factory SessionModel.fromMap(Map<String, dynamic> map) {
    return SessionModel(
      loginType: map['login_type'] == 'google'
          ? LoginType.google
          : LoginType.credentials,
      username:  map['username'] as String?,
      password:  map['password'] as String?,
      email:     map['email'] as String?,
      expiresAt: DateTime.parse(map['expires_at'] as String),
    );
  }

  Map<String, dynamic> toMap() => {
        'login_type': loginType == LoginType.google ? 'google' : 'credentials',
        'username':   username,
        'password':   password,
        'email':      email,
        'expires_at': expiresAt.toIso8601String(),
      };

  SessionEntity toEntity() => SessionEntity(
        loginType: loginType,
        username:  username,
        password:  password,
        email:     email,
        expiresAt: expiresAt,
      );
}