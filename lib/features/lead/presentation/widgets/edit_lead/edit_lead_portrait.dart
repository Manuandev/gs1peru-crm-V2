// lib/features/lead/presentation/widgets/edit_lead/edit_lead_portrait.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class EditLeadPortrait extends StatefulWidget {
  final Negociacion negociacion;
  final bool soloLectura;

  const EditLeadPortrait({
    super.key,
    required this.negociacion,
    this.soloLectura = false,
  });

  @override
  State<EditLeadPortrait> createState() => _EditLeadPortraitState();
}

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
  late final TextEditingController _precioBaseCtrl;
  late final TextEditingController _descuentoCtrl;

  // ── Información adicional ──────────────────────────────────────────────────
  late final TextEditingController _nombreLeadCtrl;
  late final TextEditingController _modalidadCtrl;

  bool _isLoading = false;
  bool _combosInicializados = false;

  // ── Ciclo de vida ─────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    final n = widget.negociacion;
    _cantidadCtrl = TextEditingController(
      text: NumberFormatUtils.fmtInt(n.cantidad),
    );
    _precioBaseCtrl = TextEditingController(
      text: NumberFormatUtils.fmtDecimal(n.precioBase),
    );
    _descuentoCtrl = TextEditingController(
      text: NumberFormatUtils.fmtDecimal(n.descuento),
    );
    _nombreLeadCtrl = TextEditingController(text: n.nombre);
    _modalidadCtrl = TextEditingController(text: n.modalidad);
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
    _descuentoCtrl.dispose();
    _nombreLeadCtrl.dispose();
    _modalidadCtrl.dispose();
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
  }

  // ── Getters financieros ───────────────────────────────────────────────────

  // Solo lectura (negociación con solicitud ya generada) o guardando — en
  // ambos casos ningún campo debe aceptar interacción.
  bool get _bloqueado => _isLoading || widget.soloLectura;

  int get _cantidad => NumberFormatUtils.parseInt(_cantidadCtrl.text);
  double get _precioBase =>
      NumberFormatUtils.parseDecimal(_precioBaseCtrl.text);
  double get _descuento => NumberFormatUtils.parseDecimal(_descuentoCtrl.text);
  double get _subtotal => _precioBase * _cantidad;
  double get _costoFinal => _subtotal - _descuento;

  // ── Detección de cambios ──────────────────────────────────────────────────

  bool get _hayCambios {
    final n = widget.negociacion;
    // idLead 0 → el guardado crea el lead, no hay nada que "cambiar" primero.
    return n.idLead == 0 ||
        _nombreLeadCtrl.text.trim() != n.nombre ||
        _modalidadCtrl.text.trim() != n.modalidad ||
        (_estado != null && _subEstado?.id != n.idEstado) ||
        (_estado != null && _estado?.id != n.idEstado && _subEstado == null) ||
        _campania?.id != n.idCampania ||
        _oportunidad?.id != n.idOportunidad ||
        _canal?.id != n.idCanal ||
        _interes?.id != n.idInteres ||
        _cantidadCtrl.text != NumberFormatUtils.fmtInt(n.cantidad) ||
        _precioBaseCtrl.text != NumberFormatUtils.fmtDecimal(n.precioBase) ||
        _descuentoCtrl.text != NumberFormatUtils.fmtDecimal(n.descuento) ||
        (_monedaItem?.id ?? '') != n.idMoneda;
  }

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

      _precioBaseCtrl.text = item != null
          ? NumberFormatUtils.fmtDecimal(item.importeGeneral)
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
    if (!_hayCambios) return;

    final confirmar = await context.showConfirmDialog(
      title: 'Confirmar cambio',
      message: '¿Deseas guardar los cambios?',
    );
    if (!confirmar) return;

    setState(() => _isLoading = true);

    final idEstadoEfectivo = _subEstado?.id ?? _estado?.id;
    final estadoEfectivo = _subEstado?.nombre ?? _estado?.nombre;
    final tieneSubEstado = _subEstado != null;

    if (context.mounted) {
      // ignore: use_build_context_synchronously
      await context.read<InfoLeadCubit>().updateLead(
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
        nombreLead: _nombreLeadCtrl.text.trim(),
        modalidad: _modalidadCtrl.text.trim(),
        cantidad: int.tryParse(_cantidadCtrl.text),
        precioBase: double.tryParse(_precioBaseCtrl.text),
        descuento: double.tryParse(_descuentoCtrl.text),
        precio: _costoFinal > 0 ? _costoFinal : null,
        idMoneda: _monedaItem?.id,
      );
    }

    if (mounted) setState(() => _isLoading = false);
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
              _nombreLeadCtrl,
              _modalidadCtrl,
              _cantidadCtrl,
              _precioBaseCtrl,
              _descuentoCtrl,
            ]),
            builder: (context, _) => FormSaveBar(
              onCancelar: () => context.goBack(),
              onGuardar: _guardar,
              isLoading: _isLoading,
              isEnabled: _hayCambios,
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
              EditLeadAdicionalSection(
                nombreLeadCtrl: _nombreLeadCtrl,
                modalidadCtrl: _modalidadCtrl,
                isLoading: _bloqueado,
              ),
              const SizedBox(height: AppSpacing.lg),

              // 2. Negociación
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
                onCampaniaChanged: _onCampaniaChanged,
                onOportunidadChanged: _onOportunidadChanged,
                onCanalChanged: (item) => setState(() => _canal = item),
                onInteresChanged: (item) => setState(() => _interes = item),
                onEstadoChanged: _onEstadoChanged,
                onSubEstadoChanged: (item) => setState(() => _subEstado = item),
              ),
              const SizedBox(height: AppSpacing.lg),

              // 3. Financiera
              ListenableBuilder(
                listenable: Listenable.merge([
                  _cantidadCtrl,
                  _precioBaseCtrl,
                  _descuentoCtrl,
                ]),
                builder: (context, _) => EditLeadFinancieraSection(
                  cantidadCtrl: _cantidadCtrl,
                  precioBaseCtrl: _precioBaseCtrl,
                  descuentoCtrl: _descuentoCtrl,
                  monedas: catalogState.monedas,
                  monedaItem: _monedaItem,
                  isLoading: _bloqueado,
                  onMonedaChanged: (item) => setState(() => _monedaItem = item),
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
