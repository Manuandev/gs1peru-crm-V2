//lib/features/chat/presentation/widgets/edit_lead/edit_lead_portrait.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/features/chat/index_chat.dart';

class EditLeadPortrait extends StatefulWidget {
  final InfoLead lead;
  const EditLeadPortrait({super.key, required this.lead});

  @override
  State<EditLeadPortrait> createState() => _EditLeadPortraitState();
}

class _EditLeadPortraitState extends State<EditLeadPortrait> {
  final _formKey = GlobalKey<FormState>();

  CampaniaItem? _campania;
  OportunidadItem? _evento;
  CanalItem? _canal;
  InteresItem? _interes;

  // Lista de eventos filtrada según campaña seleccionada
  List<OportunidadItem> _eventosFiltrados = [];

  int _eventoKey = 0;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final catalogState = context.read<CatalogsBloc>().state;
    if (catalogState is! CatalogsLoaded) return;

    final idCampania = widget.lead.idCampania;

    _campania = catalogState.campanias
        .where((e) => e.id == idCampania)
        .firstOrNull;

    _evento = catalogState.oportunidades
        .where((e) => e.idEvento == widget.lead.idEvento)
        .firstOrNull;

    _canal = catalogState.canales
        .where((e) => e.id == widget.lead.idCanal)
        .firstOrNull;

    _interes = catalogState.intereses
        .where((e) => e.id == widget.lead.idInteres)
        .firstOrNull;

    _eventosFiltrados = _buildEventos(catalogState.oportunidades, idCampania);
  }

  @override
  void didUpdateWidget(covariant EditLeadPortrait old) {
    super.didUpdateWidget(old);
    if (widget.lead == old.lead) return;

    final lead = widget.lead;
    final oldLead = old.lead;

    if (lead.idCampania == oldLead.idCampania &&
        lead.idEvento == oldLead.idEvento &&
        lead.idCanal == oldLead.idCanal &&
        lead.idInteres == oldLead.idInteres) {
      return;
    }

    final catalogState = context.read<CatalogsBloc>().state;
    if (catalogState is! CatalogsLoaded) return;

    setState(() {
      _campania = catalogState.campanias
          .where((e) => e.id == lead.idCampania)
          .firstOrNull;
      _evento = catalogState.oportunidades
          .where((e) => e.idEvento == lead.idEvento)
          .firstOrNull;
      _canal = catalogState.canales
          .where((e) => e.id == lead.idCanal)
          .firstOrNull;
      _interes = catalogState.intereses
          .where((e) => e.id == lead.idInteres)
          .firstOrNull;
      _eventosFiltrados = _buildEventos(
        catalogState.oportunidades,
        lead.idCampania,
      );
      _eventoKey++; // ← para que el combo evento se reconstruya
    });
  }

  List<OportunidadItem> _buildEventos(
    List<OportunidadItem> oportunidades,
    int? idCampania,
  ) {
    if (idCampania == null) return oportunidades;
    return oportunidades.where((e) => e.idCampania == idCampania).toList();
  }

  void _onCampaniaChanged(CampaniaItem? item) {
    final catalogState = context.read<CatalogsBloc>().state;
    if (catalogState is! CatalogsLoaded) return;

    setState(() {
      _campania = item;
      _eventoKey++;
      _evento = null; // ← siempre limpiar, sin restaurar nada
      _eventosFiltrados = _buildEventos(catalogState.oportunidades, item?.id);
    });
  }

  bool get _hayCambios {
    return _campania?.id != widget.lead.idCampania ||
        _evento?.idEvento != widget.lead.idEvento ||
        _canal?.id != widget.lead.idCanal ||
        _interes?.id != widget.lead.idInteres;
  }

  void _guardar() async {
    if (!_hayCambios) return;

    final confirmar = await context.showConfirmDialog(
      title: 'Confirmar cambio',
      message: '¿Deseas guardar los cambios?',
    );

    if (!confirmar) return;

    setState(() => _isLoading = true);

    if (context.mounted) {
      // ignore: use_build_context_synchronously
      await context.read<InfoLeadCubit>().updateLead(
        idCampania: _campania?.id,
        campania: _campania?.nombre,
        idEvento: _evento?.idEvento,
        evento: _evento?.nombre,
        clearEvento: _evento == null,
        idCanal: _canal?.id,
        canal: _canal?.nombre,
        idInteres: _interes?.id,
        interes: _interes?.nombre,
      );
    }

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final catalogState = context.watch<CatalogsBloc>().state;
    if (catalogState is! CatalogsLoaded) return const AppLoadingView();

    return Form(
      key: _formKey,
      child: Column(
        children: [
          CustomComboField<CampaniaItem>(
            enabled: !_isLoading,
            data: catalogState.campanias,
            label: 'Campaña',
            initialValue: _campania?.id.toString(),
            onChanged: _onCampaniaChanged,
          ),
          const SizedBox(height: AppSpacing.md),
          CustomComboField<OportunidadItem>(
            key: ValueKey(_eventoKey),
            data: _eventosFiltrados,
            idIndex: 0, // idEvento
            labelIndex: 2, // nombre
            label: 'Evento',
            initialValue: _evento?.idEvento.toString(),
            onChanged: (item) => setState(() => _evento = item),
            enabled: _eventosFiltrados.isNotEmpty && !_isLoading,
          ),
          const SizedBox(height: AppSpacing.md),
          CustomComboField<CanalItem>(
            enabled: !_isLoading,
            data: catalogState.canales,
            label: 'Canal',
            initialValue: _canal?.id.toString(),
            onChanged: (item) => setState(() => _canal = item),
          ),
          const SizedBox(height: AppSpacing.md),
          CustomComboField<InteresItem>(
            enabled: !_isLoading,
            data: catalogState.intereses,
            label: 'Interés',
            initialValue: _interes?.id.toString(),
            onChanged: (item) => setState(() => _interes = item),
          ),
          const SizedBox(height: AppSpacing.lg),
          CustomPrimaryButton(
            text: 'Guardar',
            onPressed: _guardar,
            isLoading: _isLoading,
            isEnabled: _hayCambios && !_isLoading,
          ),
        ],
      ),
    );
  }
}
