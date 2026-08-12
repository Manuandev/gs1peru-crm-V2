// lib/features/lead/presentation/widgets/edit_contacto_simple/edit_contacto_simple_portrait.dart
//
// Formulario reducido de "Editar contacto" (pedido de negocio 2026-07-27) —
// solo tipo/número documento, nacionalidad, sexo, nombres, apellidos,
// UN celular (el anclado en idNumero), UN correo y UNA empresa (ruc/razón
// social/cargo). No reemplaza EditContactoPortrait (pantalla completa, con
// listas de N celulares/correos/empresas) — es una alternativa aparte,
// misma idea que SeccionDatosSolicitante (solicitudes/) pero para contacto.

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class EditContactoSimplePortrait extends StatefulWidget {
  final ContactoSimple contacto;
  final ValueNotifier<bool>? guardandoNotifier;

  const EditContactoSimplePortrait({
    super.key,
    required this.contacto,
    this.guardandoNotifier,
  });

  @override
  State<EditContactoSimplePortrait> createState() =>
      _EditContactoSimplePortraitState();
}

class _EditContactoSimplePortraitState
    extends State<EditContactoSimplePortrait> {
  final _formKey = GlobalKey<FormState>();
  bool _autovalidar = false;

  TipoDocumentoItem? _tipoDocumento;
  late final TextEditingController _numeroDocumentoCtrl;
  NacionalidadItem? _nacionalidad;
  String? _prefijoContacto; // saludo: Estimado/Estimada
  late final TextEditingController _nombreCtrl;
  late final TextEditingController _apellidoPaternoCtrl;
  late final TextEditingController _apellidoMaternoCtrl;

  PaisItem? _paisCelular;
  late final TextEditingController _celularCtrl;
  late final TextEditingController _correoCtrl;

  late final TextEditingController _rucCtrl;
  late final TextEditingController _razonSocialCtrl;
  // Texto libre (NOM_CARGO) — el combo solo sugiere, no fuerza el catálogo.
  String _cargo = '';

  bool _combosInicializados = false;
  bool _isLoading = false;
  bool _mostrandoExito = false;

  final _documentoService = DocumentoExternoService();
  late final FocusNode _numDocFocus;
  late final FocusNode _rucFocus;
  bool _buscandoDocumento = false;
  bool _buscandoRuc = false;
  String _ultimoDocBuscado = '';
  String _ultimoRucBuscado = '';

  @override
  void initState() {
    super.initState();
    final c = widget.contacto;
    _prefijoContacto = c.prefijoContacto.isEmpty ? null : c.prefijoContacto;
    _numeroDocumentoCtrl = TextEditingController(text: c.numeroDocumento);
    _nombreCtrl = TextEditingController(text: c.nombre);
    _apellidoPaternoCtrl = TextEditingController(text: c.apellidoPaterno);
    _apellidoMaternoCtrl = TextEditingController(text: c.apellidoMaterno);
    _celularCtrl = TextEditingController(text: c.celular);
    _correoCtrl = TextEditingController(text: c.correo);
    _rucCtrl = TextEditingController(text: c.ruc);
    _razonSocialCtrl = TextEditingController(text: c.razonSocial);
    _numDocFocus = FocusNode()..addListener(_onNumDocFocusChange);
    _rucFocus = FocusNode()..addListener(_onRucFocusChange);
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
    // Trunca un N° documento ya guardado que exceda el máximo real del tipo
    // — este campo no tenía `DocumentoValidationUtils` hasta ahora (gap
    // documentado en core/CLAUDE.md), así que pudo haberse guardado sin
    // ningún tope de longitud. Ver DocumentoValidationUtils.limitarLongitud.
    _numeroDocumentoCtrl.text = DocumentoValidationUtils.limitarLongitud(
      _tipoDocumento?.id ?? '',
      _numeroDocumentoCtrl.text,
      state.tiposDocumento,
      state.valoresDefecto,
    );
    // Nacionalidad — default Peruano si el contacto todavía no tiene una,
    // mismo criterio que EditContacto (pedido de negocio 2026-07-23).
    _nacionalidad = c.idNacionalidad.isEmpty
        ? state.nacionalidades
              .where((n) => n.id == state.valoresDefecto.idNacionalidad)
              .firstOrNull
        : state.nacionalidades.where((n) => n.id == c.idNacionalidad).firstOrNull;
    _paisCelular = c.prefijoCelular.isEmpty
        ? state.paises
              .where((p) => p.id == state.valoresDefecto.idPais)
              .firstOrNull
        : state.paises
              .where((p) => p.codigoTelefono == c.prefijoCelular.replaceAll('+', '').trim())
              .firstOrNull;
    // Cargo ya viene como texto libre desde el backend (NOM_CARGO) — no hay
    // id de catálogo que matchear, se copia tal cual.
    _cargo = c.cargo;
  }

  @override
  void dispose() {
    _numeroDocumentoCtrl.dispose();
    _nombreCtrl.dispose();
    _apellidoPaternoCtrl.dispose();
    _apellidoMaternoCtrl.dispose();
    _celularCtrl.dispose();
    _correoCtrl.dispose();
    _rucCtrl.dispose();
    _razonSocialCtrl.dispose();
    _numDocFocus.removeListener(_onNumDocFocusChange);
    _numDocFocus.dispose();
    _rucFocus.removeListener(_onRucFocusChange);
    _rucFocus.dispose();
    widget.guardandoNotifier?.value = false;
    super.dispose();
  }

  void _onNumDocFocusChange() {
    if (_numDocFocus.hasFocus) return; // solo al perder el foco
    _buscarDocumento();
  }

  void _onRucFocusChange() {
    if (_rucFocus.hasFocus) return;
    _buscarRuc();
  }

  // Autocompleta Nombres/Apellidos/Correo al escribir un documento válido —
  // mismo patrón/servicio que EditContacto (pantalla completa). Nunca pisa
  // un campo que el usuario ya llenó a mano.
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
        if (_correoCtrl.text.trim().isEmpty && resultado.correo.isNotEmpty) {
          _correoCtrl.text = resultado.correo;
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

  // Autocompleta Razón social por RUC (11 dígitos) al perder foco — mismo
  // patrón que EditContacto (pantalla completa).
  Future<void> _buscarRuc() async {
    final ruc = _rucCtrl.text.trim();
    if (ruc.length != 11 || ruc == _ultimoRucBuscado) return;
    _ultimoRucBuscado = ruc;

    setState(() => _buscandoRuc = true);
    try {
      final resultado = await _documentoService.buscar(ruc);
      if (!mounted) return;
      if (resultado == null || resultado.sinDatos) return;

      setState(() {
        if (_razonSocialCtrl.text.trim().isEmpty &&
            resultado.nomEmpresa.isNotEmpty) {
          _razonSocialCtrl.text = resultado.nomEmpresa;
        }
      });
    } catch (_) {
      if (!mounted) return;
      AppSnackBar.error(context, 'No se pudo autocompletar los datos del RUC.');
    } finally {
      if (mounted) setState(() => _buscandoRuc = false);
    }
  }

  bool get _esNuevoContacto => widget.contacto.idContacto == 0;

  // Prefijo/Celular quedan editables SOLO si el contacto todavía no trae un
  // número real vinculado (idNumero == 0 o celular vacío) — pedido de
  // negocio 2026-08-03: un contacto sin celular capturado (ej. creado a
  // mano, sin conversación de WhatsApp de por medio) no tiene nada que
  // proteger. Si YA trae celular, se sigue bloqueando (motivo original,
  // 2026-07-28, ver comentario más abajo): editar el texto acá generaría
  // una conexión T_NUMERO duplicada en vez de reemplazar la existente.
  bool get _celularEditable =>
      widget.contacto.idNumero == 0 || widget.contacto.celular.isEmpty;

  void _setGuardando({bool? isLoading, bool? mostrandoExito}) {
    setState(() {
      if (isLoading != null) _isLoading = isLoading;
      if (mostrandoExito != null) _mostrandoExito = mostrandoExito;
    });
    widget.guardandoNotifier?.value = _isLoading || _mostrandoExito;
  }

  String _mayus(String s) => s.trim().toUpperCase();

  ContactoSimple _construirContacto() {
    return widget.contacto.copyWith(
      idTipoDocumento: _tipoDocumento?.id ?? '',
      numeroDocumento: _mayus(_numeroDocumentoCtrl.text),
      idNacionalidad: _nacionalidad?.id ?? '',
      prefijoContacto: _prefijoContacto ?? '',
      nombre: _mayus(_nombreCtrl.text),
      apellidoPaterno: _mayus(_apellidoPaternoCtrl.text),
      apellidoMaterno: _mayus(_apellidoMaternoCtrl.text),
      prefijoCelular: _paisCelular != null ? '+${_paisCelular!.codigoTelefono}' : '',
      celular: _celularCtrl.text.trim(),
      correo: _mayus(_correoCtrl.text),
      ruc: _rucCtrl.text.trim(),
      razonSocial: _mayus(_razonSocialCtrl.text),
      cargo: _cargo,
    );
  }

  Future<void> _guardar() async {
    if (_isLoading) return;
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
    final result = await context.read<ContactoSimpleFormCubit>().guardar(
      contactoActualizado,
    );

    if (!mounted) return;
    _setGuardando(isLoading: false);

    switch (result) {
      case CrudOk():
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

    // Mismo criterio que EditContacto — un contacto siempre es persona
    // natural (DNI/CE/Pasaporte/Otros), RUC vive en la sección Empresa.
    final tiposDocumento = catalogState.tiposDocumento
        .where(
          (t) =>
              t.id != catalogState.valoresDefecto.idTipoDocSnd &&
              t.id != catalogState.valoresDefecto.idTipoDocRuc,
        )
        .toList();

    final prefijosCelular = catalogState.paises
        .map(
          (p) =>
              '${p.codigoTelefono}${AppConstants.sepCampos}'
              '${p.nombre} (+${p.codigoTelefono})',
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
                    const FormSectionTitle('Datos personales'),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: CustomComboField<TipoDocumentoItem>(
                            label: 'Tipo documento',
                            data: tiposDocumento,
                            labelIndex: 2,
                            enabled: !_isLoading,
                            initialValue: _tipoDocumento?.id,
                            onChanged: (item) => setState(() {
                              _tipoDocumento = item;
                              _numeroDocumentoCtrl.clear();
                            }),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: CustomTextField(
                            label: 'Número documento',
                            controller: _numeroDocumentoCtrl,
                            focusNode: _numDocFocus,
                            enabled: !_isLoading,
                            isUpperCase: true,
                            keyboardType: DocumentoValidationUtils.keyboardType(
                              _tipoDocumento?.id ?? '',
                              catalogState.valoresDefecto,
                            ),
                            maxLength: DocumentoValidationUtils.maxLength(
                              _tipoDocumento?.id ?? '',
                              tiposDocumento,
                              catalogState.valoresDefecto,
                            ),
                            inputFormatters:
                                DocumentoValidationUtils.inputFormatters(
                                  _tipoDocumento?.id ?? '',
                                  catalogState.valoresDefecto,
                                ),
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _buscarDocumento(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        Expanded(
                          child: CustomComboSearchField(
                            data: catalogState.nacionalidades
                                .map((n) => '${n.id}${AppConstants.sepCampos}${n.nombre}')
                                .toList(),
                            label: 'Nacionalidad',
                            enabled: !_isLoading,
                            initialValue: _nacionalidad?.id,
                            onChanged: (item) => setState(() {
                              _nacionalidad = item == null
                                  ? null
                                  : catalogState.nacionalidades
                                        .where((n) => n.id == item.id)
                                        .firstOrNull;
                            }),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: CustomComboField<PrefijoContactoItem>(
                            label: 'Prefijo',
                            data: catalogState.prefijosContacto,
                            enabled: !_isLoading,
                            initialValue: _prefijoContacto,
                            onChanged: (item) =>
                                setState(() => _prefijoContacto = item?.valor),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    CustomTextField(
                      label: 'Nombres',
                      controller: _nombreCtrl,
                      enabled: !_isLoading,
                      isUpperCase: true,
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            label: 'Apellido paterno',
                            controller: _apellidoPaternoCtrl,
                            enabled: !_isLoading,
                            isUpperCase: true,
                            textCapitalization: TextCapitalization.words,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: CustomTextField(
                            label: 'Apellido materno',
                            controller: _apellidoMaternoCtrl,
                            enabled: !_isLoading,
                            isUpperCase: true,
                            textCapitalization: TextCapitalization.words,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    // Prefijo/Celular bloqueados SOLO si el contacto ya trae
                    // un número real (ver _celularEditable) — idNumero es el
                    // ancla de esta pantalla, ese celular no se reemplaza
                    // desde acá (para eso existe la lista de N celulares de
                    // EditContacto, pantalla completa): editarlo generaría
                    // una conexión T_NUMERO duplicada en vez de reemplazar
                    // el número existente. Si el contacto no trae celular
                    // todavía, no hay nada que proteger y se puede cargar
                    // uno nuevo directo desde acá.
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: CustomComboSearchField(
                            data: prefijosCelular,
                            label: 'Prefijo',
                            enabled: _celularEditable && !_isLoading,
                            initialValue: _paisCelular?.codigoTelefono,
                            onChanged: (item) {
                              if (item == null) return;
                              final pais = catalogState.paises
                                  .where((p) => p.codigoTelefono == item.id)
                                  .firstOrNull;
                              if (pais != null) {
                                setState(() => _paisCelular = pais);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          flex: 3,
                          child: CustomTextField(
                            label: 'Celular',
                            controller: _celularCtrl,
                            enabled: _celularEditable && !_isLoading,
                            keyboardType: TextInputType.phone,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    CustomTextField(
                      label: 'Correo',
                      controller: _correoCtrl,
                      enabled: !_isLoading,
                      isUpperCase: true,
                      keyboardType: TextInputType.emailAddress,
                      // Correo es opcional — solo valida el formato si el
                      // asesor sí escribió algo (v.emailValidator marca "El
                      // email es requerido" en vacío, lo cual ya no aplica).
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? null : v.emailValidator,
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    const FormSectionTitle('Información comercial'),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            label: 'RUC',
                            controller: _rucCtrl,
                            focusNode: _rucFocus,
                            enabled: !_isLoading,
                            keyboardType: TextInputType.number,
                            maxLength: 11,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: CustomTextField(
                            label: 'Razón social',
                            controller: _razonSocialCtrl,
                            enabled: !_isLoading,
                            isUpperCase: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    // El combo solo sugiere Cargos ya usados por otros
                    // asesores; si no está en la lista, se guarda el texto
                    // tipeado tal cual al confirmar con el check del teclado.
                    CustomComboSearchField(
                      data: catalogState.cargos
                          .map((cg) => '${cg.id}${AppConstants.sepCampos}${cg.nombre}')
                          .toList(),
                      label: 'Cargo',
                      enabled: !_isLoading,
                      allowFreeText: true,
                      initialText: _cargo,
                      onChanged: (item) =>
                          setState(() => _cargo = item?.descripcion ?? ''),
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
              iconoGuardar: AppIcons.save,
              textoGuardar: 'Guardar cambios',
            ),
          ],
        ),
        if (_buscandoDocumento)
          const AppProcessOverlay(
            status: AppProcessStatus.cargando,
            loadingMessage: 'Buscando datos del documento...',
          ),
        if (_buscandoRuc)
          const AppProcessOverlay(
            status: AppProcessStatus.cargando,
            loadingMessage: 'Buscando datos del RUC...',
          ),
        // Overlay único "Guardando... → check verde animado" (reusa
        // AppProcessOverlay, core — mismo patrón que EditLeadPortrait) — antes
        // eran AppLoadingOverlay + un check estático propio (_ExitoOverlaySimple,
        // ya no existe).
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
