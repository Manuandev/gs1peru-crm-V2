// lib/features/cobranza/presentation/widgets/cobranza_campos_extra.dart
//
// Contiene solo lo que CAMBIA según condición de pago:
//   esArriba: true  → crédito muestra [fecha + validar], contado muestra nada
//   esArriba: false → contado muestra [adjuntar archivo], crédito muestra nada

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/cobranza/index_cobranza.dart';

class CobranzaCamposExtra extends StatelessWidget {
  final bool esArriba;
  final CobranzaFacturaState state;

  const CobranzaCamposExtra({
    super.key,
    required this.esArriba,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      transitionBuilder: (child, animation) =>
          FadeTransition(opacity: animation, child: child),
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (esArriba) {
      return state.esCredito
          ? _ExtraCredito(key: const ValueKey('credito'), state: state)
          : const SizedBox.shrink(key: ValueKey('empty_arriba'));
    } else {
      return state.esCredito
          ? const SizedBox.shrink(key: ValueKey('empty_abajo'))
          : const _ExtraContado(key: ValueKey('contado'));
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Extra para CRÉDITO (aparece encima de los 3 campos)
// ─────────────────────────────────────────────────────────────────────────────

class _ExtraCredito extends StatefulWidget {
  final CobranzaFacturaState state;
  const _ExtraCredito({super.key, required this.state});

  @override
  State<_ExtraCredito> createState() => _ExtraCreditoState();
}

class _ExtraCreditoState extends State<_ExtraCredito> {
  late final TextEditingController _fechaCtrl;

  @override
  void initState() {
    super.initState();
    _fechaCtrl = TextEditingController(text: widget.state.fechaVencimiento);
  }

  @override
  void dispose() {
    _fechaCtrl.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha() async {
    final inicial = widget.state.fechaVencimiento.isNotEmpty
        ? DateFormatter.parseDate(widget.state.fechaVencimiento) ??
              DateTime.now().add(const Duration(days: 30))
        : DateTime.now().add(const Duration(days: 30));

    final fecha = await showDatePicker(
      context: context,
      initialDate: inicial,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      locale: const Locale('es', 'PE'),
    );

    if (fecha != null && mounted) {
      final formateada = fecha.format(AppDateFormat.shortDate);
      _fechaCtrl.text = formateada;
      if (mounted) {
        context.read<CobranzaFacturaBloc>().add(
          FechaVencimientoChanged(formateada),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Fecha de vencimiento ─────────────────────────────
        Text(
          'Fecha de vencimiento',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        // TextFormField(
        //   controller: _fechaCtrl,
        //   readOnly: true,
        //   onTap: _seleccionarFecha,
        //   decoration: InputDecoration(
        //     hintText: 'dd/mm/aaaa',
        //     hintStyle: AppTextStyles.bodyMedium.copyWith(
        //       color: AppColors.textDisabled,
        //     ),
        //     suffixIcon: IconButton(
        //       icon: Icon(
        //         AppIcons.calendar,
        //         size: AppSizing.iconSm,
        //         color: AppColors.primary,
        //       ),
        //       onPressed: _seleccionarFecha,
        //     ),
        //     contentPadding: const EdgeInsets.symmetric(
        //       horizontal: AppSpacing.sm,
        //       vertical: AppSpacing.xs,
        //     ),
        //     border: OutlineInputBorder(
        //       borderRadius: BorderRadius.circular(AppSizing.radiusMd),
        //       borderSide: const BorderSide(color: AppColors.border),
        //     ),
        //     enabledBorder: OutlineInputBorder(
        //       borderRadius: BorderRadius.circular(AppSizing.radiusMd),
        //       borderSide: const BorderSide(color: AppColors.border),
        //     ),
        //     focusedBorder: OutlineInputBorder(
        //       borderRadius: BorderRadius.circular(AppSizing.radiusMd),
        //       borderSide: BorderSide(
        //         color: AppColors.primary,
        //         width: AppSizing.borderWidthThin * 2,
        //       ),
        //     ),
        //   ),
        //   style: AppTextStyles.bodyMedium,
        // ),
        CustomTextField(
          controller: _fechaCtrl,
          readOnly: true,
          onTap: _seleccionarFecha,
          suffixIcon: IconButton(
            icon: Icon(
              AppIcons.calendar,
              size: AppSizing.iconSm,
              color: AppColors.primary,
            ),
            onPressed: _seleccionarFecha,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        // ── Botón validar plan ───────────────────────────────
        CustomPrimaryButton(
          text: 'Validar plan de crédito',
          icon: Icon(
            AppIcons.escudo,
            size: AppSizing.iconMd,
            color: AppColors.textOnDark,
          ),
          isEnabled: widget.state.fechaVencimiento.isNotEmpty,
          onPressed: () => context.read<CobranzaFacturaBloc>().add(
            const PlanValidarPressed(),
          ),
        ),

        if (widget.state.planValidado) ...[
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Icon(
                AppIcons.checkCircle,
                size: AppSizing.iconSm,
                color: AppColors.success,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Plan de crédito validado',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.success,
                  fontWeight: AppTextStyles.weightSemiBold,
                ),
              ),
            ],
          ),
        ],

        const SizedBox(height: AppSpacing.sm),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Extra para CONTADO (aparece debajo de los 3 campos)
// ─────────────────────────────────────────────────────────────────────────────

class _ExtraContado extends StatelessWidget {
  const _ExtraContado({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: GestureDetector(
        onTap: () {},
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.md,
            horizontal: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizing.radiusMd),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                AppIcons.attach,
                size: AppSizing.iconLg,
                color: AppColors.primary,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Adjuntar archivo',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: AppTextStyles.weightSemiBold,
                ),
              ),
              Text(
                'JPG, PNG o PDF',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
