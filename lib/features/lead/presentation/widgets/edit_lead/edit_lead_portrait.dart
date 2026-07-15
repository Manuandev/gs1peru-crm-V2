// lib/features/lead/presentation/widgets/edit_lead/edit_lead_portrait.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/features/lead/index_lead.dart';
import 'package:app_crm/features/solicitudes/index_solicitudes.dart';

// Id real del canal WhatsApp en el catálogo — confirmado en vivo (5), NO el
// 1 que documenta core/CLAUDE.md (dato desactualizado ahí, sin corregir en
// este cambio por no tener certeza de que ese "1" esté mal en TODOS los usos
// del resto de la app — solo se corrige acá, donde se confirmó).
const int _idCanalWhatsApp = 5;

class EditLeadPortrait extends StatefulWidget {
  final Negociacion negociacion;
  final bool soloLectura;
  // true cuando se entra desde el chat de Conversaciones — ver reglas de
  // negocio en el comentario de _EditLeadPortraitState.
  final bool desdeConversacion;

  const EditLeadPortrait({
    super.key,
    required this.negociacion,
    this.soloLectura = false,
    this.desdeConversacion = false,
  });

  @override
  State<EditLeadPortrait> createState() => _EditLeadPortraitState();
}

// ── Reglas de negocio ──────────────────────────────────────────────────────
// - Información adicional (nombre/modalidad de la negociación) nunca se
//   muestra, en ningún origen. El campo sigue existiendo en el backend pero
//   no es editable desde esta pantalla.
// - Precio base y Descuento NUNCA son editables por el usuario, en ningún
//   origen: Precio base se autocompleta al elegir Oportunidad
//   (item.importeGeneral) y Descuento se autocalcula
//   (subtotal - costo final). El único campo editable de esa fila es
//   Costo final.
// - Campaña/Oportunidad solo son editables al CREAR (negociacion.idLead ==
//   0), sin importar el origen — al editar una negociación ya creada quedan
//   siempre bloqueadas.
// - Cantidad arranca en 1 por defecto al crear.
// - Para crear una negociación son obligatorios: Estado, Campaña, Oportunidad,
//   Canal, Moneda y Cantidad — el botón Guardar no se habilita hasta tenerlos
//   completos. Subestado NUNCA es obligatorio.
//
// Al entrar desde el chat de Conversaciones (desdeConversacion == true, crear
// o editar negociación):
// - Canal siempre bloqueado en WhatsApp, en crear y en editar.
// - Estado/Subestado bloqueados en "Nuevo" (id '00') solo al CREAR — al
//   editar una negociación ya creada, sí se pueden mover de estado.
// - Interés siempre editable.
class _EditLeadPortraitState extends State<EditLeadPortrait> {
  // ── EditLeadContactoSection comentada — la página solo muestra lo que se
  // puede guardar/actualizar, no info de contacto de solo lectura. ──────────
  // final _contactoKey = GlobalKey<EditLeadContactoSectionState>();
  // final _seccionCambio = ValueNotifier<int>(0);

  // ── Combos de catálogo ────────────────────────────────────────────────────
  EstadoItem? _estado;
  EstadoItem? _subEstado;
  List<EstadoItem> _subEstadosFiltrados = [];
  CampaniaItem? _campania;
  OportunidadItem? _oportunidad;
  List<OportunidadItem> _oportunidadesFiltradas = [];
  CanalItem? _canal;
  InteresItem? _interes;
  MonedaItem? _monedaItem;

  // ── Campos editables ──────────────────────────────────────────────────────
  late final TextEditingController _cantidadCtrl;
  // Precio base ya no lo escribe el usuario — se autocompleta desde la
  // Oportunidad elegida (_onOportunidadChanged), pero se mantiene como
  // controller porque igual viaja en el guardado.
  late final TextEditingController _precioBaseCtrl;
  // Costo final es el único campo editable de la fila financiera; Descuento
  // se deriva de él (ver getters financieros).
  late final TextEditingController _costoFinalCtrl;

  bool _isLoading = false;
  bool _combosInicializados = false;

