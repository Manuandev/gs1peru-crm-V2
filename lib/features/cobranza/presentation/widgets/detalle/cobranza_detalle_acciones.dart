// lib/features/cobranza/presentation/widgets/detalle/cobranza_detalle_acciones.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/cobranza/index_cobranza.dart';

class CobranzaDetalleAcciones extends StatelessWidget {
  final CobranzaDetalle detalle;
  const CobranzaDetalleAcciones({super.key, required this.detalle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizing.radiusMd),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Acciones rápidas',
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: AppTextStyles.weightSemiBold,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _AccionBtn(
                icono: AppIcons.whatsapp,
                esFontAwesome: true,
                color: AppSocialUtils.colorCanalById(5),
                label: 'Conversación',
                onTap: detalle.celular.isEmpty
                    ? () {}
                    : () => LauncherUtils.abrirWhatsApp(detalle.celular),
              ),
              _AccionBtn(
                icono: AppIcons.phone,
                color: AppColors.primary,
                label: 'Llamar',
                onTap: detalle.celular.isEmpty
                    ? () {}
                    : () => LauncherUtils.abrirTelefono(detalle.celular),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AccionBtn extends StatelessWidget {
  final dynamic icono;
  final bool esFontAwesome;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _AccionBtn({
    required this.icono,
    this.esFontAwesome = false,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: AppSizing.buttonHeightSmall,
            height: AppSizing.buttonHeightSmall,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSizing.radiusMd),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black(0.06),
                  blurRadius: AppSizing.shadowBlurSm,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Center(
              child: esFontAwesome
                  ? FaIcon(icono, size: AppSizing.iconSm, color: color)
                  : Icon(
                      icono as IconData,
                      size: AppSizing.iconSm,
                      color: color,
                    ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}
