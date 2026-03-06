// lib/features/settings/presentation/bloc/settings/settings_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(const SettingsState());

  // Permisos que maneja esta pantalla
  static const _permisos = [
    Permission.location,
    Permission.camera,
    Permission.microphone,
    Permission.notification,
  ];

  /// Consulta el estado actual de todos los permisos
  Future<void> checkPermissions() async {
    emit(state.copyWith(isLoading: true));

    final results = <Permission, PermissionStatus>{};
    for (final p in _permisos) {
      results[p] = await p.status;
    }

    emit(state.copyWith(permissions: results, isLoading: false));
  }

  /// Solicita un permiso o abre ajustes si está bloqueado
  Future<void> requestPermission(Permission permission) async {
    final current = state.permissions[permission];

    // Bloqueado permanentemente → abrir ajustes del sistema
    if (current == PermissionStatus.permanentlyDenied ||
        current == PermissionStatus.restricted) {
      await openAppSettings();
      // Espera a que el usuario regrese de ajustes
      await Future.delayed(const Duration(milliseconds: 500));
      await checkPermissions();
      return;
    }

    // Pedir permiso normalmente
    final result = await permission.request();
    final updated = Map<Permission, PermissionStatus>.from(state.permissions);
    updated[permission] = result;
    emit(state.copyWith(permissions: updated));
  }
}