// lib/features/solicitudes/presentation/widgets/completar/solicitud_completar_view.dart

import 'package:flutter/material.dart';

import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/features/lead/index_lead.dart';
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
  // Valida los campos obligatorios (*) del paso in situ — cada CustomTextField/
  // CustomComboField con `validator` se pone en rojo con su propio mensaje al
  // fallar `_formKey.currentState.validate()`, en vez de un snackbar genérico.
  final _formKey = GlobalKey<FormState>();

  // Arranca en false para que ningún campo se marque en rojo mientras el
  // asesor recién está escribiendo — la validación solo debe empezar al
  // presionar "Siguiente" por primera vez (pedido de negocio). Una vez que
  // eso pasa, se pone en true para que los campos ya marcados se limpien
  // solos al corregirlos, sin esperar a un nuevo "Siguiente" (ver
  // _onContinuar).
  bool _autovalidar = false;

  // true mientras se trae la solicitud del backend (task 'DT') — bloquea el
  // formulario para que los combos (que solo leen su valor inicial una vez,
  // en su propio initState) no se construyan antes de tener los datos.
  bool _cargando = true;

  // true mientras se guarda el borrador (botón "Guardar")
  bool _guardando = false;

  // Pasos del guardado (Guardar solicitud → Subiendo voucher/O.C.) para
  // el overlay de progreso — ver solicitud_progreso_guardado.dart.
  final SolicitudProgreso _progreso = SolicitudProgreso();

  // Nombre del voucher/O.C. ya guardado en el backend (viene de
  // getSolicitudDetalle() al reabrir la solicitud) — vive acá, no en
  // SolicitudFormCubit, porque _construirDatosSolicitante() se llama en
  // cada sync y necesita un valor estable que sobreviva a que el usuario
  // edite otros campos. "Quitar" en un archivo existente limpia esto (sin
  // llamar al backend — no hay una operación de borrado sin reemplazo, solo
  // reemplazo subiendo uno nuevo del mismo tipo, ver CLAUDE.md).
  String _archivoVoucherExistente = '';
  String _archivoOCExistente = '';

  // Canal seleccionado (single-select) — catálogo real vía CatalogsBloc
  CanalExpoItem? _canalSeleccionado;

  // Detalle libre del canal — solo se pide/muestra cuando el canal
  // seleccionado tiene esDetallado == true (ej. "Otros"). Se manda como
  // NOMBRE_CANAL en vez de la descripción del canal (ver
  // _construirDatosSolicitante) — el id del canal (ID_CANAL) sigue viajando
  // normal.
  final _ctrlCanalDetalle = TextEditingController();

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
      _ctrlCanalDetalle,
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

  // Al crear desde "Generar solicitud" (negociación con precio ya definido,
  // `cantidadEsperada != null`) — prellena Nombres/Apellidos/Correo/Celular/
  // Cargo/Razón social con los datos ya capturados en la negociación
  // (`SolicitudFormCubit.sembrarDatosNegociacion`, ver solicitudes/CLAUDE.md).
  // A diferencia de precioBase/descuento/moneda, estos campos NO quedan
  // bloqueados — es solo un prellenado, el asesor los puede corregir si algo
  // cambió desde que se registró la negociación.
  void _prellenarDesdeNegociacion() {
    final formState = context.read<SolicitudFormCubit>().state;
    if (formState.cantidadEsperada == null) return;

    if (formState.nombresLead.isNotEmpty) {
      _ctrlNombres.text = formState.nombresLead;
    }
    if (formState.apellidoPaternoLead.isNotEmpty) {
      _ctrlApellidoPaterno.text = formState.apellidoPaternoLead;
    }
    if (formState.apellidoMaternoLead.isNotEmpty) {
      _ctrlApellidoMaterno.text = formState.apellidoMaternoLead;
    }
    if (formState.correoLead.isNotEmpty) {
      _ctrlCorreo.text = formState.correoLead;
    }
    if (formState.celularLead.isNotEmpty) {
      _ctrlCelular.text = formState.celularLead;
    }
    if (formState.cargoLead.isNotEmpty) {
      _ctrlCargo.text = formState.cargoLead;
    }
    // Nombre de empresa / RUC de la negociación → Razón social / RUC
    // (Información comercial, solo visible con tipo de persona Jurídica —
    // default del wizard).
    if (formState.nombreEmpresaLead.isNotEmpty) {
      _ctrlRazonSocial.text = formState.nombreEmpresaLead;
    }
    if (formState.rucLead.isNotEmpty) {
      _ctrlRuc.text = formState.rucLead;
    }

    if (formState.celularCodigoTelefonoLead.isNotEmpty) {
      final catalogState = context.read<CatalogsBloc>().state;
      if (catalogState is CatalogsLoaded) {
        _paisCelular = catalogState.paises
            .where(
              (p) => p.codigoTelefono == formState.celularCodigoTelefonoLead,
            )
            .firstOrNull;
      }
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
      _prellenarDesdeNegociacion();
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
          ? catalogState.canalesExpo
          : const <CanalExpoItem>[];
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
      _archivoVoucherExistente = voucher == null
          ? ''
          : nombreArchivoConExtension(voucher.nombre, voucher.extension);
      _archivoOCExistente = oc == null
          ? ''
          : nombreArchivoConExtension(oc.nombre, oc.extension);

      _tipoDocId = detalle.tipoDocId;
      _tipoDocLabel = tipoDoc?.abreviatura ?? '';
      _nacionalidadId = detalle.nacionalidadId;
      _nacionalidadLabel = nacionalidad?.nombre ?? '';
      _sexoId = detalle.sexoId;
      _canalSeleccionado = canal;
      _ctrlCanalDetalle.text = canal?.esDetallado == true
          ? detalle.canalNombre
          : '';
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
        archivoVoucherNombre: _archivoVoucherExistente,
        archivoOCNombre: _archivoOCExistente,
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
        final facNacionalidad = nacionalidades
            .where((n) => n.id == detalle.facNacionalidadId)
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
            nacionalidadId: detalle.facNacionalidadId,
            nacionalidad: facNacionalidad?.nombre ?? '',
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

      // Recupera la negociación de origen (si existe) para que "Nuevo
      // participante" pueda seguir sugiriendo el importe correcto aunque se
      // esté editando una solicitud ya guardada — antes esto se perdía
      // apenas se guardaba la solicitud por primera vez, porque
      // cantidadEsperada/precioTotalLead solo se sembraban al crear (ver
      // solicitudes/CLAUDE.md).
      final idLeadOrigen = int.tryParse(detalle.idLeadOrigen);
      if (idLeadOrigen != null && idLeadOrigen > 0) {
        try {
          final negociacion = await GetLeadDetalleUseCase(
            context.read<LeadRepository>(),
          ).call(idLeadOrigen);
          if (!mounted) return;
          context.read<SolicitudFormCubit>().sembrarDatosNegociacion(
            cantidad: negociacion.cantidad,
            precioBase: negociacion.precioBase,
            descuento: negociacion.descuento,
            idMoneda: negociacion.idMoneda,
            precioTotal: negociacion.precio,
          );
        } catch (_) {
          // Sin negociación recuperable — el importe de "Nuevo
          // participante" queda sin sugerencia, el asesor lo escribe a
          // mano (ya es editable, no bloquea nada).
        }
      }

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
      allowedExtensions: SolicitudExtensiones.archivosAdjuntos,
      withData: true, // asegura PlatformFile.bytes en todas las plataformas
    );
    final archivo = resultado?.files.single;
    if (archivo == null) return;

    final extension = archivo.extension?.toLowerCase();
    if (!SolicitudExtensiones.archivosAdjuntos.contains(extension)) {
      if (mounted) {
        AppSnackBar.error(context, 'Solo se permiten archivos PDF o imágenes');
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

  // Si hay un archivo de esta sesión (recién adjuntado), lo quita. Si no —
  // pero sí hay uno ya guardado en el backend — solo limpia la referencia
  // local (no hay operación de borrado sin reemplazo en el backend, ver
  // CLAUDE.md); "Adjuntar" vuelve a habilitarse para elegir uno nuevo, que
  // al guardar reemplaza al anterior (el SP borra por NUMSOL+TIPO antes de
  // insertar).
  void _quitarArchivo(bool esVoucher) {
    final formCubit = context.read<SolicitudFormCubit>();
    if (esVoucher) {
      if (formCubit.state.archivoVoucher != null) {
        formCubit.quitarArchivoVoucher();
      } else {
        setState(() => _archivoVoucherExistente = '');
      }
    } else {
      if (formCubit.state.archivoOC != null) {
        formCubit.quitarArchivoOC();
      } else {
        setState(() => _archivoOCExistente = '');
      }
    }
    _sincronizarCubit();
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
      canalNombre: _canalSeleccionado?.esDetallado == true
          ? _ctrlCanalDetalle.text.trim()
          : (_canalSeleccionado?.descripcion ?? ''),
      ruc: _ctrlRuc.text,
      razonSocial: _ctrlRazonSocial.text,
      solicitanteEsParticipante: _solicitanteParticipante,
      facturarAlSolicitante: _facturarAlSolicitante,
      // Prioridad: archivo recién adjuntado en esta sesión → archivo ya
      // guardado en el backend (si no se quitó) → nada. Antes esto solo
      // miraba el archivo de la sesión, así que cualquier edición de campo
      // (dispara este método) borraba el nombre del archivo ya subido — ver
      // CLAUDE.md, "Bug real — nombre de archivo ya subido se perdía...".
      archivoVoucherNombre:
          archivos.archivoVoucher?.name ?? _archivoVoucherExistente,
      archivoOCNombre: archivos.archivoOC?.name ?? _archivoOCExistente,
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

  // Activar el switch agrega un participante más (el propio solicitante) —
  // mismo candado que ya usa el botón "Nuevo" del paso 2
  // (solicitud_participantes_view.dart, `_BotonSeccionSmall` deshabilitado
  // al llegar al máximo): si la solicitud viene de una negociación con
  // cantidad ya definida (`cantidadEsperada`) y ya se alcanzó ese máximo, no
  // se deja activar el switch — se avisa por qué en vez de dejar que se
  // entere recién al presionar "Generar solicitud" en Resumen. Apagarlo
  // (quitar al solicitante de la lista) siempre está permitido, nunca se
  // bloquea esa dirección.
  void _onSolicitanteParticipanteChanged(bool v) {
    if (v) {
      final cantidadEsperada = context
          .read<SolicitudFormCubit>()
          .state
          .cantidadEsperada;
      final actuales = context.read<ParticipantesCubit>().state.participantes;
      if (cantidadEsperada != null && actuales.length >= cantidadEsperada) {
        AppSnackBar.error(
          context,
          'Ya se alcanzó el máximo de $cantidadEsperada participante(s) — '
          'quita uno en el paso 2 antes de marcar al solicitante como '
          'participante.',
        );
        return;
      }
    }
    setState(() => _solicitanteParticipante = v);
    _sincronizarCubit();
  }

  // null si esta solicitud no viene de una negociación con precio ya
  // definido — mismo cálculo que usa "Nuevo participante"
  // (solicitud_participantes_view.dart._importeFijo, ver el comentario ahí
  // para el detalle de la fórmula — siempre división simple, ya no se
  // ajusta al último para calzar exacto, ver 2026-07-22), necesario acá
  // también porque el switch "El solicitante será participante" genera su
  // propio ParticipanteLocal sin pasar por ese formulario.
  double? _importeFijo() {
    final formState = context.read<SolicitudFormCubit>().state;
    final cantidadEsperada = formState.cantidadEsperada;
    if (cantidadEsperada == null || cantidadEsperada == 0) return null;

    final catalogState = context.read<CatalogsBloc>().state;
    final igvPorcentaje = catalogState is CatalogsLoaded
        ? catalogState.igvPorcentaje
        : 0.0;

    final totalSinIgv = formState.precioTotalLead / (1 + igvPorcentaje / 100);

    return totalSinIgv / cantidadEsperada;
  }

  // Campos obligatorios (marcados con *) del paso 1. Los opcionales
  // (apellido materno, RUC/razón social con Natural, canal) no se exigen —
  // salvo con tipo de persona Jurídica, donde RUC/razón social sí son
  // obligatorios (SeccionInfoComercial, solo se muestra en ese caso), y
  // salvo el detalle del canal, obligatorio cuando el canal elegido tiene
  // esDetallado == true (si no, se mandaría un NOMBRE_CANAL vacío). Cada
  // campo valida su propio CustomTextField/CustomComboField (ver
  // _formKey) — ya no hay un getter de "todo completo" acá.
  //
  // "Siguiente" (2026-07-17, pedido de negocio — revierte el "ya no valida"
  // de la sesión anterior): valida los campos obligatorios y GUARDA de
  // verdad (borrador, IB_BORRADOR=1, incluye subir voucher/O.C.
  // pendientes con el overlay de progreso) antes de avanzar al paso 2. El
  // botón "Guardar" del medio se eliminó de este paso (y de los pasos 2 y
  // 3) — ya no hace falta, "Siguiente" cumple esa función.
  //
  // OJO — en modo solo-ver (modoEdicion == false, se entró por "Continuar"/
  // "Revisar solicitud" desde el detalle, no por "Editar ficha") esto NO
  // aplica — es un recorrido de solo lectura, nunca debe validar ni guardar
  // nada, solo avanzar (bug real detectado en vivo: el primer intento de
  // este cambio no distinguía modoEdicion y guardaba también al solo
  // revisar).
  Future<void> _onContinuar(PaisItem? paisCelular) async {
    if (!widget.modoEdicion) {
      widget.onContinuar();
      return;
    }

    if (_guardando) return;

    // Recién acá se activa la validación en tiempo real (ver _autovalidar) —
    // antes de este primer click ningún campo se marca en rojo por solo
    // escribir/tocarlo.
    setState(() => _autovalidar = true);

    // Marca en rojo cada campo/combo obligatorio que falte, con su propio
    // mensaje "Requerido" — reemplaza el snackbar genérico de antes.
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _guardando = true);

    final datos = _construirDatosSolicitante(paisCelular);
    context.read<SolicitudFormCubit>().guardarSolicitante(datos);
    context.read<ParticipantesCubit>().sincronizarSolicitante(
      datos,
      idTipoParticipantePagante: _idTipoParticipantePagante(),
      importeFijo: _importeFijo(),
    );

    final result = await guardarBorradorCompleto(
      context,
      idLead: widget.solicitud.idLead,
      pasoOrigen: '1',
      progreso: _progreso,
    );

    if (!mounted) return;
    _progreso.reset();
    setState(() => _guardando = false);

    if (result is! CrudOk) {
      mostrarResultadoGuardarSolicitud(context, result);
      return;
    }

    widget.onContinuar();
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
    _ctrlCanalDetalle.dispose();
    _progreso.dispose();
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
    // Solo se muestran los 2 primeros canales del catálogo — pedido del
    // usuario, el resto no se ofrece como opción en "¿Cómo se enteró del
    // evento?".
    final canales = catalogState is CatalogsLoaded
        ? catalogState.canalesExpo
        : const <CanalExpoItem>[];
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
                  child: Form(
                    key: _formKey,
                    // Desactivada hasta el primer "Siguiente" — nada se marca
                    // en rojo solo por escribir/tocar un campo. Una vez que
                    // "Siguiente" marca los campos en rojo (_autovalidar
                    // pasa a true), se limpian solos al corregirlos, sin
                    // esperar a un nuevo intento de "Siguiente".
                    autovalidateMode: _autovalidar
                        ? AutovalidateMode.onUserInteraction
                        : AutovalidateMode.disabled,
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
                        if (_canalSeleccionado?.esDetallado == true) ...[
                          const SizedBox(height: AppSpacing.xs),
                          CustomTextField(
                            label: '¿Desde dónde se enteró? *',
                            hint: 'Ej: Feria, recomendación, etc.',
                            controller: _ctrlCanalDetalle,
                            enabled: widget.modoEdicion,
                            textCapitalization: TextCapitalization.sentences,
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Requerido'
                                : null,
                          ),
                        ],
                        const SizedBox(height: AppSpacing.xs),

                        // ── Botones de adjuntos ────────────────────────────
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: BotonAdjuntar(
                                label: 'Voucher',
                                archivo: formState.archivoVoucher,
                                nombreExistente: _archivoVoucherExistente,
                                habilitado: widget.modoEdicion,
                                onAdjuntar: () => _adjuntarArchivo(true),
                                onQuitar: () => _quitarArchivo(true),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: BotonAdjuntar(
                                label: 'OC',
                                archivo: formState.archivoOC,
                                nombreExistente: _archivoOCExistente,
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
                          onSolicitanteChanged:
                              _onSolicitanteParticipanteChanged,
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
              ),

              // ── Botones de acción fijos al pie ──────────────────────────
              // En modo solo-ver (modoEdicion == false) solo se muestra
              // "Siguiente", sin validar ni guardar — es un recorrido de
              // lectura, no una captura de datos. En modo edición ya no hay
              // botón "Guardar" aparte — "Siguiente" valida y guarda
              // (borrador) antes de avanzar, ver _onContinuar.
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
                            child: CustomPrimaryButton(
                              text: 'Siguiente →',
                              isLoading: _guardando,
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
          SolicitudProgresoOverlay(progreso: _progreso),
        ],
      ),
    );
  }
}
