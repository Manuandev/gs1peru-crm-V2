// lib/features/solicitudes/presentation/widgets/completar/view/solicitud_carga_masiva_pasos.dart
//
// Los 3 pasos numerados de SolicitudCargaMasivaView (descargar plantilla,
// tabla de ejemplo, área de carga del archivo) + la celda genérica de tabla
// que también reusa la vista previa de importación.

import 'package:flutter/material.dart';

import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/core/index_core.dart';

class PasoSection extends StatelessWidget {
  final int numero;
  final String titulo;
  final String descripcion;
  final Widget contenido;

  const PasoSection({
    super.key,
    required this.numero,
    required this.titulo,
    required this.descripcion,
    required this.contenido,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$numero',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textOnDark,
                fontWeight: AppTextStyles.weightBold,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: AppTextStyles.titleSmall.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: AppTextStyles.weightBold,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                descripcion,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              contenido,
            ],
          ),
        ),
      ],
    );
  }
}

// ── Paso 1: Descargar plantilla ───────────────────────────────────────────────

class ContenidoPaso1 extends StatelessWidget {
  final bool descargando;
  final VoidCallback onDescargar;

  const ContenidoPaso1({
    super.key,
    required this.descargando,
    required this.onDescargar,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OutlinedButton.icon(
          onPressed: descargando ? null : onDescargar,
          icon: descargando
              ? const SizedBox(
                  width: AppSizing.iconActionSm,
                  height: AppSizing.iconActionSm,
                  child: CircularProgressIndicator(
                    strokeWidth: AppSizing.spinnerStrokeSmall,
                  ),
                )
              : const Icon(AppIcons.download, size: AppSizing.iconActionSm),
          label: Text(
            descargando ? 'Descargando...' : 'Descargar plantilla Excel',
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizing.radiusMd),
            ),
            textStyle: AppTextStyles.labelSmall.copyWith(
              fontWeight: AppTextStyles.weightSemiBold,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Paso 2: Tabla de ejemplo ──────────────────────────────────────────────────

class ContenidoPaso2 extends StatelessWidget {
  const ContenidoPaso2({super.key});

  static const _columnas = [
    'TIPO\nDOC.',
    'N° DOC.',
    'NACIONAL.',
    'NOMBRES',
    'AP.\nPATERNO',
    'AP.\nMATERNO',
    'EMAIL',
    'PAÍS',
    'TELÉFONO',
    'PART.',
  ];

  static const _filas = [
    [
      'DNI',
      '29383293',
      'PERUANA',
      'MIGUEL',
      'CÁCERES',
      'MÉNDEZ',
      'mcaceres@gmail.com',
      'Perú',
      '5037613284',
      'SI',
    ],
    [
      'CARNET',
      '29934323',
      'BRASILEÑA',
      'JOAO',
      'ROQUE',
      'VARGAS',
      'joao.roque@gmail.com',
      'Brasil',
      '50379150391',
      'SI',
    ],
    [
      'DNI',
      '29043223',
      'PERUANA',
      'KARLA',
      'MARIA',
      'CONTRERAS',
      'karlomaria@gmail.com',
      'Perú',
      '50377269772',
      'SI',
    ],
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: _buildTabla(),
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: AppColors.importacionObligatoria,
                border: Border.all(color: AppColors.border),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              'Campos obligatorios',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTabla() {
    return Table(
      border: TableBorder.all(color: AppColors.border, width: 0.5),
      defaultColumnWidth: const IntrinsicColumnWidth(),
      children: [
        TableRow(
          decoration: const BoxDecoration(
            color: AppColors.importacionObligatoria,
          ),
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
        ..._filas.map(
          (fila) => TableRow(
            children: fila.map((cel) => CeldaTabla(texto: cel)).toList(),
          ),
        ),
      ],
    );
  }
}

// ── Paso 3: Área de carga ─────────────────────────────────────────────────────

class ContenidoPaso3 extends StatelessWidget {
  final PlatformFile? archivo;
  final VoidCallback onArchivoSeleccionado;
  final VoidCallback onArchivoQuitado;

  const ContenidoPaso3({
    super.key,
    required this.archivo,
    required this.onArchivoSeleccionado,
    required this.onArchivoQuitado,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _AreaCarga(
          archivo: archivo,
          onSeleccionar: onArchivoSeleccionado,
          onQuitar: onArchivoQuitado,
        ),
        const SizedBox(height: AppSpacing.xs),
        Center(
          child: Text(
            'Formato permitido: .xlsx, .xls, .xlsm (Máx. 10 MB)',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _AreaCarga extends StatelessWidget {
  final PlatformFile? archivo;
  final VoidCallback onSeleccionar;
  final VoidCallback onQuitar;

  const _AreaCarga({
    required this.archivo,
    required this.onSeleccionar,
    required this.onQuitar,
  });

  @override
  Widget build(BuildContext context) {
    final tieneArchivo = archivo != null;

    return CustomPaint(
      painter: _DashedBorderPainter(
        color: AppColors.primary,
        borderRadius: AppSizing.radiusMd,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.lg,
        ),
        decoration: BoxDecoration(
          color: AppColors.primaryWithOpacity(0.04),
          borderRadius: BorderRadius.circular(AppSizing.radiusMd),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              tieneArchivo ? AppIcons.fileExcel : AppIcons.upload,
              size: AppSizing.iconXl,
              color: tieneArchivo ? AppColors.success : AppColors.primary,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              tieneArchivo
                  ? archivo!.name
                  : 'Arrastra y suelta el archivo aquí',
              textAlign: TextAlign.center,
              style: AppTextStyles.titleSmall.copyWith(
                color: tieneArchivo ? AppColors.success : AppColors.primary,
                fontWeight: AppTextStyles.weightSemiBold,
              ),
            ),
            if (!tieneArchivo) ...[
              const SizedBox(height: AppSpacing.xxs),
              Text(
                'o selecciona el archivo desde tu dispositivo',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            OutlinedButton.icon(
              onPressed: tieneArchivo ? onQuitar : onSeleccionar,
              icon: Icon(
                tieneArchivo ? AppIcons.close : AppIcons.attach,
                size: AppSizing.iconActionSm,
              ),
              label: Text(
                tieneArchivo ? 'Quitar archivo' : 'Adjuntar archivo Excel',
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: tieneArchivo
                    ? AppColors.error
                    : AppColors.primary,
                side: BorderSide(
                  color: tieneArchivo ? AppColors.error : AppColors.primary,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizing.radiusMd),
                ),
                textStyle: AppTextStyles.labelSmall.copyWith(
                  fontWeight: AppTextStyles.weightSemiBold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Borde a trazos para el área de carga ─────────────────────────────────────

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double borderRadius;

  const _DashedBorderPainter({required this.color, required this.borderRadius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0.75, 0.75, size.width - 1.5, size.height - 1.5),
      Radius.circular(borderRadius),
    );

    final path = Path()..addRRect(rrect);
    canvas.drawPath(_buildDashPath(path, 6.0, 4.0), paint);
  }

  Path _buildDashPath(Path source, double dashLen, double gapLen) {
    final result = Path();
    for (final metric in source.computeMetrics()) {
      double d = 0;
      bool draw = true;
      while (d < metric.length) {
        final step = draw ? dashLen : gapLen;
        final end = d + step;
        if (draw) {
          result.addPath(
            metric.extractPath(d, end < metric.length ? end : metric.length),
            Offset.zero,
          );
        }
        d += step;
        draw = !draw;
      }
    }
    return result;
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter old) =>
      old.color != color || old.borderRadius != borderRadius;
}

// ── Celda genérica de tabla ───────────────────────────────────────────────────
//
// También la reusa SolicitudCargaMasivaPreview (vista previa de importación).

class CeldaTabla extends StatelessWidget {
  final String texto;
  final bool negrita;
  final TextAlign alineacion;

  const CeldaTabla({
    super.key,
    required this.texto,
    this.negrita = false,
    this.alineacion = TextAlign.left,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      child: Text(
        texto,
        textAlign: alineacion,
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.textPrimary,
          fontWeight: negrita
              ? AppTextStyles.weightSemiBold
              : AppTextStyles.weightRegular,
        ),
      ),
    );
  }
}
