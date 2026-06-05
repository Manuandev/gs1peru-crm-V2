// lib/features/cobranza/presentation/widgets/cobranza_factura_view.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/cobranza/index_cobranza.dart';

/// StatefulWidget — necesario para los 3 controllers de los campos compartidos.
class CobranzaFacturaView extends StatefulWidget {
  const CobranzaFacturaView({super.key});

  @override
  State<CobranzaFacturaView> createState() => _CobranzaFacturaViewState();
}

class _CobranzaFacturaViewState extends State<CobranzaFacturaView> {
  late final TextEditingController _ocCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _hojaCtrl;

  static const _maxChars = 100;

  @override
  void initState() {
    super.initState();
    final state = context.read<CobranzaFacturaBloc>().state;
    _ocCtrl = TextEditingController(text: state.oc);
    _descCtrl = TextEditingController(text: state.descripcion);
    _hojaCtrl = TextEditingController(text: state.hojaAceptacion);
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
    return BlocBuilder<CobranzaFacturaBloc, CobranzaFacturaState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(state.esCredito ? 'Facturar crédito' : 'Facturar'),
            leading: IconButton(
              icon: Icon(AppIcons.back, color: AppColors.textOnDark),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── 1. Header fijo ─────────────────────────
                      CobranzaFacturaHeader(state: state),
                      const SizedBox(height: AppSpacing.sm),

                      // ── 2. Card de formulario ──────────────────
                      _FormCard(
                        children: [
                          // Combo condición de pago
                          CustomComboField<CondicionItem>(
                            label: 'Condición de pago',
                            data: condicionesDisponibles,
                            idIndex: 0,
                            labelIndex: 1,
                            initialValue: state.idCondicion,
                            onChanged: (item) {
                              if (item != null) {
                                context.read<CobranzaFacturaBloc>().add(
                                      CondicionChanged(
                                        item.fields[0],
                                        item.fields[1],
                                      ),
                                    );
                              }
                            },
                          ),
                          const SizedBox(height: AppSpacing.sm),

                          // Extra ARRIBA — solo crédito muestra fecha+validar
                          CobranzaCamposExtra(esArriba: true, state: state),

                          // O/C — siempre
                          _CampoCompartido(
                            label: 'O/C',
                            hint: 'Ingresa el número de orden de compra (opcional)',
                            controller: _ocCtrl,
                            maxChars: _maxChars,
                            onChanged: (v) => context
                                .read<CobranzaFacturaBloc>()
                                .add(OcChanged(v)),
                          ),
                          const SizedBox(height: AppSpacing.sm),

                          // Descripción — siempre
                          _CampoCompartido(
                            label: 'Descripción sugerida',
                            hint: 'Ingresa una descripción para el documento',
                            controller: _descCtrl,
                            maxChars: _maxChars,
                            onChanged: (v) => context
                                .read<CobranzaFacturaBloc>()
                                .add(DescripcionChanged(v)),
                          ),
                          const SizedBox(height: AppSpacing.sm),

                          // Hoja de aceptación — siempre
                          _CampoCompartido(
                            label: 'Hoja de aceptación',
                            hint: 'Ingresa observaciones o notas (opcional)',
                            controller: _hojaCtrl,
                            maxChars: _maxChars,
                            onChanged: (v) => context
                                .read<CobranzaFacturaBloc>()
                                .add(HojaAceptacionChanged(v)),
                          ),

                          // Extra ABAJO — solo contado muestra adjuntar
                          CobranzaCamposExtra(esArriba: false, state: state),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      // ── 3. Resumen + aviso ─────────────────────
                      CobranzaResumenCard(state: state),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                  ),
                ),
              ),

              // ── 4. Botones fijos ──────────────────────────────
              _BotonesFactura(state: state),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Card contenedor del formulario
// ─────────────────────────────────────────────────────────────────────────────

class _FormCard extends StatelessWidget {
  final List<Widget> children;
  const _FormCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
        children: children,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Campo multiline compartido (O/C, descripción, hoja)
// ─────────────────────────────────────────────────────────────────────────────

class _CampoCompartido extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final int maxChars;
  final void Function(String) onChanged;

  const _CampoCompartido({
    required this.label,
    required this.hint,
    required this.controller,
    required this.maxChars,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        CustomTextField(
          label: '',
          hint: hint,
          controller: controller,
          minLines: 1,
          maxLines: 3,
          maxLength: maxChars,
          onChanged: onChanged,
        ),
        // Contador de caracteres
        Align(
          alignment: Alignment.centerRight,
          child: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (_, value, __) => Text(
              '${value.text.length}/$maxChars',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Botones fijos en la parte inferior
// ─────────────────────────────────────────────────────────────────────────────

class _BotonesFactura extends StatelessWidget {
  final CobranzaFacturaState state;
  const _BotonesFactura({required this.state});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.md + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          // Guardar borrador
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => context
                  .read<CobranzaFacturaBloc>()
                  .add(const GuardarBorradorPressed()),
              icon: Icon(AppIcons.save, size: AppSizing.iconSm),
              label: const Text('Guardar borrador'),
              style: OutlinedButton.styleFrom(
                minimumSize: Size(double.infinity, AppSizing.buttonHeight),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizing.radiusMd),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),

          // Continuar / Facturar ahora
          Expanded(
            child: FilledButton.icon(
              onPressed: () => context
                  .read<CobranzaFacturaBloc>()
                  .add(const FacturarPressed()),
              icon: Icon(
                state.esCredito ? AppIcons.forward : AppIcons.fileFactura,
                size: AppSizing.iconSm,
              ),
              label: Text(state.esCredito ? 'Continuar' : 'Facturar ahora'),
              style: FilledButton.styleFrom(
                minimumSize: Size(double.infinity, AppSizing.buttonHeight),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizing.radiusMd),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
