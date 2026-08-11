// lib/features/lead/presentation/widgets/edit_contacto/edit_contacto_portrait.dart
//
// Formulario completo de "Editar contacto" — mismo patrón que
// EditLeadPortrait (lead/): combos/listas como estado local del State,
// FormSaveBar al pie, overlay de carga/éxito. La diferencia de fondo es que
// acá el estado "real" (ContactoDetalle) no vive en un cubit compartido con
// otra pantalla — ContactoFormCubit es dueño único, se crea en
// EditContactoPage y muere con la pantalla.

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/features/lead/index_lead.dart';

import 'contacto_form_rows.dart';

class EditContactoPortrait extends StatefulWidget {
  final ContactoDetalle contacto;
  final ValueNotifier<bool>? guardandoNotifier;

  const EditContactoPortrait({
    super.key,
    required this.contacto,
    this.guardandoNotifier,
  });

  @override
  State<EditContactoPortrait> createState() => _EditContactoPortraitState();
}

class _EditContactoPortraitState extends State<EditContactoPortrait> {
  final _formKey = GlobalKey<FormState>();
  bool _autovalidar = false;

  // ── Datos de contacto ──────────────────────────────────────────────────
  String? _saludo;
  late final TextEditingController _linkedinCtrl;
  TipoDocumentoItem? _tipoDocumento;
  late final TextEditingController _numeroDocumentoCtrl;
  NacionalidadItem? _nacionalidad;
  late final TextEditingController _nombreCtrl;
  late final TextEditingController _apellidoPaternoCtrl;
  late final TextEditingController _apellidoMaternoCtrl;
  PaisItem? _pais;
  UbigeoItem? _departamento;
  UbigeoItem? _provincia;
  UbigeoItem? _distrito;
  late final TextEditingController _direccionCtrl;

  // ── Listas dinámicas ───────────────────────────────────────────────────
  final List<NumeroFormRow> _numeros = [];
  final List<CorreoFormRow> _correos = [];
  final List<EmpresaFormRow> _empresas = [];
  int _nextLocalId = 1;

  bool _combosInicializados = false;
  bool _isLoading = false;
  bool _mostrandoExito = false;

  // Snapshot del contacto tal como quedó armado justo después de que los
  // combos terminan de inicializarse (con sus defaults ya aplicados — ej.
  // Nacionalidad/País autocompletados a Perú, ver _inicializarCombos). Es la
  // base contra la que se compara en _hayCambios — comparar contra
  // widget.contacto directo marcaría "hay cambios" apenas se abre la
  // pantalla, solo por los defaults que el propio formulario aplica.
  ContactoDetalle? _snapshotInicial;

  // ── Autocompletado por documento (mismo patrón que solicitudes) ────────
  final _documentoService = DocumentoExternoService();
  late final FocusNode _numDocFocus;
  bool _buscandoDocumento = false;
  String _ultimoDocBuscado = '';
  bool _buscandoRuc = false;

