// lib/features/solicitudes/presentation/widgets/completar/solicitud_completar_view.dart

import 'package:flutter/material.dart';

import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/features/solicitudes/index_solicitudes.dart';

// Id de catálogo de "RUC" en TipoDocumentoItem (SYSTABEXTER02 CODTABLA='F01') —
// mismo valor que en solicitud_facturacion_view.dart y en el datasource.
const _idTipoDocRucCompletar = '6';

class SolicitudCompletarView extends StatefulWidget {
  final Solicitud solicitud;
  final bool modoEdicion;

  const SolicitudCompletarView({
    super.key,
    required this.solicitud,
    required this.modoEdicion,
  });

  @override
  State<SolicitudCompletarView> createState() => _SolicitudCompletarViewState();
}

class _SolicitudCompletarViewState extends State<SolicitudCompletarView> {
  // true mientras se trae la solicitud del backend (task 'DT') — bloquea el
  // formulario para que los combos (que solo leen su valor inicial una vez,
  // en su propio initState) no se construyan antes de tener los datos.
  bool _cargando = true;

  // true mientras se guarda el borrador (botón "Guardar")
  bool _guardando = false;

  // Canal seleccionado (single-select) — catálogo real vía CatalogsBloc
  CanalItem? _canalSeleccionado;

  // País del código telefónico del celular — catálogo real vía CatalogsBloc
  PaisItem? _paisCelular;

  // Switches — opciones del solicitante
  bool _solicitanteParticipante = false;
  bool _facturarAlSolicitante = false;

  // Labels/ids de combos capturados desde SeccionDatosSolicitante
  String _tipoDocId = '';
  String _tipoDocLabel = '';
  String _nacionalidadId = '';
  String _nacionalidadLabel = '';
  String _sexoId = '';

  // Controladores — Datos del solicitante
  final _ctrlNumDoc = TextEditingController();
  final _ctrlNombres = TextEditingController();
  final _ctrlApellidoPaterno = TextEditingController();
  final _ctrlApellidoMaterno = TextEditingController();
  final _ctrlCargo = TextEditingController();
  final _ctrlCelular = TextEditingController();
  final _ctrlCorreo = TextEditingController();

  // Controladores — Información comercial
  final _ctrlRuc = TextEditingController();
  final _ctrlRazonSocial = TextEditingController();

  // Archivos adjuntos — voucher y orden de compra
  PlatformFile? _archivoVoucher;
  PlatformFile? _archivoOC;

  /// Campos obligatorios (marcados con *) del paso 1. Los opcionales
  /// (apellido materno, RUC/razón social, canales) no se exigen.
  bool get _formCompleto =>
      _tipoDocLabel.isNotEmpty &&
      _ctrlNumDoc.text.trim().isNotEmpty &&
      _nacionalidadId.isNotEmpty &&
      _sexoId.isNotEmpty &&
      _ctrlNombres.text.trim().isNotEmpty &&
      _ctrlApellidoPaterno.text.trim().isNotEmpty &&
      _ctrlCargo.text.trim().isNotEmpty &&
      _ctrlCelular.text.trim().isNotEmpty &&
      _ctrlCorreo.text.emailValidator == null;

  void _onCampoTexto() => setState(() {});

  @override
  void initState() {
    super.initState();
    for (final ctrl in [
      _ctrlNumDoc,
      _ctrlNombres,
      _ctrlApellidoPaterno,
      _ctrlCargo,
      _ctrlCelular,
      _ctrlCorreo,
    ]) {
      ctrl.addListener(_onCampoTexto);
    }
    _cargarDetalle();
  }

