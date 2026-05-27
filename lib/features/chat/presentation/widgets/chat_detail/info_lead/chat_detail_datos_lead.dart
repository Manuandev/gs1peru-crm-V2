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
                  Text(
                    'Datos del lead',
                    style: AppTextStyles.titleSmall.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
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
              ),
              _DatoItem(
                icon: Icons.list_alt_rounded,
                label: 'Subestado',
                valor: infoLead.subEstado,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              _DatoItem(
                icon: Icons.campaign_rounded,
                label: 'Campaña',
                valor: infoLead.campania,
              ),
              _DatoItem(
                icon: Icons.calendar_today_rounded,
                label: 'Evento',
                valor: infoLead.evento,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              _DatoItem(
                icon: Icons.share_rounded,
                label: 'Canal',
                valor: infoLead.canal,
              ),
              _DatoItem(
                icon: Icons.people_rounded,
                label: 'Interés',
                valor: infoLead.interes,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // ── Botón Editar lead ──
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                // acción editar lead
              },
              icon: const Icon(Icons.edit_rounded, size: 16),
              label: const Text('Editar lead'),
            ),
          ),
        ],
      ),
    );
  }
}

class _DatoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String valor;

  const _DatoItem({
    required this.icon,
    required this.label,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade500),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: Colors.grey.shade500,
                  ),
                ),
                Text(
                  valor == '' ? 'Sin $label' : valor,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
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