  @override
  void initState() {
    super.initState();
    final c = widget.contacto;
    _saludo = c.prefijoContacto.isEmpty ? null : c.prefijoContacto;
    _linkedinCtrl = TextEditingController(text: c.linkedin);
    _numeroDocumentoCtrl = TextEditingController(text: c.numeroDocumento);
    _nombreCtrl = TextEditingController(text: c.nombre);
    _apellidoPaternoCtrl = TextEditingController(text: c.apellidoPaterno);
    _apellidoMaternoCtrl = TextEditingController(text: c.apellidoMaterno);
    _direccionCtrl = TextEditingController(text: c.direccion);
    _numDocFocus = FocusNode()..addListener(_onNumDocFocusChange);

    // Estos controllers no tienen onChanged propio en
    // EditContactoDatosSection (a diferencia de los de las listas
    // dinámicas, que sí llaman setState vía onCambioNumero/onCambioCorreo/
    // onCambioCampo) — sin este listener, tipear acá no reconstruye el
    // formulario y _hayCambios nunca se vuelve a evaluar.
    _linkedinCtrl.addListener(_onCampoDatosChanged);
    _numeroDocumentoCtrl.addListener(_onCampoDatosChanged);
    _nombreCtrl.addListener(_onCampoDatosChanged);
    _apellidoPaternoCtrl.addListener(_onCampoDatosChanged);
    _apellidoMaternoCtrl.addListener(_onCampoDatosChanged);
    _direccionCtrl.addListener(_onCampoDatosChanged);

    for (final n in c.numeros) {
      _numeros.add(
        NumeroFormRow(
          localId: _nextLocalId++,
          idNumero: n.idNumero,
          // pais (PaisItem?) se matchea contra el catálogo real en
          // _inicializarCombos — todavía no hay CatalogsBloc disponible acá.
          numeroInicial: n.numero,
          esPrincipal: n.esPrincipal,
          esFavorito: n.esFavorito,
          activo: n.activo,
        ),
      );
    }
    for (final co in c.correos) {
      _correos.add(
        CorreoFormRow(
          localId: _nextLocalId++,
          idCorreo: co.idCorreo,
          correoInicial: co.correo,
          activo: co.activo,
        ),
      );
    }
    for (final e in c.empresas) {
      final row = EmpresaFormRow(
        localId: _nextLocalId++,
        idEmpresaContacto: e.idEmpresaContacto,
        idEmpresa: e.idEmpresa,
        nombreInicial: e.nombreEmpresa,
        rucInicial: e.ruc,
        razonSocialInicial: e.razonSocial,
        direccionInicial: e.direccion,
        // pais/area/cargo se matchean contra el catálogo real en
        // _inicializarCombos — todavía no hay CatalogsBloc disponible acá
        // (initState corre antes que didChangeDependencies).
      );
      _wireRucFocus(row);
      _empresas.add(row);
    }
  }

  void _wireRucFocus(EmpresaFormRow row) {
    row.rucFocus.addListener(() {
      if (row.rucFocus.hasFocus) return; // solo al perder el foco
      _buscarRuc(row);
    });
  }