  // Trae solicitante + facturación + participantes + archivos ya guardados
  // (task 'DT') y prellena el formulario + los cubits compartidos del
  // wizard. Se llama una sola vez — el paso 1 solo se entra desde
  // SolicitudDetalleView, nunca por "Atrás" desde otro paso.
  Future<void> _cargarDetalle() async {
    final numSol = widget.solicitud.idSolicitud;
    if (numSol.isEmpty) {
      setState(() => _cargando = false);
      return;
    }

    try {
      final detalle = await GetSolicitudDetalleUseCase(
        context.read<SolicitudRepository>(),
      ).call(numSol);

      if (!mounted) return;

      final catalogState = context.read<CatalogsBloc>().state;
      final tiposDocumento = catalogState is CatalogsLoaded
          ? catalogState.tiposDocumento
          : const <TipoDocumentoItem>[];
      final nacionalidades = catalogState is CatalogsLoaded
          ? catalogState.nacionalidades
          : const <NacionalidadItem>[];
      final canales = catalogState is CatalogsLoaded
          ? catalogState.canales
          : const <CanalItem>[];
      final comprobantes = catalogState is CatalogsLoaded
          ? catalogState.comprobantes
          : const <ComprobanteItem>[];
      final monedas = catalogState is CatalogsLoaded
          ? catalogState.monedas
          : const <MonedaItem>[];
      final paises = catalogState is CatalogsLoaded
          ? catalogState.paises
          : const <PaisItem>[];

      final tipoDoc = tiposDocumento
          .where((t) => t.id == detalle.tipoDocId)
          .firstOrNull;
      final nacionalidad = nacionalidades
          .where((n) => n.id == detalle.nacionalidadId)
          .firstOrNull;
      final canal = detalle.canalId.isEmpty
          ? null
          : canales
                .where((c) => c.id.toString() == detalle.canalId)
                .firstOrNull;

      final voucher = detalle.archivos
          .where((a) => a.tipo == 'voucher')
          .firstOrNull;
      final oc = detalle.archivos.where((a) => a.tipo == 'oc').firstOrNull;

      _tipoDocId = detalle.tipoDocId;
      _tipoDocLabel = tipoDoc?.abreviatura ?? '';
      _nacionalidadId = detalle.nacionalidadId;
      _nacionalidadLabel = nacionalidad?.nombre ?? '';
      _sexoId = detalle.sexoId;
      _canalSeleccionado = canal;
      _solicitanteParticipante = detalle.solicitanteEsParticipante;
      _facturarAlSolicitante = detalle.facturarAlSolicitante;
      _ctrlNumDoc.text = detalle.numDoc;
      _ctrlNombres.text = detalle.nombres;
      _ctrlApellidoPaterno.text = detalle.apellidoPaterno;
      _ctrlApellidoMaterno.text = detalle.apellidoMaterno;
      _ctrlCargo.text = detalle.cargo;
      _ctrlCelular.text = detalle.celular;
      _ctrlCorreo.text = detalle.correo;
      _ctrlRuc.text = detalle.ruc;
      _ctrlRazonSocial.text = detalle.razonSocial;

      final datosSolicitante = DatosSolicitante(
        tipoDocId: detalle.tipoDocId,
        tipoDocLabel: _tipoDocLabel,
        numDoc: detalle.numDoc,
        nacionalidadId: detalle.nacionalidadId,
        nacionalidad: _nacionalidadLabel,
        sexoId: detalle.sexoId,
        nombres: detalle.nombres,
        apellidoPaterno: detalle.apellidoPaterno,
        apellidoMaterno: detalle.apellidoMaterno,
        cargo: detalle.cargo,
        celular: detalle.celular,
        correo: detalle.correo,
        canalId: canal?.id,
        canalNombre: detalle.canalNombre,
        ruc: detalle.ruc,
        razonSocial: detalle.razonSocial,
        solicitanteEsParticipante: detalle.solicitanteEsParticipante,
        facturarAlSolicitante: detalle.facturarAlSolicitante,
        archivoVoucherNombre: voucher == null
            ? ''
            : '${voucher.nombre}${voucher.extension}',
        archivoOCNombre: oc == null ? '' : '${oc.nombre}${oc.extension}',
      );

      if (!mounted) return;
      context.read<SolicitudFormCubit>().cambiarTipoPersona(
        detalle.tipoPersona,
      );
      context.read<SolicitudFormCubit>().guardarSolicitante(datosSolicitante);

      if (!detalle.sinFacturacion) {
        final esRuc = detalle.facTipoDocId == _idTipoDocRucCompletar;
        final facTipoDoc = tiposDocumento
            .where((t) => t.id == detalle.facTipoDocId)
            .firstOrNull;
        final facComprobante = comprobantes
            .where((c) => c.id == detalle.facComprobanteId)
            .firstOrNull;
        final facMoneda = monedas
            .where((m) => m.id == detalle.facMonedaId)
            .firstOrNull;
        final facPais = paises
            .where((p) => p.id == detalle.facPaisId)
            .firstOrNull;

        context.read<SolicitudFormCubit>().guardarFacturacion(
          DatosFacturacion(
            comprobanteId: detalle.facComprobanteId,
            comprobante: facComprobante?.nombre ?? '',
            paisId: detalle.facPaisId,
            pais: facPais?.nombre ?? '',
            monedaId: detalle.facMonedaId,
            moneda: facMoneda?.nombre ?? '',
            tipoDocId: detalle.facTipoDocId,
            tipoDocLabel: facTipoDoc?.abreviatura ?? '',
            numDoc: detalle.facNumDoc,
            nombresRazon: esRuc ? detalle.facNomEmpre : detalle.facNombres,
            apellidoPaterno: esRuc ? '' : detalle.facApellidoPaterno,
            apellidoMaterno: esRuc ? '' : detalle.facApellidoMaterno,
            celular: detalle.facCelular,
            correo: detalle.facCorreo,
            direccion: detalle.facDireccion,
            actividadEconomica: '',
            nit: '',
            observaciones: '',
          ),
        );
      }

      final participantes = detalle.participantes.map((p) {
        final tipoDocP = tiposDocumento
            .where((t) => t.id == p.tipoDocId)
            .firstOrNull;
        final nacionalidadP = nacionalidades
            .where((n) => n.id == p.nacionalidadId)
            .firstOrNull;
        return ParticipanteLocal(
          id: int.tryParse(p.id) ?? 0,
          tipoDocId: p.tipoDocId,
          tipoDoc: tipoDocP?.abreviatura ?? '',
          numDoc: p.numDoc,
          nacionalidadId: p.nacionalidadId,
          nacionalidad: nacionalidadP?.nombre ?? '',
          nombres: p.nombres,
          apellidoPaterno: p.apellidoPaterno,
          apellidoMaterno: p.apellidoMaterno,
          correo: p.correo,
          cargo: p.cargo,
          celular: p.celular,
          tipoParticipante: p.tipoParticipante,
          importe: p.importe,
          esSolicitante: p.id == detalle.idParticipanteSolicitante,
        );
      }).toList();

      if (!mounted) return;
      context.read<ParticipantesCubit>().cargarParticipantes(participantes);

      setState(() => _cargando = false);
    } catch (e) {
      if (!mounted) return;
      setState(() => _cargando = false);
      AppSnackBar.error(context, 'No se pudo cargar la solicitud: $e');
    }
  }

