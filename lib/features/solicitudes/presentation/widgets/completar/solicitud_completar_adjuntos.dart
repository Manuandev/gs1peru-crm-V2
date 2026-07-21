// lib/features/solicitudes/presentation/widgets/completar/solicitud_completar_adjuntos.dart
//
// Botón de adjuntar archivo (voucher / O-C) + tarjeta de archivo adjunto,
// usados por SolicitudCompletarView (paso 1).

import 'package:flutter/material.dart';

import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/core/index_core.dart';

class BotonAdjuntar extends StatelessWidget {
  final String label;
  final PlatformFile? archivo;
  // Nombre de un archivo de este tipo ya guardado en el backend (viene de
  // getSolicitudDetalle() al reabrir la solicitud) — no hay bytes locales,
  // solo el nombre. Se ignora si `archivo` ya tiene algo (el adjunto de
  // esta sesión manda sobre el ya guardado). "Quitar" en este caso no
  // borra nada del backend — solo limpia la referencia para poder elegir
  // uno nuevo, que al guardar reemplaza al anterior (ver
  // solicitud_completar_view.dart._quitarArchivo).
  final String nombreExistente;
  final bool habilitado;
  final VoidCallback onAdjuntar;
  final VoidCallback onQuitar;

  const BotonAdjuntar({
    super.key,
    required this.label,
    required this.archivo,
    this.nombreExistente = '',
    required this.habilitado,
    required this.onAdjuntar,
    required this.onQuitar,
  });

  @override
  Widget build(BuildContext context) {
    final nombreMostrado = archivo?.name ?? nombreExistente;
    final tieneArchivo = nombreMostrado.isNotEmpty;

    if (tieneArchivo) {
      return TarjetaArchivoAdjunto(
        nombre: nombreMostrado,
        onQuitar: habilitado ? onQuitar : null,
      );
    }

    // SizedBox + tapTargetSize.shrinkWrap fuerzan el alto exacto — sin esto
    // el botón queda más alto que buttonHeightCompact (32px) porque Material
    // reserva un área de toque mínima de 48px aunque `minimumSize` diga otra
    // cosa, y termina más grande que TarjetaArchivoAdjunto de arriba (mismo
    // slot, un archivo adjuntado reemplaza al botón, ver build()).
    return SizedBox(
      height: AppSizing.buttonHeightCompact,
      child: OutlinedButton.icon(
        onPressed: habilitado ? onAdjuntar : null,
        icon: const Icon(
          Icons.attach_file_rounded,
          size: AppSizing.iconActionSm,
        ),
        label: Text(label, overflow: TextOverflow.ellipsis),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizing.radiusSm),
          ),
          textStyle: AppTextStyles.labelMedium.copyWith(
            fontWeight: AppTextStyles.weightMedium,
          ),
        ),
      ),
    );
  }
}

// ── Tarjeta de archivo adjunto (PDF) con opción de quitar ─────────────────────

class TarjetaArchivoAdjunto extends StatelessWidget {
  final String nombre;
  final VoidCallback? onQuitar;

  const TarjetaArchivoAdjunto({
    super.key,
    required this.nombre,
    required this.onQuitar,
  });

  bool get _esPdf => nombre.toLowerCase().endsWith('.pdf');

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizing.buttonHeightCompact,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSizing.radiusSm),
        border: Border.all(color: AppColors.success),
      ),
      child: Row(
        children: [
          Icon(
            _esPdf ? AppIcons.pdf : AppIcons.image,
            color: AppColors.success,
            size: AppSizing.iconActionSm,
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              nombre,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
          if (onQuitar != null)
            GestureDetector(
              onTap: onQuitar,
              child: const Icon(
                AppIcons.close,
                size: AppSizing.iconSm,
                color: AppColors.error,
              ),
            ),
        ],
      ),
    );
  }
}
