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
  CanalItem?            _canal;
  InteresItem?          _interes;

  // Moneda (de AppCurrencies)
  MonedaItem _monedaItem = AppCurrencies.pen;

  // Controladores de texto — editables
  late final TextEditingController _nombreCtrl;
  late final TextEditingController _apellidoPCtrl;
  late final TextEditingController _apellidoMCtrl;
  late final TextEditingController _cantidadCtrl;
  late final TextEditingController _precioBaseCtrl;
  late final TextEditingController _descuentoCtrl;

  // Controladores solo-lectura (no se editan, sin listeners)
  late final TextEditingController _campaniaCtrl;
  late final TextEditingController _eventoCtrl;
  late final TextEditingController _empresaCtrl;
  late final TextEditingController _correoCtrl;

  bool _mostrarAgregarNumero = false;
  bool _isLoading            = false;
  bool _combosInicializados  = false;

  final _fmt = NumberFormat('#,##0.00', 'es_PE');

  @override
  void initState() {
    super.initState();
    final l = widget.lead;
    _nombreCtrl     = TextEditingController(text: l.nombre);
    _apellidoPCtrl  = TextEditingController(text: l.apellidoPaterno);
    _apellidoMCtrl  = TextEditingController(text: l.apellidoMaterno);
    _cantidadCtrl   = TextEditingController(text: _fmtDouble(l.cantidad));
    _precioBaseCtrl = TextEditingController(text: _fmtDouble(l.precioBase));
    _descuentoCtrl  = TextEditingController(text: _fmtDouble(l.descuento));
    _campaniaCtrl   = TextEditingController(text: l.campania);
    _eventoCtrl     = TextEditingController(text: l.evento);
    _empresaCtrl    = TextEditingController(text: l.nombreEmpresa);
    _correoCtrl     = TextEditingController(text: l.correo);
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

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _fmtDouble(double? v) =>
      (v == null || v == 0) ? '' : v.toStringAsFixed(2);

  double get _cantidad   => double.tryParse(_cantidadCtrl.text)   ?? 0;
  double get _precioBase => double.tryParse(_precioBaseCtrl.text) ?? 0;
  double get _descuento  => double.tryParse(_descuentoCtrl.text)  ?? 0;
  double get _subtotal   => _precioBase * _cantidad;
  double get _costoFinal => _subtotal - _descuento;

  String get _simbolo => _monedaItem.simbolo;

  // ── Cambios detectados ────────────────────────────────────────────────────

  bool get _hayCambios {
    final l = widget.lead;
    return _canal?.id                  != l.idCanal           ||
        _interes?.id                   != l.idInteres         ||
        (_estado != null && _subEstado?.id != l.idEstado)     ||
        (_estado != null && _estado?.id    != l.idEstado && _subEstado == null) ||
        _nombreCtrl.text.trim()        != l.nombre            ||
        _apellidoPCtrl.text.trim()     != l.apellidoPaterno   ||
        _apellidoMCtrl.text.trim()     != l.apellidoMaterno   ||
        _cantidadCtrl.text             != _fmtDouble(l.cantidad)   ||
        _precioBaseCtrl.text           != _fmtDouble(l.precioBase) ||
        _descuentoCtrl.text            != _fmtDouble(l.descuento);
  }

  // ── Acciones ──────────────────────────────────────────────────────────────

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
        idCanal:                _canal?.id,
        canal:                  _canal?.nombre,
        idInteres:              _interes?.id,
        interes:                _interes?.nombre,
        nombre:                 _nombreCtrl.text.trim(),
        apellidoPaterno:        _apellidoPCtrl.text.trim(),
        apellidoMaterno:        _apellidoMCtrl.text.trim(),
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
    if (catalogState is CatalogsError) {
      return AppErrorView(
        message: 'No se pudieron cargar los catálogos.',
        onRetry: () =>
            context.read<CatalogsBloc>().add(const CatalogsLoadRequested()),
      );
    }
    if (catalogState is! CatalogsLoaded) return const AppLoadingView();

    // ListenableBuilder para el botón Guardar — reacciona a cambios en campos de texto
    final formSaveBar = ListenableBuilder(
      listenable: Listenable.merge([
        _nombreCtrl, _apellidoPCtrl, _apellidoMCtrl,
        _cantidadCtrl, _precioBaseCtrl, _descuentoCtrl,
      ]),
      builder: (context, _) => FormSaveBar(
        onCancelar:   () => context.goBack(),
        onGuardar:    _guardar,
        isLoading:    _isLoading,
        isEnabled:    _hayCambios,
        iconoGuardar: const Icon(AppIcons.save),
        textoGuardar: 'Guardar cambios',
      ),
    );

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              _buildSeccionProspecto(catalogState),
              const SizedBox(height: AppSpacing.lg),
              // ListenableBuilder para la sección financiera — solo ella se reconstruye al tipear
              ListenableBuilder(
                listenable: Listenable.merge([_cantidadCtrl, _precioBaseCtrl, _descuentoCtrl]),
                builder: (context, _) => _buildSeccionFinanciera(),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
        formSaveBar,
      ],
    );
  }

  // ── Sección Información del prospecto ─────────────────────────────────────

  Widget _buildSeccionProspecto(CatalogsLoaded state) {
    final colorScheme = Theme.of(context).colorScheme;
    final hayEstados  = state.estados.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FormSectionTitle('Información del prospecto'),
        const SizedBox(height: AppSpacing.md),

        // Estado | Subestado
        FormFieldRow(
          izquierdo: _buildComboEstado(state, hayEstados, colorScheme),
          derecho:   _buildComboSubEstado(state, hayEstados, colorScheme),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Campaña (read-only) | Evento (read-only)
        FormFieldRow(
          izquierdo: CustomTextField(
            label:      'Campaña',
            controller: _campaniaCtrl,
            enabled:    false,
            dense:      true,
            prefixIcon: Icon(AppIcons.campaign, color: colorScheme.primary, size: AppSizing.iconActionSm),
          ),
          derecho: CustomTextField(
            label:      'Evento',
            controller: _eventoCtrl,
            enabled:    false,
            dense:      true,
            prefixIcon: Icon(AppIcons.calendar, color: colorScheme.secondary, size: AppSizing.iconActionSm),
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
            prefixIcon:   CanalHelper.icon(
              _canal?.id ?? widget.lead.idCanal,
              size: AppSizing.iconActionSm,
            ),
          ),
          derecho: CustomComboField<InteresItem>(
            enabled:      !_isLoading,
            data:         state.intereses,
            label:        'Interés',
            initialValue: _interes?.id.toString(),
            onChanged:    (item) => setState(() => _interes = item),
            dense:        true,
            prefixIcon:   Icon(AppIcons.interes, color: colorScheme.primary, size: AppSizing.iconActionSm),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Nombres
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

        // Empresa | Cargo (ambos read-only)
        FormFieldRow(
          izquierdo: CustomTextField(
            label:      'Empresa',
            controller: _empresaCtrl,
            enabled:    false,
            prefixIcon: const Icon(AppIcons.business),
            dense:      true,
          ),
          derecho: CustomTextField(
            label:      'Cargo',
            controller: TextEditingController(),
            enabled:    false,
            prefixIcon: const Icon(AppIcons.documento),
            hint:       'Próximamente',
            dense:      true,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Teléfono: campo + botón agregar
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: _buildCampoTelefono()),
            const SizedBox(width: AppSpacing.xs),
            _buildToggleTelefonoBtn(),
          ],
        ),

        if (_mostrarAgregarNumero) ...[
          const SizedBox(height: AppSpacing.xs),
          AgregarNumeroPanel(
            onCancelar: () => setState(() => _mostrarAgregarNumero = false),
            onAgregar:  (prefijo, numero) => setState(() => _mostrarAgregarNumero = false),
          ),
        ],

        const SizedBox(height: AppSpacing.sm),

        // Correo (read-only)
        CustomTextField(
          label:      'Correo',
          controller: _correoCtrl,
          enabled:    false,
          prefixIcon: const Icon(AppIcons.email),
          dense:      true,
        ),
      ],
    );
  }

  Widget _buildComboEstado(CatalogsLoaded state, bool hayEstados, ColorScheme colorScheme) {
    final colorEstado = AppIconsSocial.colorEstado(
      _estado?.id ?? widget.lead.idEstado,
    );

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
      prefixIcon:   Icon(AppIcons.flag, color: colorEstado, size: AppSizing.iconActionSm),
    );
  }

  Widget _buildComboSubEstado(CatalogsLoaded state, bool hayEstados, ColorScheme colorScheme) {
    if (!hayEstados) {
      return CustomTextField(
        label:   'Subestado',
        controller: TextEditingController(
          text: widget.lead.descripcionEstadoPadre ?? widget.lead.estado,
        ),
        enabled:   false,
        dense:     true,
        prefixIcon: Icon(AppIcons.listAlt, color: colorScheme.primary, size: AppSizing.iconActionSm),
      );
    }
    return CustomComboField<EstadoItem>(
      enabled:      _subEstadosFiltrados.isNotEmpty && !_isLoading,
      data:         _subEstadosFiltrados,
      label:        'Subestado',
      initialValue: _subEstado?.id,
      onChanged:    (item) => setState(() => _subEstado = item),
      dense:        true,
      prefixIcon:   Icon(AppIcons.listAlt, color: colorScheme.primary, size: AppSizing.iconActionSm),
    );
  }

  Widget _buildCampoTelefono() {
    return CustomTextField(
      label:      'Teléfono',
      controller: TextEditingController(
        text: '${widget.lead.prefijo} ${widget.lead.numero}',
      ),
      enabled:    false,
      prefixIcon: const Icon(AppIcons.phone),
      dense:      true,
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
          size:  AppSizing.iconActionSm,
          color: _mostrarAgregarNumero
              ? colorScheme.error
              : colorScheme.primary,
        ),
      ),
    );
  }

  // ── Sección Financiera ────────────────────────────────────────────────────

  Widget _buildSeccionFinanciera() {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FormSectionTitle('Información financiera'),
        const SizedBox(height: AppSpacing.md),

        // Moneda | Cantidad
        FormFieldRow(
          izquierdo: CustomComboField<MonedaItem>(
            data:         AppCurrencies.all,
            label:        'Moneda',
            initialValue: _monedaItem.codigo,
            onChanged:    (item) => setState(() => _monedaItem = item ?? AppCurrencies.pen),
            enabled:      !_isLoading,
            dense:        true,
            prefixIcon:   Icon(AppIcons.moneda, color: colorScheme.primary, size: AppSizing.iconActionSm),
          ),
          derecho: CustomTextField(
            label:        'Cantidad',
            controller:   _cantidadCtrl,
            enabled:      !_isLoading,
            dense:        true,
            prefixIcon:   Icon(AppIcons.receipt, color: colorScheme.primary, size: AppSizing.iconActionSm),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Precio base | Descuento
        FormFieldRow(
          izquierdo: CustomTextField(
            label:        'Precio base',
            controller:   _precioBaseCtrl,
            enabled:      !_isLoading,
            prefixText:   '$_simbolo ',
            dense:        true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
          ),
          derecho: CustomTextField(
            label:        'Descuento',
            controller:   _descuentoCtrl,
            enabled:      !_isLoading,
            prefixText:   '$_simbolo ',
            dense:        true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Costo final (ancho completo, calculado, read-only)
        CustomTextField(
          label:      'Costo final',
          controller: TextEditingController(
            text: '$_simbolo ${_fmt.format(_costoFinal)}',
          ),
          enabled: false,
          dense:   true,
        ),
        const SizedBox(height: AppSpacing.md),

        // Resumen siempre visible
        NegociacionResumenCard(
          subtotal:       _subtotal,
          montoDescuento: _descuento,
          costoFinal:     _costoFinal,
          simbolo:        _simbolo,
        ),
      ],
    );
  }
}
