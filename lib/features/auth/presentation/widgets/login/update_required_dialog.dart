// lib/features/auth/presentation/widgets/login/update_required_dialog.dart
//
// Diálogo OBLIGATORIO de actualización — se muestra al entrar a Login si
// AppUpdateService().actualizacionPendiente no es null (chequeado una sola
// vez, en SplashBloc). Sin botón de cerrar y sin permitir back/tap-afuera
// (pedido de negocio) — la única salida es completar la descarga e
// instalación. Ver auth/CLAUDE.md.

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:app_crm/core/index_core.dart';

enum _EstadoActualizacion { idle, descargando, permisoRequerido, error }

/// Muestra el diálogo obligatorio — helper único, no dejar que cada caller
/// arme su propio showDialog/PopScope. La instalación de .apk vía
/// REQUEST_INSTALL_PACKAGES es exclusiva de Android — no-op en cualquier
/// otra plataforma.
///
/// [titulo]/[mensaje] permiten un texto distinto según el contexto que
/// bloquea (ej. Login: "no se puede iniciar sesión..." en vez del genérico
/// de entrada a la pantalla) — si se omiten, usa los mensajes por defecto.
Future<void> mostrarDialogoActualizacionObligatoria(
  BuildContext context,
  UpdateInfo info, {
  String? titulo,
  String? mensaje,
}) {
  if (!Platform.isAndroid) return Future.value();
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => PopScope(
      canPop: false,
      child: UpdateRequiredDialog(info: info, titulo: titulo, mensaje: mensaje),
    ),
  );
}

class UpdateRequiredDialog extends StatefulWidget {
  final UpdateInfo info;
  final String? titulo;
  final String? mensaje;

  const UpdateRequiredDialog({
    super.key,
    required this.info,
    this.titulo,
    this.mensaje,
  });

  @override
  State<UpdateRequiredDialog> createState() => _UpdateRequiredDialogState();
}

class _UpdateRequiredDialogState extends State<UpdateRequiredDialog> {
  _EstadoActualizacion _estado = _EstadoActualizacion.idle;
  double _progreso = 0;

  Future<void> _actualizar() async {
    setState(() {
      _estado = _EstadoActualizacion.descargando;
      _progreso = 0;
    });

    try {
      final dir = await getApplicationDocumentsDirectory();
      // Nombre fijo — cada actualización sobreescribe la anterior, no hace
      // falta acumular versiones viejas del instalador en disco.
      final savePath = '${dir.path}/actualizacion_gs1crm.apk';

      await Dio().download(
        widget.info.downloadUrl,
        savePath,
        onReceiveProgress: (received, total) {
          if (total > 0 && mounted) {
            setState(() => _progreso = received / total);
          }
        },
      );
      if (!mounted) return;

      // Android 8+ exige este permiso especial (se habilita a mano en
      // Ajustes) antes de poder instalar un APK fuera de Play Store.
      var permiso = await Permission.requestInstallPackages.status;
      if (!permiso.isGranted) {
        permiso = await Permission.requestInstallPackages.request();
      }
      if (!permiso.isGranted) {
        if (!mounted) return;
        setState(() => _estado = _EstadoActualizacion.permisoRequerido);
        return;
      }

      await OpenFilex.open(savePath);
      if (!mounted) return;
      setState(() => _estado = _EstadoActualizacion.idle);
    } catch (_) {
      if (!mounted) return;
      setState(() => _estado = _EstadoActualizacion.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final descargando = _estado == _EstadoActualizacion.descargando;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizing.radiusXl),
      ),
      elevation: AppSizing.elevationHigh,
      child: Container(
        constraints: const BoxConstraints(maxWidth: AppSizing.maxWidthForm),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizing.radiusXl),
          color: colorScheme.surface,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppSizing.radiusXl),
                ),
              ),
              child: Icon(
                AppIcons.download,
                size: AppSizing.iconXl,
                color: AppColors.textOnDark,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.titulo ?? 'Actualización disponible',
                    style: AppTextStyles.titleLarge.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: AppTextStyles.weightBold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    _mensaje(),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  if (descargando) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppSizing.radiusSm),
                      child: LinearProgressIndicator(
                        value: _progreso > 0 ? _progreso : null,
                        minHeight: AppSizing.spinnerStrokeLarge,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Descargando... ${(_progreso * 100).toStringAsFixed(0)}%',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],

                  SizedBox(
                    width: double.infinity,
                    child: CustomPrimaryButton(
                      text: _estado == _EstadoActualizacion.permisoRequerido
                          ? 'Reintentar'
                          : 'Actualizar ahora',
                      icon: AppIcons.download,
                      isLoading: descargando,
                      onPressed: descargando ? null : _actualizar,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _mensaje() {
    switch (_estado) {
      case _EstadoActualizacion.permisoRequerido:
        return 'Para instalar la actualización, habilita "Instalar apps '
            'desconocidas" para esta aplicación en los ajustes de tu '
            'dispositivo y presiona Reintentar.';
      case _EstadoActualizacion.error:
        return 'No se pudo descargar la actualización. Verifica tu '
            'conexión a internet e intenta nuevamente.';
      case _EstadoActualizacion.descargando:
      case _EstadoActualizacion.idle:
        return widget.mensaje ??
            'Esta versión de la aplicación ya no está actualizada. Por '
                'tu seguridad y para seguir operando sin problemas, es '
                'necesario actualizar a la última versión disponible antes '
                'de continuar.';
    }
  }
}
