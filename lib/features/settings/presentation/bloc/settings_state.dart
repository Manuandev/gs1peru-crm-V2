// lib/features/settings/presentation/bloc/settings_state.dart

import 'package:app_crm/index_dependencies.dart';

class SettingsState extends Equatable {
  final Map<Permission, PermissionStatus> permissions;
  final bool isLoading;

  const SettingsState({
    this.permissions = const {},
    this.isLoading = false,
  });

  SettingsState copyWith({
    Map<Permission, PermissionStatus>? permissions,
    bool? isLoading,
  }) {
    return SettingsState(
      permissions: permissions ?? this.permissions,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [permissions, isLoading];
}