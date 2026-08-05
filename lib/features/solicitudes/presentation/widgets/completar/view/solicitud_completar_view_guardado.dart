part of 'solicitud_completar_view.dart';

// ignore_for_file: invalid_use_of_protected_member
// (setState/widget/context de State son @protected — el lint no reconoce
// que una extensión sobre el propio State, compartiendo library vía `part
// of`, es un uso legítimo; ver el comentario de abajo)

// Búsqueda de documento + construcción de payload + validación/guardado de
// _SolicitudCompletarViewState — mismo motivo que
// solicitud_completar_view_carga.dart para usar `part of` en vez de un
// archivo con import normal: estos métodos leen y escriben directamente los
// campos privados del State (controllers, ids de combo, flags). Cero
// cambios en los call sites — todo se sigue llamando igual desde build()/
// initState() del archivo principal.
extension _SolicitudCompletarGuardadoExt on _SolicitudCompletarViewState {
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

  // Fuerza MAYÚSCULAS en texto libre al armar el payload — mismo criterio
  // que EditContactoPortrait._mayus() (lead/CLAUDE.md, "Todo texto libre se
  // guarda en MAYÚSCULAS"). Segunda capa además de isUpperCase:true en los
  // CustomTextField (feedback visual mientras se tipea) — necesaria porque
  // el autocompletado por documento (RENIEC/SUNAT) y el prellenado desde
  // negociación asignan texto directo al controller, sin pasar por el
  // formatter del widget. Nunca aplicar a campos numéricos/de documento
  // (N° documento, RUC, celular).
  String _mayus(String s) => s.trim().toUpperCase();

