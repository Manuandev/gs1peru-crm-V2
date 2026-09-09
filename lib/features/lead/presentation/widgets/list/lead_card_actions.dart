// lib/features/lead/presentation/widgets/list/lead_card_actions.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/core/index_core.dart';

/// Botones de acción de LeadCard: WhatsApp (ícono, verde/gris) y "Ver detalle"
/// (borde y texto azules), en fila. Tamaño extra compacto
/// (`AppSizing.miniActionButtonSm` = 26dp) — pedido de negocio 2026-09-09, más
/// chicos que la versión anterior (32dp). Los callbacks los inyecta el padre.
class LeadCardActions extends StatelessWidget {
  final VoidCallback? onWhatsAppTap;
  final VoidCallback? onVerDetalleTap;

  /// false si el número nunca tuvo conversación (idChatCab == 0) — oculta
  /// el botón de WhatsApp por completo, no solo lo deshabilita.
  final bool mostrarWhatsApp;

  /// true si ya se superó el tiempo de chat abierto (TDE) — pinta el botón
  /// en gris en vez de verde para indicar que ya no se puede escribir.
  final bool whatsAppVencido;

  const LeadCardActions({
    super.key,
    this.onWhatsAppTap,
    this.onVerDetalleTap,
    this.mostrarWhatsApp = true,
    this.whatsAppVencido = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorWhatsApp = whatsAppVencido
        ? AppColors.textDisabled
        : AppSocialUtils.colorCanal('whatsapp');
    final colorPrimary = Theme.of(context).colorScheme.primary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (mostrarWhatsApp) ...[
          GestureDetector(
            onTap: onWhatsAppTap,
            child: Container(
              width: AppSizing.miniActionButtonSm,
              height: AppSizing.miniActionButtonSm,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colorWhatsApp,
                borderRadius: BorderRadius.circular(AppSizing.radiusSm),
              ),
              child: FaIcon(
                AppIcons.whatsapp,
                size: AppSizing.iconXs,
                color: AppColors.textOnDark,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
        GestureDetector(
          onTap: onVerDetalleTap,
          child: Container(
            height: AppSizing.miniActionButtonSm,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizing.radiusSm),
              border: Border.all(color: colorPrimary),
            ),
            child: Text(
              'Ver detalle',
              style: AppTextStyles.labelSmall.copyWith(
                color: colorPrimary,
                fontWeight: AppTextStyles.weightSemiBold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