  Future<void> _adjuntarArchivo(bool esVoucher) async {
    final resultado = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    final archivo = resultado?.files.single;
    if (archivo == null) return;

    final extension = archivo.extension?.toLowerCase();
    if (extension != 'pdf') {
      if (mounted) {
        AppSnackBar.error(context, 'Solo se permiten archivos PDF');
      }
      return;
    }

    setState(() {
      if (esVoucher) {
        _archivoVoucher = archivo;
      } else {
        _archivoOC = archivo;
      }
    });
  }

  void _quitarArchivo(bool esVoucher) {
    setState(() {
      if (esVoucher) {
        _archivoVoucher = null;
      } else {
        _archivoOC = null;
      }
    });
  }

  Future<void> _confirmarCancelar() async {
    final confirmado = await context.showConfirmDialog(
      title: 'Cancelar solicitud',
      message: '¿Desea cancelar el proceso de solicitud?',
      confirmText: 'Sí, cancelar',
      cancelText: 'No',
    );
    if (confirmado && mounted) context.goBack();
  }

  DatosSolicitante _construirDatosSolicitante(PaisItem? paisCelular) {
    return DatosSolicitante(
      tipoDocId: _tipoDocId,
      tipoDocLabel: _tipoDocLabel,
      numDoc: _ctrlNumDoc.text,
      nacionalidadId: _nacionalidadId,
      nacionalidad: _nacionalidadLabel,
      sexoId: _sexoId,
      nombres: _ctrlNombres.text,
      apellidoPaterno: _ctrlApellidoPaterno.text,
      apellidoMaterno: _ctrlApellidoMaterno.text,
      cargo: _ctrlCargo.text,
      celular: _ctrlCelular.text,
      celularCodigoTelefono: paisCelular?.codigoTelefono ?? '',
      correo: _ctrlCorreo.text,
      canalId: _canalSeleccionado?.id,
      canalNombre: _canalSeleccionado?.nombre ?? '',
      ruc: _ctrlRuc.text,
      razonSocial: _ctrlRazonSocial.text,
      solicitanteEsParticipante: _solicitanteParticipante,
      facturarAlSolicitante: _facturarAlSolicitante,
      archivoVoucherNombre: _archivoVoucher?.name ?? '',
      archivoOCNombre: _archivoOC?.name ?? '',
    );
  }