  DatosSolicitante _construirDatosSolicitante(PaisItem? paisCelular) {
    final archivos = context.read<SolicitudFormCubit>().state;
    return DatosSolicitante(
      tipoDocId: _tipoDocId,
      tipoDocLabel: _tipoDocLabel,
      // Mayúsculas también acá — DNI es solo dígitos (no-op), pero Carnet de
      // extranjería/Pasaporte pueden traer letras (mismo criterio ya usado
      // en participante_form_sheet.dart).
      numDoc: _mayus(_ctrlNumDoc.text),
      nacionalidadId: _nacionalidadId,
      nacionalidad: _nacionalidadLabel,
      sexoId: _sexoId,
      nombres: _mayus(_ctrlNombres.text),
      apellidoPaterno: _mayus(_ctrlApellidoPaterno.text),
      apellidoMaterno: _mayus(_ctrlApellidoMaterno.text),
      cargo: _mayus(_ctrlCargo.text),
      cargoId: _cargoId,
      celular: _ctrlCelular.text,
      celularCodigoTelefono: paisCelular?.codigoTelefono ?? '',
      correo: _mayus(_ctrlCorreo.text),
      canalId: _canalSeleccionado?.id,
      canalNombre: _canalSeleccionado?.esDetallado == true
          ? _mayus(_ctrlCanalDetalle.text)
          : (_canalSeleccionado?.descripcion ?? ''),
      ruc: _ctrlRuc.text,
      razonSocial: _mayus(_ctrlRazonSocial.text),
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
  // (solicitud_participantes_view.dart, `BotonSeccionSmall` deshabilitado
  // al llegar al máximo): si la solicitud viene de una negociación con
  // cantidad ya definida (`cantidadEsperada`) y ya se alcanzó ese máximo, no
  // se deja activar el switch — se avisa por qué en vez de dejar que se
  // entere recién al presionar "Generar solicitud" en Resumen. Apagarlo
  // (quitar al solicitante de la lista) siempre está permitido, nunca se
  // bloquea esa dirección.
  //
  // Bug real reportado por el usuario, 2026-07-24 — este método solo
  // sincronizaba `SolicitudFormCubit` (vía `_sincronizarCubit()`);
  // `ParticipantesCubit.sincronizarSolicitante()` recién se llamaba al
  // presionar "Siguiente". Efecto real: apagar el switch no quitaba al
  // participante de la lista todavía — si el asesor lo volvía a prender de
  // inmediato (sin pasar por "Siguiente" primero), el chequeo del máximo de
  // arriba leía `ParticipantesCubit` con la lista vieja (el participante
  // seguía ahí) y bloqueaba con "Ya se alcanzó el máximo...", aunque el
  // switch ya se veía apagado en pantalla. Corregido: ahora sincroniza
  // ambos cubits al toque, no solo al continuar.
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

    final datos = _construirDatosSolicitante(_paisCelular);
    context.read<SolicitudFormCubit>().guardarSolicitante(datos);
    context.read<ParticipantesCubit>().sincronizarSolicitante(
      datos,
      idTipoParticipantePagante: _idTipoParticipantePagante(),
      importeFijo: _importeFijo(),
    );
  }

  // "Facturar al solicitante" tiene que reflejarse en Facturación (paso 3)
  // de inmediato, no solo cuando ese paso ya esté vivo en el wizard — antes
  // el auto-completado solo pasaba dentro de SolicitudFacturacionView (por
  // BlocListener o al construirse por primera vez), así que activar/
  // desactivar el switch ANTES de haber visitado el paso 3 una vez no tenía
  // ningún efecto hasta llegar ahí (bug real reportado en vivo). Ahora se
  // escribe directo en SolicitudFormCubit desde acá, con el mismo cálculo
  // que usa el paso 3 (construirFacturacionDesdeSolicitante) — así, cuando
  // el asesor llegue a Facturación, `formState.facturacion` ya viene
  // correcto sin importar el orden en que tocó las pantallas. Activar
  // completa TODOS los datos del solicitante (Jurídica: Factura+RUC+Razón
  // social; Natural: Boleta+DNI+Nombres), desactivar borra la facturación
  // por completo para que se vuelva a completar de cero.
  void _onFacturarAlSolicitanteChanged(bool v, PaisItem? paisCelular) {
    setState(() => _facturarAlSolicitante = v);
    _sincronizarCubit();

    final formCubit = context.read<SolicitudFormCubit>();
    if (!v) {
      formCubit.limpiarFacturacion();
      return;
    }

    final catalogState = context.read<CatalogsBloc>().state;
    if (catalogState is! CatalogsLoaded) return;
    final formState = formCubit.state;
    formCubit.guardarFacturacion(
      construirFacturacionDesdeSolicitante(
        solicitante: _construirDatosSolicitante(paisCelular),
        tipoPersona: formState.tipoPersona,
        catalogos: catalogState,
        monedaIdActual: formState.facturacion?.monedaId,
        idMonedaBloqueada: formState.idMonedaBloqueada,
      ),
    );
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

    // Red de seguridad — normalmente estas búsquedas ya corrieron por el
    // blur/check del teclado de cada campo (ver FocusNode en
    // SeccionDatosSolicitante/SeccionInfoComercial), pero si por lo que sea
    // no llegaron a dispararse (bug real reportado en vivo en Facturación,
    // mismo patrón acá), "Siguiente" terminaba validando con Nombres/
    // Apellidos/Razón social todavía vacíos. Ambas son idempotentes — si el
    // documento/RUC ya se buscó, no repiten la llamada.
    await _buscarDocumentoSolicitante();
    await _buscarRucComercial();
    if (!mounted) return;

    // Recién acá se activa la validación en tiempo real (ver _autovalidar) —
    // antes de este primer click ningún campo se marca en rojo por solo
    // escribir/tocarlo.
    setState(() => _autovalidar = true);

    // Marca en rojo cada campo/combo obligatorio que falte, con su propio
    // mensaje "Requerido" — reemplaza el snackbar genérico de antes.
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final datos = _construirDatosSolicitante(paisCelular);
    context.read<SolicitudFormCubit>().guardarSolicitante(datos);
    context.read<ParticipantesCubit>().sincronizarSolicitante(
      datos,
      idTipoParticipantePagante: _idTipoParticipantePagante(),
      importeFijo: _importeFijo(),
    );

    // Nada cambió desde que se cargó esta solicitud — avanza directo, sin
    // mostrar spinner ni overlay de guardado (ver
    // solicitudSinCambiosPendientes, solicitud_guardar_helper.dart).
    if (solicitudSinCambiosPendientes(context)) {
      widget.onContinuar();
      return;
    }

    setState(() => _guardando = true);

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
}
