// lib/features/lead/presentation/widgets/lead_detail_sheet/negociacion_card.dart

import 'package:flutter/material.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/features/lead/index_lead.dart';
import 'package:app_crm/features/solicitudes/index_solicitudes.dart';

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

  // Solicitud "en blanco" con los datos disponibles en la negociación —
  // mismo patrón que ContactoNegociacionCard._generarSolicitud, usado tanto
  // para editar una solicitud ya creada (idSolicitud = NUMSOL) como para
  // verla de solo lectura.
  Solicitud _solicitudDesdeNegociacion() => Solicitud(
    idSolicitud: negociacion.numSol,
    nombre: negociacion.nombres,
    apellidoPaterno: negociacion.apellidoPaterno,
    apellidoMaterno: negociacion.apellidoMaterno,
    nombreEmpresa: negociacion.nombreEmpresa,
    cargo: '',
    correo: negociacion.correo,
    telefono: negociacion.telefonoCompleto,
    tipoPersona: '',
    idCondicionPago: '',
    condicionPago: '',
    monto: negociacion.precio,
    fechaCreacion: negociacion.fechaHoraCreacion,
    idOportunidad: negociacion.idOportunidad,
    oportunidad: negociacion.nombreOportunidad,
    idCanal: negociacion.idCanal,
    canal: negociacion.descripcionCanal,
    idEstado: negociacion.idEstadoSol,
    estado: '',
    ibValidado: false,
    asesor: '',
    nombreAsesor: '',
    idLead: negociacion.idLead.toString(),
  );

  void _editarSolicitud(BuildContext context) {
    context.goToFichaCompletarSolicitud(
      solicitud: _solicitudDesdeNegociacion(),
      modoEdicion: true,
    );
  }

  void _verSolicitud(BuildContext context) {
    context.goToDetalleSolicitud(solicitud: _solicitudDesdeNegociacion());
  }

  // Ya existe una solicitud para esta negociación — ya no se puede editar,
  // pero se reusa la misma pantalla de Editar negociación en modo solo
  // lectura (campos deshabilitados, sin barra de Guardar/Cancelar) en vez
  // de mandar a otra pantalla distinta.
  void _verNegociacion(BuildContext context) {
    context.goToEditarLead(idLead: negociacion.idLead, soloLectura: true);
  }

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
                            text: switch (negociacion.accionSolicitud) {
                              SolicitudAccion.generar => 'Generar solicitud',
                              SolicitudAccion.editar => 'Editar solicitud',
                              SolicitudAccion.ver => 'Ver solicitud',
                            },
                            onPressed: switch (negociacion.accionSolicitud) {
                              SolicitudAccion.generar => onGenerarSolicitud,
                              SolicitudAccion.editar => () =>
                                  _editarSolicitud(context),
                              SolicitudAccion.ver => () =>
                                  _verSolicitud(context),
                            },
                            // Sin precio total definido en la negociación no
                            // hay cantidad/importe/moneda que bloquear en la
                            // solicitud — no se puede generar todavía.
                            isEnabled:
                                negociacion.accionSolicitud !=
                                    SolicitudAccion.generar ||
                                negociacion.precio > 0,
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
                            text: negociacion.tieneSolicitud
                                ? 'Ver negociación'
                                : 'Editar negociación',
                            onPressed: negociacion.tieneSolicitud
                                ? () => _verNegociacion(context)
                                : () => _irAEditar(),
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
        child: AppSocialUtils.widgetEstado(idEstado, size: AppSizing.iconSm),
      ),
    );
  }
}
