// lib/features/solicitudes/presentation/widgets/completar/solicitud_facturacion_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/solicitudes/index_solicitudes.dart';

class SolicitudFacturacionView extends StatefulWidget {
  final Solicitud solicitud;
  final bool modoEdicion;
  // Avanza al paso 4 (Resumen) dentro del mismo SolicitudWizardView.
  final VoidCallback onContinuar;
  // Retrocede al paso 2 (Participantes) dentro del mismo SolicitudWizardView.
  final VoidCallback onAtras;

  const SolicitudFacturacionView({
    super.key,
    required this.solicitud,
    required this.modoEdicion,
    required this.onContinuar,
    required this.onAtras,
  });

  @override
  State<SolicitudFacturacionView> createState() =>
      _SolicitudFacturacionViewState();
}

class _SolicitudFacturacionViewState extends State<SolicitudFacturacionView> {
  // Valida los campos obligatorios (*) del paso in situ — mismo patrón que
  // el paso 1 (ver solicitud_completar_view.dart._formKey).
  final _formKey = GlobalKey<FormState>();

  // Igual que en el paso 1 — arranca en false para que nada se marque en
  // rojo hasta el primer "Siguiente"; de ahí en adelante los campos se
  // limpian solos al corregirlos (ver _onContinuar).
  bool _autovalidar = false;

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
  String _nacionalidadLabel = '';

  // Ubigeo (Departamento/Provincia/Distrito) — solo aplica cuando el país
  // elegido es Perú (ver _esExtranjero). Provincia depende del Departamento
  // elegido, Distrito depende de Departamento+Provincia — ver
  // _onUbigeoDptoChanged/_onUbigeoProvChanged, que resetean los niveles
  // hijos al cambiar el padre.
  String _ubigeoDptoId = '';
  String _ubigeoDptoNombre = '';
  String _ubigeoProvId = '';
  String _ubigeoProvNombre = '';
  String _ubigeoDisId = '';
  String _ubigeoDisNombre = '';

  // País del código telefónico del celular — catálogo real vía CatalogsBloc
  PaisItem? _paisCelular;

  // Evita pre-rellenar más de una vez
  bool _prefillDone = false;

  // true mientras `didChangeDependencies()` está restaurando el paso (desde
  // el cubit compartido o con los defaults) — a diferencia de `_prefillDone`
  // (que se marca en `true` al INICIO del método para no reentrar), este
  // flag se apaga recién al final de esa restauración. Sin esto, asignar
  // `.text` a un controller durante la restauración disparaba su listener
  // (`_onCampoTexto` → `_sincronizarCubit()`), que con `_prefillDone` ya en
  // `true` prendía `SolicitudFormState.huboCambios` como si el asesor
  // hubiera editado algo — pasaba con solo entrar por primera vez a este
  // paso de una solicitud ya guardada, sin tocar nada.
  bool _restaurando = true;

  // true mientras se guarda el borrador (botón "Guardar")
  bool _guardando = false;

  // Pasos del guardado (Guardar solicitud → Subiendo voucher/O.C.) para
  // el overlay de progreso — ver solicitud_progreso_guardado.dart.
  final SolicitudProgreso _progreso = SolicitudProgreso();

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

  // Autocompletado por documento (Clientes/BuscarDocumento) — mismo patrón
  // que Datos del solicitante y Nuevo participante (ver solicitudes/CLAUDE.md).
  final _documentoService = DocumentoExternoService();
  bool _buscandoDocumento = false;
  String _ultimoDocBuscado = '';

  // Ids reales de catálogo (SYSTABEXTER02) usados en las reglas de este
  // paso — vienen de `CatalogsBloc.valoresDefecto` (parte [13] del SP), no
  // hardcodeados. Si el catálogo aún no cargó, caen a '' (los combos de
  // arriba tampoco tendrían datos todavía en ese caso).
  ValoresCRMItem get _valoresDefecto {
    final catalogState = context.read<CatalogsBloc>().state;
    return catalogState is CatalogsLoaded
        ? catalogState.valoresDefecto
        : const ValoresCRMItem();
  }

  String get _idComprobanteFactura => _valoresDefecto.idTipoFactura;
  String get _idComprobanteBoleta => _valoresDefecto.idTipoBoleta;
  String get _idTipoDocRuc => _valoresDefecto.idTipoDocRuc;

  bool get _esRuc => _tipoDocId == _idTipoDocRuc;

  // País distinto de Perú (pedido de negocio, 2026-07-21) — cuando aplica,
  // Comprobante se restringe a Boleta (Factura no corresponde a un
  // extranjero), Tipo documento se restringe a "Otros" y Nacionalidad se
  // oculta (se manda vacía, no aplica para un país que no es Perú).
  bool get _esExtranjero =>
      _paisId.isNotEmpty && _paisId != _valoresDefecto.idPais;

  void _onCampoTexto() {
    setState(() {});
    _sincronizarCubit();
  }

  // Empuja el draft actual (ids de combos + texto de inputs, aunque estén
  // vacíos) a SolicitudFormCubit en cada cambio — así el paso 3 nunca pierde
  // datos al moverse a otro paso dentro del wizard, sin depender de que se
  // presione "Continuar"/"Guardar". No sincroniza hasta que el prefill
  // inicial (didChangeDependencies) haya terminado, para no pisarlo con un
  // draft vacío a medio construir.
  void _sincronizarCubit() {
    if (!_prefillDone || _restaurando || !mounted) return;
    context.read<SolicitudFormCubit>().guardarFacturacion(
      _construirDatosFacturacion(_paisCelular),
    );
  }

