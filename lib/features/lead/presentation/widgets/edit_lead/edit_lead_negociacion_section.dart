// lib/features/lead/presentation/widgets/edit_lead/edit_lead_negociacion_section.dart

import 'package:flutter/material.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class EditLeadNegociacionSection extends StatelessWidget {
  final CatalogsLoaded catalogState;
  final TextEditingController campaniaCtrl;
  final TextEditingController eventoCtrl;
  final CanalItem? canal;
  final InteresItem? interes;
  final EstadoItem? estado;
  final EstadoItem? subEstado;
  final List<EstadoItem> subEstadosFiltrados;
  // Fallbacks cuando el SP aún no devuelve estados
  final String idEstadoFallback;
  final String estadoFallback;
  final String? descripcionEstadoPadreFallback;
  final int idCanalFallback;
  final bool isLoading;
  final ValueChanged<CanalItem?> onCanalChanged;
  final ValueChanged<InteresItem?> onInteresChanged;
  final ValueChanged<EstadoItem?> onEstadoChanged;
  final ValueChanged<EstadoItem?> onSubEstadoChanged;

  const EditLeadNegociacionSection({
    super.key,
    required this.catalogState,
    required this.campaniaCtrl,
    required this.eventoCtrl,
    required this.canal,
    required this.interes,
    required this.estado,
    required this.subEstado,
    required this.subEstadosFiltrados,
    required this.idEstadoFallback,
    required this.estadoFallback,
    required this.descripcionEstadoPadreFallback,
    required this.idCanalFallback,
    required this.isLoading,
    required this.onCanalChanged,
    required this.onInteresChanged,
    required this.onEstadoChanged,
    required this.onSubEstadoChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hayEstados = catalogState.estados.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FormSectionTitle('Información de la negociación'),
        const SizedBox(height: AppSpacing.md),

        FormFieldRow(
          izquierdo: _buildComboEstado(colorScheme, hayEstados),
          derecho: _buildComboSubEstado(colorScheme, hayEstados),
        ),
        const SizedBox(height: AppSpacing.sm),

        FormFieldRow(
          izquierdo: CustomTextField(
            label: 'Campaña',
            controller: campaniaCtrl,
            enabled: false,
            dense: true,
            prefixIcon: Icon(
              AppIcons.campaign,
              color: colorScheme.primary,
              size: AppSizing.iconActionSm,
            ),
          ),
          derecho: CustomTextField(
            label: 'Evento',
            controller: eventoCtrl,
            enabled: false,
            dense: true,
            prefixIcon: Icon(
              AppIcons.calendar,
              color: colorScheme.secondary,
              size: AppSizing.iconActionSm,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        FormFieldRow(
          izquierdo: CustomComboField<CanalItem>(
            enabled: !isLoading,
            data: catalogState.canales,
            label: 'Canal',
            initialValue: canal?.id.toString(),
            onChanged: onCanalChanged,
            dense: true,
            prefixIcon: AppSocialUtils.widgetCanalById(
              canal?.id ?? idCanalFallback,
              size: AppSizing.iconActionSm,
            ),
          ),
          derecho: CustomComboField<InteresItem>(
            enabled: !isLoading,
            data: catalogState.intereses,
            label: 'Interés',
            initialValue: interes?.id.toString(),
            onChanged: onInteresChanged,
            dense: true,
            prefixIcon: Icon(
              AppIcons.interes,
              color: colorScheme.primary,
              size: AppSizing.iconActionSm,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildComboEstado(ColorScheme colorScheme, bool hayEstados) {
    final colorEstado = AppSocialUtils.colorEstado(
      estado?.id ?? idEstadoFallback,
    );

    if (!hayEstados) {
      return CustomTextField(
        label: 'Estado',
        controller: TextEditingController(text: estadoFallback),
        enabled: false,
        prefixIcon: AppSocialUtils.widgetEstado(idEstadoFallback),
        dense: true,
      );
    }
    return CustomComboField<EstadoItem>(
      enabled: !isLoading,
      data: catalogState.estados.where((e) => e.esPadre).toList(),
      label: 'Estado',
      initialValue: estado?.id,
      onChanged: onEstadoChanged,
      dense: true,
      prefixIcon: Icon(
        AppIcons.flag,
        color: colorEstado,
        size: AppSizing.iconActionSm,
      ),
    );
  }

  Widget _buildComboSubEstado(ColorScheme colorScheme, bool hayEstados) {
    if (!hayEstados) {
      return CustomTextField(
        label: 'Subestado',
        controller: TextEditingController(
          text: descripcionEstadoPadreFallback ?? estadoFallback,
        ),
        enabled: false,
        dense: true,
        prefixIcon: Icon(
          AppIcons.listAlt,
          color: colorScheme.primary,
          size: AppSizing.iconActionSm,
        ),
      );
    }
    return CustomComboField<EstadoItem>(
      enabled: subEstadosFiltrados.isNotEmpty && !isLoading,
      data: subEstadosFiltrados,
      label: 'Subestado',
      initialValue: subEstado?.id,
      onChanged: onSubEstadoChanged,
      dense: true,
      prefixIcon: Icon(
        AppIcons.listAlt,
        color: colorScheme.primary,
        size: AppSizing.iconActionSm,
      ),
    );
  }
}
