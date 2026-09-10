part of 'solicitud_completar_view.dart';

// ignore_for_file: invalid_use_of_protected_member
// (setState/widget/context de State son @protected — el lint no reconoce
// que una extensión sobre el propio State, compartiendo library vía `part
// of`, es un uso legítimo; ver el comentario de abajo)

// Carga/prellenado de _SolicitudCompletarViewState — separado en `part`
// (no un archivo/import normal) porque estos 3 métodos leen y escriben
// directamente ~20 campos privados del State (controllers, ids de combo,
// flags) — un archivo aparte con import normal no podría acceder a ellos
// sin volverlos públicos. `part of` comparte el mismo scope privado que
// solicitud_completar_view.dart, así que el comportamiento es idéntico al
// de antes de dividir el archivo — cero cambios en los call sites
// (_sembrarValoresPorDefecto()/_prellenarDesdeNegociacion()/
// _cargarDetalle() se siguen llamando igual desde initState()).
extension _SolicitudCompletarCargaExt on _SolicitudCompletarViewState {
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

  // Al crear una solicitud desde una negociación (`solicitud.idLead` no
  // vacío — los 3 orígenes reales de "Generar solicitud" lo mandan, ver
  // solicitudes/CLAUDE.md), trae esa negociación fresca por idLead y siembra
  // el cubit compartido — mismo GetDatosPrellenadoSolicitudUseCase que
  // también usa el bloque de `idLeadOrigen` más abajo (recuperar cantidad/
  // precio/moneda al EDITAR). Antes estos ~16 valores llegaban ya armados
  // como parámetros de navegación (uno por dato) — se cambió porque cada
  // vez que el SP agregaba un campo (RUC, Cargo, documento) era fácil
  // olvidar threadearlo en los 3 orígenes + la ruta + la page; con un solo
  // fetch acá, agregar un campo nuevo solo toca este método.
  //
  // 2026-08-12 — pasó de GetLeadDetalleUseCase (task 'DT', trae ~40 campos
  // de estado/canal/campaña/oportunidad/chat que este wizard no usa) a
  // GetDatosPrellenadoSolicitudUseCase (task 'NEG' nuevo, dedicado — trae
  // SOLO los 17 campos que sembrarDatosNegociacion necesita). Encontrado en
  // el camino: 'DT' nunca trajo tipoDocId/numDoc en la base real (el fix
  // documentado el 2026-08-04 nunca se desplegó) — 'NEG' sí los trae desde
  // el vamos, confirmado contra el .sql real antes de escribirlo.
  //
  // Si falla (sin conexión, lead borrado) NO bloquea la creación — el
  // asesor puede seguir llenando el formulario a mano, solo pierde el
  // prellenado y los candados de cantidad/precio/moneda (cantidadEsperada
  // queda null). Se avisa con un snackbar para que no piense que el
  // formulario debía llegar prellenado y no lo hizo por otro motivo.
  Future<void> _sembrarDatosDeNegociacionOrigen() async {
    final idLead = int.tryParse(widget.solicitud.idLead);
    if (idLead == null || idLead <= 0) return;

    try {
      final datos = await GetDatosPrellenadoSolicitudUseCase(
        context.read<LeadRepository>(),
      ).call(idLead);
      if (!mounted) return;
      context.read<SolicitudFormCubit>().sembrarDatosNegociacion(
        cantidad: datos.cantidad,
        precioBase: datos.precioBase,
        descuento: datos.descuento,
        idMoneda: datos.idMoneda,
        precioTotal: datos.precio,
        nombres: datos.nombres,
        apellidoPaterno: datos.apellidoPaterno,
        apellidoMaterno: datos.apellidoMaterno,
        nombreEmpresa: datos.nombreEmpresa,
        correo: datos.correo,
        celular: datos.celular,
        celularCodigoTelefono: datos.celularCodigoTelefono,
        ruc: datos.ruc,
        cargo: datos.cargo,
        tipoDocId: datos.tipoDocId,
        numDoc: datos.numDoc,
      );
    } catch (_) {
      if (!mounted) return;
      AppSnackBar.error(
        context,
        'No se pudo cargar la negociación de origen — complete los datos manualmente',
      );
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

    // N° documento del contacto — 2026-08-04, antes quedaba vacío al crear
    // desde una negociación. Tipo documento SÍ se sobreescribe (a diferencia
    // del resto de este método, que solo llena controllers) porque
    // _sembrarValoresPorDefecto() ya corrió antes en _cargarDetalle() y dejó
    // el default DNI — si el contacto real tiene otro tipo (Carnet de
    // extranjería, etc.), ese default ya no aplica. Se resuelve el tipo
    // ANTES del número (orden importa, 2026-08-12) para poder truncar el
    // número al máximo real de ese tipo — ver DocumentoValidationUtils.
    // limitarLongitud, necesario porque un dato sucio del backend (ej. un
    // N° documento guardado sin validación desde otra pantalla) no se
    // trunca solo al asignarse directo al controller.
    List<TipoDocumentoItem> tiposDocumento = const [];
    ValoresCRMItem valoresDefecto = const ValoresCRMItem();
    if (formState.tipoDocIdLead.isNotEmpty) {
      final catalogState = context.read<CatalogsBloc>().state;
      if (catalogState is CatalogsLoaded) {
        tiposDocumento = catalogState.tiposDocumento;
        valoresDefecto = catalogState.valoresDefecto;
        final tipoDoc = tiposDocumento
            .where((t) => t.id == formState.tipoDocIdLead)
            .firstOrNull;
        if (tipoDoc != null) {
          _tipoDocId = tipoDoc.id;
          _tipoDocLabel = tipoDoc.abreviatura;
        }
      }
    }
    if (formState.numDocLead.isNotEmpty) {
      _ctrlNumDoc.text = DocumentoValidationUtils.limitarLongitud(
        _tipoDocId,
        formState.numDocLead,
        tiposDocumento,
        valoresDefecto,
      );
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
      await _sembrarDatosDeNegociacionOrigen();
      if (!mounted) return;
      _prellenarDesdeNegociacion();
      setState(() => _cargando = false);
      // Creación nueva — `numSol` sigue vacío, así que
      // `guardarBorradorCompleto()` siempre va a guardar sin importar este
      // flag (ver `solicitudSinCambiosPendientes`), pero se deja igual de
      // consistente que la rama de edición.
      context.read<SolicitudFormCubit>().marcarSinCambios();
      context.read<ParticipantesCubit>().marcarSinCambios();
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
      final ubigeoTodos = catalogState is CatalogsLoaded
          ? catalogState.ubigeo
          : const <UbigeoItem>[];
      final cargos = catalogState is CatalogsLoaded
          ? catalogState.cargos
          : const <CargoItem>[];
      final valoresDefecto = catalogState is CatalogsLoaded
          ? catalogState.valoresDefecto
          : const ValoresCRMItem();

      // Código telefónico del celular — el backend (task 'DT') NO trae este
      // dato ni para el solicitante ni para facturación (solo el número,
      // `detalle.celular`/`facCelular`), así que no hay ningún valor "real"
      // que restaurar — el mismo criterio de siempre (Perú por defecto,
      // `valoresDefecto.idPais`) se resuelve acá, UNA sola vez, y se siembra
      // en los 2 snapshots de abajo. Bug real corregido, 2026-08-12:
      // antes este campo se dejaba sin setear en ambos snapshots (quedaba
      // en '' por default del constructor) mientras que `_construirDatos
      // Solicitante()`/`_construirDatosFacturacion()` (llamados en CADA
      // "Siguiente") siempre lo resuelven a Perú vía el mismo fallback que
      // ya usa build() — la comparación `solicitante != solicitanteCargado`/
      // `facturacion != facturacionCargado` (`SolicitudFormState.huboCambios`)
      // nunca daba igual, así que "Siguiente" disparaba un guardado real
      // aunque el asesor no hubiera tocado nada.
      final paisDefectoCelular =
          paises.where((p) => p.id == valoresDefecto.idPais).firstOrNull ??
          (paises.isEmpty ? null : paises.first);
      _paisCelular = paisDefectoCelular;

      final tipoDoc = tiposDocumento
          .where((t) => t.id == detalle.tipoDocId)
          .firstOrNull;
      // Trunca al máximo real del tipo — dato ya guardado en el backend
      // puede exceder el límite (guardado desde antes de que existiera esta
      // validación, o desde otra pantalla sin el mismo candado). Se calcula
      // acá y se reusa en todo el bloque (controller, tracker de búsqueda y
      // el snapshot que se manda al cubit) para que los 3 queden
      // consistentes entre sí — ver DocumentoValidationUtils.limitarLongitud.
      final numDocSolicitante = DocumentoValidationUtils.limitarLongitud(
        detalle.tipoDocId,
        detalle.numDoc,
        tiposDocumento,
        valoresDefecto,
      );
      final nacionalidad = nacionalidades
          .where((n) => n.id == detalle.nacionalidadId)
          .firstOrNull;
      // Cargo vuelve a guardarse siempre como texto libre (2026-08-12) — este
      // match por id solo cubre solicitudes guardadas entre el 2026-07-30 y
      // ahora, cuando sí se guardaba el id del catálogo; si no matchea (texto
      // libre, de antes o de ahora), cae a mostrar el valor crudo tal cual.
      final cargo = cargos.where((c) => c.id == detalle.cargo).firstOrNull;
      final cargoLabel = cargo?.nombre ?? detalle.cargo;
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
      _ctrlNumDoc.text = numDocSolicitante;
      // Ya viene resuelto desde el backend — sembrar acá evita que
      // "Siguiente" dispare una búsqueda RENIEC/SUNAT (con su overlay
      // "Buscando datos del documento...") sobre un documento que no
      // cambió, solo porque se está validando/editando una solicitud ya
      // guardada sin haber tocado el campo. Bug real reportado en vivo,
      // 2026-08-04 — mismo criterio para el RUC comercial más abajo.
      _ultimoDocSolicitanteBuscado = numDocSolicitante;
      _ctrlNombres.text = detalle.nombres;
      _ctrlApellidoPaterno.text = detalle.apellidoPaterno;
      _ctrlApellidoMaterno.text = detalle.apellidoMaterno;
      _ctrlCargo.text = cargoLabel;
      _ctrlCelular.text = detalle.celular;
      _ctrlCorreo.text = detalle.correo;
      _ctrlRuc.text = detalle.ruc;
      _ultimoRucBuscado = detalle.ruc;
      _ctrlRazonSocial.text = detalle.razonSocial;

      // Reusa la MISMA función que arma el payload en cada "Siguiente"
      // (_construirDatosSolicitante, solicitud_completar_view_guardado.dart)
      // en vez de reconstruir un DatosSolicitante aparte a mano — antes esta
      // segunda copia se desincronizaba en silencio de la real (le faltaba
      // `celularCodigoTelefono` por completo y no aplicaba `_mayus()` a
      // nombres/apellidos/cargo/correo/razón social), así que el snapshot
      // "cargado" nunca calzaba exacto contra lo que "Siguiente" volvía a
      // construir — `SolicitudFormState.huboCambios` daba `true` SIEMPRE,
      // aunque el asesor no tocara nada, disparando un guardado real en
      // cada "Siguiente". Con una sola función fuente de verdad, este tipo
      // de desincronización ya no puede volver a pasar (bug real,
      // 2026-08-12). Todos los controllers/campos que lee ya están
      // sembrados arriba en este mismo método.
      final datosSolicitante = _construirDatosSolicitante(_paisCelular);

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
        // Trunca al máximo real del tipo — mismo criterio que numDocSolicitante
        // más arriba (dato ya guardado en el backend puede exceder el límite).
        final facNumDoc = DocumentoValidationUtils.limitarLongitud(
          detalle.facTipoDocId,
          detalle.facNumDoc,
          tiposDocumento,
          valoresDefecto,
        );
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

        // Ubigeo de facturación — el código de 6 dígitos que guardó el CUD
        // (dpto+prov+dis, 2 c/u) recién empezó a volver del SP el
        // 2026-07-30 (detalle.facUbigeoCodigo, campo nuevo); antes se
        // guardaba bien pero nunca se leía de vuelta, así que los 3 combos
        // quedaban vacíos al reabrir la solicitud. Mismo criterio de
        // "nivel" que usa el resto del feature para Ubigeo (ver
        // core/CLAUDE.md → UbigeoItem): prov=='00'&&dis=='00' es
        // departamento, prov!='00'&&dis=='00' es provincia.
        final ubigeoCodigo = detalle.facUbigeoCodigo;
        final ubigeoDptoId = ubigeoCodigo.length >= 2
            ? ubigeoCodigo.substring(0, 2)
            : '';
        final ubigeoProvId = ubigeoCodigo.length >= 4
            ? ubigeoCodigo.substring(2, 4)
            : '';
        final ubigeoDisId = ubigeoCodigo.length >= 6
            ? ubigeoCodigo.substring(4, 6)
            : '';
        final ubigeoDpto = ubigeoTodos
            .where(
              (u) => u.dpto == ubigeoDptoId && u.prov == '00' && u.dis == '00',
            )
            .firstOrNull;
        final ubigeoProv = ubigeoTodos
            .where(
              (u) =>
                  u.dpto == ubigeoDptoId &&
                  u.prov == ubigeoProvId &&
                  u.dis == '00',
            )
            .firstOrNull;
        final ubigeoDis = ubigeoTodos
            .where(
              (u) =>
                  u.dpto == ubigeoDptoId &&
                  u.prov == ubigeoProvId &&
                  u.dis == ubigeoDisId,
            )
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
            numDoc: facNumDoc,
            nombresRazon: esRuc ? detalle.facNomEmpre : detalle.facNombres,
            apellidoPaterno: esRuc ? '' : detalle.facApellidoPaterno,
            apellidoMaterno: esRuc ? '' : detalle.facApellidoMaterno,
            celular: detalle.facCelular,
            // El backend tampoco trae este código para facturación (mismo
            // gap que el solicitante, ver comentario de `paisDefectoCelular`
            // más arriba) — sin esto, `_SolicitudFacturacionViewState.
            // _restaurarPaso()` caía a `_paisCelular = null` (su condición
            // `datos.celularCodigoTelefono.isNotEmpty` nunca se cumplía),
            // mientras que `_construirDatosFacturacion()` en cada "Siguiente"
            // del paso 3 sí lo resolvía a Perú — mismo bug real de
            // "Siguiente sube cambios sin que el asesor toque nada",
            // replicado acá.
            celularCodigoTelefono: paisDefectoCelular?.codigoTelefono ?? '',
            correo: detalle.facCorreo,
            direccion: detalle.facDireccion,
            actividadEconomica: '',
            nit: '',
            observaciones: '',
            ubigeoDptoId: ubigeoDptoId,
            ubigeoDptoNombre: ubigeoDpto?.nombre ?? '',
            ubigeoProvId: ubigeoProvId,
            ubigeoProvNombre: ubigeoProv?.nombre ?? '',
            ubigeoDisId: ubigeoDisId,
            ubigeoDisNombre: ubigeoDis?.nombre ?? '',
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
        // Mismo criterio que el cargo del solicitante (arriba) — solo cubre
        // participantes guardados entre el 2026-07-30 y ahora, cuando p.cargo
        // sí traía el id del CargoItem; si no matchea, se muestra tal cual.
        final cargoP = cargos.where((c) => c.id == p.cargo).firstOrNull;
        return ParticipanteLocal(
          id: int.tryParse(p.id) ?? 0,
          tipoDocId: p.tipoDocId,
          tipoDoc: tipoDocP?.abreviatura ?? '',
          numDoc: DocumentoValidationUtils.limitarLongitud(
            p.tipoDocId,
            p.numDoc,
            tiposDocumento,
            valoresDefecto,
          ),
          nacionalidadId: p.nacionalidadId,
          nacionalidad: nacionalidadP?.nombre ?? '',
          nombres: p.nombres,
          apellidoPaterno: p.apellidoPaterno,
          apellidoMaterno: p.apellidoMaterno,
          correo: p.correo,
          cargo: cargoP?.nombre ?? p.cargo,
          celular: p.celular,
          // Mismo gap que el solicitante/facturación (arriba) — el backend
          // tampoco trae este código para cada participante. Sin esto, si
          // el asesor abre "Editar" sobre un participante ya guardado y
          // presiona "Guardar" sin tocar nada, `participante_form_sheet.
          // dart._guardar()` sí lo resuelve a Perú — quedaba distinto del
          // participante cargado (`''`), marcando un cambio falso.
          celularCodigoTelefono: paisDefectoCelular?.codigoTelefono ?? '',
          tipoParticipante: p.tipoParticipante,
          importe: p.importe,
          esSolicitante: p.id == detalle.idParticipanteSolicitante,
        );
      }).toList();

      if (!mounted) return;
      context.read<ParticipantesCubit>().cargarParticipantes(participantes);

      // Montos ya guardados (DC_IMPORTE/DC_IGV/DC_IMPORTE_TOTAL) — al
      // revisar/editar se muestran y se vuelven a mandar TAL CUAL mientras
      // el dinero de los participantes no cambie, en vez de recalcularlos
      // contra el precio actual de la negociación (bug real 2026-09-10, ver
      // calcularTotalesSolicitud() en solicitud_guardar_helper.dart).
      context.read<SolicitudFormCubit>().actualizarTotalesGuardados(
        TotalesSolicitud(
          inversion: detalle.dcImporte,
          igv: detalle.dcIgv,
          importeTotal: detalle.dcImporteTotal,
        ),
      );

      // Recupera la negociación de origen (si existe) para que "Nuevo
      // participante" pueda seguir sugiriendo el importe correcto aunque se
      // esté editando una solicitud ya guardada — antes esto se perdía
      // apenas se guardaba la solicitud por primera vez, porque
      // cantidadEsperada/precioTotalLead solo se sembraban al crear (ver
      // solicitudes/CLAUDE.md).
      final idLeadOrigen = int.tryParse(detalle.idLeadOrigen);
      if (idLeadOrigen != null && idLeadOrigen > 0) {
        try {
          // 2026-08-12 — mismo cambio que _sembrarDatosDeNegociacionOrigen()
          // (task 'NEG', dedicado) — acá solo se usan 5 de sus 17 campos
          // (cantidad/precio/descuento/moneda), el resto de la respuesta se
          // descarta sin problema, igual que antes con 'DT'.
          final datos = await GetDatosPrellenadoSolicitudUseCase(
            context.read<LeadRepository>(),
          ).call(idLeadOrigen);
          if (!mounted) return;
          context.read<SolicitudFormCubit>().sembrarDatosNegociacion(
            cantidad: datos.cantidad,
            precioBase: datos.precioBase,
            descuento: datos.descuento,
            idMoneda: datos.idMoneda,
            precioTotal: datos.precio,
          );
        } catch (_) {
          // Sin negociación recuperable — el importe de "Nuevo
          // participante" queda sin sugerencia, el asesor lo escribe a
          // mano (ya es editable, no bloquea nada).
        }
      }

      // Marca esto como la línea base "sin cambios" — recién a partir de
      // acá cualquier edición real del asesor hace que
      // `SolicitudFormState.huboCambios` pase a `true` (comparación por
      // contenido contra este snapshot, ver ese getter). `ParticipantesCubit`
      // ya quedó marcado dentro de `cargarParticipantes()` (arriba).
      context.read<SolicitudFormCubit>().marcarSinCambios();

      setState(() => _cargando = false);
    } catch (e) {
      if (!mounted) return;
      setState(() => _cargando = false);
      AppSnackBar.error(context, 'No se pudo cargar la solicitud: $e');
    }
  }
}
