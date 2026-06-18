// lib/features/lead/presentation/widgets/contacto_detalle/contacto_acciones_footer.dart

import 'package:flutter/material.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class ContactoAccionesFooter extends StatelessWidget {
  final ContactoDetalle contacto;

  const ContactoAccionesFooter({super.key, required this.contacto});

  @override
  Widget build(BuildContext context) {
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
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.md,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _BotonCircular(
            icono: AppIcons.phone,
            colorIcono: AppColors.info,
            colorFondo: AppColors.infoWithOpacity(0.15),
            onTap: contacto.numero.isEmpty
                ? null
                : () => LauncherUtils.abrirTelefono(
                      contacto.telefonoCompleto.limpiarTelefono,
                    ),
          ),
          _BotonCircular(
            icono: AppIcons.chat,
            colorIcono: AppColors.textOnDark,
            colorFondo: AppColors.success,
            // TODO: navegar a chat del contacto cuando esté definida la pantalla
            onTap: () {},
          ),
          _BotonCircular(
            icono: AppIcons.email,
            colorIcono: AppColors.textOnDark,
            colorFondo: AppColors.purple,
            onTap: contacto.correo.isEmpty
                ? null
                : () => LauncherUtils.abrirCorreo(contacto.correo),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Botón circular de acción
// ─────────────────────────────────────────────────────────────────────────────

class _BotonCircular extends StatelessWidget {
  final IconData icono;
  final Color colorIcono;
  final Color colorFondo;
  final VoidCallback? onTap;

  const _BotonCircular({
    required this.icono,
    required this.colorIcono,
    required this.colorFondo,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: AppSizing.buttonHeight,
        height: AppSizing.buttonHeight,
        decoration: BoxDecoration(
          color: onTap != null ? colorFondo : AppColors.grey200,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icono,
          size: AppSizing.iconMd,
          color: onTap != null ? colorIcono : AppColors.textDisabled,
        ),
      ),
    );
  }
}
