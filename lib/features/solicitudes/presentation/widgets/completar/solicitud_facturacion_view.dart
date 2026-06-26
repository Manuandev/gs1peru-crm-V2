// lib/features/solicitudes/presentation/widgets/completar/solicitud_facturacion_view.dart

import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/features/solicitudes/index_solicitudes.dart';
import 'package:app_crm/features/solicitudes/presentation/widgets/completar/solicitud_pasos_indicador.dart';
import 'package:app_crm/features/solicitudes/presentation/widgets/completar/solicitud_inputs.dart';

class SolicitudFacturacionView extends StatefulWidget {
  final Solicitud solicitud;
  final bool modoEdicion;

  const SolicitudFacturacionView({
    super.key,
    required this.solicitud,
    required this.modoEdicion,
  });

  @override
  State<SolicitudFacturacionView> createState() =>
      _SolicitudFacturacionViewState();
}

class _SolicitudFacturacionViewState extends State<SolicitudFacturacionView> {
  // 'juridica' | 'natural'
  String _tipoPersona = 'juridica';

  // Controladores — Datos de facturación
  final _ctrlNumDoc = TextEditingController();
  final _ctrlNombresRazon = TextEditingController();
  final _ctrlApellidoPaterno = TextEditingController();
  final _ctrlApellidoMaterno = TextEditingController();
  final _ctrlCelular = TextEditingController();
  final _ctrlCorreo = TextEditingController();
  final _ctrlDireccion = TextEditingController();

  // Controladores — Información complementaria
  final _ctrlNit = TextEditingController();
  final _ctrlObservaciones = TextEditingController();

