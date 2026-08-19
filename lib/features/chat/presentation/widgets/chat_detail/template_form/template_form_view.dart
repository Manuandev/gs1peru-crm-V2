// lib/features/chat/presentation/widgets/chat_detail/template_form/template_form_view.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/features/chat/index_chat.dart';

class TemplateFormView extends StatelessWidget {
  const TemplateFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Plantilla')),
      body: SafeArea(
        child: BlocBuilder<TemplateFormBloc, TemplateFormState>(
          builder: (context, state) {
            return switch (state) {
              TemplateFormLoaded() => _TemplateFormPortrait(
                plantilla: state.plantilla,
              ),
              TemplateFormError(:final message) => AppErrorView(
                message: message,
                onRetry: () => context.goBack(),
              ),
              TemplateFormInitial() || _ => const AppLoadingView(),
            };
          },
        ),
      ),
    );
  }
}

// ── Formulario ────────────────────────────────────────────────────────────

class _TemplateFormPortrait extends StatefulWidget {
  final Plantilla plantilla;
  const _TemplateFormPortrait({required this.plantilla});

  @override
  State<_TemplateFormPortrait> createState() => _TemplateFormPortraitState();
}

class _TemplateFormPortraitState extends State<_TemplateFormPortrait> {
  late final TextEditingController _nombreCtrl;
  late final TextEditingController _contenidoCtrl;
  late final List<TextEditingController> _botonesCtrls;
  // idBoton de cada botón, en el mismo índice que su controller en
  // _botonesCtrls (0 = nuevo, todavía sin guardar) — viaja de vuelta al
  // guardar para que el SP actualice en sitio en vez de borrar/reinsertar
  // todos los botones en cada guardado (ver Plantilla.botones/chat/CLAUDE.md).
  late final List<int> _botonesIds;

  CampaniaItem? _campania;
  OportunidadItem? _oportunidad;
  List<OportunidadItem> _oportunidadesFiltradas = [];
  EstadoItem? _estado;
  bool _activo = true;
  bool _compartir = false;
  StagedFile? _archivo;
  // true cuando `_archivo` viene de elegirlo/grabarlo recién en esta sesión
  // (path LOCAL del dispositivo, todavía no subido) — false cuando viene tal
  // cual de la plantilla ya guardada (ruta real del servidor, cargada en
  // initState) o cuando no hay archivo. Solo dispara la subida en _guardar()
  // si es true — así no se re-sube un archivo que ya estaba en el servidor
  // por el simple hecho de haber editado otro campo del formulario.
  bool _archivoEsNuevo = false;
  bool _grabandoAudio = false;
  bool _guardando = false;
  // true durante el check verde tras un guardado exitoso — mismo patrón de
  // 2 pasos que EditLeadPortrait (ver AppProcessOverlay, core/CLAUDE.md).
  bool _mostrandoExito = false;

  // Snapshot armado al terminar initState (después de matchear Campaña/
  // Oportunidad/Estado contra el catálogo) — base contra la que se compara
  // en _hayCambios, mismo patrón que EditContactoPortrait._snapshotInicial
  // (lead/CLAUDE.md). `Plantilla` ya extiende Equatable, no hizo falta
  // agregar nada ahí.
  Plantilla? _snapshotInicial;