  PaisItem? _paisDesdePrefijo(String prefijo, CatalogsLoaded state) {
    final codigo = prefijo.replaceAll('+', '').trim();
    final porCodigo = codigo.isEmpty
        ? null
        : state.paises.where((p) => p.codigoTelefono == codigo).firstOrNull;
    return porCodigo ??
        state.paises.where((p) => p.id == state.valoresDefecto.idPais).firstOrNull;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_combosInicializados) return;
    final catalogState = context.read<CatalogsBloc>().state;
    if (catalogState is! CatalogsLoaded) return;
    _inicializarCombos(catalogState);
    _combosInicializados = true;
  }

  void _inicializarCombos(CatalogsLoaded state) {
    final c = widget.contacto;
    _tipoDocumento = state.tiposDocumento
        .where((t) => t.id == c.idTipoDocumento)
        .firstOrNull;
    // Nacionalidad — default Peruano si el contacto todavía no tiene una
    // (pedido de negocio 2026-07-23), nunca pisa una ya guardada.
    _nacionalidad = c.idNacionalidad.isEmpty
        ? state.nacionalidades
              .where((n) => n.id == state.valoresDefecto.idNacionalidad)
              .firstOrNull
        : state.nacionalidades.where((n) => n.id == c.idNacionalidad).firstOrNull;
    _pais = state.paises.where((p) => p.id == c.idPais).firstOrNull;
    _departamento = state.ubigeo
        .where((u) => u.dpto == c.idDepartamento && u.prov == '00' && u.dis == '00')
        .firstOrNull;
    _provincia = state.ubigeo
        .where(
          (u) =>
              u.dpto == c.idDepartamento &&
              u.prov == c.idProvincia &&
              u.dis == '00',
        )
        .firstOrNull;
    _distrito = state.ubigeo
        .where(
          (u) =>
              u.dpto == c.idDepartamento &&
              u.prov == c.idProvincia &&
              u.dis == c.idDistrito,
        )
        .firstOrNull;

    // Prefijo (PaisItem) por fila de celular — mismo orden en que se
    // construyeron en initState a partir de c.numeros.
    for (var i = 0; i < _numeros.length && i < c.numeros.length; i++) {
      _numeros[i].pais = _paisDesdePrefijo(c.numeros[i].prefijo, state);
    }

    // Área/Cargo por fila de empresa — mismo orden en que se construyeron
    // en initState a partir de c.empresas.
    for (var i = 0; i < _empresas.length && i < c.empresas.length; i++) {
      final original = c.empresas[i];
      // País por defecto Perú si la empresa todavía no tiene uno guardado
      // (pedido de negocio 2026-07-23), sin pisar uno ya existente.
      _empresas[i].pais = original.idPais.isEmpty
          ? state.paises
                .where((p) => p.id == state.valoresDefecto.idPais)
                .firstOrNull
          : state.paises.where((p) => p.id == original.idPais).firstOrNull;
      // Área/Cargo ya vienen como texto libre desde el backend (NOM_AREA/
      // NOM_CARGO) — no hay id de catálogo que matchear, se copian tal cual.
      _empresas[i].area = original.area;
      _empresas[i].cargo = original.cargo;
      _empresas[i].departamento = state.ubigeo
          .where(
            (u) =>
                u.dpto == original.idDepartamento &&
                u.prov == '00' &&
                u.dis == '00',
          )
          .firstOrNull;
      _empresas[i].provincia = state.ubigeo
          .where(
            (u) =>
                u.dpto == original.idDepartamento &&
                u.prov == original.idProvincia &&
                u.dis == '00',
          )
          .firstOrNull;
      _empresas[i].distrito = state.ubigeo
          .where(
            (u) =>
                u.dpto == original.idDepartamento &&
                u.prov == original.idProvincia &&
                u.dis == original.idDistrito,
          )
          .firstOrNull;
    }

    // Recién acá el formulario refleja los defaults que aplica esta misma
    // función (Nacionalidad/País → Perú si venían vacíos, etc.) — este es
    // el punto de partida real contra el que se mide "hay cambios", no
    // widget.contacto tal como llegó del backend.
    _snapshotInicial = _construirContacto();
  }

  void _onCampoDatosChanged() => setState(() {});

  // ── Detección de cambios ────────────────────────────────────────────────

  bool get _hayCambios {
    if (_snapshotInicial == null) return false;
    return _construirContacto() != _snapshotInicial;
  }

  @override
  void dispose() {
    _linkedinCtrl.removeListener(_onCampoDatosChanged);
    _numeroDocumentoCtrl.removeListener(_onCampoDatosChanged);
    _nombreCtrl.removeListener(_onCampoDatosChanged);
    _apellidoPaternoCtrl.removeListener(_onCampoDatosChanged);
    _apellidoMaternoCtrl.removeListener(_onCampoDatosChanged);
    _direccionCtrl.removeListener(_onCampoDatosChanged);
    _linkedinCtrl.dispose();
    _numeroDocumentoCtrl.dispose();
    _nombreCtrl.dispose();
    _apellidoPaternoCtrl.dispose();
    _apellidoMaternoCtrl.dispose();
    _direccionCtrl.dispose();
    for (final r in _numeros) {
      r.dispose();
    }
    for (final r in _correos) {
      r.dispose();
    }
    for (final r in _empresas) {
      r.dispose();
    }
    _numDocFocus.removeListener(_onNumDocFocusChange);
    _numDocFocus.dispose();
    widget.guardandoNotifier?.value = false;
    super.dispose();
  }

  void _onNumDocFocusChange() {
    if (_numDocFocus.hasFocus) return; // solo al perder el foco
    _buscarDocumento();
  }

  // Autocompleta Nombres/Apellidos/Dirección (y agrega un correo nuevo si
  // no estaba ya) al escribir un documento válido — mismo servicio y mismo
  // patrón que Datos del solicitante/Facturación en solicitudes/ (ver
  // solicitud_facturacion_view.dart._buscarDocumento). Nunca pisa un campo
  // que el usuario ya llenó a mano.
  Future<void> _buscarDocumento() async {
    final numDoc = _numeroDocumentoCtrl.text.trim();
    final esBusqueda = numDoc.length == 8 || numDoc.length == 11;
    if (!esBusqueda || numDoc == _ultimoDocBuscado) return;
    _ultimoDocBuscado = numDoc;

    setState(() => _buscandoDocumento = true);
    try {
      final resultado = await _documentoService.buscar(numDoc);
      if (!mounted) return;
      if (resultado == null || resultado.sinDatos) return;

      final catalogState = context.read<CatalogsBloc>().state;

      setState(() {
        if (_nombreCtrl.text.trim().isEmpty && resultado.nombres.isNotEmpty) {
          _nombreCtrl.text = resultado.nombres;
        }
        if (_apellidoPaternoCtrl.text.trim().isEmpty &&
            resultado.apePaterno.isNotEmpty) {
          _apellidoPaternoCtrl.text = resultado.apePaterno;
        }
        if (_apellidoMaternoCtrl.text.trim().isEmpty &&
            resultado.apeMaterno.isNotEmpty) {
          _apellidoMaternoCtrl.text = resultado.apeMaterno;
        }
        if (_direccionCtrl.text.trim().isEmpty &&
            resultado.direccion.isNotEmpty) {
          _direccionCtrl.text = resultado.direccion;
        }
        if (catalogState is CatalogsLoaded) {
          if (_pais == null && resultado.idPais.isNotEmpty) {
            _pais = catalogState.paises
                .where((p) => p.id == resultado.idPais)
                .firstOrNull;
          }
          if (_nacionalidad == null && resultado.idNacionalidad.isNotEmpty) {
            _nacionalidad = catalogState.nacionalidades
                .where((n) => n.id == resultado.idNacionalidad)
                .firstOrNull;
          }
        }
        final correo = resultado.correo.trim();
        final yaExiste = correo.isEmpty
            ? true
            : _correos.any(
                (c) =>
                    c.correoCtrl.text.trim().toLowerCase() ==
                    correo.toLowerCase(),
              );
        if (!yaExiste) {
          _correos.add(
            CorreoFormRow(localId: _nextLocalId++, correoInicial: correo),
          );
        }
      });
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

  bool get _esNuevoContacto => widget.contacto.idContacto == 0;

  void _setGuardando({bool? isLoading, bool? mostrandoExito}) {
    setState(() {
      if (isLoading != null) _isLoading = isLoading;
      if (mostrandoExito != null) _mostrandoExito = mostrandoExito;
    });
    widget.guardandoNotifier?.value = _isLoading || _mostrandoExito;
  }

  // ── Celular ────────────────────────────────────────────────────────────

  void _agregarNumero() {
    final catalogState = context.read<CatalogsBloc>().state;
    final paisPorDefecto = catalogState is CatalogsLoaded
        ? catalogState.paises
              .where((p) => p.id == catalogState.valoresDefecto.idPais)
              .firstOrNull
        : null;
    setState(() {
      _numeros.add(
        NumeroFormRow(
          localId: _nextLocalId++,
          pais: paisPorDefecto,
          esPrincipal: _numeros.isEmpty,
        ),
      );
    });
  }

  void _eliminarNumero(NumeroFormRow row) {
    setState(() {
      row.dispose();
      _numeros.remove(row);
    });
  }

  void _togglePrincipal(NumeroFormRow row) {
    setState(() {
      for (final r in _numeros) {
        r.esPrincipal = identical(r, row);
      }
    });
  }

  // ── Correo ─────────────────────────────────────────────────────────────

  void _agregarCorreo() {
    setState(() => _correos.add(CorreoFormRow(localId: _nextLocalId++)));
  }

  void _eliminarCorreo(CorreoFormRow row) {
    setState(() {
      row.dispose();
      _correos.remove(row);
    });
  }

  // ── Empresa ────────────────────────────────────────────────────────────

  void _agregarEmpresa() {
    final catalogState = context.read<CatalogsBloc>().state;
    final paisPorDefecto = catalogState is CatalogsLoaded
        ? catalogState.paises
              .where((p) => p.id == catalogState.valoresDefecto.idPais)
              .firstOrNull
        : null;
    final row = EmpresaFormRow(
      localId: _nextLocalId++,
      pais: paisPorDefecto,
      expandido: true,
    );
    _wireRucFocus(row);
    setState(() => _empresas.add(row));
  }

  // Autocompleta Razón social/Nombre y Dirección por RUC (11 dígitos) al
  // perder foco — mismo servicio y patrón que Número de documento arriba.
  // Nunca pisa un campo ya tipeado.
  Future<void> _buscarRuc(EmpresaFormRow row) async {
    final ruc = row.rucCtrl.text.trim();
    if (ruc.length != 11 || ruc == row.ultimoRucBuscado) return;
    row.ultimoRucBuscado = ruc;

    setState(() => _buscandoRuc = true);
    try {
      final resultado = await _documentoService.buscar(ruc);
      if (!mounted) return;
      if (resultado == null || resultado.sinDatos) return;

      setState(() {
        if (row.nombreCtrl.text.trim().isEmpty &&
            resultado.nomEmpresa.isNotEmpty) {
          row.nombreCtrl.text = resultado.nomEmpresa;
        }
        if (row.razonSocialCtrl.text.trim().isEmpty &&
            resultado.nomEmpresa.isNotEmpty) {
          row.razonSocialCtrl.text = resultado.nomEmpresa;
        }
        if (row.direccionCtrl.text.trim().isEmpty &&
            resultado.direccion.isNotEmpty) {
          row.direccionCtrl.text = resultado.direccion;
        }
      });
    } catch (_) {
      if (!mounted) return;
      AppSnackBar.error(context, 'No se pudo autocompletar los datos del RUC.');
    } finally {
      if (mounted) setState(() => _buscandoRuc = false);
    }
  }

  void _eliminarEmpresa(EmpresaFormRow row) {
    setState(() {
      row.dispose();
      _empresas.remove(row);
    });
  }

  // ── Guardar ────────────────────────────────────────────────────────────

  // Todo texto libre se guarda en mayúsculas (pedido de negocio 2026-07-23)
  // — los campos ya tienen isUpperCase:true en sus widgets (feedback visual
  // inmediato al tipear), pero eso no cubre valores puestos por código
  // (autocompletado de documento/RUC), así que acá se fuerza de nuevo como
  // garantía final antes de armar el payload.
  String _mayus(String s) => s.trim().toUpperCase();

  ContactoDetalle _construirContacto() {
    return widget.contacto.copyWith(
      prefijoContacto: _saludo ?? '',
      linkedin: _linkedinCtrl.text.trim(),
      idTipoDocumento: _tipoDocumento?.id ?? '',
      numeroDocumento: _mayus(_numeroDocumentoCtrl.text),
      idNacionalidad: _nacionalidad?.id ?? '',
      nombre: _mayus(_nombreCtrl.text),
      apellidoPaterno: _mayus(_apellidoPaternoCtrl.text),
      apellidoMaterno: _mayus(_apellidoMaternoCtrl.text),
      idPais: _pais?.id ?? '',
      idDepartamento: _departamento?.dpto ?? '',
      idProvincia: _provincia?.prov ?? '',
      idDistrito: _distrito?.dis ?? '',
      direccion: _mayus(_direccionCtrl.text),
      numeros: _numeros
          .map(
            (r) => NumeroContacto(
              idNumero: r.idNumero,
              prefijo: r.pais != null ? '+${r.pais!.codigoTelefono}' : '',
              numero: r.numeroCtrl.text.trim(),
              esPrincipal: r.esPrincipal,
              esFavorito: r.esFavorito,
              activo: r.activo,
            ),
          )
          .toList(),
      correos: _correos
          .map(
            (r) => CorreoContacto(
              idCorreo: r.idCorreo,
              correo: _mayus(r.correoCtrl.text),
              activo: r.activo,
            ),
          )
          .toList(),
      empresas: _empresas
          .map(
            (r) => EmpresaContacto(
              idEmpresaContacto: r.idEmpresaContacto,
              idEmpresa: r.idEmpresa,
              nombreEmpresa: _mayus(r.nombreCtrl.text),
              idPais: r.pais?.id ?? '',
              ruc: r.rucCtrl.text.trim(),
              razonSocial: _mayus(r.razonSocialCtrl.text),
              direccion: _mayus(r.direccionCtrl.text),
              // Área/Cargo son CustomComboSearchField (texto libre vía
              // allowFreeText, ver contacto_form_rows.dart) — ese widget no
              // tiene un equivalente a isUpperCase:true, así que acá se
              // fuerza igual que el resto de texto libre, aunque no haya
              // feedback visual mientras se tipea.
              area: _mayus(r.area),
              cargo: _mayus(r.cargo),
              idDepartamento: r.departamento?.dpto ?? '',
              idProvincia: r.provincia?.prov ?? '',
              idDistrito: r.distrito?.dis ?? '',
            ),
          )
          .toList(),
    );
  }

  Future<void> _guardar() async {
    if (_isLoading || !_hayCambios) return;
    setState(() => _autovalidar = true);
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final confirmar = await context.showConfirmDialog(
      title: 'Confirmar cambio',
      message: '¿Deseas guardar los cambios del contacto?',
    );
    if (!confirmar) return;

    _setGuardando(isLoading: true);

    final contactoActualizado = _construirContacto();
    if (!context.mounted) return;
    // ignore: use_build_context_synchronously
    final result = await context.read<ContactoFormCubit>().guardar(
      contactoActualizado,
    );

    if (!mounted) return;
    _setGuardando(isLoading: false);

    switch (result) {
      case CrudOk():
        // Avisa a quien tenga cacheado un Chat/Negociacion con estos datos
        // de contacto (ej. ChatDetailPage, ver ContactoUpdateNotifier) para
        // que se refresque al volver — si no, la pestaña "Datos" se queda
        // con nombre/apellido/empresa viejos hasta que el usuario navegue
        // fuera y vuelva a entrar.
        ContactoUpdateNotifier.instance.notify(contactoActualizado.idNumero);
        _setGuardando(mostrandoExito: true);
        await Future.delayed(const Duration(milliseconds: 1500));
        if (mounted) context.goBack();
      case CrudAlert(:final message):
        AppSnackBar.warning(context, message);
      case CrudError(:final message):
        AppSnackBar.error(context, message);
      case CrudNoInternet():
        AppSnackBar.error(context, 'Sin conexión a Internet.');
      case CrudEmpty():
        AppSnackBar.error(context, 'No se recibió respuesta del servidor.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final catalogState = context.watch<CatalogsBloc>().state;
    if (catalogState is! CatalogsLoaded) return const AppLoadingView();

    final ubigeoDepartamentos = catalogState.ubigeo
        .where((u) => u.prov == '00' && u.dis == '00')
        .toList();
    final ubigeoProvincias = catalogState.ubigeo
        .where(
          (u) => u.dpto == (_departamento?.dpto ?? '') && u.prov != '00' && u.dis == '00',
        )
        .toList();
    final ubigeoDistritos = catalogState.ubigeo
        .where(
          (u) =>
              u.dpto == (_departamento?.dpto ?? '') &&
              u.prov == (_provincia?.prov ?? '') &&
              u.dis != '00',
        )
        .toList();

    // "Sin documento" no aplica acá — un contacto siempre tiene algún tipo
    // de documento real (DNI/CE/Pasaporte/Otros). RUC tampoco aplica — un
    // contacto es una persona natural, el RUC es de la Empresa (su propio
    // campo, con autocompletado propio, ver EmpresaFormRow/_buscarRuc)
    // (pedido de negocio 2026-07-23).
    final tiposDocumento = catalogState.tiposDocumento
        .where(
          (t) =>
              t.id != catalogState.valoresDefecto.idTipoDocSnd &&
              t.id != catalogState.valoresDefecto.idTipoDocRuc,
        )
        .toList();

    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: Form(
                key: _formKey,
                autovalidateMode: _autovalidar
                    ? AutovalidateMode.onUserInteraction
                    : AutovalidateMode.disabled,
                child: ListView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  children: [
                    EditContactoDatosSection(
                      isLoading: _isLoading,
                      prefijosContacto: catalogState.prefijosContacto,
                      saludoInicial: _saludo,
                      onSaludoChanged: (v) => setState(() => _saludo = v),
                      linkedinCtrl: _linkedinCtrl,
                      tiposDocumento: tiposDocumento,
                      tipoDocumento: _tipoDocumento,
                      onTipoDocumentoChanged: (item) {
                        setState(() {
                          _tipoDocumento = item;
                          _numeroDocumentoCtrl.clear();
                        });
                      },
                      numeroDocumentoCtrl: _numeroDocumentoCtrl,
                      numeroDocumentoFocus: _numDocFocus,
                      onBuscarDocumento: _buscarDocumento,
                      valoresDefecto: catalogState.valoresDefecto,
                      nacionalidades: catalogState.nacionalidades,
                      nacionalidad: _nacionalidad,
                      onNacionalidadChanged: (item) =>
                          setState(() => _nacionalidad = item),
                      nombreCtrl: _nombreCtrl,
                      apellidoPaternoCtrl: _apellidoPaternoCtrl,
                      apellidoMaternoCtrl: _apellidoMaternoCtrl,
                      paises: catalogState.paises,
                      pais: _pais,
                      onPaisChanged: (item) => setState(() => _pais = item),
                      departamentos: ubigeoDepartamentos,
                      provincias: ubigeoProvincias,
                      distritos: ubigeoDistritos,
                      departamentoInicialId: _departamento?.dpto,
                      provinciaInicialId: _provincia?.prov,
                      distritoInicialId: _distrito?.dis,
                      onDepartamentoChanged: (item) => setState(() {
                        _departamento = item;
                        _provincia = null;
                        _distrito = null;
                      }),
                      onProvinciaChanged: (item) => setState(() {
                        _provincia = item;
                        _distrito = null;
                      }),
                      onDistritoChanged: (item) =>
                          setState(() => _distrito = item),
                      direccionCtrl: _direccionCtrl,
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    EditContactoCelularSection(
                      numeros: _numeros,
                      isLoading: _isLoading,
                      paises: catalogState.paises,
                      onAgregar: _agregarNumero,
                      onEliminar: _eliminarNumero,
                      onTogglePrincipal: _togglePrincipal,
                      onToggleFavorito: (row, v) =>
                          setState(() => row.esFavorito = v),
                      onToggleActivo: (row, v) =>
                          setState(() => row.activo = v),
                      onCambioPais: (row, pais) =>
                          setState(() => row.pais = pais),
                      onCambioNumero: (_) => setState(() {}),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    EditContactoCorreoSection(
                      correos: _correos,
                      isLoading: _isLoading,
                      onAgregar: _agregarCorreo,
                      onEliminar: _eliminarCorreo,
                      onToggleActivo: (row, v) =>
                          setState(() => row.activo = v),
                      onCambioCorreo: (_) => setState(() {}),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    EditContactoEmpresaSection(
                      empresas: _empresas,
                      isLoading: _isLoading,
                      paises: catalogState.paises,
                      areas: catalogState.areas,
                      cargos: catalogState.cargos,
                      ubigeo: catalogState.ubigeo,
                      onAgregar: _agregarEmpresa,
                      onEliminar: _eliminarEmpresa,
                      onToggleExpandido: (row) =>
                          setState(() => row.expandido = !row.expandido),
                      onCambioCampo: (_) => setState(() {}),
                      onPaisChanged: (row, item) =>
                          setState(() => row.pais = item),
                      onAreaChanged: (row, area) =>
                          setState(() => row.area = area),
                      onCargoChanged: (row, cargo) =>
                          setState(() => row.cargo = cargo),
                      onDepartamentoChanged: (row, item) => setState(() {
                        row.departamento = item;
                        row.provincia = null;
                        row.distrito = null;
                      }),
                      onProvinciaChanged: (row, item) => setState(() {
                        row.provincia = item;
                        row.distrito = null;
                      }),
                      onDistritoChanged: (row, item) =>
                          setState(() => row.distrito = item),
                      onBuscarRuc: _buscarRuc,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),
            FormSaveBar(
              onCancelar: () => context.goBack(),
              onGuardar: _guardar,
              isLoading: _isLoading || _mostrandoExito,
              isEnabled: _hayCambios,
              iconoGuardar: AppIcons.save,
              textoGuardar: 'Guardar cambios',
            ),
          ],
        ),
        if (_buscandoDocumento)
          const AppLoadingOverlay(message: 'Buscando datos del documento...'),
        if (_buscandoRuc)
          const AppLoadingOverlay(message: 'Buscando datos del RUC...'),
        // Overlay único "Guardando... → check verde animado" (reusa
        // AppProcessOverlay, core — mismo patrón que EditLeadPortrait/
        // EditContactoSimplePortrait) — antes eran AppLoadingOverlay + un
        // check estático propio (_ExitoOverlay, ya no existe).
        if (_isLoading || _mostrandoExito)
          AppProcessOverlay(
            status: _isLoading
                ? AppProcessStatus.cargando
                : AppProcessStatus.exito,
            loadingMessage: _esNuevoContacto
                ? 'Creando contacto...'
                : 'Editando contacto...',
            successMessage: _esNuevoContacto
                ? 'El contacto se creó correctamente'
                : 'El contacto se editó correctamente',
          ),
      ],
    );
  }
}
