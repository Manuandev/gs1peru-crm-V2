// lib/features/solicitudes/presentation/widgets/completar/solicitud_facturacion_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/features/solicitudes/index_solicitudes.dart';
import 'package:app_crm/features/solicitudes/presentation/widgets/completar/solicitud_pasos_indicador.dart';

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

  // IDs y labels de combos (id para pre-selección, label para guardar en cubit)
  String _comprobanteId = '';
  String _comprobanteLabel = '';
  String _paisId = '';
  String _paisLabel = '';
  String _monedaId = '';
  String _monedaLabel = '';
  String _tipoDocId = '';
  String _tipoDocLabel = '';
  String _nacionalidadId = '';

  // Evita pre-rellenar más de una vez
  bool _prefillDone = false;

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

  /// Campos obligatorios (marcados con *) del paso 3. Apellido materno,
  /// actividad económica, NIT y observaciones son opcionales.
  bool get _formCompleto =>
      _comprobanteId.isNotEmpty &&
      _paisId.isNotEmpty &&
      _monedaId.isNotEmpty &&
      _tipoDocId.isNotEmpty &&
      _ctrlNumDoc.text.trim().isNotEmpty &&
      _nacionalidadId.isNotEmpty &&
      _ctrlNombresRazon.text.trim().isNotEmpty &&
      _ctrlApellidoPaterno.text.trim().isNotEmpty &&
      _ctrlCelular.text.trim().isNotEmpty &&
      _ctrlCorreo.text.trim().isNotEmpty &&
      _ctrlDireccion.text.trim().isNotEmpty;

  void _onCampoTexto() => setState(() {});

  @override
  void initState() {
    super.initState();
    for (final ctrl in [
      _ctrlNumDoc,
      _ctrlNombresRazon,
      _ctrlApellidoPaterno,
      _ctrlCelular,
      _ctrlCorreo,
      _ctrlDireccion,
    ]) {
      ctrl.addListener(_onCampoTexto);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_prefillDone) return;
    _prefillDone = true;
    final datos = context.read<SolicitudFormCubit>().state.facturacion;
    if (datos == null) return;
    _tipoPersona = datos.tipoPersona;
    _comprobanteId = datos.comprobanteId;
    _comprobanteLabel = datos.comprobante;
    _paisId = datos.paisId;
    _paisLabel = datos.pais;
    _monedaId = datos.monedaId;
    _monedaLabel = datos.moneda;
    _ctrlNumDoc.text = datos.numDoc;
    _ctrlNombresRazon.text = datos.nombresRazon;
    _ctrlApellidoPaterno.text = datos.apellidoPaterno;
    _ctrlApellidoMaterno.text = datos.apellidoMaterno;
    _ctrlCelular.text = datos.celular;
    _ctrlCorreo.text = datos.correo;
    _ctrlDireccion.text = datos.direccion;
    _ctrlNit.text = datos.nit;
    _ctrlObservaciones.text = datos.observaciones;
  }

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
    final catalogState = context.watch<CatalogsBloc>().state;
    final monedas = catalogState is CatalogsLoaded
        ? catalogState.monedas
        : const <MonedaItem>[];

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
                    monedas: monedas,
                    comprobanteInicialId: _comprobanteId.isNotEmpty
                        ? _comprobanteId
                        : null,
                    paisInicialId: _paisId.isNotEmpty ? _paisId : null,
                    monedaInicialId: _monedaId.isNotEmpty ? _monedaId : null,
                    onComprobanteChanged: (item) => setState(() {
                      _comprobanteId = item?.id ?? '';
                      _comprobanteLabel = item?.descripcion ?? '';
                    }),
                    onPaisChanged: (item) => setState(() {
                      _paisId = item?.id ?? '';
                      _paisLabel = item?.descripcion ?? '';
                    }),
                    onMonedaChanged: (item) => setState(() {
                      _monedaId = item?.id ?? '';
                      _monedaLabel = item?.nombre ?? '';
                    }),
                    tipoDocInicialId: _tipoDocId.isNotEmpty ? _tipoDocId : null,
                    nacionalidadInicialId: _nacionalidadId.isNotEmpty
                        ? _nacionalidadId
                        : null,
                    onTipoDocChanged: (item) => setState(() {
                      _tipoDocId = item?.id ?? '';
                      _tipoDocLabel = item?.descripcion ?? '';
                    }),
                    onNacionalidadChanged: (item) =>
                        setState(() => _nacionalidadId = item?.id ?? ''),
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
                        child:
                            BlocBuilder<ParticipantesCubit, ParticipantesState>(
                              builder: (context, state) => _ItemResumen(
                                icono: AppIcons.users,
                                colorIcono: AppColors.warning,
                                colorFondo: AppColors.warning.withOpacity(0.12),
                                label: 'Participantes pagantes',
                                valor: state.participantes
                                    .where(
                                      (p) => p.tipoParticipante == 'Pagante',
                                    )
                                    .length
                                    .toString(),
                              ),
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
                      child: CustomSecondaryButton(
                        text: 'Atrás',
                        icon: AppIcons.back,
                        backgroundColor: AppColors.brandRaspberryAccessible,
                        onPressed: () => context.goBack(),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: CustomSecondaryButton(
                        text: 'Guardar',
                        icon: AppIcons.save,
                        onPressed: () {},
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: CustomPrimaryButton(
                        text: 'Continuar →',
                        onPressed: !_formCompleto
                            ? null
                            : () {
                                context
                                    .read<SolicitudFormCubit>()
                                    .guardarFacturacion(
                                      DatosFacturacion(
                                        tipoPersona: _tipoPersona,
                                        comprobanteId: _comprobanteId,
                                        comprobante: _comprobanteLabel,
                                        paisId: _paisId,
                                        pais: _paisLabel,
                                        monedaId: _monedaId,
                                        moneda: _monedaLabel,
                                        tipoDocLabel: _tipoDocLabel,
                                        numDoc: _ctrlNumDoc.text,
                                        nombresRazon: _ctrlNombresRazon.text,
                                        apellidoPaterno:
                                            _ctrlApellidoPaterno.text,
                                        apellidoMaterno:
                                            _ctrlApellidoMaterno.text,
                                        celular: _ctrlCelular.text,
                                        correo: _ctrlCorreo.text,
                                        direccion: _ctrlDireccion.text,
                                        actividadEconomica: '',
                                        nit: _ctrlNit.text,
                                        observaciones: _ctrlObservaciones.text,
                                      ),
                                    );
                                context.goToFichaResumenSolicitud(
                                  solicitud: widget.solicitud,
                                  modoEdicion: widget.modoEdicion,
                                  formCubit: context.read<SolicitudFormCubit>(),
                                  participantesCubit: context
                                      .read<ParticipantesCubit>(),
                                );
                              },
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
          decoration: BoxDecoration(color: colorFondo, shape: BoxShape.circle),
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
  final List<MonedaItem> monedas;
  final String? comprobanteInicialId;
  final String? paisInicialId;
  final String? monedaInicialId;
  final String? tipoDocInicialId;
  final String? nacionalidadInicialId;
  final ValueChanged<ComboItem?>? onComprobanteChanged;
  final ValueChanged<ComboItem?>? onPaisChanged;
  final ValueChanged<MonedaItem?>? onMonedaChanged;
  final ValueChanged<ComboItem?>? onTipoDocChanged;
  final ValueChanged<ComboItem?>? onNacionalidadChanged;

  const _SeccionDatosFacturacion({
    required this.habilitado,
    required this.ctrlNumDoc,
    required this.ctrlNombresRazon,
    required this.ctrlApellidoPaterno,
    required this.ctrlApellidoMaterno,
    required this.ctrlCelular,
    required this.ctrlCorreo,
    required this.ctrlDireccion,
    required this.monedas,
    this.comprobanteInicialId,
    this.paisInicialId,
    this.monedaInicialId,
    this.tipoDocInicialId,
    this.nacionalidadInicialId,
    this.onComprobanteChanged,
    this.onPaisChanged,
    this.onMonedaChanged,
    this.onTipoDocChanged,
    this.onNacionalidadChanged,
  });

  static const _comprobantes = ['01¦Boleta', '02¦Factura'];
  static const _paises = [
    '01¦Perú',
    '02¦El Salvador',
    '03¦Colombia',
    '04¦México',
  ];
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
              child: CustomComboSearchField(
                label: 'Comprobante *',
                data: _comprobantes,
                enabled: habilitado,
                initialValue: comprobanteInicialId,
                onChanged: onComprobanteChanged,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: CustomComboSearchField(
                label: 'País *',
                data: _paises,
                enabled: habilitado,
                initialValue: paisInicialId,
                onChanged: onPaisChanged,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: CustomComboField<MonedaItem>(
                label: 'Moneda *',
                data: monedas,
                enabled: habilitado,
                initialValue: monedaInicialId,
                onChanged: onMonedaChanged,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),

        // Fila 2: Tipo documento + Número documento
        Row(
          children: [
            Expanded(
              child: CustomComboSearchField(
                label: 'Tipo documento *',
                data: _tiposDoc,
                enabled: habilitado,
                initialValue: tipoDocInicialId,
                onChanged: onTipoDocChanged,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: CustomTextField(
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
              child: CustomComboSearchField(
                label: 'Nacionalidad *',
                data: _nacionalidades,
                enabled: habilitado,
                initialValue: nacionalidadInicialId,
                onChanged: onNacionalidadChanged,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: CustomTextField(
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
              child: CustomTextField(
                label: 'Apellido paterno / razón legal *',
                controller: ctrlApellidoPaterno,
                enabled: habilitado,
                isUpperCase: true,
                textCapitalization: TextCapitalization.words,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: CustomTextField(
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
              child: CustomTextField(
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
        CustomTextField(
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
