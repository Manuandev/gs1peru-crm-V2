// lib/features/lead/presentation/widgets/contacto_detalle/contacto_acciones_footer.dart

import 'package:flutter/material.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class ContactoAccionesFooter extends StatelessWidget {
  final Lead lead;

  const ContactoAccionesFooter({super.key, required this.lead});

  @override
  Widget build(BuildContext context) {
    final telefono = '${lead.prefijo}${lead.numero}';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.black(AppColors.opacitySubtle),
            blurRadius: AppSizing.shadowBlurMd,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: CustomOutlinedButton(
              text: 'WhatsApp',
              icon: AppIcons.whatsapp,
              borderColor: AppSocialUtils.colorCanalById(1),
              foregroundColor: AppSocialUtils.colorCanalById(1),
              onPressed: lead.numero.isEmpty
                  ? null
                  : () => LauncherUtils.abrirWhatsApp(telefono),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: CustomOutlinedButton(
              text: 'Llamar',
              icon: AppIcons.phone,
              onPressed: lead.numero.isEmpty
                  ? null
                  : () => LauncherUtils.abrirTelefono(telefono),
            ),
          ),
          // Editar contacto — pendiente hasta que exista la pantalla de edición.
          // const SizedBox(width: AppSpacing.sm),
          // Expanded(
          //   child: CustomPrimaryButton(
          //     text: 'Editar',
          //     icon: AppIcons.edit,
          //     onPressed: () {},
          //   ),
          // ),
        ],
      ),
    );
  }
}
