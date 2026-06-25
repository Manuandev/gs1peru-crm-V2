// lib/features/lead/presentation/widgets/edit_lead/edit_lead_portrait.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  // Combos catálogo
  EstadoItem?           _estado;
  EstadoItem?           _subEstado;
  List<EstadoItem>      _subEstadosFiltrados = [];
  CampaniaItem?         _campania;
  OportunidadItem?      _evento;
  CanalItem?            _canal;
  InteresItem?          _interes;
  List<OportunidadItem> _eventosFiltrados = [];
  int                   _eventoKey = 0;

  // Controladores de texto
  late final TextEditingController _nombreCtrl;
  late final TextEditingController _apellidoPCtrl;
  late final TextEditingController _apellidoMCtrl;
  late final TextEditingController _correoCtrl;
  late final TextEditingController _cantidadCtrl;
  late final TextEditingController _precioBaseCtrl;
  late final TextEditingController _descuentoCtrl;

  bool _mostrarAgregarNumero = false;
  bool _isLoading            = false;
  bool _combosInicializados  = false;

  final _fmt = NumberFormat('#,##0.00', 'es_PE');

  @override
  void initState() {
    super.initState();
    _nombreCtrl     = TextEditingController(text: widget.lead.nombre);
    _apellidoPCtrl  = TextEditingController(text: widget.lead.apellidoPaterno);
    _apellidoMCtrl  = TextEditingController(text: widget.lead.apellidoMaterno);
    _correoCtrl     = TextEditingController(text: widget.lead.correo);
    _cantidadCtrl   = TextEditingController(text: _fmtDouble(widget.lead.cantidad));
    _precioBaseCtrl = TextEditingController(text: _fmtDouble(widget.lead.precioBase));
    _descuentoCtrl  = TextEditingController(text: _fmtDouble(widget.lead.descuento));

    _cantidadCtrl.addListener(_recalcular);
    _precioBaseCtrl.addListener(_recalcular);
    _descuentoCtrl.addListener(_recalcular);
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
    _campania = state.campanias
        .where((e) => e.id == widget.lead.idCampania)
        .firstOrNull;
    _evento = state.oportunidades
        .where((e) => e.idEvento == widget.lead.idEvento)
        .firstOrNull;
    _canal = state.canales
        .where((e) => e.id == widget.lead.idCanal)
        .firstOrNull;
    _interes = state.intereses
        .where((e) => e.id == widget.lead.idInteres)
        .firstOrNull;
    _eventosFiltrados = _filtrarEventos(state.oportunidades, widget.lead.idCampania);

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
    _correoCtrl.dispose();
    _cantidadCtrl.dispose();
    _precioBaseCtrl.dispose();
    _descuentoCtrl.dispose();
    super.dispose();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _fmtDouble(double? v) =>
      (v == null || v == 0) ? '' : v.toStringAsFixed(2);

  List<OportunidadItem> _filtrarEventos(
    List<OportunidadItem> oportunidades,
    int? idCampania,
  ) {
    if (idCampania == null) return oportunidades;
    return oportunidades.where((e) => e.idCampania == idCampania).toList();
  }

  double get _cantidad   => double.tryParse(_cantidadCtrl.text)   ?? 0;
  double get _precioBase => double.tryParse(_precioBaseCtrl.text) ?? 0;
  double get _descuento  => double.tryParse(_descuentoCtrl.text)  ?? 0;
  double get _subtotal   => _precioBase * _cantidad;
  double get _costoFinal => _subtotal * (1 - _descuento / 100);

  void _recalcular() => setState(() {});

  // ── Cambios detectados ────────────────────────────────────────────────────

  bool get _hayCambios {
    final l = widget.lead;
    return _campania?.id             != l.idCampania          ||
        _evento?.idEvento            != l.idEvento            ||
        _canal?.id                   != l.idCanal             ||
        _interes?.id                 != l.idInteres           ||
        (_estado != null && _subEstado?.id != l.idEstado)     ||
        (_estado != null && _estado?.id    != l.idEstado && _subEstado == null) ||
        _nombreCtrl.text.trim()      != l.nombre              ||
        _apellidoPCtrl.text.trim()   != l.apellidoPaterno     ||
        _apellidoMCtrl.text.trim()   != l.apellidoMaterno     ||
        _correoCtrl.text.trim()      != l.correo              ||
        _cantidadCtrl.text           != _fmtDouble(l.cantidad)   ||
        _precioBaseCtrl.text         != _fmtDouble(l.precioBase) ||
        _descuentoCtrl.text          != _fmtDouble(l.descuento);
  }

  // ── Acciones ──────────────────────────────────────────────────────────────

  void _onCampaniaChanged(CampaniaItem? item) {
    final catalogState = context.read<CatalogsBloc>().state;
    if (catalogState is! CatalogsLoaded) return;
    setState(() {
      _campania = item;
      _eventoKey++;
      _evento = null;
      _eventosFiltrados = _filtrarEventos(catalogState.oportunidades, item?.id);
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

  Future<void> _guardar() async {
    if (!_hayCambios) return;

    final confirmar = await context.showConfirmDialog(
      title:   'Confirmar cambio',
      message: '¿Deseas guardar los cambios?',
    );
    if (!confirmar) return;

    setState(() => _isLoading = true);

    final idEstadoEfectivo = _subEstado?.id     ?? _estado?.id;
    final estadoEfectivo   = _subEstado?.nombre ?? _estado?.nombre;
    final tieneSubEstado   = _subEstado != null;

    if (context.mounted) {
      // ignore: use_build_context_synchronously
      await context.read<InfoLeadCubit>().updateLead(
        idEstado:               idEstadoEfectivo,
        estado:                 estadoEfectivo,
        idEstadoPadre:          tieneSubEstado ? _estado?.id     : null,
        descripcionEstadoPadre: tieneSubEstado ? _estado?.nombre : null,
        clearEstadoPadre:       !tieneSubEstado,
        idCampania:             _campania?.id,
        campania:               _campania?.nombre,
        idEvento:               _evento?.idEvento,
        evento:                 _evento?.nombre,
        clearEvento:            _evento == null,
        idCanal:                _canal?.id,
        canal:                  _canal?.nombre,
        idInteres:              _interes?.id,
        interes:                _interes?.nombre,
        nombre:                 _nombreCtrl.text.trim(),
        apellidoPaterno:        _apellidoPCtrl.text.trim(),
        apellidoMaterno:        _apellidoMCtrl.text.trim(),
        correo:                 _correoCtrl.text.trim(),
        cantidad:               double.tryParse(_cantidadCtrl.text),
        precioBase:             double.tryParse(_precioBaseCtrl.text),
        descuento:              double.tryParse(_descuentoCtrl.text),
        precio:                 _costoFinal > 0 ? _costoFinal : null,
      );
    }

    if (mounted) setState(() => _isLoading = false);

    if (mounted) {
      // ignore: use_build_context_synchronously
      final cubitState  = context.read<InfoLeadCubit>().state;
      final updatedLead = cubitState is InfoLeadSuccess ? cubitState.lead : null;
      LeadUpdateNotifier.instance.notify(
        widget.lead.idLead,
        updatedLead: updatedLead,
      );
      // ignore: use_build_context_synchronously
      context.goBack();
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final catalogState = context.watch<CatalogsBloc>().state;
    if (catalogState is! CatalogsLoaded) return const AppLoadingView();

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              LeadEditHeaderCard(lead: widget.lead),
              const SizedBox(height: AppSpacing.lg),
              _buildSeccionProspecto(catalogState),
              const SizedBox(height: AppSpacing.lg),
              _buildSeccionFinanciera(),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
        FormSaveBar(
          onCancelar:   () => context.goBack(),
          onGuardar:    _guardar,
          isLoading:    _isLoading,
          isEnabled:    _hayCambios,
          iconoGuardar: const Icon(AppIcons.save),
          textoGuardar: 'Guardar',
        ),
      ],
    );
  }

  // ── Sección Información del prospecto ─────────────────────────────────────

  Widget _buildSeccionProspecto(CatalogsLoaded state) {
    final hayEstados = state.estados.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FormSectionTitle('Información del prospecto'),
        const SizedBox(height: AppSpacing.md),

        // Estado | Subestado
        FormFieldRow(
          izquierdo: _buildComboEstado(state, hayEstados),
          derecho:   _buildComboSubEstado(state, hayEstados),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Campaña | Evento
        FormFieldRow(
          izquierdo: CustomComboField<CampaniaItem>(
            enabled:      !_isLoading,
            data:         state.campanias,
            label:        'Campaña',
            initialValue: _campania?.id.toString(),
            onChanged:    _onCampaniaChanged,
            dense:        true,
          ),
          derecho: CustomComboField<OportunidadItem>(
            key:          ValueKey(_eventoKey),
            data:         _eventosFiltrados,
            idIndex:      0,
            labelIndex:   2,
            label:        'Evento',
            initialValue: _evento?.idEvento.toString(),
            onChanged:    (item) => setState(() => _evento = item),
            enabled:      _eventosFiltrados.isNotEmpty && !_isLoading,
            dense:        true,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Canal | Interés
        FormFieldRow(
          izquierdo: CustomComboField<CanalItem>(
            enabled:      !_isLoading,
            data:         state.canales,
            label:        'Canal',
            initialValue: _canal?.id.toString(),
            onChanged:    (item) => setState(() => _canal = item),
            dense:        true,
          ),
          derecho: CustomComboField<InteresItem>(
            enabled:      !_isLoading,
            data:         state.intereses,
            label:        'Interés',
            initialValue: _interes?.id.toString(),
            onChanged:    (item) => setState(() => _interes = item),
            dense:        true,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Nombres (ancho completo)
        CustomTextField(
          label:              'Nombres',
          controller:         _nombreCtrl,
          enabled:            !_isLoading,
          prefixIcon:         const Icon(AppIcons.user),
          textCapitalization: TextCapitalization.words,
          dense:              true,
        ),
        const SizedBox(height: AppSpacing.sm),

        // Apellido Paterno | Apellido Materno
        FormFieldRow(
          izquierdo: CustomTextField(
            label:              'Apellido Paterno',
            controller:         _apellidoPCtrl,
            enabled:            !_isLoading,
            textCapitalization: TextCapitalization.words,
            dense:              true,
          ),
          derecho: CustomTextField(
            label:              'Apellido Materno',
            controller:         _apellidoMCtrl,
            enabled:            !_isLoading,
            textCapitalization: TextCapitalization.words,
            dense:              true,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Empresa (read-only) | Cargo (futuro)
        FormFieldRow(
          izquierdo: CustomTextField(
            label:      'Empresa',
            controller: TextEditingController(text: widget.lead.nombreEmpresa),
            enabled:    false,
            prefixIcon: const Icon(AppIcons.users),
            dense:      true,
          ),
          derecho: CustomTextField(
            label:      'Cargo',
            controller: TextEditingController(),
            enabled:    false,
            hint:       'Próximamente',
            dense:      true,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Teléfono: [campo read-only] [+ externo]
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: _buildCampoTelefono()),
            const SizedBox(width: AppSpacing.xs),
            _buildToggleTelefonoBtn(),
          ],
        ),

        // Fila nueva: [combo prefijo] [input número] — sin contenedor
        if (_mostrarAgregarNumero) ...[
          const SizedBox(height: AppSpacing.xs),
          AgregarNumeroPanel(
            onCancelar: () => setState(() => _mostrarAgregarNumero = false),
            onAgregar:  (_, _) => setState(() => _mostrarAgregarNumero = false),
          ),
        ],

        const SizedBox(height: AppSpacing.sm),

        // Correo (ancho completo)
        CustomTextField(
          label:        'Correo',
          controller:   _correoCtrl,
          enabled:      !_isLoading,
          prefixIcon:   const Icon(AppIcons.email),
          keyboardType: TextInputType.emailAddress,
          dense:        true,
          suffixIcon:   _correoCtrl.text.isNotEmpty
              ? IconButton(
                  icon:     const Icon(AppIcons.close),
                  iconSize: AppSizing.iconActionSm,
                  onPressed: () => setState(() => _correoCtrl.clear()),
                )
              : null,
        ),
      ],
    );
  }

  Widget _buildComboEstado(CatalogsLoaded state, bool hayEstados) {
    if (!hayEstados) {
      return CustomTextField(
        label:      'Estado',
        controller: TextEditingController(text: widget.lead.estado),
        enabled:    false,
        prefixIcon: AppIconsSocial.widgetEstado(widget.lead.idEstado),
        dense:      true,
      );
    }
    return CustomComboField<EstadoItem>(
      enabled:      !_isLoading,
      data:         state.estados.where((e) => e.esPadre).toList(),
      label:        'Estado',
      initialValue: _estado?.id,
      onChanged:    _onEstadoChanged,
      dense:        true,
    );
  }

  Widget _buildComboSubEstado(CatalogsLoaded state, bool hayEstados) {
    if (!hayEstados) {
      return CustomTextField(
        label:      'Subestado',
        controller: TextEditingController(
          text: widget.lead.descripcionEstadoPadre ?? widget.lead.estado,
        ),
        enabled: false,
        dense:   true,
      );
    }
    return CustomComboField<EstadoItem>(
      enabled:      _subEstadosFiltrados.isNotEmpty && !_isLoading,
      data:         _subEstadosFiltrados,
      label:        'Subestado',
      initialValue: _subEstado?.id,
      onChanged:    (item) => setState(() => _subEstado = item),
      dense:        true,
    );
  }

  Widget _buildCampoTelefono() {
    return CustomTextField(
      label:      'Teléfono',
      controller: TextEditingController(
        text: '${widget.lead.prefijo} ${widget.lead.numero}',
      ),
      enabled: false,
      dense:   true,
    );
  }

  Widget _buildToggleTelefonoBtn() {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: _isLoading
          ? null
          : () => setState(() => _mostrarAgregarNumero = !_mostrarAgregarNumero),
      borderRadius: BorderRadius.circular(AppSizing.radiusCircular),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xs),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: _mostrarAgregarNumero
                ? colorScheme.error
                : colorScheme.primary,
            width: AppSizing.hairline,
          ),
        ),
        child: Icon(
          _mostrarAgregarNumero ? AppIcons.close : AppIcons.add,
          size: AppSizing.iconActionSm,
          color: _mostrarAgregarNumero
              ? colorScheme.error
              : colorScheme.primary,
        ),
      ),
    );
  }

  // ── Sección Financiera ────────────────────────────────────────────────────

  Widget _buildSeccionFinanciera() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FormSectionTitle('Información financiera'),
        const SizedBox(height: AppSpacing.md),

        // Cantidad | Precio base
        FormFieldRow(
          izquierdo: CustomTextField(
            label:        'Cantidad',
            controller:   _cantidadCtrl,
            enabled:      !_isLoading,
            dense:        true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
          ),
          derecho: CustomTextField(
            label:        'Precio base',
            controller:   _precioBaseCtrl,
            enabled:      !_isLoading,
            prefixText:   'S/ ',
            dense:        true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Descuento | Costo final
        FormFieldRow(
          izquierdo: CustomTextField(
            label:        'Descuento',
            controller:   _descuentoCtrl,
            enabled:      !_isLoading,
            suffixText:   '%',
            dense:        true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
          ),
          derecho: CustomTextField(
            label:      'Costo final',
            controller: TextEditingController(
              text: _costoFinal > 0 ? 'S/ ${_fmt.format(_costoFinal)}' : '',
            ),
            enabled:    false,
            prefixText: _costoFinal > 0 ? null : 'S/ ',
            dense:      true,
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        if (_subtotal > 0)
          NegociacionResumenCard(
            subtotal:   _subtotal,
            descuento:  _descuento,
            costoFinal: _costoFinal,
          ),
      ],
    );
  }
}
