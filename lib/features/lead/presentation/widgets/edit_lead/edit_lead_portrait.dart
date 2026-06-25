// lib/features/lead/presentation/widgets/edit_lead/edit_lead_portrait.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/features/lead/index_lead.dart';

// ── Prefijos de país para agregar número ──────────────────────────────────────

class _PrefijoPais with Comboable {
  final String codigo;
  final String pais;
  const _PrefijoPais({required this.codigo, required this.pais});

  @override
  List<dynamic> get fields => [codigo, '$codigo  $pais'];
}

const _prefijosDisponibles = [
  _PrefijoPais(codigo: '+51',  pais: 'Perú'),
  _PrefijoPais(codigo: '+1',   pais: 'USA'),
  _PrefijoPais(codigo: '+57',  pais: 'Colombia'),
  _PrefijoPais(codigo: '+54',  pais: 'Argentina'),
  _PrefijoPais(codigo: '+56',  pais: 'Chile'),
  _PrefijoPais(codigo: '+52',  pais: 'México'),
  _PrefijoPais(codigo: '+593', pais: 'Ecuador'),
  _PrefijoPais(codigo: '+55',  pais: 'Brasil'),
  _PrefijoPais(codigo: '+34',  pais: 'España'),
];

// ── Widget principal ──────────────────────────────────────────────────────────

class EditLeadPortrait extends StatefulWidget {
  final Lead lead;
  const EditLeadPortrait({super.key, required this.lead});

  @override
  State<EditLeadPortrait> createState() => _EditLeadPortraitState();
}

class _EditLeadPortraitState extends State<EditLeadPortrait> {
  // Combos catálogo
  EstadoItem?     _estado;
  EstadoItem?     _subEstado;
  List<EstadoItem> _subEstadosFiltrados = [];
  CampaniaItem?   _campania;
  OportunidadItem? _evento;
  CanalItem?      _canal;
  InteresItem?    _interes;
  List<OportunidadItem> _eventosFiltrados = [];
  int _eventoKey = 0;

  // Controladores de texto
  late final TextEditingController _nombreCtrl;
  late final TextEditingController _apellidoPCtrl;
  late final TextEditingController _apellidoMCtrl;
  late final TextEditingController _correoCtrl;
  late final TextEditingController _cantidadCtrl;
  late final TextEditingController _precioBaseCtrl;
  late final TextEditingController _descuentoCtrl;

  // Agregar número
  bool _mostrarAgregarNumero = false;
  _PrefijoPais? _nuevoPrefijo = _prefijosDisponibles.first;
  final _nuevoNumeroCtrl = TextEditingController();

  bool _isLoading = false;

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

