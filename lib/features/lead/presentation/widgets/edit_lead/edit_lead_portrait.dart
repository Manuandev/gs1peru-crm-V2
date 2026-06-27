// lib/features/lead/presentation/widgets/edit_lead/edit_lead_portrait.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class EditLeadPortrait extends StatefulWidget {
  final Lead lead;
  const EditLeadPortrait({super.key, required this.lead});

  @override
  State<EditLeadPortrait> createState() => _EditLeadPortraitState();
}

class _EditLeadPortraitState extends State<EditLeadPortrait> {
  // ── Combos de catálogo ────────────────────────────────────────────────────
  EstadoItem? _estado;
  EstadoItem? _subEstado;
  List<EstadoItem> _subEstadosFiltrados = [];
  CanalItem? _canal;
  InteresItem? _interes;
  MonedaItem _monedaItem = AppCurrencies.pen;

  // ── Campos editables ──────────────────────────────────────────────────────
  late final TextEditingController _nombreCtrl;
  late final TextEditingController _apellidoPCtrl;
  late final TextEditingController _apellidoMCtrl;
  late final TextEditingController _cantidadCtrl;
  late final TextEditingController _precioBaseCtrl;
  late final TextEditingController _descuentoCtrl;

  // ── Campos solo-lectura ───────────────────────────────────────────────────
  late final TextEditingController _campaniaCtrl;
  late final TextEditingController _eventoCtrl;
  late final TextEditingController _empresaCtrl;
  late final TextEditingController _correoCtrl;

  bool _mostrarAgregarNumero = false;
  bool _isLoading = false;
  bool _combosInicializados = false;

