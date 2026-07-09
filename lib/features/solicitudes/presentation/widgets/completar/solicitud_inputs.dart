// lib/features/solicitudes/presentation/widgets/completar/solicitud_inputs.dart
//
// Widgets exclusivos del wizard de solicitud que NO tienen equivalente en
// lib/core/presentation/widgets — toggle de tipo de persona, badge de paso y
// el campo de celular con prefijo de país. Para texto/combos/botones usar
// siempre los widgets generales del core (CustomTextField, CustomComboField,
// CustomComboSearchField, CustomPrimaryButton, CustomSecondaryButton,
// CustomOutlinedButton) — no crear wrappers locales para ellos.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:app_crm/core/index_core.dart';

// ── SolicitudToggleTipoPersona (pill jurídica/natural) ────────────────────────

class SolicitudToggleTipoPersona extends StatelessWidget {
  final String valor;
  final bool habilitado;
  final ValueChanged<String> onChanged;

  const SolicitudToggleTipoPersona({
    super.key,
    required this.valor,
    required this.habilitado,
    required this.onChanged,
  });

  static const _duracion = Duration(milliseconds: 250);
  static const _curva = Curves.easeInOut;
  static const double _anchoPorOpcion = 82.0;

  @override
  Widget build(BuildContext context) {
    final esJuridica = valor == 'juridica';

    return SizedBox(
      height: AppSizing.buttonHeightSmall,
      width: _anchoPorOpcion * 2 + 6,
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: AppColors.surfaceLightVariant,
          borderRadius: BorderRadius.circular(AppSizing.radiusCircular),
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: _duracion,
              curve: _curva,
              left: esJuridica ? 0 : _anchoPorOpcion,
              top: 0,
              bottom: 0,
              width: _anchoPorOpcion,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppSizing.radiusCircular),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black(0.14),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
            Row(
              children: [
                SizedBox(
                  width: _anchoPorOpcion,
                  child: GestureDetector(
                    onTap: habilitado ? () => onChanged('juridica') : null,
                    behavior: HitTestBehavior.opaque,
                    child: Center(
                      child: AnimatedDefaultTextStyle(
                        duration: _duracion,
                        curve: _curva,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: esJuridica
                              ? AppColors.textOnDark
                              : AppColors.textSecondary,
                          fontWeight: esJuridica
                              ? AppTextStyles.weightSemiBold
                              : AppTextStyles.weightRegular,
                        ),
                        child: const Text('Jurídica'),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: _anchoPorOpcion,
                  child: GestureDetector(
                    onTap: habilitado ? () => onChanged('natural') : null,
                    behavior: HitTestBehavior.opaque,
                    child: Center(
                      child: AnimatedDefaultTextStyle(
                        duration: _duracion,
                        curve: _curva,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: !esJuridica
                              ? AppColors.textOnDark
                              : AppColors.textSecondary,
                          fontWeight: !esJuridica
                              ? AppTextStyles.weightSemiBold
                              : AppTextStyles.weightRegular,
                        ),
                        child: const Text('Natural'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── SolicitudCampoCelular (prefijo de país + input) ───────────────────────────

class SolicitudCampoCelular extends StatelessWidget {
  final TextEditingController controller;
  final bool habilitado;

  const SolicitudCampoCelular({
    super.key,
    required this.controller,
    required this.habilitado,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            onTap: habilitado ? () {} : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              decoration: BoxDecoration(
                color: habilitado
                    ? AppColors.inputBackground
                    : AppColors.surfaceLightVariant,
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(AppSizing.radiusMd),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '🇵🇪',
                    style: TextStyle(fontSize: AppTextStyles.sizeMd),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    '+51',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: AppTextStyles.weightMedium,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xxs),
                  const Icon(
                    Icons.expand_more_rounded,
                    size: AppSizing.iconSm,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: CustomTextField(
              label: 'Celular *',
              controller: controller,
              keyboardType: TextInputType.phone,
              enabled: habilitado,
              maxLength: 9,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
          ),
        ],
      ),
    );
  }
}

// ── SolicitudBadgePaso (chip "Paso X de Y" del AppBar) ───────────────────────

class SolicitudBadgePaso extends StatelessWidget {
  final int paso;
  final int total;

  const SolicitudBadgePaso({super.key, required this.paso, this.total = 4});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.md),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: AppColors.white(0.15),
          borderRadius: BorderRadius.circular(AppSizing.radiusSm),
        ),
        child: Text(
          '$paso de $total',
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textOnDark,
            fontWeight: AppTextStyles.weightSemiBold,
          ),
        ),
      ),
    );
  }
}
