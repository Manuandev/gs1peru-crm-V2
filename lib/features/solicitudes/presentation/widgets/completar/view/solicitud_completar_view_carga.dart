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
    // extranjería, etc.), ese default ya no aplica.
    if (formState.numDocLead.isNotEmpty) {
      _ctrlNumDoc.text = formState.numDocLead;
    }
    if (formState.tipoDocIdLead.isNotEmpty) {
      final catalogState = context.read<CatalogsBloc>().state;
      if (catalogState is CatalogsLoaded) {
        final tipoDoc = catalogState.tiposDocumento
            .where((t) => t.id == formState.tipoDocIdLead)
            .firstOrNull;
        if (tipoDoc != null) {
          _tipoDocId = tipoDoc.id;
          _tipoDocLabel = tipoDoc.abreviatura;
        }
      }
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

      final tipoDoc = tiposDocumento
          .where((t) => t.id == detalle.tipoDocId)
          .firstOrNull;
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
      _ctrlNumDoc.text = detalle.numDoc;
      // Ya viene resuelto desde el backend — sembrar acá evita que
      // "Siguiente" dispare una búsqueda RENIEC/SUNAT (con su overlay
      // "Buscando datos del documento...") sobre un documento que no
      // cambió, solo porque se está validando/editando una solicitud ya
      // guardada sin haber tocado el campo. Bug real reportado en vivo,
      // 2026-08-04 — mismo criterio para el RUC comercial más abajo.
      _ultimoDocSolicitanteBuscado = detalle.numDoc;
      _ctrlNombres.text = detalle.nombres;
      _ctrlApellidoPaterno.text = detalle.apellidoPaterno;
      _ctrlApellidoMaterno.text = detalle.apellidoMaterno;
      _ctrlCargo.text = cargoLabel;
      _ctrlCelular.text = detalle.celular;
      _ctrlCorreo.text = detalle.correo;
      _ctrlRuc.text = detalle.ruc;
      _ultimoRucBuscado = detalle.ruc;
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
        cargo: cargoLabel,
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
          numDoc: p.numDoc,
          nacionalidadId: p.nacionalidadId,
          nacionalidad: nacionalidadP?.nombre ?? '',
          nombres: p.nombres,
          apellidoPaterno: p.apellidoPaterno,
          apellidoMaterno: p.apellidoMaterno,
          correo: p.correo,
          cargo: cargoP?.nombre ?? p.cargo,
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
