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
  String get _idAvatarEstado => negociacion.idEstadoPadre.isNotEmpty
      ? negociacion.idEstadoPadre
      : negociacion.idEstado;

  // Esta card solo vive dentro de NegociacionesTab (ChatLeadPanel de
  // Conversaciones) — editar acá siempre es "desde conversación".
  Future<void> _irAEditar() async {
    if (negociacion.idLead == 0) return;
    await NavigationService.navigateTo(
      AppRoutes.detalleEditarLead,
      arguments: {'idLead': negociacion.idLead, 'desdeConversacion': true},
    );
    onEdited?.call();
  }

  // Cerrada = estado o estado padre '04' — ya no se puede editar la
  // negociación en ningún caso (mismo criterio que ContactoNegociacionCard,
  // Seguimiento).
  bool get _cerrada =>
      negociacion.idEstado == '04' || negociacion.idEstadoPadre == '04';

  // "Ganada" = negociación cerrada en el sub-estado '05' — mismo código de
  // negocio que NegociacionesTab/ContactoNegociacionCard.
  bool get _esGanada =>
      negociacion.idEstado == '05' && negociacion.idEstadoPadre == '04';

  // Mutuamente excluyentes: editar solo si no está cerrada; generar
  // solicitud solo si está Ganada y aún no tiene una. Cerrada-pero-no-Ganada
  // (perdida/desistió) y Ganada-con-solicitud no muestran ningún botón acá
  // — esta última se gestiona desde Solicitudes.
  bool get _puedeEditar => negociacion.idLead != 0 && !_cerrada;
  bool get _puedeGenerarSolicitud => _esGanada && !negociacion.tieneSolicitud;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final esSeleccionado = negociacion.idLead == leadId;
    final puedeEditar = _puedeEditar;
    final puedeGenerarSolicitud = _puedeGenerarSolicitud;

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
                          negociacion.nombreOportunidad.aTitulo,
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
                        // Mostrar el estado REAL (padre si hay sub-estado) para
                        // que cuadre con "Datos" — salvo el caso ganada real
                        // (estado '04' + sub '05'), que sí muestra "Cerrado
                        // ganado". Antes mostraba el sub-estado crudo
                        // (descripcionEstado), así una negociación en estado
                        // "Nuevo" con sub '05' salía como "Cerrado ganado".
                        AppSocialUtils.chipEstado(
                          negociacion.idEstadoEfectivo,
                          label: _esGanada
                              ? negociacion.descripcionEstado
                              : negociacion.estadoEfectivo,
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
                                negociacion.fechaHoraInteraccion.formatDate(
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

                  // Sub-columna derecha: un solo botón (o ninguno) — editar
                  // y generar solicitud son mutuamente excluyentes.
                  if (puedeEditar || puedeGenerarSolicitud) ...[
                    const SizedBox(width: AppSpacing.xxs),
                    SizedBox(
                      width: 80,
                      height: 26,
                      child: puedeGenerarSolicitud
                          ? CustomOutlinedButton(
                              text: 'Generar',
                              onPressed: onGenerarSolicitud,
                              // Sin precio total definido en la negociación
                              // no hay cantidad/importe/moneda que bloquear
                              // en la solicitud — no se puede generar todavía.
                              isEnabled: negociacion.precio > 0,
                              height: 26,
                              textStyle: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              borderColor: AppColors.border,
                              borderWidth: AppSizing.hairline,
                            )
                          : CustomPrimaryButton(
                              text: 'Editar',
                              onPressed: () => _irAEditar(),
                              height: 26,
                              textStyle: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                            ),
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
        child: AppSocialUtils.widgetEstado(idEstado, size: AppSizing.iconSm),
      ),
    );
  }
}
