// lib/features/lead/presentation/widgets/lead_detail_sheet/negociacion_card.dart

import 'package:flutter/material.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class NegociacionCard extends StatelessWidget {
  final Negociacion negociacion;
  final int leadId;
  final VoidCallback onGenerarSolicitud;
  // Se llama cuando el usuario vuelve de editar — recarga la lista
  final VoidCallback? onEdited;

  const NegociacionCard({
    super.key,
    required this.negociacion,
    required this.leadId,
    required this.onGenerarSolicitud,
    this.onEdited,
  });

  static const TextStyle _estiloMicro = TextStyle(
    fontSize: 9,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    overflow: TextOverflow.ellipsis,
  );

  // Usa el estado padre si existe (ej: "Con ficha" → muestra ícono de "En desarrollo")
  String get _idAvatarEstado =>
      negociacion.idEstadoPadre.isNotEmpty
          ? negociacion.idEstadoPadre
          : negociacion.idEstado;

  Future<void> _irAEditar() async {
    if (negociacion.idLead == 0) return;
    await NavigationService.navigateTo(
      AppRoutes.detalleEditarLead,
      arguments: {'idLead': negociacion.idLead},
    );
    onEdited?.call();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final esSeleccionado = negociacion.idLead == leadId;
    final mostrarBotones = negociacion.idEstadoPadre != '04';

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizing.radiusMd),
        border: Border.all(
          color: esSeleccionado ? colorScheme.primary : AppColors.border,
          width: esSeleccionado ? 2.0 : AppSizing.hairline,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xs),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Mitad izquierda: avatar + info principal ──────────────────
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _AvatarEstado(idEstado: _idAvatarEstado),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          negociacion.nombreOportunidad,
                          style: AppTextStyles.labelSmall.copyWith(
                            fontWeight: AppTextStyles.weightSemiBold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (negociacion.nombreCampania.isNotEmpty)
                          Text(
                            negociacion.nombreCampania,
                            style: _estiloMicro,
                            maxLines: 1,
                          ),
                        const SizedBox(height: AppSpacing.xxs),
                        AppSocialUtils.chipEstado(
                          negociacion.idEstado,
                          label: negociacion.descripcionEstado,
                          fontSize: 9,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs,
                            vertical: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: AppSpacing.xs),

            // ── Mitad derecha: info + botones en fila ────────────────────
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Sub-columna izquierda: canal, cantidad, fecha
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Text('Canal: ', style: _estiloMicro),
                            AppSocialUtils.widgetCanalById(
                              negociacion.idCanal,
                              size: 12,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Row(
                          children: [
                            const Icon(
                              AppIcons.users,
                              size: 12,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: AppSpacing.xxs),
                            Text(
                              '${negociacion.cantidad}',
                              style: _estiloMicro,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Row(
                          children: [
                            const Icon(
                              AppIcons.calendar,
                              size: 12,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: AppSpacing.xxs),
                            Expanded(
                              child: Text(
                                negociacion.fechaHora.formatDate(
                                  AppDateFormat.shortDate,
                                ),
                                style: _estiloMicro,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Sub-columna derecha: botones apilados
                  if (mostrarBotones) ...[
                    const SizedBox(width: AppSpacing.xxs),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 80,
                          height: 26,
                          child: CustomOutlinedButton(
                            text: 'Generar',
                            onPressed: onGenerarSolicitud,
                            height: 26,
                            textStyle: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            borderColor: AppColors.border,
                            borderWidth: AppSizing.hairline,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        SizedBox(
                          width: 80,
                          height: 26,
                          child: CustomPrimaryButton(
                            text: 'Editar lead',
                            onPressed: () => _irAEditar(),
                            height: 26,
                            textStyle: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Avatar circular con ícono del estado (o estado padre si existe)
// ─────────────────────────────────────────────────────────────────────────────

class _AvatarEstado extends StatelessWidget {
  final String idEstado;
  const _AvatarEstado({required this.idEstado});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizing.avatarXs,
      height: AppSizing.avatarXs,
      decoration: BoxDecoration(
        color: AppSocialUtils.bgEstado(idEstado),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: AppSocialUtils.widgetEstado(
          idEstado,
          size: AppSizing.iconSm,
        ),
      ),
    );
  }
}
