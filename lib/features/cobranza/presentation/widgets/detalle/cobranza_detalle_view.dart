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
    final tieneAccion = detalle.idEstado != 3; // 3 = Cancelado

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

class _BottomActionButton extends StatelessWidget {
  final CobranzaDetalle detalle;
  const _BottomActionButton({required this.detalle});

  @override
  Widget build(BuildContext context) {
    final config = _configBoton(detalle.idEstado);
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
          icon: Icon(config.icono, size: AppSizing.iconMd),
          label: Text(config.texto, style: AppTextStyles.button),
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizing.radiusMd),
            ),
          ),
        ),
      ),
    );
  }

  // ID_ESTADO_GES crudo: 0=Pend.deDocumento 2=Facturar 5=Pend.factura.
  _BotonConfig _configBoton(int idEstado) {
    switch (idEstado) {
      case 0:
        return _BotonConfig(
          texto: 'Continuar facturación',
          icono: AppIcons.receipt,
        );
      case 2:
        return _BotonConfig(
          texto: 'Marcar como facturado',
          icono: AppIcons.checkCircle,
        );
      case 5:
        return _BotonConfig(texto: 'Confirmar pago', icono: AppIcons.moneda);
      default:
        return _BotonConfig(texto: '', icono: AppIcons.check);
    }
  }
}

class _BotonConfig {
  final String texto;
  final IconData icono;
  const _BotonConfig({required this.texto, required this.icono});
}
