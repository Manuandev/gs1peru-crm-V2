// lib/features/solicitudes/presentation/widgets/completar/solicitud_completar_view.dart

import 'package:flutter/material.dart';

import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/features/solicitudes/index_solicitudes.dart';

class SolicitudCompletarView extends StatefulWidget {
  final Solicitud solicitud;
  final bool modoEdicion;
  // Avanza al paso 2 (Participantes) dentro del mismo SolicitudWizardView —
  // ya no navega a una ruta aparte, ver CLAUDE.md "Wizard de una sola page".
  final VoidCallback onContinuar;
  // Sale del wizard por completo (Cancelar, con confirmación) — pop de la
  // page raíz del wizard, no un paso interno.
  final VoidCallback onCancelar;

  const SolicitudCompletarView({
    super.key,
    required this.solicitud,
    required this.modoEdicion,
    required this.onContinuar,
    required this.onCancelar,
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

  // Autocompletado por documento (Clientes/BuscarDocumento) — mismo servicio
  // que participante_form_sheet.dart, usado en dos campos independientes de
  // este paso: Número documento (Datos del solicitante) y RUC (Información
  // comercial, solo llena Razón Social).
  final _documentoService = DocumentoExternoService();
  bool _buscandoDocSolicitante = false;
  String _ultimoDocSolicitanteBuscado = '';
  bool _buscandoRuc = false;
  String _ultimoRucBuscado = '';

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

  void _onCampoTexto() {
    setState(() {});
    _sincronizarCubit();
  }

  // Empuja el draft actual (ids de combos + texto de inputs, aunque estén
  // vacíos) a SolicitudFormCubit en cada cambio — así el paso 1 nunca pierde
  // datos al moverse a otro paso dentro del wizard, sin depender de que se
  // presione "Continuar"/"Guardar". No sincroniza mientras `_cargando` es
  // true (evita pisar el draft con datos a medio poblar durante el fetch).
  void _sincronizarCubit() {
    if (_cargando || !mounted) return;
    context.read<SolicitudFormCubit>().guardarSolicitante(
      _construirDatosSolicitante(_paisCelular),
    );
  }

  // Autocompleta nombres/apellidos/correo del solicitante por DNI (8 dígitos)
  // o RUC (11) al salir del campo N° documento o presionar el check del
  // teclado — mismo servicio y mismo patrón que
  // participante_form_sheet.dart._buscarDocumento.
  Future<void> _buscarDocumentoSolicitante() async {
    final numDoc = _ctrlNumDoc.text.trim();
    final esBusqueda = numDoc.length == 8 || numDoc.length == 11;
    if (!esBusqueda || numDoc == _ultimoDocSolicitanteBuscado) return;
    _ultimoDocSolicitanteBuscado = numDoc;

    setState(() => _buscandoDocSolicitante = true);
    try {
      final resultado = await _documentoService.buscar(numDoc);
      if (!mounted) return;
      if (resultado == null || resultado.sinDatos) return;

      if (resultado.nombres.isNotEmpty) {
        _ctrlNombres.text = resultado.nombres;
      } else if (resultado.nomEmpresa.isNotEmpty) {
        _ctrlNombres.text = resultado.nomEmpresa; // RUC sin persona natural
      }
      if (resultado.apePaterno.isNotEmpty) {
        _ctrlApellidoPaterno.text = resultado.apePaterno;
      }
      if (resultado.apeMaterno.isNotEmpty) {
        _ctrlApellidoMaterno.text = resultado.apeMaterno;
      }
      if (resultado.correo.isNotEmpty) {
        _ctrlCorreo.text = resultado.correo;
      }
    } catch (_) {
      if (!mounted) return;
      AppSnackBar.error(
        context,
        'No se pudo autocompletar los datos del documento.',
      );
    } finally {
      if (mounted) setState(() => _buscandoDocSolicitante = false);
    }
  }

  // Autocompleta solo la Razón Social por RUC (Información comercial) al
  // salir del campo o presionar el check del teclado.
  Future<void> _buscarRucComercial() async {
    final ruc = _ctrlRuc.text.trim();
    if (ruc.length != 11 || ruc == _ultimoRucBuscado) return;
    _ultimoRucBuscado = ruc;

    setState(() => _buscandoRuc = true);
    try {
      final resultado = await _documentoService.buscar(ruc);
      if (!mounted) return;
      if (resultado == null || resultado.sinDatos) return;
      if (resultado.nomEmpresa.isNotEmpty) {
        _ctrlRazonSocial.text = resultado.nomEmpresa;
      }
    } catch (_) {
      if (!mounted) return;
      AppSnackBar.error(context, 'No se pudo autocompletar la razón social.');
    } finally {
      if (mounted) setState(() => _buscandoRuc = false);
    }
  }

  @override
  void initState() {
    super.initState();
    for (final ctrl in [
      _ctrlNumDoc,
      _ctrlNombres,
      _ctrlApellidoPaterno,
      _ctrlApellidoMaterno,
      _ctrlCargo,
      _ctrlCelular,
      _ctrlCorreo,
      _ctrlRuc,
      _ctrlRazonSocial,
    ]) {
      ctrl.addListener(_onCampoTexto);
    }
    _cargarDetalle();
  }

  // Al crear una solicitud nueva (numSol vacío) — nunca al editar una ya
  // guardada, ese caso prellena todo desde `detalle` en _cargarDetalle() —
  // Tipo documento y Nacionalidad arrancan en DNI/Perú (ids reales de
  // CatalogsBloc.valoresDefecto, parte [13] del SP), mismo default que usa
  // el formulario de "Nuevo participante" (ver solicitudes/CLAUDE.md). Sexo
  // queda sin seleccionar a propósito — a diferencia del documento/
  // nacionalidad no hay un valor por defecto razonable, el asesor debe
  // elegirlo.
  void _sembrarValoresPorDefecto() {
    final catalogState = context.read<CatalogsBloc>().state;
    if (catalogState is! CatalogsLoaded) return;
    final valoresDefecto = catalogState.valoresDefecto;

    final tipoDocDefecto = catalogState.tiposDocumento
        .where((t) => t.id == valoresDefecto.idTipoDocDni)
        .firstOrNull;
    if (tipoDocDefecto != null) {
      _tipoDocId = tipoDocDefecto.id;
      _tipoDocLabel = tipoDocDefecto.abreviatura;
    }

    final nacionalidadDefecto = catalogState.nacionalidades
        .where((n) => n.id == valoresDefecto.idNacionalidad)
        .firstOrNull;
    if (nacionalidadDefecto != null) {
      _nacionalidadId = nacionalidadDefecto.id;
      _nacionalidadLabel = nacionalidadDefecto.nombre;
    }
  }

  // Trae solicitante + facturación + participantes + archivos ya guardados
  // (task 'DT') y prellena el formulario + los cubits compartidos del
  // wizard. Se llama una sola vez — el paso 1 solo se entra desde
  // SolicitudDetalleView, nunca por "Atrás" desde otro paso.
  Future<void> _cargarDetalle() async {
    final numSol = widget.solicitud.idSolicitud;
    // Siembra el NUMSOL en el cubit compartido — vacío si es creación nueva,
    // real si se está editando. guardarSolicitudDesdeWizard() lo actualiza
    // solo después de la primera creación exitosa.
    context.read<SolicitudFormCubit>().actualizarNumSol(numSol);

    if (numSol.isEmpty) {
      _sembrarValoresPorDefecto();
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
      final valoresDefecto = catalogState is CatalogsLoaded
          ? catalogState.valoresDefecto
          : const ValoresCRMItem();

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
        final esRuc = detalle.facTipoDocId == valoresDefecto.idTipoDocRuc;
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
      withData: true, // asegura PlatformFile.bytes en todas las plataformas
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

    if (!mounted) return;
    final formCubit = context.read<SolicitudFormCubit>();
    if (esVoucher) {
      formCubit.guardarArchivoVoucher(archivo);
    } else {
      formCubit.guardarArchivoOC(archivo);
    }
  }

  void _quitarArchivo(bool esVoucher) {
    final formCubit = context.read<SolicitudFormCubit>();
    if (esVoucher) {
      formCubit.quitarArchivoVoucher();
    } else {
      formCubit.quitarArchivoOC();
    }
  }

  Future<void> _confirmarCancelar() async {
    final confirmado = await context.showConfirmDialog(
      title: 'Cancelar solicitud',
      message: '¿Desea cancelar el proceso de solicitud?',
      confirmText: 'Sí, cancelar',
      cancelText: 'No',
    );
    if (confirmado && mounted) widget.onCancelar();
  }

  DatosSolicitante _construirDatosSolicitante(PaisItem? paisCelular) {
    final archivos = context.read<SolicitudFormCubit>().state;
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
      archivoVoucherNombre: archivos.archivoVoucher?.name ?? '',
      archivoOCNombre: archivos.archivoOC?.name ?? '',
    );
  }

  // Id real de "Pagante" (catálogo TipoParticipanteItem, esInvitado == false)
  // — usado para el participante que se autogenera con el switch "El
  // solicitante será participante". `firstOrNull` porque el orden del SP no
  // está garantizado; si el catálogo aún no cargó, cae a '' (el CUD lo
  // rechazaría, mismo comportamiento que antes si el campo llegaba vacío).
  String _idTipoParticipantePagante() {
    final catalogState = context.read<CatalogsBloc>().state;
    if (catalogState is! CatalogsLoaded) return '';
    return catalogState.tiposParticipante
            .where((t) => !t.esInvitado)
            .firstOrNull
            ?.id ??
        '';
  }

  // null si esta solicitud no viene de una negociación con precio ya
  // definido — mismo cálculo que usa "Nuevo participante"
  // (solicitud_participantes_view.dart._importeFijo), necesario acá también
  // porque el switch "El solicitante será participante" genera su propio
  // ParticipanteLocal sin pasar por ese formulario.
  double? _importeFijo() {
    final formState = context.read<SolicitudFormCubit>().state;
    return formState.cantidadEsperada != null ? formState.precioBaseLead : null;
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
    context.read<ParticipantesCubit>().sincronizarSolicitante(
      datos,
      idTipoParticipantePagante: _idTipoParticipantePagante(),
      importeFijo: _importeFijo(),
    );
    // Si ya existe NUMSOL (edición) y hay un archivo recién adjuntado, se
    // sube en segundo plano — no bloquea la navegación. En creación nueva
    // (NUMSOL aún vacío) no hace nada hasta que se presione "Guardar".
    subirArchivosPendientes(context);
    widget.onContinuar();
  }

  // Botón "Guardar" — borrador (IB_BORRADOR=1), sin navegar ni validar
  // campos obligatorios. Guarda lo que haya en los controllers tal cual.
  Future<void> _onGuardar(PaisItem? paisCelular) async {
    if (_guardando) return;
    setState(() => _guardando = true);

    final datos = _construirDatosSolicitante(paisCelular);
    context.read<SolicitudFormCubit>().guardarSolicitante(datos);
    context.read<ParticipantesCubit>().sincronizarSolicitante(
      datos,
      idTipoParticipantePagante: _idTipoParticipantePagante(),
      importeFijo: _importeFijo(),
    );

    final result = await guardarSolicitudDesdeWizard(
      context,
      idLead: widget.solicitud.idLead,
      esBorrador: true,
    );

    // Recién acá hay NUMSOL confirmado (si era creación nueva, lo generó
    // este mismo guardado) — es el punto correcto para subir voucher/OC.
    if (result is CrudOk && mounted) await subirArchivosPendientes(context);

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
      return const AppLoadingView();
    }

    final formState = context.watch<SolicitudFormCubit>().state;
    final tipoPersona = formState.tipoPersona;
    final catalogState = context.watch<CatalogsBloc>().state;
    final canales = catalogState is CatalogsLoaded
        ? catalogState.canales
        : const <CanalItem>[];
    final paises = catalogState is CatalogsLoaded
        ? catalogState.paises
        : const <PaisItem>[];
    final idPaisDefecto = catalogState is CatalogsLoaded
        ? catalogState.valoresDefecto.idPais
        : '';
    final paisCelular =
        _paisCelular ??
        (paises.isEmpty
            ? null
            : paises.where((p) => p.id == idPaisDefecto).firstOrNull ??
                  paises.first);

    return BlocListener<ParticipantesCubit, ParticipantesState>(
      // Se dispara solo en la transición "existía un participante marcado
      // esSolicitante" → "ya no existe ninguno" — el caso real es que el
      // asesor lo borró a mano desde el paso 2 (Participantes). Si eso pasa,
      // el switch de acá debe reflejarlo y apagarse solo — si no, quedaría
      // encendido pero sin ningún participante real detrás, y el próximo
      // "Continuar" lo volvería a crear de la nada.
      listenWhen: (previous, current) =>
          previous.participantes.any((p) => p.esSolicitante) &&
          !current.participantes.any((p) => p.esSolicitante),
      listener: (context, state) {
        if (_solicitanteParticipante) {
          setState(() => _solicitanteParticipante = false);
          _sincronizarCubit();
        }
      },
      child: Stack(
        children: [
          Column(
            children: [
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
                            _canalSeleccionado =
                                _canalSeleccionado?.id == canal.id
                                ? null
                                : canal;
                          });
                          _sincronizarCubit();
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
                              archivo: formState.archivoVoucher,
                              habilitado: widget.modoEdicion,
                              onAdjuntar: () => _adjuntarArchivo(true),
                              onQuitar: () => _quitarArchivo(true),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: BotonAdjuntar(
                              label: 'Adjuntar O/C',
                              archivo: formState.archivoOC,
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
                        onPaisCelularChanged: (p) {
                          setState(() => _paisCelular = p);
                          _sincronizarCubit();
                        },
                        tipoDocInicialId: _tipoDocId.isNotEmpty
                            ? _tipoDocId
                            : null,
                        nacionalidadInicialId: _nacionalidadId.isNotEmpty
                            ? _nacionalidadId
                            : null,
                        sexoInicialId: _sexoId.isNotEmpty ? _sexoId : null,
                        onTipoDocChanged: (item) {
                          setState(() {
                            _tipoDocId = item?.id ?? '';
                            _tipoDocLabel = item?.abreviatura ?? '';
                          });
                          _sincronizarCubit();
                        },
                        onNacionalidadChanged: (item) {
                          setState(() {
                            _nacionalidadId = item?.id ?? '';
                            _nacionalidadLabel = item?.nombre ?? '';
                          });
                          _sincronizarCubit();
                        },
                        onSexoChanged: (item) {
                          setState(() => _sexoId = item?.id ?? '');
                          _sincronizarCubit();
                        },
                        onBuscarDocumento: _buscarDocumentoSolicitante,
                      ),
                      if (tipoPersona == 'juridica') ...[
                        const SizedBox(height: AppSpacing.sm),

                        // ── Información comercial (solo jurídica) ──────────
                        SeccionInfoComercial(
                          habilitado: widget.modoEdicion,
                          ctrlRuc: _ctrlRuc,
                          ctrlRazonSocial: _ctrlRazonSocial,
                          onBuscarRuc: _buscarRucComercial,
                        ),
                      ],
                      const SizedBox(height: AppSpacing.sm),

                      // ── Switches ───────────────────────────────────────
                      SeccionSwitches(
                        solicitanteParticipante: _solicitanteParticipante,
                        facturarAlSolicitante: _facturarAlSolicitante,
                        onSolicitanteChanged: (v) {
                          setState(() => _solicitanteParticipante = v);
                          _sincronizarCubit();
                        },
                        onFacturarChanged: (v) {
                          setState(() => _facturarAlSolicitante = v);
                          _sincronizarCubit();
                        },
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
                              backgroundColor:
                                  AppColors.brandRaspberryAccessible,
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
          if (_buscandoDocSolicitante || _buscandoRuc)
            const AppLoadingOverlay(message: 'Buscando datos del documento...'),
        ],
      ),
    );
  }
}
