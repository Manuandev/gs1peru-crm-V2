// lib/core/presentation/widgets/form_save_bar.dart

import 'package:flutter/material.dart';
import 'package:app_crm/core/index_core.dart';

/// Barra inferior fija con botones Cancelar / Guardar.
/// Estándar para formularios de edición en toda la app.
class FormSaveBar extends StatelessWidget {
  final VoidCallback onCancelar;
  final VoidCallback onGuardar;
  final bool isLoading;
  final bool isEnabled;
  final String textoCancelar;
  final String textoGuardar;
  final Widget? iconoGuardar;

  const FormSaveBar({
    super.key,
    required this.onCancelar,
    required this.onGuardar,
    this.isLoading = false,
    this.isEnabled = true,
    this.textoCancelar = 'Cancelar',
    this.textoGuardar = 'Guardar cambios',
    this.iconoGuardar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color:      AppColors.cardShadow,
            blurRadius: AppSizing.shadowBlurMd,
            offset:     const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: CustomOutlinedButton(
              text:      textoCancelar,
              isEnabled: !isLoading,
              onPressed: onCancelar,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: CustomPrimaryButton(
              text:      textoGuardar,
              onPressed: onGuardar,
              isLoading: isLoading,
              isEnabled: isEnabled && !isLoading,
              icon:      iconoGuardar,
            ),
          ),
        ],
      ),
    );
  }
}