  // ── Ciclo de vida ─────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    final l = widget.lead;
    _nombreCtrl = TextEditingController(text: l.nombre);
    _apellidoPCtrl = TextEditingController(text: l.apellidoPaterno);
    _apellidoMCtrl = TextEditingController(text: l.apellidoMaterno);
    _cantidadCtrl = TextEditingController(
      text: EditLeadHelpers.fmtDouble(l.cantidad),
    );
    _precioBaseCtrl = TextEditingController(
      text: EditLeadHelpers.fmtDouble(l.precioBase),
    );
    _descuentoCtrl = TextEditingController(
      text: EditLeadHelpers.fmtDouble(l.descuento),
    );
    _campaniaCtrl = TextEditingController(text: l.campania);
    _eventoCtrl = TextEditingController(text: l.evento);
    _empresaCtrl = TextEditingController(text: l.nombreEmpresa);
    _correoCtrl = TextEditingController(text: l.correo);
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
    if (widget.lead == old.lead) return;
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
    _nombreCtrl.dispose();
    _apellidoPCtrl.dispose();
    _apellidoMCtrl.dispose();
    _cantidadCtrl.dispose();
    _precioBaseCtrl.dispose();
    _descuentoCtrl.dispose();
    _campaniaCtrl.dispose();
    _eventoCtrl.dispose();
    _empresaCtrl.dispose();
    _correoCtrl.dispose();
    super.dispose();
  }

  // ── Inicialización de combos ──────────────────────────────────────────────

  void _inicializarCombos(CatalogsLoaded state) {
    _canal = state.canales
        .where((e) => e.id == widget.lead.idCanal)
        .firstOrNull;
    _interes = state.intereses
        .where((e) => e.id == widget.lead.idInteres)
        .firstOrNull;

    if (state.estados.isNotEmpty) {
      final tienePadre = widget.lead.idEstadoPadre?.isNotEmpty ?? false;
      if (tienePadre) {
        _estado = state.estados
            .where((e) => e.id == widget.lead.idEstadoPadre && e.esPadre)
            .firstOrNull;
        if (_estado != null) {
          _subEstadosFiltrados = state.estados
              .where((e) => e.idPadre == _estado!.id)
              .toList();
          _subEstado = _subEstadosFiltrados
              .where((e) => e.id == widget.lead.idEstado)
              .firstOrNull;
        }
      } else {
        _estado = state.estados
            .where((e) => e.id == widget.lead.idEstado && e.esPadre)
            .firstOrNull;
      }
    }
  }

  // ── Getters financieros ───────────────────────────────────────────────────

  double get _cantidad => EditLeadHelpers.parseTexto(_cantidadCtrl.text);
  double get _precioBase => EditLeadHelpers.parseTexto(_precioBaseCtrl.text);
  double get _descuento => EditLeadHelpers.parseTexto(_descuentoCtrl.text);
  double get _subtotal => _precioBase * _cantidad;
  double get _costoFinal => EditLeadHelpers.calcCostoFinal(
    precioBase: _precioBase,
    cantidad: _cantidad,
    descuento: _descuento,
  );

  // ── Detección de cambios ──────────────────────────────────────────────────

  bool get _hayCambios {
    final l = widget.lead;
    return _canal?.id != l.idCanal ||
        _interes?.id != l.idInteres ||
        (_estado != null && _subEstado?.id != l.idEstado) ||
        (_estado != null && _estado?.id != l.idEstado && _subEstado == null) ||
        _nombreCtrl.text.trim() != l.nombre ||
        _apellidoPCtrl.text.trim() != l.apellidoPaterno ||
        _apellidoMCtrl.text.trim() != l.apellidoMaterno ||
        _cantidadCtrl.text != EditLeadHelpers.fmtDouble(l.cantidad) ||
        _precioBaseCtrl.text != EditLeadHelpers.fmtDouble(l.precioBase) ||
        _descuentoCtrl.text != EditLeadHelpers.fmtDouble(l.descuento);
  }

  // ── Callbacks de combos ───────────────────────────────────────────────────

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
        idEstado: idEstadoEfectivo,
        estado: estadoEfectivo,
        idEstadoPadre: tieneSubEstado ? _estado?.id : null,
        descripcionEstadoPadre: tieneSubEstado ? _estado?.nombre : null,
        clearEstadoPadre: !tieneSubEstado,
        idCanal: _canal?.id,
        canal: _canal?.nombre,
        idInteres: _interes?.id,
        interes: _interes?.nombre,
        nombre: _nombreCtrl.text.trim(),
        apellidoPaterno: _apellidoPCtrl.text.trim(),
        apellidoMaterno: _apellidoMCtrl.text.trim(),
        cantidad: double.tryParse(_cantidadCtrl.text),
        precioBase: double.tryParse(_precioBaseCtrl.text),
        descuento: double.tryParse(_descuentoCtrl.text),
        precio: _costoFinal > 0 ? _costoFinal : null,
      );
    }

    if (mounted) setState(() => _isLoading = false);
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final catalogState = context.read<CatalogsBloc>().state;
    if (catalogState is! CatalogsLoaded) return const AppLoadingView();

    final formSaveBar = ListenableBuilder(
      listenable: Listenable.merge([
        _nombreCtrl,
        _apellidoPCtrl,
        _apellidoMCtrl,
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
              // 1. Contacto
              EditLeadContactoSection(
                nombreCtrl: _nombreCtrl,
                apellidoPCtrl: _apellidoPCtrl,
                apellidoMCtrl: _apellidoMCtrl,
                empresaCtrl: _empresaCtrl,
                correoCtrl: _correoCtrl,
                telefonoPrefijo: widget.lead.prefijo,
                telefonoNumero: widget.lead.numero,
                isLoading: _isLoading,
                mostrarAgregarNumero: _mostrarAgregarNumero,
                onToggleTelefono: () => setState(
                  () => _mostrarAgregarNumero = !_mostrarAgregarNumero,
                ),
                onAgregarNumero: (_, __) =>
                    setState(() => _mostrarAgregarNumero = false),
              ),
              const SizedBox(height: AppSpacing.lg),

              // 2. Negociación
              EditLeadNegociacionSection(
                catalogState: catalogState,
                campaniaCtrl: _campaniaCtrl,
                eventoCtrl: _eventoCtrl,
                canal: _canal,
                interes: _interes,
                estado: _estado,
                subEstado: _subEstado,
                subEstadosFiltrados: _subEstadosFiltrados,
                idEstadoFallback: widget.lead.idEstado,
                estadoFallback: widget.lead.estado,
                descripcionEstadoPadreFallback:
                    widget.lead.descripcionEstadoPadre,
                idCanalFallback: widget.lead.idCanal,
                isLoading: _isLoading,
                onCanalChanged: (item) => setState(() => _canal = item),
                onInteresChanged: (item) => setState(() => _interes = item),
                onEstadoChanged: _onEstadoChanged,
                onSubEstadoChanged: (item) => setState(() => _subEstado = item),
              ),
              const SizedBox(height: AppSpacing.lg),

              // 3. Financiera — ListenableBuilder para que solo ella se reconstruya al tipear
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
                  monedaItem: _monedaItem,
                  isLoading: _isLoading,
                  onMonedaChanged: (item) =>
                      setState(() => _monedaItem = item ?? AppCurrencies.pen),
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