  // En modo edición valida los campos obligatorios antes de continuar; en
  // modo solo-ver (modoEdicion == false) avanza directo, sin validar.
  void _onContinuar(PaisItem? paisCelular) {
    if (widget.modoEdicion && !_formCompleto) {
      AppSnackBar.error(
        context,
        'Completa todos los campos obligatorios (*) para continuar',
      );
      return;
    }
    final datos = _construirDatosSolicitante(paisCelular);
    context.read<SolicitudFormCubit>().guardarSolicitante(datos);
    context.read<ParticipantesCubit>().sincronizarSolicitante(datos);
    context.goToFichaParticipantesSolicitud(
      solicitud: widget.solicitud,
      modoEdicion: widget.modoEdicion,
      formCubit: context.read<SolicitudFormCubit>(),
      participantesCubit: context.read<ParticipantesCubit>(),
    );
  }

  // Botón "Guardar" — borrador (IB_BORRADOR=1), sin navegar ni validar
  // campos obligatorios. Guarda lo que haya en los controllers tal cual.
  Future<void> _onGuardar(PaisItem? paisCelular) async {
    if (_guardando) return;
    setState(() => _guardando = true);

    final datos = _construirDatosSolicitante(paisCelular);
    context.read<SolicitudFormCubit>().guardarSolicitante(datos);
    context.read<ParticipantesCubit>().sincronizarSolicitante(datos);

    final result = await guardarSolicitudDesdeWizard(
      context,
      numSol: widget.solicitud.idSolicitud,
      idLead: widget.solicitud.idLead,
      esBorrador: true,
    );

    if (!mounted) return;
    setState(() => _guardando = false);
    mostrarResultadoGuardarSolicitud(context, result);
  }

  @override
  void dispose() {
    _ctrlNumDoc.dispose();
    _ctrlNombres.dispose();
    _ctrlApellidoPaterno.dispose();
    _ctrlApellidoMaterno.dispose();
    _ctrlCargo.dispose();
    _ctrlCelular.dispose();
    _ctrlCorreo.dispose();
    _ctrlRuc.dispose();
    _ctrlRazonSocial.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return BasePage(
        onPop: () => context.goBack(),
        drawerSide: DrawerSide.none,
        title: 'Solicitud de inscripción',
        body: const AppLoadingView(),
      );
    }

