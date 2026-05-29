// lib/features/auth/data/models/session_model.dart


import 'package:app_crm/features/auth/index_auth.dart';

class SessionModel {
  final LoginType loginType;
  final String? username;
  final String? password;
  final String? email;
  final DateTime expiresAt;
  final bool rememberMe;

  const SessionModel({
    required this.loginType,
    required this.expiresAt, 
    this.rememberMe = false,
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
      rememberMe: (map['remember_me'] as int?) == 1,
    );
  }

  Map<String, dynamic> toMap() => {
        'login_type': loginType == LoginType.google ? 'google' : 'credentials',
        'username':   username,
        'password':   password,
        'email':      email,
        'expires_at': expiresAt.toIso8601String(),
        'remember_me': rememberMe ? 1 : 0,
      };

  SessionEntity toEntity() => SessionEntity(
        loginType: loginType,
        username:  username,
        password:  password,
        email:     email,
        expiresAt: expiresAt,
        rememberMe: rememberMe,
      );
}