  @override
  void initState() {
    super.initState();
    final p = widget.plantilla;

    _nombreCtrl = TextEditingController(text: p.nombre)
      ..addListener(_onFormChanged);
    _contenidoCtrl = TextEditingController(text: p.contenido)
      ..addListener(_onFormChanged);
    _botonesCtrls = p.botones
        .map(
          (b) =>
              TextEditingController(text: b.texto)..addListener(_onFormChanged),
        )
        .toList();
    _botonesIds = p.botones.map((b) => b.idBoton).toList();
    _activo = p.activo;
    _compartir = p.compartir;

    if (p.archivoNombre.isNotEmpty) {
      _archivo = StagedFile(
        path: p.archivoRuta,
        nameWithoutExt: p.archivoNombre,
        ext: p.archivoExt,
        tipo: 'document',
        sizeBytes: 0,
      );
    }

    // Campaña/Oportunidad/Estado se matchean por id contra el catálogo
    // global, mismo criterio que edit_lead_portrait._inicializarCombos.
    final catalogState = context.read<CatalogsBloc>().state;
    if (catalogState is CatalogsLoaded) {
      _campania = catalogState.campanias
          .where((c) => c.id == p.idCampania)
          .firstOrNull;
      if (_campania != null) {
        _oportunidadesFiltradas = catalogState.oportunidades
            .where((o) => o.idCampania == _campania!.id)
            .toList();
        _oportunidad = _oportunidadesFiltradas
            .where((o) => o.id == p.idOportunidad)
            .firstOrNull;
      }
      _estado = catalogState.estados
          .where((e) => e.id == p.idEstadoNegociacion && e.esPadre)
          .firstOrNull;
    }

    _snapshotInicial = _construirPlantilla();
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _contenidoCtrl.dispose();
    for (final c in _botonesCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  // Reconstruye el form al tipear en descripción o en cualquier botón — las
  // reglas de audio/texto/botones de abajo dependen del contenido en vivo de
  // esos controllers, no solo de su presencia.
  void _onFormChanged() {
    if (mounted) setState(() {});
  }

  // "No se puede enviar audio junto con texto": grabar/adjuntar audio exige
  // la descripción vacía, y un audio ya grabado/adjunto bloquea escribir la
  // descripción y agregar o editar botones (ver template_form_adjuntos_section.dart /
  // template_form_descripcion_section.dart / template_form_botones_section.dart).
  bool get _hayDescripcion => _contenidoCtrl.text.trim().isNotEmpty;
  bool get _archivoEsAudio => _archivo?.tipo == 'audio';
  bool get _bloqueadoPorAudio => _grabandoAudio || _archivoEsAudio;
  bool get _puedeGrabarAudio => !_hayDescripcion;

  // Nombre, Campaña y Oportunidad son obligatorios (regla de negocio
  // confirmada por el usuario) — Estado NO lo es, queda sin exigir. Gatea
  // `FormSaveBar.isEnabled`, mismo criterio que
  // `EditLeadPortrait._camposObligatoriosCompletos`.
  bool get _camposObligatoriosCompletos =>
      _nombreCtrl.text.trim().isNotEmpty &&
      _campania != null &&
      _oportunidad != null;

  // true si el formulario ya no calza con lo que había al entrar — gatea el
  // diálogo de confirmación al cancelar/retroceder (_confirmarSalir).
  bool get _hayCambios =>
      _snapshotInicial != null && _construirPlantilla() != _snapshotInicial;

  // Cancelar (botón) y retroceder (AppBar/gesto físico, ver PopScope en
  // build()) pasan por acá — solo interrumpe con un diálogo si de verdad hay
  // algo que se perdería, mismo criterio que
  // SolicitudWizardView._confirmarSalir (solicitudes/CLAUDE.md).
  Future<void> _confirmarSalir() async {
    if (!_hayCambios) {
      context.goBack();
      return;
    }
    final confirmado = await context.showConfirmDialog(
      title: 'Salir sin guardar',
      message:
          'Tienes cambios sin guardar en la plantilla. ¿Deseas salir? Los '
          'cambios se perderán.',
      confirmText: 'Sí, salir',
      cancelText: 'No',
    );
    if (confirmado && mounted) context.goBack();
  }

  void _onCampaniaChanged(CampaniaItem? item) {
    final catalogState = context.read<CatalogsBloc>().state;
    if (catalogState is! CatalogsLoaded) return;
    setState(() {
      _campania = item;
      _oportunidad = null;
      _oportunidadesFiltradas = item == null
          ? []
          : catalogState.oportunidades
                .where((o) => o.idCampania == item.id)
                .toList();
    });
  }

  // Con archivo adjunto el tope de botones baja a 3; sin archivo son 6
  // (regla de negocio confirmada por el usuario).
  int get _maxBotones => _archivo != null ? 3 : 6;

  // Con más de 3 botones ya agregados no se puede adjuntar un archivo —
  // adjuntar bajaría el tope a 3 dejando la plantilla en un estado inválido.
  bool get _puedeAdjuntar => _botonesCtrls.length <= 3;

  void _agregarBoton() {
    if (_botonesCtrls.length >= _maxBotones) return;
    // Botones solo se crean con descripción escrita, sin audio grabando/
    // adjunto, y con el botón anterior ya completo (regla de negocio
    // confirmada por el usuario) — la UI ya deshabilita "Agregar botón" en
    // estos casos, este guard es solo defensivo.
    if (!_hayDescripcion || _bloqueadoPorAudio) return;
    if (_botonesCtrls.any((c) => c.text.trim().isEmpty)) return;
    setState(() {
      _botonesCtrls.add(TextEditingController()..addListener(_onFormChanged));
      _botonesIds.add(0);
    });
  }

  void _quitarBoton(int index) {
    setState(() {
      _botonesCtrls.removeAt(index).dispose();
      _botonesIds.removeAt(index);
    });
  }

  // Solo arma el StagedFile local (path del dispositivo) — no sube nada
  // todavía. La subida real pasa recién al presionar "Guardar plantilla"
  // (_guardar), y solo si hace falta — ver TemplateFormBloc.guardar().
  void _onArchivoSeleccionado(StagedFile local) {
    setState(() {
      _archivo = local;
      _archivoEsNuevo = true;
      _grabandoAudio = false;
    });
  }

  Plantilla _construirPlantilla() => Plantilla(
    idPlantilla: widget.plantilla.idPlantilla,
    nombre: _nombreCtrl.text,
    idMeta: widget.plantilla.idMeta,
    estadoMeta: widget.plantilla.estadoMeta,
    contenido: _contenidoCtrl.text,
    archivoRuta: _archivo?.path ?? '',
    archivoNombre: _archivo?.nameWithoutExt ?? '',
    archivoExt: _archivo?.ext ?? '',
    tieneBoton: _botonesCtrls.isNotEmpty,
    idCampania: _campania?.id ?? 0,
    idOportunidad: _oportunidad?.id ?? 0,
    idEstadoNegociacion: _estado?.id ?? '',
    activo: _activo,
    compartir: _compartir,
    botones: [
      for (var i = 0; i < _botonesCtrls.length; i++)
        if (_botonesCtrls[i].text.trim().isNotEmpty)
          PlantillaBoton(
            idBoton: _botonesIds[i],
            texto: _botonesCtrls[i].text.trim(),
          ),
    ],
  );

  Future<void> _guardar() async {
    if (!_camposObligatoriosCompletos) return;

    final plantilla = _construirPlantilla();

    setState(() => _guardando = true);

    // Si hay un archivo elegido/grabado en esta sesión, el Bloc lo sube
    // primero (y recién con la ruta real del servidor guarda la plantilla);
    // si no hay archivo nuevo (sin adjunto, o el que ya traía la plantilla
    // sin tocarlo), guarda directo — ver TemplateFormBloc.guardar().
    final result = await context.read<TemplateFormBloc>().guardar(
      plantilla,
      archivoLocal: _archivoEsNuevo ? _archivo : null,
    );

    if (!mounted) return;
    setState(() => _guardando = false);

    switch (result) {
      case CrudOk():
        setState(() => _mostrandoExito = true);
        await Future.delayed(const Duration(milliseconds: 1500));
        if (mounted) context.goBack(true);
      case CrudAlert(:final message) || CrudError(:final message):
        AppSnackBar.error(context, message);
      case CrudNoInternet():
        AppSnackBar.error(context, 'Sin conexión a Internet.');
      case CrudEmpty():
        AppSnackBar.error(context, 'El servidor no respondió.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final esNueva = widget.plantilla.idPlantilla == 0;

    return PopScope(
      // Cubre el back del AppBar y el gesto/botón físico — ambos llaman
      // Navigator.maybePop internamente, que sí respeta PopScope (a
      // diferencia del botón "Cancelar" de FormSaveBar más abajo, que llama
      // _confirmarSalir directo porque un pop explícito no pasa por acá).
      canPop: !_hayCambios,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmarSalir();
      },
      child: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const FormSectionTitle('Datos generales'),
                      const SizedBox(height: AppSpacing.sm),
                      TemplateFormGeneralSection(
                        nombreCtrl: _nombreCtrl,
                        campania: _campania,
                        oportunidad: _oportunidad,
                        oportunidadesFiltradas: _oportunidadesFiltradas,
                        estado: _estado,
                        activo: _activo,
                        compartir: _compartir,
                        onCampaniaChanged: _onCampaniaChanged,
                        onOportunidadChanged: (item) =>
                            setState(() => _oportunidad = item),
                        onEstadoChanged: (item) =>
                            setState(() => _estado = item),
                        onActivoChanged: (v) => setState(() => _activo = v),
                        onCompartirChanged: (v) =>
                            setState(() => _compartir = v),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      TemplateFormAdjuntosSection(
                        archivo: _archivo,
                        grabando: _grabandoAudio,
                        puedeAdjuntar: _puedeAdjuntar,
                        puedeGrabarAudio: _puedeGrabarAudio,
                        subiendo: _guardando,
                        onArchivoSeleccionado: _onArchivoSeleccionado,
                        onQuitarArchivo: () => setState(() {
                          _archivo = null;
                          _archivoEsNuevo = false;
                        }),
                        onIniciarGrabacion: () =>
                            setState(() => _grabandoAudio = true),
                        onCancelarGrabacion: () =>
                            setState(() => _grabandoAudio = false),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      TemplateFormDescripcionSection(
                        controller: _contenidoCtrl,
                        enabled: !_bloqueadoPorAudio,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      TemplateFormBotonesSection(
                        botonesCtrls: _botonesCtrls,
                        maxBotones: _maxBotones,
                        hayDescripcion: _hayDescripcion,
                        bloqueadoPorAudio: _bloqueadoPorAudio,
                        onAgregar: _agregarBoton,
                        onQuitar: _quitarBoton,
                      ),
                    ],
                  ),
                ),
              ),
              FormSaveBar(
                onCancelar: _confirmarSalir,
                onGuardar: _guardar,
                isLoading: _guardando || _mostrandoExito,
                isEnabled: _camposObligatoriosCompletos,
                textoGuardar: 'Guardar plantilla',
              ),
            ],
          ),
          // Mismo overlay de 2 pasos "Guardando... → check verde" que
          // EditLeadPortrait (ver AppProcessOverlay, core/CLAUDE.md) — cubre
          // tanto la subida del archivo adjunto (si hay uno nuevo) como el
          // guardado de la plantilla en sí, ambos parte de la misma llamada
          // a TemplateFormBloc.guardar() en _guardar().
          if (_guardando || _mostrandoExito)
            AppProcessOverlay(
              status: _guardando
                  ? AppProcessStatus.cargando
                  : AppProcessStatus.exito,
              loadingMessage: esNueva
                  ? 'Creando plantilla...'
                  : 'Editando plantilla...',
              successMessage: esNueva
                  ? 'La plantilla se creó correctamente'
                  : 'La plantilla se editó correctamente',
            ),
        ],
      ),
    );
  }
}
