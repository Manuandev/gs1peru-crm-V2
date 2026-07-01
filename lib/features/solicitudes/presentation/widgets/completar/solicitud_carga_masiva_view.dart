// lib/features/solicitudes/presentation/widgets/completar/solicitud_carga_masiva_view.dart

import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/features/solicitudes/index_solicitudes.dart';

class SolicitudCargaMasivaView extends StatefulWidget {
  const SolicitudCargaMasivaView({super.key});

  @override
  State<SolicitudCargaMasivaView> createState() =>
      _SolicitudCargaMasivaViewState();
}

class _SolicitudCargaMasivaViewState extends State<SolicitudCargaMasivaView> {
  bool _archivoSeleccionado = false;

  void _seleccionarArchivo() {
    setState(() => _archivoSeleccionado = true);
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      onPop: () => context.goBack(),
      drawerSide: DrawerSide.none,
      bodyPadding: EdgeInsets.zero,
      title: 'Carga masiva de participantes',
      appBarLeadingButtons: [
        IconButton(
          onPressed: () => context.goBack(),
          icon: Icon(
            AppIcons.back,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      ],
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PasoSection(
                    numero: 1,
                    titulo: 'Descarga la plantilla',
                    descripcion:
                        'Descarga la plantilla Excel en blanco y completa la información requerida.',
                    contenido: const _ContenidoPaso1(),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const _PasoSection(
                    numero: 2,
                    titulo: 'Completa la plantilla',
                    descripcion:
                        'Los campos obligatorios son las columnas sombreadas en amarillo.',
                    contenido: _ContenidoPaso2(),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _PasoSection(
                    numero: 3,
                    titulo: 'Carga los participantes',
                    descripcion:
                        'Adjunta el archivo Excel completado para importar los participantes.',
                    contenido: _ContenidoPaso3(
                      onArchivoSeleccionado: _seleccionarArchivo,
                    ),
                  ),
                  if (_archivoSeleccionado) ...[
                    const SizedBox(height: AppSpacing.lg),
                    const _VistaPreviaImportacion(),
                  ],
                ],
              ),
            ),
          ),

          // ── Botones pie ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                Expanded(
                  child: SolicitudBotonAtras(
                    label: 'Cancelar',
                    onPressed: () => context.goBack(),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: SolicitudBotonContinuar(
                    label: 'Subir participantes',
                    icono: AppIcons.upload,
                    onPressed: _archivoSeleccionado ? () {} : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sección de paso numerado ──────────────────────────────────────────────────

class _PasoSection extends StatelessWidget {
  final int numero;
  final String titulo;
  final String descripcion;
  final Widget contenido;

  const _PasoSection({
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

class _ContenidoPaso1 extends StatelessWidget {
  const _ContenidoPaso1();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(AppIcons.download, size: AppSizing.iconActionSm),
          label: const Text('Descargar plantilla Excel'),
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

class _ContenidoPaso2 extends StatelessWidget {
  const _ContenidoPaso2();

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
                (col) => _CeldaTabla(
                  texto: col,
                  negrita: true,
                  alineacion: TextAlign.center,
                ),
              )
              .toList(),
        ),
        ..._filas.map(
          (fila) => TableRow(
            children: fila.map((cel) => _CeldaTabla(texto: cel)).toList(),
          ),
        ),
      ],
    );
  }
}

// ── Paso 3: Área de carga ─────────────────────────────────────────────────────

class _ContenidoPaso3 extends StatelessWidget {
  final VoidCallback onArchivoSeleccionado;

  const _ContenidoPaso3({required this.onArchivoSeleccionado});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _AreaCarga(onSeleccionar: onArchivoSeleccionado),
        const SizedBox(height: AppSpacing.xs),
        Center(
          child: Text(
            'Formato permitido: .xlsx, .xls (Máx. 10 MB)',
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
  final VoidCallback onSeleccionar;

  const _AreaCarga({required this.onSeleccionar});

  @override
  Widget build(BuildContext context) {
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
            const Icon(
              AppIcons.upload,
              size: AppSizing.iconXl,
              color: AppColors.primary,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Arrastra y suelta el archivo aquí',
              style: AppTextStyles.titleSmall.copyWith(
                color: AppColors.primary,
                fontWeight: AppTextStyles.weightSemiBold,
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              'o selecciona el archivo desde tu dispositivo',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton.icon(
              onPressed: onSeleccionar,
              icon: const Icon(AppIcons.attach, size: AppSizing.iconActionSm),
              label: const Text('Adjuntar archivo Excel'),
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
        ),
      ),
    );
  }
}

// ── Vista previa de importación ───────────────────────────────────────────────

class _VistaPreviaImportacion extends StatelessWidget {
  const _VistaPreviaImportacion();

  static const _columnas = [
    'DOCUMENTO',
    'NOMBRE COMPLETO',
    'AP. PATERNO',
    'AP. MATERNO',
    'CORREO',
    'PAÍS',
    'TELÉFONO',
    'PART.',
  ];

  static const _filas = [
    [
      '29383293',
      'Miguel Cáceres Méndez',
      'Cáceres',
      'Méndez',
      'mcaceres@gmail.com',
      'Perú',
      '5037613284',
      'SI',
    ],
    [
      '29934323',
      'Joao Roque Vargas',
      'Roque',
      'Vargas',
      'joao.roque@gmail.com',
      'Brasil',
      '50379150391',
      'SI',
    ],
    [
      '29043223',
      'Karla Maria Contreras',
      'Maria',
      'Contreras',
      'karlamaria@gmail.com',
      'Perú',
      '50377269772',
      'SI',
    ],
  ];

  @override
  Widget build(BuildContext context) {
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
              _ChipConteo(count: 5, valido: true),
              const SizedBox(width: AppSpacing.xs),
              _ChipConteo(count: 0, valido: false),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // Tabla de vista previa
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: _buildTabla(),
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
                    'Se mostrarán hasta 3 filas en la vista previa. El total de registros se validará al subir el archivo.',
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

  Widget _buildTabla() {
    return Table(
      border: TableBorder.all(color: AppColors.border, width: 0.5),
      defaultColumnWidth: const IntrinsicColumnWidth(),
      children: [
        TableRow(
          children: _columnas
              .map(
                (col) => _CeldaTabla(
                  texto: col,
                  negrita: true,
                  alineacion: TextAlign.center,
                ),
              )
              .toList(),
        ),
        ..._filas.map(
          (fila) => TableRow(
            children: [
              ...fila
                  .sublist(0, fila.length - 1)
                  .map((cel) => _CeldaTabla(texto: cel)),
              // Última columna PART. con chip verde
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                    vertical: AppSpacing.xs,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(AppSizing.radiusXs),
                    ),
                    child: Text(
                      fila.last,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textOnDark,
                        fontWeight: AppTextStyles.weightBold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Chip de conteo válidos/errores ────────────────────────────────────────────

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

// ── Celda genérica de tabla ───────────────────────────────────────────────────

class _CeldaTabla extends StatelessWidget {
  final String texto;
  final bool negrita;
  final TextAlign alineacion;

  const _CeldaTabla({
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
