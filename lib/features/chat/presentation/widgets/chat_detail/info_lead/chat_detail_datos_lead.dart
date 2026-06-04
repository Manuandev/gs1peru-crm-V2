import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/chat/index_chat.dart';

class ChatDetailDatosLead extends StatefulWidget {
  final InfoLead infoLead;
  const ChatDetailDatosLead({super.key, required this.infoLead});

  @override
  State<ChatDetailDatosLead> createState() => _ChatDetailDatosLeadState();
}

class _ChatDetailDatosLeadState extends State<ChatDetailDatosLead> {
  bool _expandido = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final themeText = theme.textTheme;

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
                        width: 3,
                        height: 16,
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('Datos del lead', style: themeText.titleMedium),
                    ],
                  ),
                  const Spacer(),
                  Icon(
                    _expandido
                        ? Icons.keyboard_arrow_down_rounded
                        : Icons.keyboard_arrow_up_rounded,
                    color: colorScheme.onSurface,
                  ),
                ],
              ),
            ),
          ),

          // ── Contenido expandible ──
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: _DatosLeadContenido(infoLead: widget.infoLead),
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
  final InfoLead infoLead;
  const _DatosLeadContenido({required this.infoLead});

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
                icon: Icons.flag_rounded,
                label: 'Estado',
                valor: infoLead.estado,
                iconColor: Colors.blue.shade700,
                iconBackground: Colors.blue.shade50,
              ),
              _DatoItem(
                icon: Icons.list_alt_rounded,
                label: 'Subestado',
                valor: infoLead.subEstado,
                iconColor: Colors.purple.shade700,
                iconBackground: Colors.purple.shade50,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              _DatoItem(
                icon: Icons.campaign_rounded,
                label: 'Campaña',
                valor: infoLead.campania ?? '',
                iconColor: Colors.teal.shade700,
                iconBackground: Colors.teal.shade50,
              ),
              _DatoItem(
                icon: Icons.calendar_today_rounded,
                label: 'Evento',
                valor: infoLead.evento ?? '',
                iconColor: Colors.orange.shade700,
                iconBackground: Colors.orange.shade50,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              _DatoItem(
                icon: Icons.share_rounded,
                label: 'Canal',
                valor: infoLead.canal ?? '',
                iconColor: Colors.pink.shade700,
                iconBackground: Colors.pink.shade50,
              ),
              _DatoItem(
                icon: Icons.people_rounded,
                label: 'Interés',
                valor: infoLead.interes ?? '',
                iconColor: Colors.green.shade700,
                iconBackground: Colors.green.shade50,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // ── Botón Editar lead ──
          // Align(
          //   alignment: Alignment.centerRight,
          //   child: CustomOutlinedButton(
          //     text: 'Editar lead',
          //     icon: const Icon(Icons.edit_rounded, size: AppSizing.iconSm),
          //     onPressed: () => context.goToEditarLead(
          //       lead: infoLead,
          //       cubit: context.read<InfoLeadCubit>(),
          //     ),
          //   ),
          // ),
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
    final themeText = Theme.of(context).textTheme;

    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 14, color: iconColor),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: themeText.labelSmall?.copyWith(
                    color: Colors.grey.shade500,
                  ),
                ),
                Text(
                  valor == '' ? 'Sin $label' : valor,
                  style: themeText.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
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
