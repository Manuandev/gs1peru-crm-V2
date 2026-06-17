// lib/features/lead/presentation/widgets/detalle/lead_detalle_comentarios.dart

import 'package:flutter/material.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class LeadDetalleComentarios extends StatelessWidget {
  final List<ComentarioLead> comentarios;
  const LeadDetalleComentarios({super.key, required this.comentarios});

  @override
  Widget build(BuildContext context) {
    final visibles = comentarios.take(3).toList();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Comentarios (${comentarios.length})',
                style: AppTextStyles.titleSmall,
              ),
              CustomTextButton(
                text: 'Ver todos',
                onPressed: () {},
              ),
            ],
          ),
          ...visibles.map((c) => _ComentarioBubble(comentario: c)),
          const SizedBox(height: AppSpacing.xs),
          CustomOutlinedButton(
            text: 'Agregar comentario',
            icon: const Icon(AppIcons.add),
            onPressed: () {},
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

class _ComentarioBubble extends StatelessWidget {
  final ComentarioLead comentario;
  const _ComentarioBubble({required this.comentario});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceLightVariant,
        borderRadius: BorderRadius.circular(AppSizing.radiusMd),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: AppSizing.avatarRadiusSm,
            backgroundColor: AvatarUtils.color(comentario.autor),
            child: Text(
              AvatarUtils.initials(comentario.autor),
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textOnDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comentario.fechaHora.formatConDia(),
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(comentario.texto, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
