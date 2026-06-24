// lib/features/chat/presentation/widgets/chat_detail/info_lead/chat_detail_datos_lead.dart
import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class ChatDetailDatosLead extends StatefulWidget {
  final Lead lead;
  const ChatDetailDatosLead({super.key, required this.lead});

  @override
  State<ChatDetailDatosLead> createState() => _ChatDetailDatosLeadState();
}

class _ChatDetailDatosLeadState extends State<ChatDetailDatosLead> {
  bool _expandido = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: Column(
        children: [
          // ── Header clickeable ──
          InkWell(
            onTap: () => setState(() => _expandido = !_expandido),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  Row(
                    children: [
                      Container(
                        width: AppSizing.accentBarWidth,
                        height: AppSizing.iconSm,
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius:
                              BorderRadius.circular(AppSizing.radiusXxs),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text('Datos del lead', style: AppTextStyles.titleMedium),
                    ],
                  ),
                  const Spacer(),
                  Icon(
                    _expandido ? AppIcons.arrowDown : AppIcons.arrowUp,
                    color: colorScheme.onSurface,
                  ),
                ],
              ),
            ),
          ),

          // ── Contenido expandible ──
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: _DatosLeadContenido(lead: widget.lead),
            crossFadeState: _expandido
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }
}

class _DatosLeadContenido extends StatelessWidget {
  final Lead lead;
  const _DatosLeadContenido({required this.lead});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.md,
      ),
      child: Column(
        children: [
          Row(
            children: [
              _DatoItem(
                icon: AppIcons.flag,
                label: 'Estado',
                valor: lead.estado,
                iconColor: AppColors.datoEstadoFg,
                iconBackground: AppColors.datoEstadoBg,
              ),
              _DatoItem(
                icon: AppIcons.listAlt,
                label: 'Subestado',
                valor: lead.subEstado ?? '',
                iconColor: AppColors.datoSubestadoFg,
                iconBackground: AppColors.datoSubestadobg,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              _DatoItem(
                icon: AppIcons.campaign,
                label: 'Campaña',
                valor: lead.campania,
                iconColor: AppColors.datoCampaniaFg,
                iconBackground: AppColors.datoCampaniaBg,
              ),
              _DatoItem(
                icon: AppIcons.calendar,
                label: 'Evento',
                valor: lead.evento,
                iconColor: AppColors.datoEventoFg,
                iconBackground: AppColors.datoEventoBg,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              _DatoItem(
                icon: AppIcons.share,
                label: 'Canal',
                valor: lead.canal,
                iconColor: AppColors.datoCanalFg,
                iconBackground: AppColors.datoCanalBg,
              ),
              _DatoItem(
                icon: AppIcons.users,
                label: 'Interés',
                valor: lead.interes,
                iconColor: AppColors.datoInteresFg,
                iconBackground: AppColors.datoInteresBg,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}

class _DatoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String valor;
  final Color iconColor;
  final Color iconBackground;

  const _DatoItem({
    required this.icon,
    required this.label,
    required this.valor,
    required this.iconColor,
    required this.iconBackground,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.iconBgPad),
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(AppSizing.radiusTag),
            ),
            child: Icon(icon, size: AppSizing.iconXs, color: iconColor),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.grey500,
                  ),
                ),
                Text(
                  valor == '' ? 'Sin $label' : valor,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: AppTextStyles.weightMedium,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
