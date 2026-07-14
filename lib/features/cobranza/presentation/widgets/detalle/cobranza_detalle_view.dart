// lib/features/cobranza/presentation/widgets/detalle/cobranza_detalle_view.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/cobranza/index_cobranza.dart';

class CobranzaDetalleView extends StatelessWidget {
  final String idCobranza;
  const CobranzaDetalleView({super.key, required this.idCobranza});

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Detalle de cobro',
      drawerSide: DrawerSide.none,
      bodyPadding: EdgeInsets.zero,
      appBarLeadingButtons: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.goBack(),
        ),
      ],

      body: BlocBuilder<CobranzaDetalleBloc, CobranzaDetalleState>(
        builder: (context, state) {
          if (state is CobranzaDetalleLoading ||
              state is CobranzaDetalleInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CobranzaDetalleError) {
            return AppErrorView(
              message: state.mensaje,
              onRetry: () => context.read<CobranzaDetalleBloc>().add(
                CobranzaDetalleStarted(idCobranza),
              ),
            );
          }

          if (state is CobranzaDetalleSuccess) {
            return _CobranzaDetalleBody(detalle: state.detalle);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _CobranzaDetalleBody extends StatelessWidget {
  final CobranzaDetalle detalle;
  const _CobranzaDetalleBody({required this.detalle});

  @override
  Widget build(BuildContext context) {
    // Solo se puede facturar cuando está en Pend. de documento (0) — el UE
    // real solo hace algo con estado='2' (Facturar); para cualquier otro
    // estado actual no hay una acción de backend definida todavía.
    final tieneAccion = detalle.idEstado == 0;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CobranzaDetalleInfoCard(detalle: detalle),
                const SizedBox(height: AppSpacing.md),
                CobranzaDetalleStepper(idEstadoActual: detalle.idEstado),
                const SizedBox(height: AppSpacing.md),
                CobranzaDetalleAcciones(detalle: detalle),
                const SizedBox(height: AppSpacing.md),
                CobranzaDetalleDatosClave(detalle: detalle),
                const SizedBox(height: AppSpacing.md),
                CobranzaDetalleHistorial(historial: detalle.historial),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
        if (tieneAccion) _BottomActionButton(detalle: detalle),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Botón de acción contextual fijo en la parte inferior
// ─────────────────────────────────────────────────────────────────────────────

// Solo se renderiza cuando detalle.idEstado == 0 (Pend. de documento) — ver
// _CobranzaDetalleBody.tieneAccion. Los demás estados no tienen una acción
// de backend definida todavía (el UE real solo hace algo con estado='2').
class _BottomActionButton extends StatelessWidget {
  final CobranzaDetalle detalle;
  const _BottomActionButton({required this.detalle});

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
      child: SizedBox(
        width: double.infinity,
        height: AppSizing.buttonHeight,
        child: FilledButton.icon(
          onPressed: () => context.goToFacturarCobranza(
            idCobranza: detalle.idCobranza,
            nombre: detalle.nombreCompleto,
            oportunidad: detalle.oportunidad,
            montoTotal: detalle.montoTotal,
            moneda: detalle.moneda,
            idCondicion: detalle.idCondicion,
            condicion: detalle.condicion,
          ),
          icon: Icon(AppIcons.receipt, size: AppSizing.iconMd),
          label: Text('Continuar facturación', style: AppTextStyles.button),
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizing.radiusMd),
            ),
          ),
        ),
      ),
    );
  }
}
