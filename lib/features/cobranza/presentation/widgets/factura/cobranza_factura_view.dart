// lib/features/cobranza/presentation/widgets/factura/cobranza_factura_view.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/features/cobranza/index_cobranza.dart';

/// StatefulWidget — necesario para los 3 controllers de los campos compartidos.
class CobranzaFacturaView extends StatefulWidget {
  const CobranzaFacturaView({super.key});

  @override
  State<CobranzaFacturaView> createState() => _CobranzaFacturaViewState();
}

class _CobranzaFacturaViewState extends State<CobranzaFacturaView> {
  final _formKey = GlobalKey<FormState>();
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

  void _onFacturarPressed() {
    // El Form valida O/C inline (rojo bajo el campo) — si falla, ni
    // siquiera se dispara el evento (nada de snackbar para esto).
    if (!_formKey.currentState!.validate()) return;
    context.read<CobranzaFacturaBloc>().add(const FacturarPressed());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CobranzaFacturaBloc, CobranzaFacturaState>(
      builder: (context, state) {
        return BasePage(
          drawerSide: DrawerSide.none,
          bodyPadding: EdgeInsets.zero,
          title: state.esCredito ? 'Facturar crédito' : 'Facturar',
          appBarLeadingButtons: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => context.goBack(),
            ),
          ],
          body: Stack(
            children: [
              Form(
                key: _formKey,
                child: Column(
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

                                // O/C — opcional
                                _CampoCompartido(
                                  label: 'O/C',
                                  hint: 'Ingresa el número de orden de compra',
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
                          ],
                        ),
                      ),
                    ),

                    // ── 4. Botones fijos ──────────────────────────────
                    _BotonesFactura(state: state, onFacturar: _onFacturarPressed),
                  ],
                ),
              ),
              // Mismo overlay de carga que EditLeadPortrait/TemplateFormView
              // (AppProcessOverlay, core/CLAUDE.md) — cubre las 2 llamadas
              // secuenciales de _onFacturarPressed en crédito (RC + UE; solo
              // UE en contado). Al terminar, CobranzaFacturaPage ya maneja el
              // snackbar + navegación (facturadoOk) o el error, así que acá
              // solo hace falta el paso "cargando" — no un check de éxito.
              if (state.status == CobranzaFacturaStatus.loading)
                AppProcessOverlay(
                  status: AppProcessStatus.cargando,
                  loadingMessage: state.esCredito
                      ? 'Guardando plan y facturando...'
                      : 'Facturando...',
                ),
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
          textInputAction: TextInputAction.done,
          onChanged: onChanged,
          onSubmitted: (_) => FocusScope.of(context).unfocus(),
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
  final VoidCallback onFacturar;
  const _BotonesFactura({required this.state, required this.onFacturar});

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
          // Cancelar
          Expanded(
            child: OutlinedButton(
              onPressed: () => context.goBack(),
              style: OutlinedButton.styleFrom(
                minimumSize: Size(double.infinity, AppSizing.buttonHeight),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizing.radiusMd),
                ),
              ),
              child: const Text('Cancelar'),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),

          // Facturar
          Expanded(
            child: FilledButton.icon(
              onPressed:
                  state.status == CobranzaFacturaStatus.loading ? null : onFacturar,
              icon: Icon(AppIcons.fileFactura, size: AppSizing.iconSm),
              label: const Text('Facturar'),
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
