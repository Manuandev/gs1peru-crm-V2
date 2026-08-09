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

  @override
  void initState() {
    super.initState();
    final p = widget.plantilla;

    _nombreCtrl = TextEditingController(text: p.nombre);
    _contenidoCtrl = TextEditingController(text: p.contenido);
    _botonesCtrls = p.botones
        .map((texto) => TextEditingController(text: texto))
        .toList();
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
    setState(() => _botonesCtrls.add(TextEditingController()));
  }

  void _quitarBoton(int index) {
    setState(() => _botonesCtrls.removeAt(index).dispose());
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

  Future<void> _guardar() async {
    final plantilla = Plantilla(
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
      botones: _botonesCtrls
          .map((c) => c.text.trim())
          .where((t) => t.isNotEmpty)
          .toList(),
    );

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
        if (mounted) context.goBack();
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

    return Stack(
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
                    TemplateFormDescripcionSection(controller: _contenidoCtrl),
                    const SizedBox(height: AppSpacing.lg),
                    TemplateFormBotonesSection(
                      botonesCtrls: _botonesCtrls,
                      maxBotones: _maxBotones,
                      onAgregar: _agregarBoton,
                      onQuitar: _quitarBoton,
                    ),
                  ],
                ),
              ),
            ),
            FormSaveBar(
              onCancelar: () => context.goBack(),
              onGuardar: _guardar,
              isLoading: _guardando || _mostrandoExito,
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
    );
  }
}
