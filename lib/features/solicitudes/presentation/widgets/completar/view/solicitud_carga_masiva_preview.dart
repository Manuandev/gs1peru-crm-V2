// lib/features/solicitudes/presentation/widgets/completar/view/solicitud_carga_masiva_preview.dart
//
// Banner de error de parseo y vista previa de los participantes importados
// desde el Excel, usados por SolicitudCargaMasivaView.

import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/solicitudes/index_solicitudes.dart';

class BannerError extends StatelessWidget {
  final String mensaje;

  const BannerError({super.key, required this.mensaje});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.error.withAlpha(26),
        border: Border.all(color: AppColors.error),
        borderRadius: BorderRadius.circular(AppSizing.radiusSm),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            AppIcons.warning,
            size: AppSizing.iconSm,
            color: AppColors.error,
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              mensaje,
              style: AppTextStyles.labelSmall.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class VistaPreviaImportacion extends StatelessWidget {
  final List<ParticipanteLocal> participantes;

  const VistaPreviaImportacion({super.key, required this.participantes});

  static const _columnas = [
    'TIPO DOC.',
    'N° DOC.',
    'NOMBRE COMPLETO',
    'CARGO',
    'NACIONALIDAD',
    'CELULAR',
    'CORREO',
  ];

  @override
  Widget build(BuildContext context) {
    final filas = participantes
        .take(3)
        .map(
          (p) => [
            p.tipoDoc,
            p.numDoc,
            p.nombreCompleto,
            p.cargo,
            p.nacionalidad,
            [
              p.celularCodigoTelefono,
              p.celular,
            ].where((s) => s.isNotEmpty).join(' '),
            p.correo,
          ],
        )
        .toList();

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppSizing.radiusMd),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                AppIcons.visibility,
                color: AppColors.primary,
                size: AppSizing.iconMd,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vista previa de importación',
                      style: AppTextStyles.titleSmall.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: AppTextStyles.weightBold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      'Revisa la información antes de subir los participantes.',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              _ChipConteo(count: participantes.length, valido: true),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // Tabla de vista previa
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: _buildTabla(filas),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Nota inferior
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.ui1,
              borderRadius: BorderRadius.circular(AppSizing.radiusSm),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  AppIcons.infoCircle,
                  size: AppSizing.iconSm,
                  color: AppColors.info,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    'Se muestran hasta 3 filas en la vista previa. '
                    'Se importarán ${participantes.length} participante(s) en total — '
                    'las validaciones de campo se agregarán más adelante.',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabla(List<List<String>> filas) {
    return Table(
      border: TableBorder.all(color: AppColors.border, width: 0.5),
      defaultColumnWidth: const IntrinsicColumnWidth(),
      children: [
        TableRow(
          children: _columnas
              .map(
                (col) => CeldaTabla(
                  texto: col,
                  negrita: true,
                  alineacion: TextAlign.center,
                ),
              )
              .toList(),
        ),
        ...filas.map(
          (fila) => TableRow(
            children: fila.map((cel) => CeldaTabla(texto: cel)).toList(),
          ),
        ),
      ],
    );
  }
}

class _ChipConteo extends StatelessWidget {
  final int count;
  final bool valido;

  const _ChipConteo({required this.count, required this.valido});

  @override
  Widget build(BuildContext context) {
    final color = valido ? AppColors.success : AppColors.error;
    final icono = valido ? AppIcons.checkCircle : AppIcons.warning;
    final label = valido ? '$count válidos' : '$count errores';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(AppSizing.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: AppSizing.iconSm, color: color),
          const SizedBox(width: AppSpacing.xxs),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: color,
              fontWeight: AppTextStyles.weightSemiBold,
            ),
          ),
        ],
      ),
    );
  }
}
