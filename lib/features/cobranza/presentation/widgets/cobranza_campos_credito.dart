// lib/features/cobranza/presentation/widgets/cobranza_campos_credito.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/cobranza/index_cobranza.dart';

class CobranzaCamposCredito extends StatefulWidget {
  final CobranzaFacturaState state;
  const CobranzaCamposCredito({super.key, required this.state});

  @override
  State<CobranzaCamposCredito> createState() => _CobranzaCamposCreditoState();
}

class _CobranzaCamposCreditoState extends State<CobranzaCamposCredito> {
  late final TextEditingController _ocCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _hojaCtrl;
  late final TextEditingController _fechaCtrl;

  static const _maxChars = 100;

  @override
  void initState() {
    super.initState();
    _ocCtrl = TextEditingController(text: widget.state.oc);
    _descCtrl = TextEditingController(text: widget.state.descripcion);
    _hojaCtrl = TextEditingController(text: widget.state.hojaAceptacion);
    _fechaCtrl = TextEditingController(text: widget.state.fechaVencimiento);
  }

  @override
  void dispose() {
    _ocCtrl.dispose();
    _descCtrl.dispose();
    _hojaCtrl.dispose();
    _fechaCtrl.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha() async {
    final inicial = DateTime.tryParse(
          widget.state.fechaVencimiento.split('/').reversed.join('-'),
        ) ??
        DateTime.now().add(const Duration(days: 30));

    final fecha = await showDatePicker(
      context: context,
      initialDate: inicial,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (fecha != null && mounted) {
      final formateada =
          '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
      _fechaCtrl.text = formateada;
      context
          .read<CobranzaFacturaBloc>()
          .add(FechaVencimientoChanged(formateada));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
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
          // ── Condición de pago ──────────────────────────────
          _FilaFormulario(
            label: 'Condición de pago',
            child: CustomComboField<CondicionItem>(
              label: '',
              data: condicionesDisponibles,
              idIndex: 0,
              labelIndex: 1,
              initialValue: widget.state.idCondicion,
              onChanged: (item) {
                if (item != null) {
                  context.read<CobranzaFacturaBloc>().add(
                        CondicionChanged(item.fields[0], item.fields[1]),
                      );
                }
              },
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // ── Fecha de vencimiento ───────────────────────────
          _FilaFormulario(
            label: 'Fecha de vencimiento',
            child: TextFormField(
              controller: _fechaCtrl,
              readOnly: true,
              onTap: _seleccionarFecha,
              decoration: InputDecoration(
                hintText: 'DD/MM/AAAA',
                hintStyle: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textDisabled,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    AppIcons.calendar,
                    size: AppSizing.iconMd,
                    color: AppColors.primary,
                  ),
                  onPressed: _seleccionarFecha,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizing.radiusMd),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizing.radiusMd),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizing.radiusMd),
                  borderSide: BorderSide(
                    color: AppColors.primary,
                    width: AppSizing.borderWidthThin * 2,
                  ),
                ),
              ),
              style: AppTextStyles.bodySmall,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // ── Botón validar plan de crédito ──────────────────
          CustomPrimaryButton(
            text: 'Validar plan de crédito',
            icon: Icon(
              AppIcons.escudo,
              size: AppSizing.iconSm,
              color: AppColors.textOnDark,
            ),
            isEnabled: widget.state.fechaVencimiento.isNotEmpty,
            onPressed: () => context
                .read<CobranzaFacturaBloc>()
                .add(const PlanValidarPressed()),
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

          const SizedBox(height: AppSpacing.md),

          // ── O/C ────────────────────────────────────────────
          _FilaFormulario(
            label: 'O/C',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextField(
                  label: '',
                  hint: 'Ingresa la orden de compra (opcional)',
                  controller: _ocCtrl,
                  maxLength: _maxChars,
                  onChanged: (v) => context
                      .read<CobranzaFacturaBloc>()
                      .add(OcChanged(v)),
                ),
                Text(
                  '${_maxChars - _ocCtrl.text.length} caracteres restantes',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // ── Descripción sugerida ───────────────────────────
          _FilaFormulario(
            label: 'Descripción sugerida',
            child: CustomTextField(
              label: '',
              hint: 'Ingresa una descripción (opcional)',
              controller: _descCtrl,
              maxLength: _maxChars,
              onChanged: (v) => context
                  .read<CobranzaFacturaBloc>()
                  .add(DescripcionChanged(v)),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // ── Hoja de aceptación ─────────────────────────────
          _FilaFormulario(
            label: 'Hoja de aceptación',
            child: CustomTextField(
              label: '',
              hint: 'Ingresa la hoja de aceptación (opcional)',
              controller: _hojaCtrl,
              maxLength: _maxChars,
              onChanged: (v) => context
                  .read<CobranzaFacturaBloc>()
                  .add(HojaAceptacionChanged(v)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Fila de formulario 2 columnas: label izquierda + widget derecha
// ─────────────────────────────────────────────────────────────────────────────

class _FilaFormulario extends StatelessWidget {
  final String label;
  final Widget child;
  const _FilaFormulario({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: AppSpacing.xl * 4,
          child: Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: child),
      ],
    );
  }
}
