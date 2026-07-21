// lib/features/lead/presentation/widgets/edit_lead/edit_lead_negociacion_section.dart

import 'package:flutter/material.dart';
import 'package:app_crm/core/index_core.dart';

class EditLeadNegociacionSection extends StatelessWidget {
  final CatalogsLoaded catalogState;
  final CampaniaItem? campania;
  final OportunidadItem? oportunidad;
  final List<OportunidadItem> oportunidadesFiltradas;
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
  // Desde conversación al crear — Estado/Subestado se muestran fijos en
  // "Nuevo": mismo CustomComboField que el resto, solo con enabled:false.
  // El valor ('00') ya viene matcheado por id contra el catálogo desde
  // _inicializarCombos antes de este build — nunca un literal acá.
  final bool estadoBloqueado;
  // Desde conversación — Canal siempre fijo en WhatsApp, mismo patrón.
  final bool canalBloqueado;
  // Solo editables al crear (negociacion.idLead == 0), en cualquier origen
  // — al editar quedan siempre fijas.
  final bool campaniaOportunidadBloqueada;
  final ValueChanged<CampaniaItem?> onCampaniaChanged;
  final ValueChanged<OportunidadItem?> onOportunidadChanged;
  final ValueChanged<CanalItem?> onCanalChanged;
  final ValueChanged<InteresItem?> onInteresChanged;
  final ValueChanged<EstadoItem?> onEstadoChanged;
  final ValueChanged<EstadoItem?> onSubEstadoChanged;

  const EditLeadNegociacionSection({
    super.key,
    required this.catalogState,
    required this.campania,
    required this.oportunidad,
    required this.oportunidadesFiltradas,
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
    this.estadoBloqueado = false,
    this.canalBloqueado = false,
    this.campaniaOportunidadBloqueada = false,
    required this.onCampaniaChanged,
    required this.onOportunidadChanged,
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
          izquierdo: CustomComboField<CampaniaItem>(
            enabled: !isLoading && !campaniaOportunidadBloqueada,
            data: catalogState.campanias,
            label: 'Campaña (*)',
            initialValue: campania?.id.toString(),
            onChanged: onCampaniaChanged,
            dense: true,
            prefixIcon: Icon(
              AppIcons.campaign,
              color: colorScheme.primary,
              size: AppSizing.iconActionSm,
            ),
          ),
          derecho: CustomComboField<OportunidadItem>(
            enabled:
                oportunidadesFiltradas.isNotEmpty &&
                !isLoading &&
                !campaniaOportunidadBloqueada,
            data: oportunidadesFiltradas,
            labelIndex: 2,
            label: 'Oportunidad (*)',
            initialValue: oportunidad?.id.toString(),
            onChanged: onOportunidadChanged,
            dense: true,
            prefixIcon: Icon(
              AppIcons.calendar,
              color: colorScheme.primary,
              size: AppSizing.iconActionSm,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        FormFieldRow(
          izquierdo: _buildComboCanal(colorScheme),
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

  Widget _buildComboCanal(ColorScheme colorScheme) {
    return CustomComboField<CanalItem>(
      enabled: !isLoading && !canalBloqueado,
      data: catalogState.canales,
      label: 'Canal (*)',
      initialValue: canal?.id.toString(),
      onChanged: onCanalChanged,
      dense: true,
      prefixIcon: AppSocialUtils.widgetCanalById(
        canal?.id ?? idCanalFallback,
        size: AppSizing.iconActionSm,
      ),
    );
  }

  Widget _buildComboEstado(ColorScheme colorScheme, bool hayEstados) {
    if (!hayEstados) {
      return CustomTextField(
        label: 'Estado (*)',
        controller: TextEditingController(text: estadoFallback),
        enabled: false,
        prefixIcon: AppSocialUtils.widgetEstado(idEstadoFallback),
        dense: true,
      );
    }
    return CustomComboField<EstadoItem>(
      enabled: !isLoading && !estadoBloqueado,
      data: catalogState.estados.where((e) => e.esPadre).toList(),
      label: 'Estado (*)',
      initialValue: estado?.id,
      onChanged: onEstadoChanged,
      dense: true,
      prefixIcon: AppSocialUtils.widgetEstado(
        estado?.id ?? idEstadoFallback,
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
