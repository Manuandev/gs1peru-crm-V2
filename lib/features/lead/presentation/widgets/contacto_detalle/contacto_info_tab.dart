// lib/features/lead/presentation/widgets/contacto_detalle/contacto_info_tab.dart

import 'package:flutter/material.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

/// Pestaña "Información": grilla de 2 columnas con los datos del lead
/// (contacto, estado, canal, campaña, oportunidad, interés).
class ContactoInfoTab extends StatelessWidget {
  final Negociacion lead;

  /// Negociaciones del lead — solo alimenta "Última interacción".
  final List<Negociacion> negociaciones;

  const ContactoInfoTab({
    super.key,
    required this.lead,
    this.negociaciones = const [],
  });

  @override
  Widget build(BuildContext context) {
    final tieneSubestado = lead.idEstadoPadre.isNotEmpty;
    final ultima = negociaciones.ultimaInteraccion;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _InfoCard(
            filas: [
              _FilaCampos(
                izquierda: _CampoInfo(
                  icono: AppIcons.user,
                  etiqueta: 'Nombres y apellidos',
                  valor: lead.nombreCompleto.isEmpty
                      ? '—'
                      : lead.nombreCompleto,
                ),
                derecha: _CampoInfo(
                  icono: AppIcons.phone,
                  etiqueta: 'Celular',
                  valor: lead.telefonoCompleto.isEmpty
                      ? '—'
                      : lead.telefonoCompleto,
                  iconColor: AppColors.success,
                ),
              ),
              _FilaCampos(
                izquierda: _CampoInfo(
                  icono: AppIcons.email,
                  etiqueta: 'Correo',
                  valor: lead.correo.isEmpty ? '—' : lead.correo,
                ),
                derecha: _CampoInfo(
                  icono: AppIcons.business,
                  etiqueta: 'Empresa',
                  valor: lead.nombreEmpresa.isEmpty ? '—' : lead.nombreEmpresa,
                ),
              ),
              _FilaCampos(
                izquierda: _CampoInfo(
                  icono: AppIcons.campaign,
                  etiqueta: 'Campaña',
                  valor: lead.nombreCampania.isEmpty ? '—' : lead.nombreCampania,
                ),
                derecha: _CampoInfo(
                  icono: AppIcons.cursoEvento,
                  etiqueta: 'Oportunidad',
                  valor: lead.nombreOportunidad.isEmpty
                      ? '—'
                      : lead.nombreOportunidad,
                ),
              ),
              _FilaCampos(
                izquierda: _CampoInfo(
                  iconoWidget: AppSocialUtils.widgetCanalById(
                    lead.idCanal,
                    size: AppSizing.iconSm,
                  ),
                  etiqueta: 'Canal',
                  valor: lead.descripcionCanal.isEmpty
                      ? '—'
                      : lead.descripcionCanal,
                ),
                derecha: _CampoInfo(
                  icono: AppIcons.interes,
                  etiqueta: 'Interés',
                  valor: lead.descripcionInteres.isEmpty
                      ? '—'
                      : lead.descripcionInteres,
                ),
              ),
              _FilaCampos(
                izquierda: _CampoInfo(
                  iconoWidget: AppSocialUtils.widgetEstado(
                    lead.idEstadoEfectivo,
                    size: AppSizing.iconSm,
                  ),
                  etiqueta: 'Estado',
                  valor: lead.estadoEfectivo,
                  colorValor: AppSocialUtils.colorEstado(lead.idEstadoEfectivo),
                ),
                derecha: tieneSubestado
                    ? _CampoInfo(
                        iconoWidget: AppSocialUtils.widgetEstado(
                          lead.idEstado,
                          size: AppSizing.iconSm,
                        ),
                        etiqueta: 'Subestado',
                        valor: lead.descripcionEstado,
                        colorValor: AppSocialUtils.colorEstado(lead.idEstado),
                      )
                    : const _CampoInfo(
                        icono: AppIcons.listAlt,
                        etiqueta: 'Subestado',
                        valor: '—',
                      ),
              ),
              _FilaCampos(
                izquierda: _CampoInfo(
                  icono: AppIcons.calendar,
                  etiqueta: 'Fecha de registro',
                  valor: lead.fechaHoraCreacion.isEmpty
                      ? '—'
                      : lead.fechaHoraCreacion.formatDate(
                          AppDateFormat.shortDate,
                        ),
                ),
                derecha: _CampoInfo(
                  // Ícono fijo — la última interacción no depende del canal.
                  icono: AppIcons.time,
                  etiqueta: 'Última interacción',
                  valor: ultima == null
                      ? '—'
                      : ultima.fechaHoraInteraccion.formatConDia(),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Card de sección
// ─────────────────────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final List<Widget> filas;

  const _InfoCard({required this.filas});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < filas.length; i++) ...[
            filas[i],
            if (i < filas.length - 1)
              const Divider(height: AppSizing.hairline),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Fila de 2 columnas
// ─────────────────────────────────────────────────────────────────────────────

class _FilaCampos extends StatelessWidget {
  final Widget izquierda;
  final Widget derecha;

  const _FilaCampos({required this.izquierda, required this.derecha});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: izquierda),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: derecha),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Campo individual: ícono chico + etiqueta arriba / valor abajo.
// Sin color por defecto — solo Celular, Canal y Estado/Subestado llevan color.
// ─────────────────────────────────────────────────────────────────────────────

class _CampoInfo extends StatelessWidget {
  final IconData? icono;
  final Widget? iconoWidget;
  final String etiqueta;
  final String valor;
  final Color? iconColor;
  final Color? colorValor;

  const _CampoInfo({
    this.icono,
    this.iconoWidget,
    required this.etiqueta,
    required this.valor,
    this.iconColor,
    this.colorValor,
  }) : assert(icono != null || iconoWidget != null);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: AppSizing.iconSm,
          height: AppSizing.iconSm,
          child:
              iconoWidget ??
              Icon(icono, size: AppSizing.iconSm, color: iconColor ?? AppColors.grey500),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                etiqueta.toUpperCase(),
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                  letterSpacing: AppTextStyles.letterSpacingNarrow,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                valor,
                style: AppTextStyles.bodySmall.copyWith(
                  color: colorValor ?? AppColors.textPrimary,
                  fontWeight: AppTextStyles.weightSemiBold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
