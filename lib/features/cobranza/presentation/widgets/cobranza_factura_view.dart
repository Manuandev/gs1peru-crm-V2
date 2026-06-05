// lib/features/cobranza/presentation/widgets/cobranza_factura_view.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/cobranza/index_cobranza.dart';

class CobranzaFacturaView extends StatelessWidget {
  const CobranzaFacturaView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CobranzaFacturaBloc, CobranzaFacturaState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(
              state.esCredito ? 'Facturar crédito' : 'Facturar',
            ),
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
                      // ── 1. Header ──────────────────────────────
                      CobranzaFacturaHeader(state: state),
                      const SizedBox(height: AppSpacing.md),

                      // ── 2. Campos (animados al cambiar condición)
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 280),
                        transitionBuilder: (child, animation) =>
                            FadeTransition(opacity: animation, child: child),
                        child: state.esCredito
                            ? CobranzaCamposCredito(
                                key: const ValueKey('credito'),
                                state: state,
                              )
                            : CobranzaCamposContado(
                                key: const ValueKey('contado'),
                                state: state,
                              ),
                      ),
                      const SizedBox(height: AppSpacing.md),

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