  // ── Ciclo de vida ─────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    final n = widget.negociacion;
    // Al crear, Cantidad arranca en 1 por defecto — no en blanco/0.
    final cantidadInicial = (n.idLead == 0 && n.cantidad == 0) ? 1 : n.cantidad;
    _cantidadCtrl = TextEditingController(
      text: NumberFormatUtils.fmtInt(cantidadInicial),
    );
    _precioBaseCtrl = TextEditingController(
      text: NumberFormatUtils.fmtDecimal(n.precioBase),
    );
    _costoFinalCtrl = TextEditingController(
      text: NumberFormatUtils.fmtDecimal(n.precio),
    );
    // Costo final se resetea al nuevo subtotal cada vez que cambia Cantidad
    // — mismo comportamiento que al cambiar Oportunidad (ver
    // _onOportunidadChanged). Bug real detectado en vivo: sin esto, un Costo
    // final manual quedaba "congelado" mientras el subtotal (precioBase ×
    // cantidad) crecía, y Descuento (subtotal - costoFinal) se inflaba solo
    // por subir la cantidad, no porque hubiera un descuento real.
    _cantidadCtrl.addListener(_onCantidadChanged);
  }

  void _onCantidadChanged() {
    final nuevoCostoFinal = NumberFormatUtils.fmtDecimal(
      _precioBase * _cantidad,
    );
    if (_costoFinalCtrl.text != nuevoCostoFinal) {
      _costoFinalCtrl.text = nuevoCostoFinal;
    }
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

  @override
  void didUpdateWidget(covariant EditLeadPortrait old) {
    super.didUpdateWidget(old);
    if (widget.negociacion == old.negociacion) return;
    final catalogState = context.read<CatalogsBloc>().state;
    if (catalogState is! CatalogsLoaded) return;
    setState(() {
      _combosInicializados = false;
      _inicializarCombos(catalogState);
      _combosInicializados = true;
    });
  }

  @override
  void dispose() {
    _cantidadCtrl.dispose();
    _precioBaseCtrl.dispose();
    _costoFinalCtrl.dispose();
    // _seccionCambio.dispose();
    super.dispose();
  }

  // ── Inicialización de combos ──────────────────────────────────────────────

  void _inicializarCombos(CatalogsLoaded state) {
    final n = widget.negociacion;
    _campania = state.campanias.where((e) => e.id == n.idCampania).firstOrNull;
    _oportunidadesFiltradas = _campania == null
        ? []
        : state.oportunidades
              .where((e) => e.idCampania == _campania!.id)
              .toList();
    _oportunidad = _oportunidadesFiltradas
        .where((e) => e.id == n.idOportunidad)
        .firstOrNull;
    _canal = state.canales.where((e) => e.id == n.idCanal).firstOrNull;
    // Desde conversación el canal siempre es WhatsApp y no se muestra
    // editable — matchea SOLO por id (5, confirmado en vivo; el
    // core/CLAUDE.md documentaba 1, dato desactualizado). Nada de matchear
    // por nombre — lo que se guarda es el id real del catálogo.
    if (widget.desdeConversacion) {
      _canal =
          state.canales.where((e) => e.id == _idCanalWhatsApp).firstOrNull ??
          _canal;
    }
    _interes = state.intereses.where((e) => e.id == n.idInteres).firstOrNull;

    _monedaItem =
        state.monedas.where((m) => m.id == n.idMoneda).firstOrNull ??
        state.monedas.firstOrNull;

    if (state.estados.isNotEmpty) {
      final tienePadre = n.idEstadoPadre.isNotEmpty;
      if (tienePadre) {
        _estado = state.estados
            .where((e) => e.id == n.idEstadoPadre && e.esPadre)
            .firstOrNull;
        if (_estado != null) {
          _subEstadosFiltrados = state.estados
              .where((e) => e.idPadre == _estado!.id)
              .toList();
          _subEstado = _subEstadosFiltrados
              .where((e) => e.id == n.idEstado)
              .firstOrNull;
        }
      } else {
        _estado = state.estados
            .where((e) => e.id == n.idEstado && e.esPadre)
            .firstOrNull;

        if (_estado == null) {
          final hijo = state.estados
              .where((e) => e.id == n.idEstado && !e.esPadre)
              .firstOrNull;
          if (hijo != null) {
            _estado = state.estados
                .where((e) => e.id == hijo.idPadre && e.esPadre)
                .firstOrNull;
            if (_estado != null) {
              _subEstadosFiltrados = state.estados
                  .where((e) => e.idPadre == _estado!.id)
                  .toList();
              _subEstado = _subEstadosFiltrados
                  .where((e) => e.id == n.idEstado)
                  .firstOrNull;
            }
          }
        }
      }
    }

    // Desde conversación, al CREAR (idLead == 0) el estado siempre arranca
    // en "Nuevo" (id '00') y no se muestra editable — matchea SOLO por id,
    // sin exigir esPadre (acá no se usa como opción de un combo con data
    // filtrada, es el valor fijo que se manda tal cual al guardar).
    if (widget.desdeConversacion && _esNuevo) {
      _estado = state.estados.where((e) => e.id == '00').firstOrNull;
      _subEstado = null;
      _subEstadosFiltrados = [];
    }
  }

  // ── Getters financieros ───────────────────────────────────────────────────

  // Solo lectura (negociación con solicitud ya generada) o guardando — en
  // ambos casos ningún campo debe aceptar interacción.
  bool get _bloqueado => _isLoading || widget.soloLectura;

  // idLead 0 → aún no se creó el lead (pantalla "Crear negociación").
  bool get _esNuevo => widget.negociacion.idLead == 0;

  int get _cantidad => NumberFormatUtils.parseInt(_cantidadCtrl.text);
  double get _precioBase =>
      NumberFormatUtils.parseDecimal(_precioBaseCtrl.text);
  double get _subtotal => _precioBase * _cantidad;

  // Costo final es el campo editable; Descuento siempre se autocompleta —
  // en toda la app, sin excepción (ver reglas arriba).
  double get _costoFinal =>
      NumberFormatUtils.parseDecimal(_costoFinalCtrl.text);
  double get _descuento => (_subtotal - _costoFinal).clamp(0, double.infinity);

  // ── Detección de cambios / validación de campos obligatorios ──────────────

  bool get _hayCambios {
    final n = widget.negociacion;
    // idLead 0 → el guardado crea el lead, no hay nada que "cambiar" primero.
    return n.idLead == 0 ||
        (_estado != null && _subEstado?.id != n.idEstado) ||
        (_estado != null && _estado?.id != n.idEstado && _subEstado == null) ||
        _campania?.id != n.idCampania ||
        _oportunidad?.id != n.idOportunidad ||
        _canal?.id != n.idCanal ||
        _interes?.id != n.idInteres ||
        _cantidadCtrl.text != NumberFormatUtils.fmtInt(n.cantidad) ||
        _precioBaseCtrl.text != NumberFormatUtils.fmtDecimal(n.precioBase) ||
        _costoFinalCtrl.text != NumberFormatUtils.fmtDecimal(n.precio) ||
        (_monedaItem?.id ?? '') != n.idMoneda;
  }

  // Al crear son obligatorios Estado, Campaña, Oportunidad, Canal, Moneda y
  // Cantidad (Subestado nunca). Estado/Canal siempre deben venir matcheados
  // por id contra el catálogo (incluidos los valores fijos de conversación,
  // '00' y WhatsApp) — si no matchearon, Guardar debe quedar deshabilitado
  // en vez de guardar con un valor vacío.
  bool get _camposObligatoriosCompletos =>
      _estado != null &&
      _campania != null &&
      _oportunidad != null &&
      _canal != null &&
      _monedaItem != null &&
      _cantidad > 0;

  bool get _puedeGuardar =>
      _esNuevo ? _camposObligatoriosCompletos : _hayCambios;

  // ── Callbacks de combos ───────────────────────────────────────────────────

  void _onCampaniaChanged(CampaniaItem? item) {
    final catalogState = context.read<CatalogsBloc>().state;
    if (catalogState is! CatalogsLoaded) return;
    setState(() {
      _campania = item;
      _oportunidad = null;
      _oportunidadesFiltradas = item == null
          ? []
          : catalogState.oportunidades
                .where((e) => e.idCampania == item.id)
                .toList();
    });
  }

  void _onOportunidadChanged(OportunidadItem? item) {
    final catalogState = context.read<CatalogsBloc>().state;
    if (catalogState is! CatalogsLoaded) return;
    setState(() {
      _oportunidad = item;
      _monedaItem = catalogState.monedas
          .where((m) => m.id == item?.idMoneda)
          .firstOrNull;

      final precioBase = item?.importeGeneral ?? 0;
      _precioBaseCtrl.text = item != null
          ? NumberFormatUtils.fmtDecimal(precioBase)
          : '';
      // Costo final arranca igual al subtotal (precio base × cantidad) —
      // sin esto se quedaba en 0/vacío al cambiar de Oportunidad, y
      // Descuento (subtotal - costo final) salía igual al precio base
      // completo en vez de 0. El usuario ajusta Costo final manualmente
      // si corresponde un descuento real.
      _costoFinalCtrl.text = item != null
          ? NumberFormatUtils.fmtDecimal(precioBase * _cantidad)
          : '';
    });
  }

  void _onEstadoChanged(EstadoItem? item) {
    final catalogState = context.read<CatalogsBloc>().state;
    if (catalogState is! CatalogsLoaded) return;
    setState(() {
      _estado = item;
      _subEstado = null;
      _subEstadosFiltrados = item == null
          ? []
          : catalogState.estados.where((e) => e.idPadre == item.id).toList();
    });
  }

  // ── Guardar ───────────────────────────────────────────────────────────────

  Future<void> _guardar() async {
    if (!_puedeGuardar) return;

    final confirmar = await context.showConfirmDialog(
      title: 'Confirmar cambio',
      message: '¿Deseas guardar los cambios?',
    );
    if (!confirmar) return;

    setState(() => _isLoading = true);

    // Siempre se manda lo que quedó matcheado en _estado/_subEstado contra
    // el catálogo (por id) — al crear desde conversación eso ya es "Nuevo"
    // ('00'), forzado por id en _inicializarCombos, no un literal acá.
    final idEstadoEfectivo = _subEstado?.id ?? _estado?.id;
    final estadoEfectivo = _subEstado?.nombre ?? _estado?.nombre;
    final tieneSubEstado = _subEstado != null;

    // "Ganada": sub-estado '05' bajo el estado padre '04' (Cerrado). Si el
    // guardado la deja en ese estado por primera vez (no si ya estaba ahí
    // antes de este guardado, ni si ya tiene una solicitud generada), se
    // pasa directo al wizard de generar solicitud — mismo flujo/mismo
    // Solicitud en blanco que el botón manual "Generar solicitud" de
    // NegociacionCard/ContactoNegociacionCard (ver negociaciones_tab.dart).
    final n = widget.negociacion;
    final yaEstabaGanada = n.idEstado == '05' && n.idEstadoPadre == '04';
    final quedaGanada =
        tieneSubEstado && _estado?.id == '04' && _subEstado?.id == '05';
    final debeGenerarSolicitud =
        quedaGanada &&
        !yaEstabaGanada &&
        n.accionSolicitud == SolicitudAccion.generar;

    var guardadoOk = false;
    if (context.mounted) {
      // ignore: use_build_context_synchronously
      guardadoOk = await context.read<InfoLeadCubit>().updateLead(
        idNumero: widget.negociacion.idNumero,
        idEstado: idEstadoEfectivo,
        estado: estadoEfectivo,
        idEstadoPadre: tieneSubEstado ? _estado?.id : '',
        descripcionEstadoPadre: tieneSubEstado ? _estado?.nombre : '',
        idCampania: _campania?.id,
        campania: _campania?.nombre,
        idOportunidad: _oportunidad?.id,
        oportunidad: _oportunidad?.nombre,
        idCanal: _canal?.id,
        canal: _canal?.nombre,
        idInteres: _interes?.id,
        interes: _interes?.nombre,
        cantidad: int.tryParse(_cantidadCtrl.text),
        precioBase: double.tryParse(_precioBaseCtrl.text),
        descuento: _descuento,
        precio: _costoFinal > 0 ? _costoFinal : null,
        idMoneda: _monedaItem?.id,
      );
    }

    if (mounted) setState(() => _isLoading = false);

    if (guardadoOk && debeGenerarSolicitud && mounted) {
      final estadoInfoLead = context.read<InfoLeadCubit>().state;
      final idLeadFinal = estadoInfoLead is InfoLeadSuccess
          ? estadoInfoLead.negociacion.idLead
          : n.idLead;
      // ignore: use_build_context_synchronously
      context.goToFichaCompletarSolicitud(
        solicitud: Solicitud(
          idSolicitud: '',
          nombre: '',
          apellidoPaterno: '',
          apellidoMaterno: '',
          nombreEmpresa: '',
          cargo: '',
          correo: '',
          telefono: '',
          tipoPersona: '',
          idCondicionPago: '',
          condicionPago: '',
          monto: 0,
          fechaCreacion: '',
          idOportunidad: 0,
          oportunidad: '',
          idCanal: 0,
          canal: '',
          idEstado: 0,
          estado: '',
          ibValidado: false,
          asesor: '',
          nombreAsesor: '',
          idLead: idLeadFinal.toString(),
        ),
        modoEdicion: true,
        cantidadNegociacion: int.tryParse(_cantidadCtrl.text),
        precioBaseNegociacion: _precioBase,
        descuentoNegociacion: _descuento,
        idMonedaNegociacion: _monedaItem?.id,
        precioTotalNegociacion: _costoFinal,
        nombresNegociacion: n.nombres,
        apellidoPaternoNegociacion: n.apellidoPaterno,
        apellidoMaternoNegociacion: n.apellidoMaterno,
        nombreEmpresaNegociacion: n.nombreEmpresa,
        correoNegociacion: n.correo,
        celularNegociacion: n.numero,
        celularCodigoTelefonoNegociacion: n.prefijoPais,
        rucNegociacion: n.ruc,
      );
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final catalogState = context.read<CatalogsBloc>().state;
    if (catalogState is! CatalogsLoaded) return const AppLoadingView();

    // Solo lectura: ni el botón "Guardar" ni "Cancelar" tienen sentido — no
    // hay nada que guardar ni cancelar, solo volver con el back del AppBar.
    final formSaveBar = widget.soloLectura
        ? const SizedBox.shrink()
        : ListenableBuilder(
            listenable: Listenable.merge([
              _cantidadCtrl,
              _precioBaseCtrl,
              _costoFinalCtrl,
            ]),
            builder: (context, _) => FormSaveBar(
              onCancelar: () => context.goBack(),
              onGuardar: _guardar,
              isLoading: _isLoading,
              isEnabled: _puedeGuardar,
              iconoGuardar: AppIcons.save,
              textoGuardar: 'Guardar cambios',
            ),
          );

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              // 1. Negociación — Información adicional (nombre/modalidad) ya
              // no se muestra en ningún origen, ver nota de reglas arriba.
              EditLeadNegociacionSection(
                catalogState: catalogState,
                campania: _campania,
                oportunidad: _oportunidad,
                oportunidadesFiltradas: _oportunidadesFiltradas,
                canal: _canal,
                interes: _interes,
                estado: _estado,
                subEstado: _subEstado,
                subEstadosFiltrados: _subEstadosFiltrados,
                idEstadoFallback: widget.negociacion.idEstado,
                estadoFallback: widget.negociacion.descripcionEstado,
                descripcionEstadoPadreFallback:
                    widget.negociacion.descripcionEstadoPadre,
                idCanalFallback: widget.negociacion.idCanal,
                isLoading: _bloqueado,
                // Solo al crear desde conversación el estado queda fijo en
                // "Nuevo"; al editar sí se puede mover de estado.
                estadoBloqueado: widget.desdeConversacion && _esNuevo,
                // El canal desde conversación siempre es WhatsApp fijo.
                canalBloqueado: widget.desdeConversacion,
                // Campaña/Oportunidad solo se activan al crear, en
                // cualquier origen — al editar quedan fijas siempre.
                campaniaOportunidadBloqueada: !_esNuevo,
                onCampaniaChanged: _onCampaniaChanged,
                onOportunidadChanged: _onOportunidadChanged,
                onCanalChanged: (item) => setState(() => _canal = item),
                onInteresChanged: (item) => setState(() => _interes = item),
                onEstadoChanged: _onEstadoChanged,
                onSubEstadoChanged: (item) => setState(() => _subEstado = item),
              ),
              const SizedBox(height: AppSpacing.lg),

              // 2. Financiera
              ListenableBuilder(
                listenable: Listenable.merge([
                  _cantidadCtrl,
                  _precioBaseCtrl,
                  _costoFinalCtrl,
                ]),
                builder: (context, _) => EditLeadFinancieraSection(
                  cantidadCtrl: _cantidadCtrl,
                  precioBaseCtrl: _precioBaseCtrl,
                  costoFinalCtrl: _costoFinalCtrl,
                  monedas: catalogState.monedas,
                  monedaItem: _monedaItem,
                  isLoading: _bloqueado,
                  subtotal: _subtotal,
                  descuento: _descuento,
                  costoFinal: _costoFinal,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
        formSaveBar,
      ],
    );
  }
}
