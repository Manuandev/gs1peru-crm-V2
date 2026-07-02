// lib/features/lead/presentation/widgets/contacto_detalle/contacto_info_tab.dart

import 'package:flutter/material.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

/// Pestaña "Información": grilla de 2 columnas con datos del contacto y de
/// su primer lead (estado, canal, campaña, oportunidad, interés).
class ContactoInfoTab extends StatelessWidget {
  final ContactoDetalle contacto;

  /// Negociación más antigua del contacto — alimenta Campaña, Oportunidad,
  /// Canal, Interés, Estado y Subestado. Null si el contacto aún no tiene
  /// negociaciones.
  final Negociacion? primerLead;

  /// Negociación con la actividad más reciente — alimenta "Última interacción".
  final Negociacion? ultimaInteraccion;

  const ContactoInfoTab({
    super.key,
    required this.contacto,
    this.primerLead,
    this.ultimaInteraccion,
  });

  @override
  Widget build(BuildContext context) {
    final lead = primerLead;
    final ultima = ultimaInteraccion;

    // Un lead "efectivo" solo tiene subestado cuando idEstadoPadre está
    // presente — misma regla que Lead.idEstadoEfectivo/estadoEfectivo.
    final tieneSubestado = lead != null && lead.idEstadoPadre.isNotEmpty;
    final idEstadoEfectivo = lead == null
        ? ''
        : (tieneSubestado ? lead.idEstadoPadre : lead.idEstado);
    final estadoLabel = lead == null
        ? '—'
        : (tieneSubestado ? lead.descripcionEstadoPadre : lead.descripcionEstado);
    final subestadoLabel = tieneSubestado ? lead.descripcionEstado : '—';

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
                  valor: contacto.nombreCompleto,
                ),
                derecha: _CampoInfo(
                  icono: AppIcons.phone,
                  etiqueta: 'Celular',
                  valor: contacto.numero.isEmpty
                      ? '—'
                      : contacto.telefonoCompleto,
                ),
              ),
              _FilaCampos(
                izquierda: _CampoInfo(
                  icono: AppIcons.email,
                  etiqueta: 'Correo',
                  valor: contacto.correo.isEmpty ? '—' : contacto.correo,
                ),
                derecha: _CampoInfo(
                  icono: AppIcons.business,
                  etiqueta: 'Empresa',
                  valor: contacto.empresa.isEmpty ? '—' : contacto.empresa,
                ),
              ),
              _FilaCampos(
                izquierda: _CampoInfo(
                  icono: AppIcons.cargo,
                  etiqueta: 'Cargo',
                  valor: contacto.cargo.isEmpty ? '—' : contacto.cargo,
                ),
                derecha: _CampoInfo(
                  icono: AppIcons.documento,
                  etiqueta: 'Razón social',
                  valor: contacto.razonSocial.isEmpty
                      ? '—'
                      : contacto.razonSocial,
                ),
              ),
              _FilaCampos(
                izquierda: _CampoInfo(
                  icono: AppIcons.campaign,
                  etiqueta: 'Campaña',
                  valor: lead == null || lead.nombreCampania.isEmpty
                      ? '—'
                      : lead.nombreCampania,
                ),
                derecha: _CampoInfo(
                  icono: AppIcons.cursoEvento,
                  etiqueta: 'Oportunidad',
                  valor: lead == null || lead.nombreOportunidad.isEmpty
                      ? '—'
                      : lead.nombreOportunidad,
                ),
              ),
              _FilaCampos(
                izquierda: lead == null
                    ? const _CampoInfo(
                        icono: AppIcons.language,
                        etiqueta: 'Canal',
                        valor: '—',
                      )
                    : _CampoInfo(
                        iconoWidget: AppSocialUtils.widgetCanalById(
                          lead.idCanal,
                          size: AppSizing.iconSm,
                        ),
                        etiqueta: 'Canal',
                        valor: lead.descripcionCanal.isEmpty
                            ? '—'
                            : lead.descripcionCanal,
                        colorValor: AppSocialUtils.colorCanalById(
                          lead.idCanal,
                        ),
                      ),
                derecha: _CampoInfo(
                  icono: AppIcons.interes,
                  etiqueta: 'Interés',
                  valor: lead == null || lead.descripcionInteres.isEmpty
                      ? '—'
                      : lead.descripcionInteres,
                ),
              ),
              _FilaCampos(
                izquierda: lead == null
                    ? const _CampoInfo(
                        icono: AppIcons.flag,
                        etiqueta: 'Estado',
                        valor: '—',
                      )
                    : _CampoInfo(
                        iconoWidget: AppSocialUtils.widgetEstado(
                          idEstadoEfectivo,
                          size: AppSizing.iconSm,
                        ),
                        etiqueta: 'Estado',
                        valor: estadoLabel,
                        colorValor: AppSocialUtils.colorEstado(
                          idEstadoEfectivo,
                        ),
                      ),
                derecha: _CampoInfo(
                  icono: AppIcons.listAlt,
                  etiqueta: 'Subestado',
                  valor: subestadoLabel,
                ),
              ),
              _FilaCampos(
                izquierda: _CampoInfo(
                  icono: AppIcons.calendar,
                  etiqueta: 'Fecha de registro',
                  valor: contacto.fechaRegistro.isEmpty
                      ? '—'
                      : contacto.fechaRegistro.formatDate(
                          AppDateFormat.shortDate,
                        ),
                ),
                derecha: ultima == null
                    ? const _CampoInfo(
                        icono: AppIcons.chat,
                        etiqueta: 'Última interacción',
                        valor: '—',
                      )
                    : _CampoInfo(
                        iconoWidget: AppSocialUtils.widgetCanalById(
                          ultima.idCanal,
                          size: AppSizing.iconSm,
                        ),
                        etiqueta: 'Última interacción',
                        valor: ultima.fechaHora.formatConDia(),
                      ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          CustomOutlinedButton(
            text: 'Editar contacto',
            icon: AppIcons.edit,
            // TODO: navegar a pantalla de edición de contacto cuando esté disponible
            onPressed: () {},
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
// Campo individual: ícono + etiqueta arriba / valor abajo
// ─────────────────────────────────────────────────────────────────────────────

class _CampoInfo extends StatelessWidget {
  final IconData? icono;
  final Widget? iconoWidget;
  final String etiqueta;
  final String valor;
  final Color? colorValor;

  const _CampoInfo({
    this.icono,
    this.iconoWidget,
    required this.etiqueta,
    required this.valor,
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
              Icon(icono, size: AppSizing.iconSm, color: AppColors.grey500),
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
