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
            minimumSize: const Size.fromHeight(AppSizing.buttonHeight),
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

// Mismo tamaño/estilo que el botón de "Descargar plantilla Excel" (paso 1) —
// pedido explícito de negocio, el área de carga anterior (caja punteada
// grande) quedaba demasiado grande frente a ese botón. Con archivo
// seleccionado, el mismo botón muestra el nombre + un ícono de eliminar al
// lado, en vez de un bloque aparte.
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
    final color = tieneArchivo ? AppColors.success : AppColors.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: tieneArchivo ? null : onSeleccionar,
        borderRadius: BorderRadius.circular(AppSizing.radiusMd),
        child: Container(
          width: double.infinity,
          height: AppSizing.buttonHeight,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            border: Border.all(color: color),
            borderRadius: BorderRadius.circular(AppSizing.radiusMd),
          ),
          child: Row(
            children: [
              Icon(
                tieneArchivo ? AppIcons.fileExcel : AppIcons.attach,
                size: AppSizing.iconActionSm,
                color: color,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  tieneArchivo
                      ? archivo!.name
                      : 'Selecciona el archivo Excel aquí',
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: color,
                    fontWeight: AppTextStyles.weightSemiBold,
                  ),
                ),
              ),
              if (tieneArchivo) ...[
                const SizedBox(width: AppSpacing.xs),
                InkWell(
                  onTap: onQuitar,
                  borderRadius: BorderRadius.circular(
                    AppSizing.radiusCircular,
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(AppSpacing.xxs),
                    child: Icon(
                      AppIcons.delete,
                      size: AppSizing.iconActionSm,
                      color: AppColors.error,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
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
