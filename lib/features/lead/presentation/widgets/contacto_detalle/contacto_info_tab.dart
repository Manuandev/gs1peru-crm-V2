// lib/features/lead/presentation/widgets/contacto_detalle/contacto_info_tab.dart

import 'package:flutter/material.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

/// Pestaña "Información": grilla de 2 columnas con los datos del lead
/// (contacto, estado, canal, campaña, oportunidad, interés).
class ContactoInfoTab extends StatelessWidget {
  final Lead lead;

  /// Negociaciones del lead — solo alimenta "Última interacción".
  final List<Negociacion> negociaciones;

  const ContactoInfoTab({
    super.key,
    required this.lead,
    this.negociaciones = const [],
  });

  @override
  Widget build(BuildContext context) {
    final tieneSubestado = lead.idEstadoPadre?.isNotEmpty ?? false;
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
                  valor: lead.nombreCompleto,
                  iconColor: AppColors.datoNombreFg,
                  iconBackground: AppColors.datoNombreBg,
                ),
                derecha: _CampoInfo(
                  icono: AppIcons.phone,
                  etiqueta: 'Celular',
                  valor: '${lead.prefijo} ${lead.numero}'.trim(),
                  iconColor: AppColors.datoCelularFg,
                  iconBackground: AppColors.datoCelularBg,
                ),
              ),
              _FilaCampos(
                izquierda: _CampoInfo(
                  icono: AppIcons.email,
                  etiqueta: 'Correo',
                  valor: lead.correo.isEmpty ? '—' : lead.correo,
                  iconColor: AppColors.datoCorreoFg,
                  iconBackground: AppColors.datoCorreoBg,
                ),
                derecha: _CampoInfo(
                  icono: AppIcons.business,
                  etiqueta: 'Empresa',
                  valor: lead.nombreEmpresa.isEmpty ? '—' : lead.nombreEmpresa,
                  iconColor: AppColors.datoEmpresaFg,
                  iconBackground: AppColors.datoEmpresaBg,
                ),
              ),
              _FilaCampos(
                izquierda: _CampoInfo(
                  icono: AppIcons.campaign,
                  etiqueta: 'Campaña',
                  valor: lead.campania.isEmpty ? '—' : lead.campania,
                  iconColor: AppColors.datoCampaniaFg,
                  iconBackground: AppColors.datoCampaniaBg,
                ),
                derecha: _CampoInfo(
                  icono: AppIcons.cursoEvento,
                  etiqueta: 'Oportunidad',
                  valor: lead.evento.isEmpty ? '—' : lead.evento,
                  iconColor: AppColors.datoEventoFg,
                  iconBackground: AppColors.datoEventoBg,
                ),
              ),
              _FilaCampos(
                izquierda: _CampoInfo(
                  iconoWidget: AppSocialUtils.widgetCanalById(
                    lead.idCanal,
                    size: AppSizing.iconMd,
                  ),
                  etiqueta: 'Canal',
                  valor: lead.canal.isEmpty ? '—' : lead.canal,
                  iconBackground: AppColors.datoCanalBg,
                ),
                derecha: _CampoInfo(
                  icono: AppIcons.interes,
                  etiqueta: 'Interés',
                  valor: lead.interes.isEmpty ? '—' : lead.interes,
                  iconColor: AppColors.datoInteresFg,
                  iconBackground: AppColors.datoInteresBg,
                ),
              ),
              _FilaCampos(
                izquierda: _CampoInfo(
                  iconoWidget: AppSocialUtils.widgetEstado(
                    lead.idEstadoEfectivo,
                    size: AppSizing.iconMd,
                  ),
                  etiqueta: 'Estado',
                  valor: lead.estadoEfectivo,
                  colorValor: AppSocialUtils.colorEstado(lead.idEstadoEfectivo),
                  iconBackground: AppColors.datoEstadoBg,
                ),
                derecha: tieneSubestado
                    ? _CampoInfo(
                        iconoWidget: AppSocialUtils.widgetEstado(
                          lead.idEstado,
                          size: AppSizing.iconMd,
                        ),
                        etiqueta: 'Subestado',
                        valor: lead.estado,
                        colorValor: AppSocialUtils.colorEstado(lead.idEstado),
                        iconBackground: AppColors.datoSubestadobg,
                      )
                    : _CampoInfo(
                        icono: AppIcons.listAlt,
                        etiqueta: 'Subestado',
                        valor: '—',
                        iconColor: AppColors.datoSubestadoFg,
                        iconBackground: AppColors.datoSubestadobg,
                      ),
              ),
              _FilaCampos(
                izquierda: _CampoInfo(
                  icono: AppIcons.calendar,
                  etiqueta: 'Fecha de registro',
                  valor: lead.fechaHora.isEmpty
                      ? '—'
                      : lead.fechaHora.formatDate(AppDateFormat.shortDate),
                  iconColor: AppColors.datoFechaRegistroFg,
                  iconBackground: AppColors.datoFechaRegistroBg,
                ),
                derecha: _CampoInfo(
                  // Ícono fijo — la última interacción no depende del canal.
                  icono: AppIcons.time,
                  etiqueta: 'Última interacción',
                  valor: ultima == null ? '—' : ultima.fechaHora.formatConDia(),
                  iconColor: AppColors.datoUltimaInteraccionFg,
                  iconBackground: AppColors.datoUltimaInteraccionBg,
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
// Campo individual: ícono grande en círculo de color / label arriba / valor abajo
// ─────────────────────────────────────────────────────────────────────────────

class _CampoInfo extends StatelessWidget {
  final IconData? icono;
  final Widget? iconoWidget;
  final String etiqueta;
  final String valor;
  final Color? iconColor;
  final Color? colorValor;
  final Color iconBackground;

  const _CampoInfo({
    this.icono,
    this.iconoWidget,
    required this.etiqueta,
    required this.valor,
    required this.iconBackground,
    this.iconColor,
    this.colorValor,
  }) : assert(icono != null || iconoWidget != null);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: AppSizing.infoBadgeSize,
          height: AppSizing.infoBadgeSize,
          decoration: BoxDecoration(
            color: iconBackground,
            shape: BoxShape.circle,
          ),
          child: Center(
            child:
                iconoWidget ??
                Icon(icono, size: AppSizing.iconMd, color: iconColor),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
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