  // Autocompleta Nombres/Apellidos/Correo (o solo Razón Social si el tipo de
  // documento es RUC) por DNI (8 dígitos) o RUC (11) al salir del campo
  // Número documento/RUC o presionar el check del teclado — mismo servicio y
  // mismo patrón que Datos del solicitante y Nuevo participante.
  Future<void> _buscarDocumento() async {
    final numDoc = _ctrlNumDoc.text.trim();
    final esBusqueda = numDoc.length == 8 || numDoc.length == 11;
    if (!esBusqueda || numDoc == _ultimoDocBuscado) return;
    _ultimoDocBuscado = numDoc;

    setState(() => _buscandoDocumento = true);
    try {
      final resultado = await _documentoService.buscar(numDoc);
      if (!mounted) return;
      if (resultado == null || resultado.sinDatos) return;

      if (_esRuc) {
        if (resultado.nomEmpresa.isNotEmpty) {
          _ctrlNombresRazon.text = resultado.nomEmpresa;
        }
      } else {
        if (resultado.nombres.isNotEmpty) {
          _ctrlNombresRazon.text = resultado.nombres;
        } else if (resultado.nomEmpresa.isNotEmpty) {
          _ctrlNombresRazon.text = resultado.nomEmpresa;
        }
        if (resultado.apePaterno.isNotEmpty) {
          _ctrlApellidoPaterno.text = resultado.apePaterno;
        }
        if (resultado.apeMaterno.isNotEmpty) {
          _ctrlApellidoMaterno.text = resultado.apeMaterno;
        }
      }
      if (resultado.correo.isNotEmpty) {
        _ctrlCorreo.text = resultado.correo;
      }
      // Solo RUC/SUNAT trae dirección — DNI/RENIEC no, resultado.direccion
      // llega vacío en ese caso y el if no hace nada.
      if (resultado.direccion.isNotEmpty) {
        _ctrlDireccion.text = resultado.direccion;
      }
    } catch (_) {
      if (!mounted) return;
      AppSnackBar.error(
        context,
        'No se pudo autocompletar los datos del documento.',
      );
    } finally {
      if (mounted) setState(() => _buscandoDocumento = false);
    }
  }

  DatosFacturacion _construirDatosFacturacion(PaisItem? paisCelular) {
    return DatosFacturacion(
      comprobanteId: _comprobanteId,
      comprobante: _comprobanteLabel,
      paisId: _paisId,
      pais: _paisLabel,
      monedaId: _monedaId,
      moneda: _monedaLabel,
      tipoDocId: _tipoDocId,
      tipoDocLabel: _tipoDocLabel,
      numDoc: _ctrlNumDoc.text,
      nacionalidadId: _nacionalidadId,
      nacionalidad: _nacionalidadLabel,
      nombresRazon: _ctrlNombresRazon.text,
      apellidoPaterno: _ctrlApellidoPaterno.text,
      apellidoMaterno: _ctrlApellidoMaterno.text,
      celular: _ctrlCelular.text,
      celularCodigoTelefono: paisCelular?.codigoTelefono ?? '',
      correo: _ctrlCorreo.text,
      direccion: _ctrlDireccion.text,
      actividadEconomica: '',
      nit: _ctrlNit.text,
      observaciones: _ctrlObservaciones.text,
      ubigeoDptoId: _ubigeoDptoId,
      ubigeoDptoNombre: _ubigeoDptoNombre,
      ubigeoProvId: _ubigeoProvId,
      ubigeoProvNombre: _ubigeoProvNombre,
      ubigeoDisId: _ubigeoDisId,
      ubigeoDisNombre: _ubigeoDisNombre,
    );
  }