  @override
  void dispose() {
    _ctrlNumDoc.dispose();
    _ctrlNombresRazon.dispose();
    _ctrlApellidoPaterno.dispose();
    _ctrlApellidoMaterno.dispose();
    _ctrlCelular.dispose();
    _ctrlCorreo.dispose();
    _ctrlDireccion.dispose();
    _ctrlNit.dispose();
    _ctrlObservaciones.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      onPop: () => context.goBack(),
      drawerSide: DrawerSide.none,
      bodyPadding: EdgeInsets.zero,
      title: 'Solicitud de inscripción',
      appBarLeadingButtons: [
        IconButton(
          onPressed: () => context.goBack(),
          icon: Icon(
            AppIcons.back,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      ],
      appBarTrailingButtons: [const SolicitudBadgePaso(paso: 3)],
      body: Column(
        children: [
          const SolicitudPasosIndicador(pasoActual: 3),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Encabezado + Toggle ────────────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(
                        AppIcons.receipt,
                        color: AppColors.primary,
                        size: AppSizing.iconLg,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Datos de facturación',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: AppTextStyles.weightBold,
                              ),
                            ),
                            Text(
                              '¿Quién paga la inscripción?',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      SolicitudToggleTipoPersona(
                        valor: _tipoPersona,
                        habilitado: widget.modoEdicion,
                        onChanged: (v) => setState(() => _tipoPersona = v),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // ── Tooltip informativo ────────────────────────────
                  const _TooltipFacturacion(),
                  const SizedBox(height: AppSpacing.sm),

                  // ── Formulario ─────────────────────────────────────
                  _SeccionDatosFacturacion(
                    habilitado: widget.modoEdicion,
                    ctrlNumDoc: _ctrlNumDoc,
                    ctrlNombresRazon: _ctrlNombresRazon,
                    ctrlApellidoPaterno: _ctrlApellidoPaterno,
                    ctrlApellidoMaterno: _ctrlApellidoMaterno,
                    ctrlCelular: _ctrlCelular,
                    ctrlCorreo: _ctrlCorreo,
                    ctrlDireccion: _ctrlDireccion,
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // ── Información complementaria ─────────────────────
                  _SeccionInfoComplementaria(
                    habilitado: widget.modoEdicion,
                    ctrlNit: _ctrlNit,
                    ctrlObservaciones: _ctrlObservaciones,
                  ),
                ],
              ),
            ),
          ),

          // ── Resumen + Botones fijos al pie ───────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(
                top: BorderSide(color: AppColors.border, width: 1),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Info: Facturar al solicitante | Participantes ──
                IntrinsicHeight(
                  child: Row(
                    children: [
                      Expanded(
                        child: _ItemResumen(
                          icono: AppIcons.user,
                          colorIcono: AppColors.brandForest,
                          colorFondo: AppColors.brandForest.withOpacity(0.12),
                          label: 'Facturar al solicitante',
                          valor: 'No',
                        ),
                      ),
                      VerticalDivider(
                        width: AppSpacing.md,
                        thickness: 1,
                        color: AppColors.border,
                      ),
                      Expanded(
                        child: _ItemResumen(
                          icono: AppIcons.users,
                          colorIcono: AppColors.warning,
                          colorFondo: AppColors.warning.withOpacity(0.12),
                          label: 'Participantes pagantes',
                          valor: '5',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),

                // ── Botones ────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: SolicitudBotonAtras(
                        icono: AppIcons.back,
                        onPressed: () => context.goBack(),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: SolicitudBotonBorrador(onPressed: () {}),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: SolicitudBotonContinuar(
                        onPressed: () => context.goToFichaResumenSolicitud(
                          solicitud: widget.solicitud,
                          modoEdicion: widget.modoEdicion,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Item resumen del pie ──────────────────────────────────────────────────────

class _ItemResumen extends StatelessWidget {
  final IconData icono;
  final Color colorIcono;
  final Color colorFondo;
  final String label;
  final String valor;

  const _ItemResumen({
    required this.icono,
    required this.colorIcono,
    required this.colorFondo,
    required this.label,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: AppSizing.iconMd,
          height: AppSizing.iconMd,
          decoration: BoxDecoration(
            color: colorFondo,
            shape: BoxShape.circle,
          ),
          child: Icon(icono, color: colorIcono, size: AppSizing.iconSm),
        ),
        const SizedBox(width: AppSpacing.sm),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              valor,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: AppTextStyles.weightBold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Tooltip informativo ───────────────────────────────────────────────────────

class _TooltipFacturacion extends StatelessWidget {
  const _TooltipFacturacion();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.ui2,
        borderRadius: BorderRadius.circular(AppSizing.radiusSm),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: AppSizing.iconActionSm,
            color: AppColors.primary,
          ),
          const SizedBox(width: AppSpacing.sm2),
          Expanded(
            child: Text(
              'Quién paga será usado para la emisión del comprobante.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primary,
                fontWeight: AppTextStyles.weightMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sección Datos de facturación ─────────────────────────────────────────────

class _SeccionDatosFacturacion extends StatelessWidget {
  final bool habilitado;
  final TextEditingController ctrlNumDoc;
  final TextEditingController ctrlNombresRazon;
  final TextEditingController ctrlApellidoPaterno;
  final TextEditingController ctrlApellidoMaterno;
  final TextEditingController ctrlCelular;
  final TextEditingController ctrlCorreo;
  final TextEditingController ctrlDireccion;

  const _SeccionDatosFacturacion({
    required this.habilitado,
    required this.ctrlNumDoc,
    required this.ctrlNombresRazon,
    required this.ctrlApellidoPaterno,
    required this.ctrlApellidoMaterno,
    required this.ctrlCelular,
    required this.ctrlCorreo,
    required this.ctrlDireccion,
  });

  static const _comprobantes = ['01¦Boleta', '02¦Factura'];
  static const _paises = [
    '01¦Perú',
    '02¦El Salvador',
    '03¦Colombia',
    '04¦México',
  ];
  static const _monedas = ['01¦Soles (PEN)', '02¦Dólares (USD)'];
  static const _tiposDoc = [
    '01¦DNI',
    '02¦Pasaporte',
    '03¦Carnet de extranjería',
    '04¦RUC',
    '05¦Otros',
  ];
  static const _nacionalidades = [
    '01¦Peruano/a',
    '02¦Salvadoreño/a',
    '03¦Colombiano/a',
    '04¦Mexicano/a',
    '05¦Extranjero/a',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Fila 1: Comprobante + País + Moneda (3 columnas)
        Row(
          children: [
            Expanded(
              child: SolicitudComboField(
                label: 'Comprobante *',
                data: _comprobantes,
                enabled: habilitado,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: SolicitudComboField(
                label: 'País *',
                data: _paises,
                enabled: habilitado,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: SolicitudComboField(
                label: 'Moneda *',
                data: _monedas,
                enabled: habilitado,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),

        // Fila 2: Tipo documento + Número documento
        Row(
          children: [
            Expanded(
              child: SolicitudComboField(
                label: 'Tipo documento *',
                data: _tiposDoc,
                enabled: habilitado,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: SolicitudTextField(
                label: 'Número documento *',
                controller: ctrlNumDoc,
                keyboardType: TextInputType.number,
                enabled: habilitado,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),

        // Fila 3: Nacionalidad + Nombres o Razón social
        Row(
          children: [
            Expanded(
              child: SolicitudComboField(
                label: 'Nacionalidad *',
                data: _nacionalidades,
                enabled: habilitado,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: SolicitudTextField(
                label: 'Nombres o Razón social *',
                controller: ctrlNombresRazon,
                enabled: habilitado,
                isUpperCase: true,
                textCapitalization: TextCapitalization.words,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),

        // Fila 4: Apellido paterno + Apellido materno
        Row(
          children: [
            Expanded(
              child: SolicitudTextField(
                label: 'Apellido paterno / razón legal *',
                controller: ctrlApellidoPaterno,
                enabled: habilitado,
                isUpperCase: true,
                textCapitalization: TextCapitalization.words,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: SolicitudTextField(
                label: 'Apellido materno / complemento',
                hint: 'Opcional',
                controller: ctrlApellidoMaterno,
                enabled: habilitado,
                isUpperCase: true,
                textCapitalization: TextCapitalization.words,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),

        // Fila 5: Celular + Correo
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SolicitudCampoCelular(
                controller: ctrlCelular,
                habilitado: habilitado,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: SolicitudTextField(
                label: 'Correo para envío de boleta *',
                controller: ctrlCorreo,
                keyboardType: TextInputType.emailAddress,
                enabled: habilitado,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),

        // Dirección de domicilio (ancho completo)
        SolicitudTextField(
          label: 'Dirección de domicilio *',
          controller: ctrlDireccion,
          enabled: habilitado,
          textCapitalization: TextCapitalization.sentences,
        ),
      ],
    );
  }
}

// ── Sección Información complementaria ───────────────────────────────────────

class _SeccionInfoComplementaria extends StatelessWidget {
  final bool habilitado;
  final TextEditingController ctrlNit;
  final TextEditingController ctrlObservaciones;

  const _SeccionInfoComplementaria({
    required this.habilitado,
    required this.ctrlNit,
    required this.ctrlObservaciones,
  });

  static const _actividades = [
    '01¦Manufactura',
    '02¦Comercio',
    '03¦Servicios',
    '04¦Agroindustria',
    '05¦Tecnología',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            const Icon(
              Icons.apps_rounded,
              color: AppColors.primary,
              size: AppSizing.iconMd,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              'Información complementaria',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primary,
                fontWeight: AppTextStyles.weightSemiBold,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),

        // Actividad económica + NIT
        Row(
          children: [
            Expanded(
              child: SolicitudComboField(
                label: 'Actividad económica',
                data: _actividades,
                enabled: habilitado,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: SolicitudTextField(
                label: 'NIT',
                controller: ctrlNit,
                enabled: habilitado,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),

        // Observaciones
        SolicitudTextField(
          label: 'Observaciones',
          hint: 'Opcional',
          controller: ctrlObservaciones,
          enabled: habilitado,
          textCapitalization: TextCapitalization.sentences,
          maxLines: 3,
        ),
        const SizedBox(height: AppSpacing.sm),
      ],
    );
  }
}

