// lib/features/cobranza/presentation/widgets/cobranza_campos_contado.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/cobranza/index_cobranza.dart';

class CobranzaCamposContado extends StatefulWidget {
  final CobranzaFacturaState state;
  const CobranzaCamposContado({super.key, required this.state});

  @override
  State<CobranzaCamposContado> createState() => _CobranzaCamposContadoState();
}

class _CobranzaCamposContadoState extends State<CobranzaCamposContado> {
  late final TextEditingController _ocCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _hojaCtrl;

  static const _maxChars = 100;

  @override
  void initState() {
    super.initState();
    _ocCtrl = TextEditingController(text: widget.state.oc);
    _descCtrl = TextEditingController(text: widget.state.descripcion);
    _hojaCtrl = TextEditingController(text: widget.state.hojaAceptacion);
  }

  @override
  void dispose() {
    _ocCtrl.dispose();
    _descCtrl.dispose();
    _hojaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Card formulario ────────────────────────────────────
        _CardFormulario(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Condición de pago
              Text(
                'Condición de pago (*)',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              CustomComboField<CondicionItem>(
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
              const SizedBox(height: AppSpacing.md),

              // O/C
              _CampoConContador(
                label: 'O/C',
                hint: 'Ingresa el número de orden de compra (opcional)',
                controller: _ocCtrl,
                maxChars: _maxChars,
                onChanged: (v) =>
                    context.read<CobranzaFacturaBloc>().add(OcChanged(v)),
              ),
              const SizedBox(height: AppSpacing.md),

              // Descripción sugerida
              _CampoConContador(
                label: 'Descripción sugerida',
                hint: 'Ingresa una descripción para el documento',
                controller: _descCtrl,
                maxChars: _maxChars,
                onChanged: (v) => context
                    .read<CobranzaFacturaBloc>()
                    .add(DescripcionChanged(v)),
              ),
              const SizedBox(height: AppSpacing.md),

              // Hoja de aceptación
              _CampoConContador(
                label: 'Hoja de aceptación',
                hint: 'Ingresa observaciones o notas (opcional)',
                controller: _hojaCtrl,
                maxChars: _maxChars,
                onChanged: (v) => context
                    .read<CobranzaFacturaBloc>()
                    .add(HojaAceptacionChanged(v)),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // ── Sección documentos ─────────────────────────────────
        _CardFormulario(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Documentos',
                    style: AppTextStyles.titleSmall.copyWith(
                      fontWeight: AppTextStyles.weightSemiBold,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Icon(
                    AppIcons.help,
                    size: AppSizing.iconSm,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: _BtnDocumento(
                      icono: AppIcons.attach,
                      colorIcono: AppColors.primary,
                      titulo: 'Adjuntar voucher',
                      subtitulo: 'JPG, PNG o PDF',
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _BtnDocumento(
                      icono: AppIcons.fileFactura,
                      colorIcono: AppColors.success,
                      titulo: 'Adjuntar hoja',
                      subtitulo: 'PDF',
                      onTap: () {},
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _CardFormulario extends StatelessWidget {
  final Widget child;
  const _CardFormulario({required this.child});

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
      child: child,
    );
  }
}

class _CampoConContador extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final int maxChars;
  final void Function(String) onChanged;

  const _CampoConContador({
    required this.label,
    required this.hint,
    required this.controller,
    required this.maxChars,
    required this.onChanged,
  });

  @override
  State<_CampoConContador> createState() => _CampoConContadorState();
}

class _CampoConContadorState extends State<_CampoConContador> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        CustomTextField(
          label: '',
          hint: widget.hint,
          controller: widget.controller,
          maxLines: 3,
          maxLength: widget.maxChars,
          onChanged: (v) {
            setState(() {});
            widget.onChanged(v);
          },
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '${widget.controller.text.length}/${widget.maxChars}',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _BtnDocumento extends StatelessWidget {
  final IconData icono;
  final Color colorIcono;
  final String titulo;
  final String subtitulo;
  final VoidCallback onTap;

  const _BtnDocumento({
    required this.icono,
    required this.colorIcono,
    required this.titulo,
    required this.subtitulo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizing.radiusMd),
          border: Border.all(
            color: AppColors.border,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono, size: AppSizing.iconLg, color: colorIcono),
            const SizedBox(height: AppSpacing.xs),
            Text(
              titulo,
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.primary,
                fontWeight: AppTextStyles.weightSemiBold,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              subtitulo,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