  // Campos obligatorios (marcados con *) del paso 3 — todos, menos apellido
  // materno, actividad económica, NIT y observaciones. Apellido paterno solo
  // aplica cuando el tipo de documento NO es RUC. Cada campo valida su
  // propio CustomTextField/CustomComboField (ver _formKey en
  // _SeccionDatosFacturacion) — ya no hay un getter de "todo completo" acá.
  //
  // "Siguiente" (2026-07-17, pedido de negocio): valida los campos
  // obligatorios y GUARDA de verdad (borrador) antes de avanzar a Resumen —
  // mismo patrón que los pasos 1 y 2. El botón "Guardar" del medio se
  // eliminó, "Siguiente" ya cumple esa función.
  //
  // OJO — en modo solo-ver (modoEdicion == false) no se valida ni se
  // guarda, es un recorrido de solo lectura, solo avanza.
  Future<void> _onContinuar(PaisItem? paisCelular) async {
    if (!widget.modoEdicion) {
      widget.onContinuar();
      return;
    }

    if (_guardando) return;

    // Recién acá se activa la validación en tiempo real (ver _autovalidar).
    setState(() => _autovalidar = true);

    // Marca en rojo cada campo/combo obligatorio que falte, con su propio
    // mensaje "Requerido" — reemplaza el snackbar genérico de antes.
    if (!(_formKey.currentState?.validate() ?? false)) return;

    context.read<SolicitudFormCubit>().guardarFacturacion(
      _construirDatosFacturacion(paisCelular),
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
      pasoOrigen: '3',
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
  void initState() {
    super.initState();
    for (final ctrl in [
      _ctrlNumDoc,
      _ctrlNombresRazon,
      _ctrlApellidoPaterno,
      _ctrlApellidoMaterno,
      _ctrlCelular,
      _ctrlCorreo,
      _ctrlDireccion,
      _ctrlNit,
      _ctrlObservaciones,
    ]) {
      ctrl.addListener(_onCampoTexto);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_prefillDone) return;
    _prefillDone = true;
    // `_restaurando` se apaga recién en el `finally`, después de terminar
    // TODA la restauración (sin importar cuál de los 3 `return` de abajo se
    // tome) — ver comentario en la declaración del campo.
    try {
      _restaurarPaso();
    } finally {
      _restaurando = false;
    }
  }

  void _restaurarPaso() {
    final formState = context.read<SolicitudFormCubit>().state;
    final datos = formState.facturacion;
    if (datos != null) {
      // Ya se guardó facturación antes (venimos de "Atrás") — restaurar.
      _comprobanteId = datos.comprobanteId;
      _comprobanteLabel = datos.comprobante;
      _tipoDocId = datos.tipoDocId;
      _tipoDocLabel = datos.tipoDocLabel;
      _paisId = datos.paisId;
      _paisLabel = datos.pais;
      _monedaId = datos.monedaId;
      _monedaLabel = datos.moneda;
      _nacionalidadId = datos.nacionalidadId;
      _nacionalidadLabel = datos.nacionalidad;
      _ctrlNumDoc.text = datos.numDoc;
      _ctrlNombresRazon.text = datos.nombresRazon;
      _ctrlApellidoPaterno.text = datos.apellidoPaterno;
      _ctrlApellidoMaterno.text = datos.apellidoMaterno;
      _ctrlCelular.text = datos.celular;
      _ctrlCorreo.text = datos.correo;
      _ctrlDireccion.text = datos.direccion;
      _ctrlNit.text = datos.nit;
      _ctrlObservaciones.text = datos.observaciones;
      _ubigeoDptoId = datos.ubigeoDptoId;
      _ubigeoDptoNombre = datos.ubigeoDptoNombre;
      _ubigeoProvId = datos.ubigeoProvId;
      _ubigeoProvNombre = datos.ubigeoProvNombre;
      _ubigeoDisId = datos.ubigeoDisId;
      _ubigeoDisNombre = datos.ubigeoDisNombre;

      if (datos.celularCodigoTelefono.isNotEmpty) {
        final catalogState = context.read<CatalogsBloc>().state;
        if (catalogState is CatalogsLoaded) {
          _paisCelular = catalogState.paises
              .where((p) => p.codigoTelefono == datos.celularCodigoTelefono)
              .firstOrNull;
        }
      }
      return;
    }

    // Solicitud generada desde una negociación con precio ya definido — la
    // moneda no se elige acá, viene fija del lead (ver
    // SolicitudFormState.idMonedaBloqueada).
    final idMonedaBloqueada = formState.idMonedaBloqueada;
    if (idMonedaBloqueada != null && idMonedaBloqueada.isNotEmpty) {
      _monedaId = idMonedaBloqueada;
      final catalogState = context.read<CatalogsBloc>().state;
      if (catalogState is CatalogsLoaded) {
        _monedaLabel =
            catalogState.monedas
                .where((m) => m.id == idMonedaBloqueada)
                .firstOrNull
                ?.nombre ??
            '';
      }
    }

    // Primera vez en este paso — si el solicitante marcó "Facturar al
    // solicitante", autocompletar con sus mismos datos. Pedido de negocio,
    // 2026-07-17. El caso "activó el switch después de haber entrado una vez
    // a este paso" lo cubre el BlocListener del build() de más abajo — ver
    // comentario en _aplicarDatosSolicitante.
    final solicitante = formState.solicitante;
    if (solicitante != null && solicitante.facturarAlSolicitante) {
      _aplicarDatosSolicitante(solicitante, formState.tipoPersona);
      return;
    }

    // Ni datos guardados ni "Facturar al solicitante" — Comprobante y Tipo
    // documento arrancan según el tipo de persona del paso 1: Jurídica →
    // Factura/RUC, Natural → Boleta/DNI (antes Tipo documento siempre caía
    // en DNI sin importar el tipo de persona, y Comprobante no tenía
    // ningún default). Nacionalidad/País mantienen su propio default fijo
    // (Perú), igual que Datos del solicitante y Nuevo participante (ver
    // solicitudes/CLAUDE.md). Pedido de negocio, 2026-07-17.
    final catalogState = context.read<CatalogsBloc>().state;
    if (catalogState is CatalogsLoaded) {
      final valoresDefecto = catalogState.valoresDefecto;
      final esJuridica = formState.tipoPersona == 'juridica';

      final idComprobanteDefecto = esJuridica
          ? valoresDefecto.idTipoFactura
          : valoresDefecto.idTipoBoleta;
      final comprobanteDefecto = catalogState.comprobantes
          .where((c) => c.id == idComprobanteDefecto)
          .firstOrNull;
      if (comprobanteDefecto != null) {
        _comprobanteId = comprobanteDefecto.id;
        _comprobanteLabel = comprobanteDefecto.nombre;
      }

      final idTipoDocDefecto = esJuridica
          ? valoresDefecto.idTipoDocRuc
          : valoresDefecto.idTipoDocDni;
      final tipoDocDefecto = catalogState.tiposDocumento
          .where((t) => t.id == idTipoDocDefecto)
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
      // Bug real detectado en vivo: a diferencia de Tipo documento/
      // Nacionalidad, "País" nunca tenía un default — se quedaba vacío
      // hasta que el asesor lo tocara a mano, y si no lo hacía, se guardaba
      // vacío (ID_PAIS nunca llegaba al backend).
      final paisDefecto = catalogState.paises
          .where((p) => p.id == valoresDefecto.idPais)
          .firstOrNull;
      if (paisDefecto != null) {
        _paisId = paisDefecto.id;
        _paisLabel = paisDefecto.nombre;
      }
    }
  }

  // Aplica los datos del solicitante (paso 1) a los campos de este paso —
  // Jurídica pinta RUC + Razón Social (capturados en "Información
  // comercial", paso 1 — DatosSolicitante.ruc/razonSocial, NO los datos
  // personales); Natural pinta el documento personal + nombres/apellidos tal
  // cual los tiene el solicitante.
  //
  // Se llama en 2 momentos: (1) didChangeDependencies, la primera vez que
  // este paso se construye con el switch ya activo, y (2) el BlocListener de
  // build() de más abajo, cada vez que el switch pasa de apagado a encendido
  // mientras este paso ya está vivo en el IndexedStack. Bug real detectado
  // en vivo: antes esto solo corría en (1) — como el paso nunca se destruye
  // dentro del wizard (IndexedStack), activar el switch DESPUÉS de haber
  // visitado este paso una vez (aunque sea sin haber tocado nada) no
  // reflejaba nada al volver, porque `didChangeDependencies` ya se había
  // marcado como hecho (`_prefillDone`) y `formState.facturacion` ya existía
  // (con los defaults de la rama "sin datos"), así que la rama de acá nunca
  // se volvía a evaluar.
  void _aplicarDatosSolicitante(
    DatosSolicitante solicitante,
    String tipoPersona,
  ) {
    final esJuridica = tipoPersona == 'juridica';
    final catalogState = context.read<CatalogsBloc>().state;

    if (esJuridica) {
      if (catalogState is CatalogsLoaded) {
        final valoresDefecto = catalogState.valoresDefecto;
        final factura = catalogState.comprobantes
            .where((c) => c.id == valoresDefecto.idTipoFactura)
            .firstOrNull;
        if (factura != null) {
          _comprobanteId = factura.id;
          _comprobanteLabel = factura.nombre;
        }
        // Jurídica solo puede facturar con RUC — se fuerza el tipo
        // documento para que la UI muestre RUC/Razón Social en vez de
        // Número documento/Nombres/Apellidos (ver esRuc).
        final ruc = catalogState.tiposDocumento
            .where((t) => t.id == valoresDefecto.idTipoDocRuc)
            .firstOrNull;
        if (ruc != null) {
          _tipoDocId = ruc.id;
          _tipoDocLabel = ruc.abreviatura;
        }
      }
      _ctrlNumDoc.text = solicitante.ruc;
      _ctrlNombresRazon.text = solicitante.razonSocial;
    } else {
      if (catalogState is CatalogsLoaded) {
        final boleta = catalogState.comprobantes
            .where((c) => c.id == catalogState.valoresDefecto.idTipoBoleta)
            .firstOrNull;
        if (boleta != null) {
          _comprobanteId = boleta.id;
          _comprobanteLabel = boleta.nombre;
        }
      }
      _tipoDocId = solicitante.tipoDocId;
      _tipoDocLabel = solicitante.tipoDocLabel;
      _ctrlNumDoc.text = solicitante.numDoc;
      _ctrlNombresRazon.text = solicitante.nombres;
      _ctrlApellidoPaterno.text = solicitante.apellidoPaterno;
      _ctrlApellidoMaterno.text = solicitante.apellidoMaterno;
    }

    _nacionalidadId = solicitante.nacionalidadId;
    _nacionalidadLabel = solicitante.nacionalidad;
    _ctrlCelular.text = solicitante.celular;
    _ctrlCorreo.text = solicitante.correo;

    if (catalogState is CatalogsLoaded) {
      _paisCelular = catalogState.paises
          .where((p) => p.codigoTelefono == solicitante.celularCodigoTelefono)
          .firstOrNull;
      // DatosSolicitante no tiene "País" (solo Nacionalidad) — mismo default
      // que la rama sin datos previos. Sin esto "País" se quedaba vacío
      // también en este camino (mismo bug real).
      final paisDefecto = catalogState.paises
          .where((p) => p.id == catalogState.valoresDefecto.idPais)
          .firstOrNull;
      if (paisDefecto != null) {
        _paisId = paisDefecto.id;
        _paisLabel = paisDefecto.nombre;
      }
    }
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
    _progreso.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState = context.watch<SolicitudFormCubit>().state;
    final facturarAlSolicitante =
        formState.solicitante?.facturarAlSolicitante ?? false;
    final catalogState = context.watch<CatalogsBloc>().state;
    final tiposDocumentoTodos = catalogState is CatalogsLoaded
        ? catalogState.tiposDocumento
        : const <TipoDocumentoItem>[];
    final nacionalidades = catalogState is CatalogsLoaded
        ? catalogState.nacionalidades
        : const <NacionalidadItem>[];
    final paises = catalogState is CatalogsLoaded
        ? catalogState.paises
        : const <PaisItem>[];
    final comprobantesTodos = catalogState is CatalogsLoaded
        ? catalogState.comprobantes
        : const <ComprobanteItem>[];
    final ubigeoTodos = catalogState is CatalogsLoaded
        ? catalogState.ubigeo
        : const <UbigeoItem>[];

    // Ubigeo en cascada — Departamento (prov/dis en '00'), Provincia (dis en
    // '00', filtrada por el Departamento elegido) y Distrito (filtrada por
    // Departamento+Provincia). Solo se muestran con país Perú (!esExtranjero,
    // ver _SeccionDatosFacturacion).
    final ubigeoDepartamentos = ubigeoTodos
        .where((u) => u.prov == '00' && u.dis == '00')
        .toList();
    final ubigeoProvincias = ubigeoTodos
        .where(
          (u) => u.dpto == _ubigeoDptoId && u.prov != '00' && u.dis == '00',
        )
        .toList();
    final ubigeoDistritos = ubigeoTodos
        .where(
          (u) =>
              u.dpto == _ubigeoDptoId &&
              u.prov == _ubigeoProvId &&
              u.dis != '00',
        )
        .toList();

    // "Otros" en Tipo documento — sin id fijo en ValoresCRMItem (el catálogo
    // real no trae uno), se ubica por nombre. Si el catálogo real no tiene
    // ningún ítem "Otros", este fallback queda en null y la restricción de
    // extranjero simplemente no se aplica sobre Tipo documento (se deja la
    // lista completa) — avisar a negocio si esto pasa en producción.
    final tipoDocOtros = tiposDocumentoTodos
        .where((t) => t.nombre.toUpperCase().contains('OTRO'))
        .firstOrNull;

    // Solo Factura/Boleta se muestran en este combo (aunque el catálogo
    // real traiga también N. Crédito/N. Débito). Con un país distinto de
    // Perú, Factura no aplica — solo Boleta.
    final comprobantes = _esExtranjero
        ? comprobantesTodos.where((c) => c.id == _idComprobanteBoleta).toList()
        : comprobantesTodos
              .where(
                (c) =>
                    c.id == _idComprobanteFactura ||
                    c.id == _idComprobanteBoleta,
              )
              .toList();
    // Con país extranjero, Tipo documento se restringe a "Otros" (si existe
    // en el catálogo). Si no, sigue la regla de siempre: Factura exige RUC,
    // Boleta admite cualquier tipo de documento.
    final tiposDocumento = _esExtranjero
        ? (tipoDocOtros != null ? [tipoDocOtros] : tiposDocumentoTodos)
        : (_comprobanteId == _idComprobanteFactura
              ? tiposDocumentoTodos.where((t) => t.id == _idTipoDocRuc).toList()
              : tiposDocumentoTodos);
    final correoLabel = _comprobanteId == _idComprobanteFactura
        ? 'Correo para envío de factura *'
        : 'Correo para envío de boleta *';

    final paisCelular =
        _paisCelular ??
        (paises.isEmpty
            ? null
            : paises.where((p) => p.id == _valoresDefecto.idPais).firstOrNull ??
                  paises.first);

    // Re-sincroniza este paso con el solicitante cuando "Facturar al
    // solicitante" pasa de apagado a encendido MIENTRAS este paso ya está
    // vivo en el IndexedStack (volver al paso 1, activar el switch, volver
    // acá) — ver comentario completo en _aplicarDatosSolicitante.
    return BlocListener<SolicitudFormCubit, SolicitudFormState>(
      listenWhen: (previous, current) =>
          current.solicitante?.facturarAlSolicitante == true &&
          previous.solicitante?.facturarAlSolicitante != true,
      listener: (context, state) {
        final solicitante = state.solicitante;
        if (solicitante == null) return;
        setState(
          () => _aplicarDatosSolicitante(solicitante, state.tipoPersona),
        );
        _sincronizarCubit();
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
                    // Desactivada hasta el primer "Siguiente" — ver
                    // _autovalidar / solicitud_completar_view.dart.
                    autovalidateMode: _autovalidar
                        ? AutovalidateMode.onUserInteraction
                        : AutovalidateMode.disabled,
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
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),

                        // ── Formulario ─────────────────────────────────────
                        _SeccionDatosFacturacion(
                          habilitado: widget.modoEdicion,
                          esRuc: _esRuc,
                          esExtranjero: _esExtranjero,
                          correoLabel: correoLabel,
                          ctrlNumDoc: _ctrlNumDoc,
                          ctrlNombresRazon: _ctrlNombresRazon,
                          ctrlApellidoPaterno: _ctrlApellidoPaterno,
                          ctrlApellidoMaterno: _ctrlApellidoMaterno,
                          ctrlCelular: _ctrlCelular,
                          ctrlCorreo: _ctrlCorreo,
                          ctrlDireccion: _ctrlDireccion,
                          tiposDocumento: tiposDocumento,
                          nacionalidades: nacionalidades,
                          paises: paises,
                          comprobantes: comprobantes,
                          ubigeoDepartamentos: ubigeoDepartamentos,
                          ubigeoProvincias: ubigeoProvincias,
                          ubigeoDistritos: ubigeoDistritos,
                          ubigeoDptoInicialId: _ubigeoDptoId.isNotEmpty
                              ? _ubigeoDptoId
                              : null,
                          ubigeoProvInicialId: _ubigeoProvId.isNotEmpty
                              ? _ubigeoProvId
                              : null,
                          ubigeoDisInicialId: _ubigeoDisId.isNotEmpty
                              ? _ubigeoDisId
                              : null,
                          onUbigeoDptoChanged: (item) {
                            setState(() {
                              _ubigeoDptoId = item?.dpto ?? '';
                              _ubigeoDptoNombre = item?.nombre ?? '';
                              // Cambiar el Departamento invalida la
                              // Provincia/Distrito ya elegidos — dependen de
                              // este nivel.
                              _ubigeoProvId = '';
                              _ubigeoProvNombre = '';
                              _ubigeoDisId = '';
                              _ubigeoDisNombre = '';
                            });
                            _sincronizarCubit();
                          },
                          onUbigeoProvChanged: (item) {
                            setState(() {
                              _ubigeoProvId = item?.prov ?? '';
                              _ubigeoProvNombre = item?.nombre ?? '';
                              // Cambiar la Provincia invalida el Distrito.
                              _ubigeoDisId = '';
                              _ubigeoDisNombre = '';
                            });
                            _sincronizarCubit();
                          },
                          onUbigeoDisChanged: (item) {
                            setState(() {
                              _ubigeoDisId = item?.dis ?? '';
                              _ubigeoDisNombre = item?.nombre ?? '';
                            });
                            _sincronizarCubit();
                          },
                          paisCelular: paisCelular,
                          onPaisCelularChanged: (p) {
                            setState(() => _paisCelular = p);
                            _sincronizarCubit();
                          },
                          comprobanteInicialId: _comprobanteId.isNotEmpty
                              ? _comprobanteId
                              : null,
                          paisInicialId: _paisId.isNotEmpty ? _paisId : null,
                          onComprobanteChanged: (item) {
                            setState(() {
                              _comprobanteId = item?.id ?? '';
                              _comprobanteLabel = item?.nombre ?? '';
                              if (_comprobanteId == _idComprobanteFactura) {
                                // Factura exige RUC — se fuerza el tipo documento.
                                final ruc = tiposDocumentoTodos
                                    .where((t) => t.id == _idTipoDocRuc)
                                    .firstOrNull;
                                _tipoDocId = ruc?.id ?? '';
                                _tipoDocLabel = ruc?.abreviatura ?? '';
                                _ctrlNumDoc.clear();
                              }
                            });
                            _sincronizarCubit();
                          },
                          onPaisChanged: (item) {
                            setState(() {
                              _paisId = item?.id ?? '';
                              _paisLabel = item?.nombre ?? '';
                              if (_esExtranjero) {
                                // País distinto de Perú — Factura no
                                // aplica, se fuerza Boleta.
                                final boleta = comprobantesTodos
                                    .where((c) => c.id == _idComprobanteBoleta)
                                    .firstOrNull;
                                if (boleta != null) {
                                  _comprobanteId = boleta.id;
                                  _comprobanteLabel = boleta.nombre;
                                }
                                // Se fuerza Tipo documento "Otros" (si el
                                // catálogo real lo trae).
                                if (tipoDocOtros != null) {
                                  _tipoDocId = tipoDocOtros.id;
                                  _tipoDocLabel = tipoDocOtros.abreviatura;
                                  _ctrlNumDoc.clear();
                                }
                                // Nacionalidad no aplica para un país que no
                                // es Perú — se manda vacía.
                                _nacionalidadId = '';
                                _nacionalidadLabel = '';
                                // Ubigeo tampoco aplica — solo existe para Perú.
                                _ubigeoDptoId = '';
                                _ubigeoDptoNombre = '';
                                _ubigeoProvId = '';
                                _ubigeoProvNombre = '';
                                _ubigeoDisId = '';
                                _ubigeoDisNombre = '';
                              }
                            });
                            _sincronizarCubit();
                          },
                          tipoDocInicialId: _tipoDocId.isNotEmpty
                              ? _tipoDocId
                              : null,
                          nacionalidadInicialId: _nacionalidadId.isNotEmpty
                              ? _nacionalidadId
                              : null,
                          onTipoDocChanged: (item) {
                            setState(() {
                              _tipoDocId = item?.id ?? '';
                              _tipoDocLabel = item?.abreviatura ?? '';
                              _ctrlNumDoc.clear();
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
                          onBuscarDocumento: _buscarDocumento,
                        ),
                      ],
                    ),
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
                              colorFondo: AppColors.brandForest.withOpacity(
                                0.12,
                              ),
                              label: 'Facturar al solicitante',
                              valor: facturarAlSolicitante ? 'Sí' : 'No',
                            ),
                          ),
                          VerticalDivider(
                            width: AppSpacing.md,
                            thickness: 1,
                            color: AppColors.border,
                          ),
                          Expanded(
                            child:
                                BlocBuilder<
                                  ParticipantesCubit,
                                  ParticipantesState
                                >(
                                  builder: (context, state) => _ItemResumen(
                                    icono: AppIcons.users,
                                    colorIcono: AppColors.warning,
                                    colorFondo: AppColors.warning.withOpacity(
                                      0.12,
                                    ),
                                    label: 'Participantes pagantes',
                                    valor: state.participantes
                                        .where(
                                          (p) =>
                                              p.tipoParticipante ==
                                              '1', // Pagante
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
                    // "Siguiente" valida y guarda (borrador) antes de
                    // avanzar — ya no hay botón "Guardar" aparte. En modo
                    // solo-ver (modoEdicion == false) solo se muestra
                    // "Siguiente", sin validar ni guardar — recorrido de
                    // lectura.
                    widget.modoEdicion
                        ? Row(
                            children: [
                              Expanded(
                                child: CustomSecondaryButton(
                                  text: 'Atrás',
                                  icon: AppIcons.back,
                                  backgroundColor:
                                      AppColors.brandRaspberryAccessible,
                                  onPressed: widget.onAtras,
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
                  ],
                ),
              ),
            ],
          ),
          if (_buscandoDocumento)
            const AppLoadingOverlay(message: 'Buscando datos del documento...'),
          SolicitudProgresoOverlay(progreso: _progreso),
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

// ── Sección Datos de facturación ─────────────────────────────────────────────
//
// Los campos de identidad cambian según el tipo de documento (esRuc):
// RUC -> RUC + Razón Social. Cualquier otro -> Número documento + Nombres +
// Apellido paterno + Apellido materno (opcional).

class _SeccionDatosFacturacion extends StatefulWidget {
  final bool habilitado;
  final bool esRuc;
  // País distinto de Perú (paso 3) — oculta Nacionalidad (no aplica, se
  // manda vacía). Comprobante/Tipo documento ya llegan pre-filtrados por el
  // padre en ese caso (solo Boleta / solo "Otros").
  final bool esExtranjero;
  final String correoLabel;
  final TextEditingController ctrlNumDoc;
  final TextEditingController ctrlNombresRazon;
  final TextEditingController ctrlApellidoPaterno;
  final TextEditingController ctrlApellidoMaterno;
  final TextEditingController ctrlCelular;
  final TextEditingController ctrlCorreo;
  final TextEditingController ctrlDireccion;
  final List<TipoDocumentoItem> tiposDocumento;
  final List<NacionalidadItem> nacionalidades;
  final List<PaisItem> paises;
  final List<ComprobanteItem> comprobantes;
  // Ubigeo en cascada — ya filtrados por el padre según Departamento/
  // Provincia elegidos (ver SolicitudFacturacionView.build). Solo se
  // muestran si !esExtranjero.
  final List<UbigeoItem> ubigeoDepartamentos;
  final List<UbigeoItem> ubigeoProvincias;
  final List<UbigeoItem> ubigeoDistritos;
  final String? ubigeoDptoInicialId;
  final String? ubigeoProvInicialId;
  final String? ubigeoDisInicialId;
  final ValueChanged<UbigeoItem?>? onUbigeoDptoChanged;
  final ValueChanged<UbigeoItem?>? onUbigeoProvChanged;
  final ValueChanged<UbigeoItem?>? onUbigeoDisChanged;
  final PaisItem? paisCelular;
  final ValueChanged<PaisItem> onPaisCelularChanged;
  final String? comprobanteInicialId;
  final String? paisInicialId;
  final String? tipoDocInicialId;
  final String? nacionalidadInicialId;
  final ValueChanged<ComprobanteItem?>? onComprobanteChanged;
  final ValueChanged<PaisItem?>? onPaisChanged;
  final ValueChanged<TipoDocumentoItem?>? onTipoDocChanged;
  final ValueChanged<NacionalidadItem?>? onNacionalidadChanged;
  // Autocompletado por documento (Clientes/BuscarDocumento) — se dispara al
  // perder foco o al presionar el check del teclado en Número documento/RUC.
  // El indicador de carga es un overlay de pantalla completa que arma el
  // padre (SolicitudFacturacionView), no algo local a este campo.
  final VoidCallback? onBuscarDocumento;

  const _SeccionDatosFacturacion({
    required this.habilitado,
    required this.esRuc,
    required this.esExtranjero,
    required this.correoLabel,
    required this.ctrlNumDoc,
    required this.ctrlNombresRazon,
    required this.ctrlApellidoPaterno,
    required this.ctrlApellidoMaterno,
    required this.ctrlCelular,
    required this.ctrlCorreo,
    required this.ctrlDireccion,
    required this.tiposDocumento,
    required this.nacionalidades,
    required this.paises,
    required this.comprobantes,
    required this.ubigeoDepartamentos,
    required this.ubigeoProvincias,
    required this.ubigeoDistritos,
    this.ubigeoDptoInicialId,
    this.ubigeoProvInicialId,
    this.ubigeoDisInicialId,
    this.onUbigeoDptoChanged,
    this.onUbigeoProvChanged,
    this.onUbigeoDisChanged,
    required this.paisCelular,
    required this.onPaisCelularChanged,
    this.comprobanteInicialId,
    this.paisInicialId,
    this.tipoDocInicialId,
    this.nacionalidadInicialId,
    this.onComprobanteChanged,
    this.onPaisChanged,
    this.onTipoDocChanged,
    this.onNacionalidadChanged,
    this.onBuscarDocumento,
  });

  @override
  State<_SeccionDatosFacturacion> createState() =>
      _SeccionDatosFacturacionState();
}

class _SeccionDatosFacturacionState extends State<_SeccionDatosFacturacion> {
  late final FocusNode _numDocFocus;

  @override
  void initState() {
    super.initState();
    _numDocFocus = FocusNode()..addListener(_onNumDocFocusChange);
  }

  void _onNumDocFocusChange() {
    if (_numDocFocus.hasFocus) return; // solo al perder el foco
    widget.onBuscarDocumento?.call();
  }

  @override
  void dispose() {
    _numDocFocus.removeListener(_onNumDocFocusChange);
    _numDocFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Fila 1: País + Comprobante — Moneda ya no se muestra (pedido de
        // negocio, 2026-07-21), el valor sigue viajando por detrás tal cual
        // ya se resolvía antes de este cambio (ver
        // SolicitudFacturacionView._construirDatosFacturacion). Orden
        // (País primero) pedido de negocio, 2026-07-22.
        Row(
          children: [
            Expanded(
              child: CustomComboField<PaisItem>(
                label: 'País *',
                data: widget.paises,
                enabled: widget.habilitado,
                initialValue: widget.paisInicialId,
                onChanged: widget.onPaisChanged,
                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: CustomComboField<ComprobanteItem>(
                label: 'Comprobante *',
                data: widget.comprobantes,
                enabled: widget.habilitado,
                initialValue: widget.comprobanteInicialId,
                onChanged: widget.onComprobanteChanged,
                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),

        // Fila 2: Tipo documento + Número documento / RUC — sin
        // restricciones de longitud/teclado por tipo de documento (pedido
        // de negocio, 2026-07-22: ya no se usa DocumentoValidationUtils
        // acá, solo un tope fijo de 12 caracteres, texto libre, sin
        // importar si es RUC/DNI/Otros). A diferencia de Datos del
        // solicitante y Nuevo participante, que SÍ siguen usando ese
        // utilitario tal cual — este cambio es solo para Facturación.
        Row(
          children: [
            Expanded(
              child: CustomComboField<TipoDocumentoItem>(
                label: 'Tipo documento *',
                data: widget.tiposDocumento,
                labelIndex: 2, // abreviatura (DNI/CE/RUC/Pasaporte...)
                enabled: widget.habilitado,
                initialValue: widget.tipoDocInicialId,
                onChanged: widget.onTipoDocChanged,
                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: CustomTextField(
                label: 'Número documento *',
                controller: widget.ctrlNumDoc,
                focusNode: _numDocFocus,
                maxLength: 12,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => widget.onBuscarDocumento?.call(),
                enabled: widget.habilitado,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Requerido' : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),

        // Fila 3: Nacionalidad (ancho completo, oculta si el país no es
        // Perú — no aplica, se manda vacía)
        if (!widget.esExtranjero) ...[
          CustomComboField<NacionalidadItem>(
            label: 'Nacionalidad *',
            data: widget.nacionalidades,
            enabled: widget.habilitado,
            initialValue: widget.nacionalidadInicialId,
            onChanged: widget.onNacionalidadChanged,
            validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
          ),
          const SizedBox(height: AppSpacing.xs),
        ],

        // Fila 4: Nombres / Razón social (ancho completo)
        CustomTextField(
          label: widget.esRuc ? 'Razón Social *' : 'Nombres *',
          controller: widget.ctrlNombresRazon,
          enabled: widget.habilitado,
          isUpperCase: true,
          textCapitalization: TextCapitalization.words,
          validator: (v) => v == null || v.trim().isEmpty ? 'Requerido' : null,
        ),
        const SizedBox(height: AppSpacing.xs),

        // Fila 5: Apellido paterno + Apellido materno — solo persona natural
        if (!widget.esRuc) ...[
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  label: 'Apellido paterno *',
                  controller: widget.ctrlApellidoPaterno,
                  enabled: widget.habilitado,
                  isUpperCase: true,
                  textCapitalization: TextCapitalization.words,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Requerido' : null,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: CustomTextField(
                  label: 'Apellido materno',
                  hint: 'Opcional',
                  controller: widget.ctrlApellidoMaterno,
                  enabled: widget.habilitado,
                  isUpperCase: true,
                  textCapitalization: TextCapitalization.words,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
        ],

        // Fila 6/7: Ubigeo (Departamento + Provincia, luego Distrito ancho
        // completo) — solo Perú, con combo de búsqueda (tipeas y filtra),
        // pedido de negocio 2026-07-22. Provincia/Distrito llevan una key
        // que cambia con el padre (Departamento/Provincia) para forzar que
        // el combo se remonte limpio cuando el nivel padre cambia —
        // CustomComboSearchField no re-sincroniza initialValue solo (ver
        // CustomComboField, que sí lo hace, para contraste).
        if (!widget.esExtranjero) ...[
          Row(
            children: [
              Expanded(
                child: _ComboBusquedaUbigeo(
                  label: 'Departamento *',
                  items: widget.ubigeoDepartamentos,
                  nivel: (u) => u.dpto,
                  enabled: widget.habilitado,
                  initialValue: widget.ubigeoDptoInicialId,
                  onChanged: widget.onUbigeoDptoChanged,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _ComboBusquedaUbigeo(
                  key: ValueKey('ubigeo-prov-${widget.ubigeoDptoInicialId}'),
                  label: 'Provincia *',
                  items: widget.ubigeoProvincias,
                  nivel: (u) => u.prov,
                  enabled: widget.habilitado,
                  initialValue: widget.ubigeoProvInicialId,
                  onChanged: widget.onUbigeoProvChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          _ComboBusquedaUbigeo(
            key: ValueKey(
              'ubigeo-dis-${widget.ubigeoDptoInicialId}-${widget.ubigeoProvInicialId}',
            ),
            label: 'Distrito *',
            items: widget.ubigeoDistritos,
            nivel: (u) => u.dis,
            enabled: widget.habilitado,
            initialValue: widget.ubigeoDisInicialId,
            onChanged: widget.onUbigeoDisChanged,
          ),
          const SizedBox(height: AppSpacing.xs),
        ],

        // Dirección de domicilio (ancho completo)
        CustomTextField(
          label: 'Dirección de domicilio *',
          controller: widget.ctrlDireccion,
          enabled: widget.habilitado,
          textCapitalization: TextCapitalization.sentences,
          validator: (v) => v == null || v.trim().isEmpty ? 'Requerido' : null,
        ),
        const SizedBox(height: AppSpacing.xs),

        // Correo (ancho completo, línea propia — antes compartía fila con
        // Celular)
        CustomTextField(
          label: widget.correoLabel,
          controller: widget.ctrlCorreo,
          keyboardType: TextInputType.emailAddress,
          enabled: widget.habilitado,
          validator: (v) => v.emailValidator,
        ),
        const SizedBox(height: AppSpacing.xs),

        // Celular (ancho completo, línea propia) — combo de país/prefijo
        // con búsqueda en vez del modal de siempre (solo en Facturación,
        // pedido de negocio 2026-07-22 — SolicitudCampoCelular, usado en
        // Datos del solicitante y Nuevo participante, no se tocó).
        SolicitudCampoCelularBusqueda(
          controller: widget.ctrlCelular,
          habilitado: widget.habilitado,
          paises: widget.paises,
          paisSeleccionado: widget.paisCelular,
          onPaisChanged: widget.onPaisCelularChanged,
          validator: (v) => v == null || v.trim().isEmpty ? 'Requerido' : null,
        ),
      ],
    );
  }
}

// ── Combo de búsqueda para un nivel de Ubigeo (Departamento/Provincia/
// Distrito) — envuelve CustomComboSearchField (core) resolviendo el
// UbigeoItem real a partir del código del nivel elegido (dpto/prov/dis
// según corresponda), ya que ese widget solo maneja pares id¦descripción
// crudos, no objetos tipados.
class _ComboBusquedaUbigeo extends StatelessWidget {
  final String label;
  final List<UbigeoItem> items;
  final String Function(UbigeoItem) nivel;
  final bool enabled;
  final String? initialValue;
  final ValueChanged<UbigeoItem?>? onChanged;

  const _ComboBusquedaUbigeo({
    super.key,
    required this.label,
    required this.items,
    required this.nivel,
    required this.enabled,
    this.initialValue,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final data = items
        .map((u) => '${nivel(u)}${AppConstants.sepCampos}${u.nombre}')
        .toList();

    return CustomComboSearchField(
      data: data,
      label: label,
      enabled: enabled,
      initialValue: initialValue,
      validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
      onChanged: (item) {
        if (item == null) {
          onChanged?.call(null);
          return;
        }
        final seleccionado = items
            .where((u) => nivel(u) == item.id)
            .firstOrNull;
        onChanged?.call(seleccionado);
      },
    );
  }
}
