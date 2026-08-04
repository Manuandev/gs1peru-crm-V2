// lib/features/solicitudes/presentation/widgets/completar/solicitud_facturacion_view.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  // Jurídica/Natural — SOLO de vista, exclusivo de este paso (pedido de
  // negocio, 2026-07-29). No se guarda en DatosFacturacion ni se manda al
  // backend — decide únicamente si este formulario muestra Razón Social
  // (jurídica) o Nombres + Apellido paterno/materno (natural), reemplazando
  // para ese propósito a `_esRuc` (que sigue existiendo, pero solo para la
  // regla "Factura exige RUC" y el autocompletado por documento). Arranca
  // sembrado con el tipo de persona del paso 1 (SolicitudFormState.
  // tipoPersona) la primera vez que se entra a este paso, pero de ahí en
  // adelante es 100% independiente — el asesor lo puede cambiar acá sin que
  // afecte al paso 1 ni viceversa.
  String _tipoPersonaVista = 'natural';

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

  // País distinto de Perú (pedido de negocio, 2026-07-21; 2026-07-29 —
  // cambió de comparar el id contra valoresDefecto.idPais a leer
  // PaisItem.esNacional del catálogo real, mismo campo que ya trae
  // TipoDocumentoItem/NacionalidadItem, ver core/CLAUDE.md) — cuando aplica,
  // Comprobante se restringe a Boleta (Factura no corresponde a un
  // extranjero), Tipo documento se restringe a los tipos con
  // esNacional == false y Nacionalidad se oculta (se manda vacía, no aplica
  // para un país que no es Perú).
  bool get _esExtranjero {
    if (_paisId.isEmpty) return false;
    final catalogState = context.read<CatalogsBloc>().state;
    if (catalogState is! CatalogsLoaded) return false;
    final pais = catalogState.paises
        .where((p) => p.id == _paisId)
        .firstOrNull;
    return pais != null && !pais.esNacional;
  }

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
    // País distinto de Perú — no se consulta Clientes/BuscarDocumento
    // (RENIEC/SUNAT), pedido de negocio 2026-07-29: un documento extranjero
    // no existe en esas fuentes, el asesor completa los datos a mano.
    if (_esExtranjero) return;
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

  // Ver comentario completo en solicitud_completar_view.dart._mayus() —
  // mismo criterio, misma segunda capa (isUpperCase:true en los campos ya
  // cubre el tipeo; esto cubre lo que llega por autocompletado/prellenado).
  String _mayus(String s) => s.trim().toUpperCase();

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
      // Mayúsculas también acá — mismo criterio que el paso 1 (DNI/RUC son
      // dígitos, no-op; Carnet de extranjería/Pasaporte pueden traer letras).
      numDoc: _mayus(_ctrlNumDoc.text),
      nacionalidadId: _nacionalidadId,
      nacionalidad: _nacionalidadLabel,
      nombresRazon: _mayus(_ctrlNombresRazon.text),
      apellidoPaterno: _mayus(_ctrlApellidoPaterno.text),
      apellidoMaterno: _mayus(_ctrlApellidoMaterno.text),
      celular: _ctrlCelular.text,
      celularCodigoTelefono: paisCelular?.codigoTelefono ?? '',
      correo: _mayus(_ctrlCorreo.text),
      direccion: _mayus(_ctrlDireccion.text),
      actividadEconomica: '',
      nit: _ctrlNit.text,
      observaciones: _mayus(_ctrlObservaciones.text),
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

    // Red de seguridad — normalmente _buscarDocumento() ya corrió por el
    // blur/check del teclado en Número documento (ver _numDocFocus en
    // _SeccionDatosFacturacionState), pero si por lo que sea eso no llegó a
    // dispararse (bug real reportado en vivo: en algunos dispositivos ni el
    // check del teclado lo disparaba), "Siguiente" terminaba validando con
    // Nombres/Apellidos todavía vacíos, sin haber intentado autocompletar.
    // Idempotente — si el número ya se buscó, no repite la llamada.
    await _buscarDocumento();
    if (!mounted) return;

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
    // Semilla única del toggle de vista — de ahí en más es independiente
    // del paso 1 (ver comentario en la declaración del campo).
    _tipoPersonaVista = formState.tipoPersona;
    final datos = formState.facturacion;
    if (datos != null) {
      // Ya hay facturación en el cubit — venimos de "Atrás", o el paso 1 ya
      // la calculó al activar "Facturar al solicitante" (ver
      // _onFacturarAlSolicitanteChanged, solicitud_completar_view.dart) antes
      // de que este paso se construyera por primera vez. Bug real corregido
      // 2026-08-04: antes esta rama restauraba SIEMPRE que hubiera datos acá,
      // sin mirar si el switch seguía activo — si la solicitud ya tenía
      // facturación guardada de antes y el asesor desactivaba/reactivaba el
      // switch en el paso 1 sin haber visitado este paso todavía, esta rama
      // mostraba la facturación VIEJA en vez de recalcular. Ahora el paso 1
      // es quien mantiene `formState.facturacion` sincronizado con el switch
      // en todo momento (incluso antes de que este paso exista), así que acá
      // basta con confiar en lo que ya trae el cubit.
      _restaurarDesdeFacturacion(datos);
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

    // Red de seguridad: "Facturar al solicitante" ya está activo pero el
    // cubit todavía no trae `facturacion` (el catálogo no había cargado
    // cuando se tocó el switch en el paso 1) — recalcula acá con el mismo
    // helper que usa ese switch, para no depender de que ese camino haya
    // corrido a tiempo.
    final solicitante = formState.solicitante;
    if (solicitante != null && solicitante.facturarAlSolicitante) {
      final catalogState = context.read<CatalogsBloc>().state;
      if (catalogState is CatalogsLoaded) {
        _restaurarDesdeFacturacion(
          construirFacturacionDesdeSolicitante(
            solicitante: solicitante,
            tipoPersona: formState.tipoPersona,
            catalogos: catalogState,
            idMonedaBloqueada: formState.idMonedaBloqueada,
          ),
        );
        return;
      }
    }

    // Ni datos guardados ni "Facturar al solicitante" — Comprobante y Tipo
    // documento arrancan según el tipo de persona del paso 1: Jurídica →
    // Factura/RUC, Natural → Boleta/DNI (antes Tipo documento siempre caía
    // en DNI sin importar el tipo de persona, y Comprobante no tenía
    // ningún default). Nacionalidad/País/Departamento/Provincia mantienen su
    // propio default fijo (Perú/Perú/Lima/Lima), igual que Datos del
    // solicitante y Nuevo participante (ver solicitudes/CLAUDE.md). Pedido
    // de negocio, 2026-07-17 (Perú) y 2026-08-04 (Lima/Lima).
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

      // Departamento/Provincia siempre Lima/Lima por defecto — pedido de
      // negocio 2026-08-04, sin importar jurídica/natural.
      final ubigeoLimaDpto = resolverUbigeoLimaDepartamento(catalogState.ubigeo);
      final ubigeoLimaProv = resolverUbigeoLimaProvincia(
        catalogState.ubigeo,
        ubigeoLimaDpto?.dpto ?? '',
      );
      if (ubigeoLimaDpto != null) {
        _ubigeoDptoId = ubigeoLimaDpto.dpto;
        _ubigeoDptoNombre = ubigeoLimaDpto.nombre;
      }
      if (ubigeoLimaProv != null) {
        _ubigeoProvId = ubigeoLimaProv.prov;
        _ubigeoProvNombre = ubigeoLimaProv.nombre;
      }
    }
  }

  // Copia un DatosFacturacion (del cubit) a los campos/controllers locales
  // de este paso — único lugar que hace esta asignación, reusado por la
  // restauración inicial y por el BlocListener de más abajo (cada vez que
  // "Facturar al solicitante" cambia mientras este paso ya está vivo).
  void _restaurarDesdeFacturacion(DatosFacturacion datos) {
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
    // Ya viene resuelto (restaurado o recién calculado) — sembrar acá evita
    // que "Siguiente" dispare una búsqueda RENIEC/SUNAT innecesaria sobre un
    // documento que no cambió, mismo bug/mismo fix que
    // solicitud_completar_view.dart._ultimoDocSolicitanteBuscado.
    _ultimoDocBuscado = datos.numDoc;
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
    } else {
      _paisCelular = null;
    }
  }

  // Vacía por completo los campos de este paso — pedido de negocio
  // 2026-08-04: al desactivar "Facturar al solicitante" en el paso 1 (ver
  // _onFacturarAlSolicitanteChanged), toda la facturación se borra para que
  // el asesor la vuelva a completar desde cero, en vez de dejar datos del
  // solicitante ya desvinculados del switch.
  void _limpiarCamposFacturacion() {
    _comprobanteId = '';
    _comprobanteLabel = '';
    _tipoDocId = '';
    _tipoDocLabel = '';
    _paisId = '';
    _paisLabel = '';
    _monedaId = '';
    _monedaLabel = '';
    _nacionalidadId = '';
    _nacionalidadLabel = '';
    _ctrlNumDoc.clear();
    _ultimoDocBuscado = '';
    _ctrlNombresRazon.clear();
    _ctrlApellidoPaterno.clear();
    _ctrlApellidoMaterno.clear();
    _ctrlCelular.clear();
    _ctrlCorreo.clear();
    _ctrlDireccion.clear();
    _ctrlNit.clear();
    _ctrlObservaciones.clear();
    _ubigeoDptoId = '';
    _ubigeoDptoNombre = '';
    _ubigeoProvId = '';
    _ubigeoProvNombre = '';
    _ubigeoDisId = '';
    _ubigeoDisNombre = '';
    _paisCelular = null;
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

    // Tipos de documento "del extranjero"/"nacionales" — TipoDocumentoItem.
    // esNacional (mismo campo real del catálogo que ya usa PaisItem, ver
    // _esExtranjero arriba), reemplaza el fallback frágil de buscar por
    // nombre que contuviera "OTRO". Si el catálogo no trae ninguno de un
    // lado, se deja la lista completa sin restringir (fallback de siempre).
    final tiposDocumentoExtranjero = tiposDocumentoTodos
        .where((t) => !t.esNacional)
        .toList();
    final tiposDocumentoNacional = tiposDocumentoTodos
        .where((t) => t.esNacional)
        .toList();

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
    // Con país extranjero, Tipo documento se restringe a los tipos con
    // esNacional == false. Con país Perú, se restringe a los tipos con
    // esNacional == true (DNI, RUC...) — pedido de negocio 2026-07-30,
    // "que salgan solamente los tipos de documento que son nacionales".
    // Factura sigue exigiendo específicamente RUC (subconjunto de los
    // nacionales), Boleta admite cualquier nacional.
    final tiposDocumento = _esExtranjero
        ? (tiposDocumentoExtranjero.isNotEmpty
              ? tiposDocumentoExtranjero
              : tiposDocumentoTodos)
        : (_comprobanteId == _idComprobanteFactura
              ? tiposDocumentoTodos.where((t) => t.id == _idTipoDocRuc).toList()
              : (tiposDocumentoNacional.isNotEmpty
                    ? tiposDocumentoNacional
                    : tiposDocumentoTodos));
    final correoLabel = _comprobanteId == _idComprobanteFactura
        ? 'Correo para envío de factura *'
        : 'Correo para envío de boleta *';

    // Longitud máxima real (TipoDocumentoItem.canCaracteresMax) + teclado/
    // formatters de Número documento/RUC según el tipo elegido — se busca
    // contra el catálogo completo (tiposDocumentoTodos, no la lista ya
    // filtrada de arriba) porque el tipo seleccionado puede ser cualquiera
    // de esos, sin importar el filtro vigente en este render.
    final numDocMaxLength = DocumentoValidationUtils.maxLength(
      _tipoDocId,
      tiposDocumentoTodos,
    );
    final numDocKeyboardType = DocumentoValidationUtils.keyboardType(
      _tipoDocId,
      _valoresDefecto,
    );
    final numDocInputFormatters = DocumentoValidationUtils.inputFormatters(
      _tipoDocId,
      _valoresDefecto,
    );

    final paisCelular =
        _paisCelular ??
        (paises.isEmpty
            ? null
            : paises.where((p) => p.id == _valoresDefecto.idPais).firstOrNull ??
                  paises.first);

    // Re-sincroniza este paso con "Facturar al solicitante" cada vez que
    // cambia MIENTRAS este paso ya está vivo en el IndexedStack (volver al
    // paso 1, tocar el switch, volver acá) — en cualquier dirección, no solo
    // apagado→encendido: encendido ya deja `formState.facturacion` listo
    // (calculado por solicitud_completar_view.dart._onFacturarAlSolicitanteChanged),
    // apagado lo deja en `null` (`SolicitudFormCubit.limpiarFacturacion()`).
    return BlocListener<SolicitudFormCubit, SolicitudFormState>(
      listenWhen: (previous, current) =>
          current.solicitante?.facturarAlSolicitante !=
          previous.solicitante?.facturarAlSolicitante,
      listener: (context, state) {
        final facturarAlSolicitante =
            state.solicitante?.facturarAlSolicitante ?? false;
        setState(() {
          if (facturarAlSolicitante && state.facturacion != null) {
            _restaurarDesdeFacturacion(state.facturacion!);
          } else if (!facturarAlSolicitante) {
            _limpiarCamposFacturacion();
          }
        });
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
                        // Toggle Jurídica/Natural (SOLO de vista, ver
                        // comentario en _tipoPersonaVista) vive en la misma
                        // fila que el ícono/título — pedido de negocio
                        // 2026-07-30: antes iba en su propia fila debajo,
                        // dejando un hueco en blanco cuando no aplicaba
                        // (país Perú, ver más abajo). Solo se muestra con
                        // país extranjero — con Perú, Razón Social vs
                        // Nombres/Apellidos se decide como siempre por Tipo
                        // documento == RUC (_esRuc), el toggle no aplica ahí
                        // ("jurídica/natural me sirve cuando es extranjero").
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
                            if (_esExtranjero) ...[
                              const SizedBox(width: AppSpacing.sm),
                              SolicitudToggleTipoPersona(
                                valor: _tipoPersonaVista,
                                habilitado: widget.modoEdicion,
                                onChanged: (v) =>
                                    setState(() => _tipoPersonaVista = v),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),

                        // ── Formulario ─────────────────────────────────────
                        _SeccionDatosFacturacion(
                          habilitado: widget.modoEdicion,
                          // Con país extranjero, Razón Social vs Nombres/
                          // Apellidos la decide el toggle de vista de arriba
                          // (_tipoPersonaVista); con Perú, sigue el criterio
                          // de siempre (_esRuc, Tipo documento == RUC) — el
                          // toggle ni se muestra en ese caso.
                          mostrarRazonSocial: _esExtranjero
                              ? _tipoPersonaVista == 'juridica'
                              : _esRuc,
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
                          numDocMaxLength: numDocMaxLength,
                          numDocKeyboardType: numDocKeyboardType,
                          numDocInputFormatters: numDocInputFormatters,
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
                                // Tipo documento — ya no se fuerza uno
                                // específico ("Otros"); el combo ahora
                                // muestra TODOS los tipos con
                                // esNacional == false (ver
                                // tiposDocumentoExtranjero) y el asesor
                                // elige. Si el tipo ya seleccionado no es
                                // uno de esos (ej. venía en DNI), se limpia
                                // para forzar una nueva elección.
                                if (!tiposDocumentoExtranjero.any(
                                  (t) => t.id == _tipoDocId,
                                )) {
                                  _tipoDocId = '';
                                  _tipoDocLabel = '';
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
                              } else if (!tiposDocumentoNacional.any(
                                (t) => t.id == _tipoDocId,
                              )) {
                                // Volvió a un país nacional (Perú) — si el
                                // tipo documento que tenía elegido era uno
                                // exclusivo de extranjero, ya no es válido
                                // acá, se limpia para forzar una nueva
                                // elección (simétrico al caso de arriba).
                                _tipoDocId = '';
                                _tipoDocLabel = '';
                                _ctrlNumDoc.clear();
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
// Los campos de identidad cambian según mostrarRazonSocial: true -> Número
// documento + Razón Social. false -> Número documento + Nombres + Apellido
// paterno + Apellido materno (opcional).

class _SeccionDatosFacturacion extends StatefulWidget {
  final bool habilitado;
  // Decide si se muestra Razón Social o Nombres + Apellido paterno/materno.
  // Con país Perú (!esExtranjero) es _esRuc (Tipo documento == RUC, criterio
  // de siempre); con país extranjero es el toggle Jurídica/Natural de vista
  // (SolicitudFacturacionView._tipoPersonaVista) — pedido de negocio
  // 2026-07-30: el toggle "solo sirve cuando es extranjero", con Perú se
  // sigue decidiendo por RUC como antes de que existiera el toggle.
  final bool mostrarRazonSocial;
  // País distinto de Perú (paso 3) — oculta Nacionalidad (no aplica, se
  // manda vacía). Comprobante/Tipo documento ya llegan pre-filtrados por el
  // padre en ese caso (solo Boleta / solo los de esNacional == false).
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
  // Longitud máxima/teclado/formatters reales para Número documento/RUC,
  // según el tipo de documento elegido — calculados por el padre con
  // DocumentoValidationUtils (mismo utilitario que ya usan Datos del
  // solicitante y Nuevo participante). Reemplaza el `maxLength: 12` fijo sin
  // restricciones que tenía este campo desde 2026-07-22 ("no quiero
  // validaciones") — pedido de negocio 2026-07-29, "revisa el máximo real de
  // cada tipo de documento, en todas las partes".
  final int? numDocMaxLength;
  final TextInputType numDocKeyboardType;
  final List<TextInputFormatter>? numDocInputFormatters;
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
    required this.mostrarRazonSocial,
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
    this.numDocMaxLength,
    this.numDocKeyboardType = TextInputType.text,
    this.numDocInputFormatters,
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

        // Fila 2: Tipo documento + Número documento / RUC — longitud
        // máxima/teclado/formatters reales por tipo de documento
        // (DocumentoValidationUtils, ver numDocMaxLength/numDocKeyboardType/
        // numDocInputFormatters) — mismo utilitario que ya usan Datos del
        // solicitante y Nuevo participante. Reemplaza el `maxLength: 12`
        // fijo sin restricciones que tenía este campo desde 2026-07-22,
        // pedido de negocio 2026-07-29.
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
                maxLength: widget.numDocMaxLength,
                keyboardType: widget.numDocKeyboardType,
                inputFormatters: widget.numDocInputFormatters,
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

        // Fila 4: Nombres / Razón social (ancho completo) — ver
        // mostrarRazonSocial (Perú: _esRuc: extranjero: toggle de vista)
        CustomTextField(
          label: widget.mostrarRazonSocial ? 'Razón Social *' : 'Nombres *',
          controller: widget.ctrlNombresRazon,
          enabled: widget.habilitado,
          isUpperCase: true,
          textCapitalization: TextCapitalization.words,
          validator: (v) => v == null || v.trim().isEmpty ? 'Requerido' : null,
        ),
        const SizedBox(height: AppSpacing.xs),

        // Fila 5: Apellido paterno + Apellido materno — solo persona
        // natural (ver mostrarRazonSocial arriba)
        if (!widget.mostrarRazonSocial) ...[
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
          isUpperCase: true,
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
          isUpperCase: true,
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
