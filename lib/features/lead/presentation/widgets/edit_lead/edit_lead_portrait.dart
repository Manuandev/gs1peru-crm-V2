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
  // Espejo de _isLoading/_mostrandoExito para que EditLeadView bloquee el
  // back del AppBar mientras se guarda — ver nota en _setGuardando().
  final ValueNotifier<bool>? guardandoNotifier;

  const EditLeadPortrait({
    super.key,
    required this.negociacion,
    this.soloLectura = false,
    this.desdeConversacion = false,
    this.guardandoNotifier,
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
// - Estado/Subestado SIEMPRE fijos en "Nuevo" (id '00') al CREAR, sin
//   importar el origen — el combo queda bloqueado (enabled: false), no solo
//   con un valor por defecto. Al editar una negociación ya creada, sí se
//   pueden mover de estado normalmente.
//
// Al entrar desde el chat de Conversaciones (desdeConversacion == true, crear
// o editar negociación):
// - Canal siempre bloqueado en WhatsApp, en crear y en editar.
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
  // Cantidad nunca puede quedar por debajo de 1 — ver _onCantidadFocusChange.
  late final FocusNode _cantidadFocus;

  bool _isLoading = false;
  bool _combosInicializados = false;
  // Defaults de Precio base/Costo final/Moneda (ver _inicializarCombos) solo
  // se aplican UNA VEZ, al entrar a la pantalla — no en cada re-sync de
  // combos. _inicializarCombos también corre en didUpdateWidget cada vez que
  // cambia widget.negociacion (ej. justo después de guardar, cuando
  // InfoLeadCubit emite la negociación ya persistida) — sin este flag, un
  // Costo final puesto a propósito en 0 (negociación gratuita) se volvería a
  // pisar con el precio calculado apenas se guarda, deshaciendo la elección
  // del usuario.
  bool _defaultsFinancierosAplicados = false;
  // true mientras se muestra el check verde de "guardado correctamente" —
  // ver _ExitoOverlay y _guardar().
  bool _mostrandoExito = false;

  // ── Ciclo de vida ─────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    final n = widget.negociacion;
    // Cantidad nunca arranca en 0/blanco — si la negociación no trae
    // cantidad (crear o editar), se completa en 1. Precio base/Costo
    // final/Moneda dependen de la Oportunidad del catálogo (que acá todavía
    // no está cargado) — esos defaults se completan más abajo, en
    // _inicializarCombos.
    final cantidadInicial = n.cantidad > 0 ? n.cantidad : 1;
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
    // Cantidad no puede quedar por debajo de 1 — se corrige recién al
    // perder el foco (no en cada tecla), para no pelear con el usuario
    // mientras borra el campo para tipear un valor nuevo.
    _cantidadFocus = FocusNode()..addListener(_onCantidadFocusChange);
  }

  void _onCantidadChanged() {
    final nuevoCostoFinal = NumberFormatUtils.fmtDecimal(
      _precioBase * _cantidad,
    );
    if (_costoFinalCtrl.text != nuevoCostoFinal) {
      _costoFinalCtrl.text = nuevoCostoFinal;
    }
  }

  void _onCantidadFocusChange() {
    if (_cantidadFocus.hasFocus) return; // solo al perder el foco
    if (_cantidad < 1) {
      _cantidadCtrl.text = NumberFormatUtils.fmtInt(1);
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
    _cantidadFocus.dispose();
    // _seccionCambio.dispose();
    widget.guardandoNotifier?.value = false;
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

    // Moneda: fuente normal es el idMoneda de la negociación.
    _monedaItem = state.monedas.where((m) => m.id == n.idMoneda).firstOrNull;

    // Defaults de Precio base/Costo final/Moneda cuando la negociación no
    // los trae — pedido de negocio, solo al ENTRAR a la pantalla (ver
    // _defaultsFinancierosAplicados). Si el usuario deja Costo final en 0 a
    // propósito (negociación gratuita) y guarda, ese 0 debe respetarse en
    // cualquier re-sync posterior de este método — nunca se vuelve a
    // "corregir" solo porque siga siendo 0.
    if (!_defaultsFinancierosAplicados) {
      // Moneda: si no matcheó por id, se completa con la moneda de la
      // Oportunidad elegida — "primera moneda del catálogo" queda solo como
      // último recurso, si tampoco la Oportunidad trae una moneda válida.
      _monedaItem ??= state.monedas
          .where((m) => m.id == _oportunidad?.idMoneda)
          .firstOrNull;
      _monedaItem ??= state.monedas.firstOrNull;

      // Precio base / Costo final: se completan con el precio general de la
      // Oportunidad elegida. Con ambos completados así, Descuento (subtotal
      // - costoFinal, ver getter _descuento) sale en 0 automáticamente, sin
      // necesitar un default aparte.
      final precioGeneralOportunidad = _oportunidad?.importeGeneral ?? 0;
      if (n.precioBase <= 0) {
        _precioBaseCtrl.text = NumberFormatUtils.fmtDecimal(
          precioGeneralOportunidad,
        );
      }
      if (n.precio <= 0) {
        _costoFinalCtrl.text = NumberFormatUtils.fmtDecimal(
          precioGeneralOportunidad * _cantidad,
        );
      }
      _defaultsFinancierosAplicados = true;
    }

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

    // Al CREAR (idLead == 0), en CUALQUIER origen, el estado siempre queda
    // fijo en "Nuevo" (id '00') — matchea SOLO por id, sin exigir esPadre
    // (acá no se usa como opción de un combo con data filtrada, es el valor
    // fijo que se manda tal cual al guardar). El combo se bloquea
    // (enabled: false) en build() vía estadoBloqueado: _esNuevo — no depende
    // de desdeConversacion, el usuario no puede cambiarlo en ningún origen.
    if (_esNuevo) {
      _estado = state.estados.where((e) => e.id == '00').firstOrNull;
      _subEstado = null;
      _subEstadosFiltrados = [];
    }
  }

  // Centraliza los cambios de _isLoading/_mostrandoExito y avisa al
  // ValueNotifier compartido con EditLeadView — sin esto, el botón back del
  // AppBar (fuera de este State) queda tocable durante el guardado y durante
  // los 1.5s del check verde, y una salida manual ahí compite con el pop
  // automático de _guardar() (bug real detectado en vivo: el pop manual
  // dejaba _guardar() varado a mitad de guardar/refrescar, y en Conversación
  // el ChatLeadPanel se cerraba de encima al volver antes de tiempo).
  void _setGuardando({bool? isLoading, bool? mostrandoExito}) {
    setState(() {
      if (isLoading != null) _isLoading = isLoading;
      if (mostrandoExito != null) _mostrandoExito = mostrandoExito;
    });
    widget.guardandoNotifier?.value = _isLoading || _mostrandoExito;
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

    _setGuardando(isLoading: true);

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
        // idContacto, no idNumero — ver comentario en InfoLeadCubit.updateLead.
        idContacto: widget.negociacion.idContacto,
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

    if (mounted) _setGuardando(isLoading: false);

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
        cargoNegociacion: n.cargo,
        tipoDocIdNegociacion: n.tipoDocId,
        numDocNegociacion: n.numDoc,
      );
      return;
    }

    // Guardado normal (sin redirect a "Generar solicitud"): muestra el check
    // verde un momento y vuelve sola — el llamador (NegociacionesTab/
    // NegociacionCard en Conversaciones, ContactoNegociacionCard/
    // ContactoDetalleView en Seguimiento) ya refresca sus datos al recibir
    // LeadUpdateNotifier (emitido dentro de InfoLeadCubit.updateLead) o al
    // compartir el mismo InfoLeadCubit, así que acá solo hace falta
    // retroceder — no un refresh explícito.
    if (guardadoOk && mounted) {
      _setGuardando(mostrandoExito: true);
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) context.goBack();
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
              // Incluye _mostrandoExito — sin esto "Cancelar" queda tocable
              // durante los 1.5s del check verde, compitiendo con el pop
              // automático de _guardar() (ver _setGuardando()).
              isLoading: _isLoading || _mostrandoExito,
              isEnabled: _puedeGuardar,
              iconoGuardar: AppIcons.save,
              textoGuardar: 'Guardar cambios',
            ),
          );

    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.md),
                children: [
                  // 1. Negociación — Información adicional (nombre/modalidad)
                  // ya no se muestra en ningún origen, ver nota de reglas
                  // arriba.
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
                    // Al crear, en cualquier origen, el estado queda fijo en
                    // "Nuevo" y no se puede cambiar; al editar sí se puede
                    // mover de estado normalmente.
                    estadoBloqueado: _esNuevo,
                    // El canal desde conversación siempre es WhatsApp fijo.
                    canalBloqueado: widget.desdeConversacion,
                    // Campaña/Oportunidad solo se activan al crear, en
                    // cualquier origen — al editar quedan fijas siempre.
                    campaniaOportunidadBloqueada: !_esNuevo,
                    onCampaniaChanged: _onCampaniaChanged,
                    onOportunidadChanged: _onOportunidadChanged,
                    onCanalChanged: (item) => setState(() => _canal = item),
                    onInteresChanged: (item) =>
                        setState(() => _interes = item),
                    onEstadoChanged: _onEstadoChanged,
                    onSubEstadoChanged: (item) =>
                        setState(() => _subEstado = item),
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
                      cantidadFocusNode: _cantidadFocus,
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
        ),
        // Overlay único "Guardando... → check verde animado" (reusa
        // AppProcessOverlay, core) — antes eran dos overlays separados
        // (AppLoadingOverlay + un check estático) que se cortaban en seco
        // uno con otro; ahora AppProcessOverlay anima la transición entre
        // ambos estados. _guardar() retrocede solo tras mostrar el check
        // (ver _setGuardando()).
        if (_isLoading || _mostrandoExito)
          AppProcessOverlay(
            status: _isLoading
                ? AppProcessStatus.cargando
                : AppProcessStatus.exito,
            loadingMessage: _esNuevo
                ? 'Creando negociación...'
                : 'Editando negociación...',
            successMessage: _esNuevo
                ? 'La negociación se creó correctamente'
                : 'La negociación se editó correctamente',
          ),
      ],
    );
  }
}