    final catalogState = context.read<CatalogsBloc>().state;
    if (catalogState is! CatalogsLoaded) return;
    _inicializarCombos(catalogState);
  }

  void _inicializarCombos(CatalogsLoaded state) {
    // ── Campaña / Evento ─────────────────────────────────────────────────────
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

    // ── Estado / Subestado ───────────────────────────────────────────────────
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
    setState(() => _inicializarCombos(catalogState));
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
    _nuevoNumeroCtrl.dispose();
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
    return _campania?.id            != l.idCampania          ||
        _evento?.idEvento           != l.idEvento            ||
        _canal?.id                  != l.idCanal             ||
        _interes?.id                != l.idInteres           ||
        (_estado != null && _subEstado?.id != l.idEstado)    ||
        (_estado != null && _estado?.id    != l.idEstado && _subEstado == null) ||
        _nombreCtrl.text.trim()     != l.nombre              ||
        _apellidoPCtrl.text.trim()  != l.apellidoPaterno     ||
        _apellidoMCtrl.text.trim()  != l.apellidoMaterno     ||
        _correoCtrl.text.trim()     != l.correo              ||
        _cantidadCtrl.text          != _fmtDouble(l.cantidad)   ||
        _precioBaseCtrl.text        != _fmtDouble(l.precioBase) ||
        _descuentoCtrl.text         != _fmtDouble(l.descuento);
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
      title: 'Confirmar cambio',
      message: '¿Deseas guardar los cambios?',
    );
    if (!confirmar) return;

    setState(() => _isLoading = true);

    // Estado efectivo: si hay subestado seleccionado, ese es el idEstado real.
    final idEstadoEfectivo = _subEstado?.id ?? _estado?.id;
    final estadoEfectivo   = _subEstado?.nombre ?? _estado?.nombre;
    final tieneSubEstado   = _subEstado != null;

    if (context.mounted) {
      // ignore: use_build_context_synchronously
      await context.read<InfoLeadCubit>().updateLead(
        idEstado:               idEstadoEfectivo,
        estado:                 estadoEfectivo,
        idEstadoPadre:          tieneSubEstado ? _estado?.id : null,
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
      final cubitState = context.read<InfoLeadCubit>().state;
      final updatedLead =
          cubitState is InfoLeadSuccess ? cubitState.lead : null;
      LeadUpdateNotifier.instance.notify(
        widget.lead.idLead,
        updatedLead: updatedLead,
      );
      // ignore: use_build_context_synchronously
      context.goBack();
    }
  }

  Future<void> _agregarNumero() async {
    final numero = _nuevoNumeroCtrl.text.trim();
    if (numero.isEmpty || _nuevoPrefijo == null) return;
    // TODO: conectar SP de agregar número cuando esté disponible.
    setState(() {
      _mostrarAgregarNumero = false;
      _nuevoNumeroCtrl.clear();
    });
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
              _buildHeader(context),
              const SizedBox(height: AppSpacing.lg),
              _buildSeccionProspecto(context, catalogState),
              const SizedBox(height: AppSpacing.lg),
              _buildSeccionFinanciera(context),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
        _buildBotones(context),
      ],
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    final lead         = widget.lead;
    final colorScheme  = Theme.of(context).colorScheme;
    final avatarColor  = lead.nombreCompleto.avatarColor;
    final iniciales    = lead.nombreCompleto.initials;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color:        colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSizing.radiusLg),
        boxShadow: [
          BoxShadow(
            color:       AppColors.cardShadow,
            blurRadius:  8,
            offset:      const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius:          AppSizing.avatarRadiusMd,
            backgroundColor: avatarColor,
            child: Text(
              iniciales,
              style: AppTextStyles.titleSmall.copyWith(
                color:      AppColors.textOnDark,
                fontWeight: AppTextStyles.weightBold,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lead.nombreCompleto,
                  style: AppTextStyles.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    AppIconsSocial.widgetCanal(lead.idCanal, size: AppSizing.iconSm),
                    const SizedBox(width: AppSpacing.xs),
                    Flexible(
                      child: Text(
                        lead.canal,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    AppIconsSocial.chipEstado(
                      lead.idEstadoPadre?.isNotEmpty == true
                          ? lead.idEstadoPadre!
                          : lead.idEstado,
                      label: lead.idEstadoPadre?.isNotEmpty == true
                          ? lead.descripcionEstadoPadre ?? lead.estado
                          : lead.estado,
                    ),
                  ],
                ),
                if (lead.nombreEmpresa.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    lead.nombreEmpresa,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Sección Información del prospecto ─────────────────────────────────────

  Widget _buildSeccionProspecto(
    BuildContext context,
    CatalogsLoaded state,
  ) {
    final hayEstados = state.estados.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _tituloSeccion('Información del prospecto'),
        const SizedBox(height: AppSpacing.md),

        // Estado | Subestado
        _buildFila(
          _buildComboEstado(state, hayEstados),
          _buildComboSubEstado(state, hayEstados),
        ),
        const SizedBox(height: AppSpacing.md),

        // Campaña | Evento
        _buildFila(
          CustomComboField<CampaniaItem>(
            enabled:       !_isLoading,
            data:          state.campanias,
            label:         'Campaña',
            initialValue:  _campania?.id.toString(),
            onChanged:     _onCampaniaChanged,
          ),
          CustomComboField<OportunidadItem>(
            key:           ValueKey(_eventoKey),
            data:          _eventosFiltrados,
            idIndex:       0,
            labelIndex:    2,
            label:         'Evento',
            initialValue:  _evento?.idEvento.toString(),
            onChanged:     (item) => setState(() => _evento = item),
            enabled:       _eventosFiltrados.isNotEmpty && !_isLoading,
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Canal | Interés
        _buildFila(
          CustomComboField<CanalItem>(
            enabled:      !_isLoading,
            data:         state.canales,
            label:        'Canal',
            initialValue: _canal?.id.toString(),
            onChanged:    (item) => setState(() => _canal = item),
          ),
          CustomComboField<InteresItem>(
            enabled:      !_isLoading,
            data:         state.intereses,
            label:        'Interés',
            initialValue: _interes?.id.toString(),
            onChanged:    (item) => setState(() => _interes = item),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Nombres (ancho completo)
        CustomTextField(
          label:      'Nombres',
          controller: _nombreCtrl,
          enabled:    !_isLoading,
          prefixIcon: const Icon(AppIcons.user),
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: AppSpacing.md),

        // Apellido Paterno | Apellido Materno
        _buildFila(
          CustomTextField(
            label:      'Apellido Paterno',
            controller: _apellidoPCtrl,
            enabled:    !_isLoading,
            textCapitalization: TextCapitalization.words,
          ),
          CustomTextField(
            label:      'Apellido Materno',
            controller: _apellidoMCtrl,
            enabled:    !_isLoading,
            textCapitalization: TextCapitalization.words,
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Empresa (read-only hasta que el SP lo soporte) | Cargo (futuro)
        _buildFila(
          CustomTextField(
            label:      'Empresa',
            controller: TextEditingController(text: widget.lead.nombreEmpresa),
            enabled:    false,
            prefixIcon: const Icon(AppIcons.users),
          ),
          CustomTextField(
            label:      'Cargo',
            controller: TextEditingController(),
            enabled:    false,
            hint:       'Próximamente',
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Teléfono (read-only + botón agregar) | Correo
        _buildFila(
          _buildCampoTelefono(context),
          CustomTextField(
            label:         'Correo',
            controller:    _correoCtrl,
            enabled:       !_isLoading,
            prefixIcon:    const Icon(AppIcons.email),
            keyboardType:  TextInputType.emailAddress,
            suffixIcon:    _correoCtrl.text.isNotEmpty
                ? IconButton(
                    icon:     const Icon(AppIcons.close),
                    iconSize: AppSizing.iconActionSm,
                    onPressed: () => setState(() => _correoCtrl.clear()),
                  )
                : null,
          ),
        ),

        // Mini formulario agregar número
        if (_mostrarAgregarNumero) ...[
          const SizedBox(height: AppSpacing.sm),
          _buildAgregarNumero(context),
        ],
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
      );
    }
    return CustomComboField<EstadoItem>(
      enabled:      !_isLoading,
      data:         state.estados.where((e) => e.esPadre).toList(),
      label:        'Estado',
      initialValue: _estado?.id,
      onChanged:    _onEstadoChanged,
    );
  }

  Widget _buildComboSubEstado(CatalogsLoaded state, bool hayEstados) {
    if (!hayEstados) {
      final subLabel = widget.lead.descripcionEstadoPadre ?? widget.lead.estado;
      return CustomTextField(
        label:      'Subestado',
        controller: TextEditingController(text: subLabel),
        enabled:    false,
      );
    }
    return CustomComboField<EstadoItem>(
      enabled:      _subEstadosFiltrados.isNotEmpty && !_isLoading,
      data:         _subEstadosFiltrados,
      label:        'Subestado',
      initialValue: _subEstado?.id,
      onChanged:    (item) => setState(() => _subEstado = item),
    );
  }

  Widget _buildCampoTelefono(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          label:      'Teléfono',
          controller: TextEditingController(
            text: '${widget.lead.prefijo} ${widget.lead.numero}',
          ),
          enabled:    false,
          prefixIcon: const Icon(AppIcons.phone),
          suffixIcon: IconButton(
            icon:     const Icon(AppIcons.add),
            iconSize: AppSizing.iconActionSm,
            tooltip:  'Agregar número',
            onPressed: _isLoading
                ? null
                : () => setState(
                      () => _mostrarAgregarNumero = !_mostrarAgregarNumero,
                    ),
          ),
        ),
      ],
    );
  }

  Widget _buildAgregarNumero(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color:        AppColors.surfaceLightVariant,
        borderRadius: BorderRadius.circular(AppSizing.radiusMd),
        border:       Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nuevo número',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Combo prefijo (compacto)
              SizedBox(
                width: 130,
                child: CustomComboField<_PrefijoPais>(
                  data:         _prefijosDisponibles,
                  label:        'Prefijo',
                  initialValue: _nuevoPrefijo?.codigo,
                  onChanged:    (item) => setState(() => _nuevoPrefijo = item),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: CustomTextField(
                  label:        'Número',
                  controller:   _nuevoNumeroCtrl,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              const Spacer(),
              CustomOutlinedButton(
                text:      'Cancelar',
                height:    AppSizing.buttonHeightSmall,
                onPressed: () => setState(() {
                  _mostrarAgregarNumero = false;
                  _nuevoNumeroCtrl.clear();
                }),
              ),
              const SizedBox(width: AppSpacing.sm),
              CustomPrimaryButton(
                text:      'Agregar',
                height:    AppSizing.buttonHeightSmall,
                onPressed: _agregarNumero,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Sección Financiera ────────────────────────────────────────────────────

  Widget _buildSeccionFinanciera(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _tituloSeccion('Información financiera'),
        const SizedBox(height: AppSpacing.md),

        // Cantidad | Precio base
        _buildFila(
          CustomTextField(
            label:        'Cantidad',
            controller:   _cantidadCtrl,
            enabled:      !_isLoading,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
          ),
          CustomTextField(
            label:        'Precio base',
            controller:   _precioBaseCtrl,
            enabled:      !_isLoading,
            prefixText:   'S/ ',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Descuento | Costo final
        _buildFila(
          CustomTextField(
            label:        'Descuento',
            controller:   _descuentoCtrl,
            enabled:      !_isLoading,
            suffixText:   '%',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
          ),
          CustomTextField(
            label:      'Costo final',
            controller: TextEditingController(
              text: _costoFinal > 0 ? 'S/ ${_fmt.format(_costoFinal)}' : '',
            ),
            enabled:    false,
            prefixText: _costoFinal > 0 ? null : 'S/ ',
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Resumen
        if (_subtotal > 0) _buildResumen(context),
      ],
    );
  }

  Widget _buildResumen(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final montoDesc   = _subtotal * (_descuento / 100);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color:        AppColors.primaryWithOpacity(0.06),
        borderRadius: BorderRadius.circular(AppSizing.radiusMd),
        border:       Border.all(color: AppColors.primaryWithOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color:        colorScheme.primary,
              borderRadius: BorderRadius.circular(AppSizing.radiusSm),
            ),
            child: Icon(
              AppIcons.receipt,
              color: AppColors.textOnDark,
              size:  AppSizing.iconMd,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Resumen de la negociación',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Subtotal', style: AppTextStyles.bodySmall),
                    Text(
                      'S/ ${_fmt.format(_subtotal)}',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
                if (_descuento > 0)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Descuento (${_descuento.toStringAsFixed(0)}%)',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                      Text(
                        '- S/ ${_fmt.format(montoDesc)}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Total',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                'S/ ${_fmt.format(_costoFinal)}',
                style: AppTextStyles.titleMedium.copyWith(
                  color:      colorScheme.primary,
                  fontWeight: AppTextStyles.weightBold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Botones ───────────────────────────────────────────────────────────────

  Widget _buildBotones(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color:       AppColors.cardShadow,
            blurRadius:  8,
            offset:      const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: CustomOutlinedButton(
              text:      'Cancelar',
              isEnabled: !_isLoading,
              onPressed: () => context.goBack(),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: CustomPrimaryButton(
              text:      'Guardar cambios',
              onPressed: _guardar,
              isLoading: _isLoading,
              isEnabled: _hayCambios && !_isLoading,
              icon:      const Icon(AppIcons.save),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers de UI ─────────────────────────────────────────────────────────

  Widget _tituloSeccion(String titulo) {
    return Text(
      titulo.toUpperCase(),
      style: AppTextStyles.labelMedium.copyWith(
        color:          AppColors.textSecondary,
        letterSpacing:  0.8,
      ),
    );
  }

  Widget _buildFila(Widget izq, Widget der) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: izq),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: der),
      ],
    );
  }
}
