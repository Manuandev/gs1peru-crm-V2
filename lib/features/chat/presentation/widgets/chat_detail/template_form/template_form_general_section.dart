// lib/features/chat/presentation/widgets/chat_detail/template_form/template_form_general_section.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/core/index_core.dart';

/// Datos generales del formulario de plantilla: nombre, Campaña→Oportunidad
/// en cascada, Estado (catálogo general de estados de negociación) y los dos
/// switches Activo/Compartir — separados a pedido del usuario, el mockup
/// original los mezclaba en un solo campo "Estado".
class TemplateFormGeneralSection extends StatelessWidget {
  final TextEditingController nombreCtrl;
  final CampaniaItem? campania;
  final OportunidadItem? oportunidad;
  final List<OportunidadItem> oportunidadesFiltradas;
  final EstadoItem? estado;
  final bool activo;
  final bool compartir;
  final ValueChanged<CampaniaItem?> onCampaniaChanged;
  final ValueChanged<OportunidadItem?> onOportunidadChanged;
  final ValueChanged<EstadoItem?> onEstadoChanged;
  final ValueChanged<bool> onActivoChanged;
  final ValueChanged<bool> onCompartirChanged;

  const TemplateFormGeneralSection({
    super.key,
    required this.nombreCtrl,
    required this.campania,
    required this.oportunidad,
    required this.oportunidadesFiltradas,
    required this.estado,
    required this.activo,
    required this.compartir,
    required this.onCampaniaChanged,
    required this.onOportunidadChanged,
    required this.onEstadoChanged,
    required this.onActivoChanged,
    required this.onCompartirChanged,
  });

  @override
  Widget build(BuildContext context) {
    final catalogState = context.watch<CatalogsBloc>().state;
    final campanias = catalogState is CatalogsLoaded
        ? catalogState.campanias
        : const <CampaniaItem>[];
    final estados = catalogState is CatalogsLoaded
        ? catalogState.estados.where((e) => e.esPadre).toList()
        : const <EstadoItem>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(label: 'Nombre plantilla', controller: nombreCtrl),
        const SizedBox(height: AppSpacing.md),
        CustomComboField<CampaniaItem>(
          data: campanias,
          label: 'Campaña',
          initialValue: campania?.id.toString(),
          onChanged: onCampaniaChanged,
        ),
        const SizedBox(height: AppSpacing.md),
        CustomComboField<OportunidadItem>(
          data: oportunidadesFiltradas,
          label: 'Oportunidad',
          // OportunidadItem.fields = [id, idCampania, nombre] — sin
          // labelIndex:2 el combo muestra idCampania (labelIndex default 1)
          // en vez del nombre, mismo fix que ya usa
          // edit_lead_negociacion_section.dart.
          labelIndex: 2,
          enabled: oportunidadesFiltradas.isNotEmpty,
          initialValue: oportunidad?.id.toString(),
          onChanged: onOportunidadChanged,
        ),
        const SizedBox(height: AppSpacing.md),
        CustomComboField<EstadoItem>(
          data: estados,
          label: 'Estado',
          initialValue: estado?.id,
          onChanged: onEstadoChanged,
        ),
        const SizedBox(height: AppSpacing.sm),
        _SwitchRow(
          label: 'Activo',
          value: activo,
          onChanged: onActivoChanged,
        ),
        _SwitchRow(
          label: 'Compartir',
          value: compartir,
          onChanged: onCompartirChanged,
        ),
      ],
    );
  }
}

class _SwitchRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(label, style: AppTextStyles.bodyMedium),
        ),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }
}