    final tipoPersona = context.watch<SolicitudFormCubit>().state.tipoPersona;
    final catalogState = context.watch<CatalogsBloc>().state;
    final canales = catalogState is CatalogsLoaded
        ? catalogState.canales
        : const <CanalItem>[];
    final paises = catalogState is CatalogsLoaded
        ? catalogState.paises
        : const <PaisItem>[];
    final paisCelular =
        _paisCelular ??
        (paises.isEmpty
            ? null
            : paises.where((p) => p.codigoTelefono == '51').firstOrNull ??
                  paises.first);

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
      appBarTrailingButtons: [const SolicitudBadgePaso(paso: 1)],
      body: Column(
        children: [
          const SolicitudPasosIndicador(pasoActual: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Toggle tipo persona ─────────────────────────────
                  Align(
                    alignment: Alignment.centerRight,
                    child: SolicitudToggleTipoPersona(
                      valor: tipoPersona,
                      habilitado: widget.modoEdicion,
                      onChanged: (v) => context
                          .read<SolicitudFormCubit>()
                          .cambiarTipoPersona(v),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // ── ¿Cómo se enteró del evento? ────────────────────
                  Text(
                    '¿Cómo se enteró del evento?',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: AppTextStyles.weightMedium,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  ChipsCanales(
                    canales: canales,
                    seleccionado: _canalSeleccionado,
                    habilitado: widget.modoEdicion,
                    onSeleccionar: (canal) {
                      if (!widget.modoEdicion) return;
                      setState(() {
                        _canalSeleccionado = _canalSeleccionado?.id == canal.id
                            ? null
                            : canal;
                      });
                    },
                  ),
                  const SizedBox(height: AppSpacing.xs),

                  // ── Botones de adjuntos ────────────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: BotonAdjuntar(
                          label: 'Adjuntar voucher',
                          archivo: _archivoVoucher,
                          habilitado: widget.modoEdicion,
                          onAdjuntar: () => _adjuntarArchivo(true),
                          onQuitar: () => _quitarArchivo(true),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: BotonAdjuntar(
                          label: 'Adjuntar O/C',
                          archivo: _archivoOC,
                          habilitado: widget.modoEdicion,
                          onAdjuntar: () => _adjuntarArchivo(false),
                          onQuitar: () => _quitarArchivo(false),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),

                  // ── Tooltip informativo — 3 partes de la solicitud ─
                  const TooltipPartesSolicitud(),
                  const SizedBox(height: AppSpacing.sm),

                  // ── Datos del solicitante ──────────────────────────
                  SeccionDatosSolicitante(
                    habilitado: widget.modoEdicion,
                    ctrlNumDoc: _ctrlNumDoc,
                    ctrlNombres: _ctrlNombres,
                    ctrlApellidoPaterno: _ctrlApellidoPaterno,
                    ctrlApellidoMaterno: _ctrlApellidoMaterno,
                    ctrlCargo: _ctrlCargo,
                    ctrlCelular: _ctrlCelular,
                    ctrlCorreo: _ctrlCorreo,
                    paises: paises,
                    paisCelular: paisCelular,
                    onPaisCelularChanged: (p) =>
                        setState(() => _paisCelular = p),
                    tipoDocInicialId: _tipoDocId.isNotEmpty
                        ? _tipoDocId
                        : null,
                    nacionalidadInicialId: _nacionalidadId.isNotEmpty
                        ? _nacionalidadId
                        : null,
                    sexoInicialId: _sexoId.isNotEmpty ? _sexoId : null,
                    onTipoDocChanged: (item) => setState(() {
                      _tipoDocId = item?.id ?? '';
                      _tipoDocLabel = item?.abreviatura ?? '';
                    }),
                    onNacionalidadChanged: (item) => setState(() {
                      _nacionalidadId = item?.id ?? '';
                      _nacionalidadLabel = item?.nombre ?? '';
                    }),
                    onSexoChanged: (v) => setState(() => _sexoId = v),
                  ),
                  if (tipoPersona == 'juridica') ...[
                    const SizedBox(height: AppSpacing.sm),

                    // ── Información comercial (solo jurídica) ──────────
                    SeccionInfoComercial(
                      habilitado: widget.modoEdicion,
                      ctrlRuc: _ctrlRuc,
                      ctrlRazonSocial: _ctrlRazonSocial,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.sm),

                  // ── Switches ───────────────────────────────────────
                  SeccionSwitches(
                    solicitanteParticipante: _solicitanteParticipante,
                    facturarAlSolicitante: _facturarAlSolicitante,
                    onSolicitanteChanged: (v) =>
                        setState(() => _solicitanteParticipante = v),
                    onFacturarChanged: (v) =>
                        setState(() => _facturarAlSolicitante = v),
                    habilitado: widget.modoEdicion,
                  ),
                ],
              ),
            ),
          ),

          // ── Botones de acción fijos al pie ──────────────────────────
          // En modo solo-ver (modoEdicion == false) solo se muestra
          // "Continuar", sin validar campos — es un recorrido de lectura,
          // no una captura de datos.
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: widget.modoEdicion
                ? Row(
                    children: [
                      Expanded(
                        child: CustomSecondaryButton(
                          text: 'Cancelar',
                          backgroundColor: AppColors.brandRaspberryAccessible,
                          onPressed: _confirmarCancelar,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: CustomSecondaryButton(
                          text: 'Guardar',
                          icon: AppIcons.save,
                          isLoading: _guardando,
                          onPressed: () => _onGuardar(paisCelular),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: CustomPrimaryButton(
                          text: 'Continuar →',
                          onPressed: () => _onContinuar(paisCelular),
                        ),
                      ),
                    ],
                  )
                : CustomPrimaryButton(
                    text: 'Continuar →',
                    onPressed: () => _onContinuar(paisCelular),
                  ),
          ),
        ],
      ),
    );
  }
}
