// lib/features/lead/presentation/widgets/detalle/lead_detalle_view.dart

import 'package:app_crm/config/index_config.dart';
import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class LeadDetalleView extends StatelessWidget {
  final int idLead;
  const LeadDetalleView({super.key, required this.idLead});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LeadDetalleBloc, LeadDetalleState>(
      builder: (context, state) {
        if (state is LeadDetalleInitial || state is LeadDetalleLoading) {
          return const LeadDetalleSkeleton();
        }
        if (state is LeadDetalleError) {
          return AppErrorView(
            message: state.message,
            onRetry: () =>
                context.read<LeadDetalleBloc>().add(LeadDetalleStarted(idLead)),
          );
        }
        if (state is LeadDetalleLoaded) {
          return _DetalleScaffold(
            detalle: state.detalle,
            comentarios: state.comentarios,
            idLead: idLead,
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Scaffold real — datos cargados
// ─────────────────────────────────────────────────────────────────────────────

class _DetalleScaffold extends StatelessWidget {
  final LeadDetalle detalle;
  final List<ComentarioLead> comentarios;
  final int idLead;

  const _DetalleScaffold({
    required this.detalle,
    required this.comentarios,
    required this.idLead,
  });

  @override
  Widget build(BuildContext context) {
    final lead = detalle.lead;

    return BasePage(
      bodyPadding: EdgeInsets.zero,
      titleWidget: _AppBarTitulo(nombre: lead.nombreCompleto),
      drawerSide: DrawerSide.none,
      footer: LeadDetalleActions(
        onEditar: () async {
          final infoState = context.read<InfoLeadCubit>().state;
          if (infoState is! InfoLeadSuccess) return;
          await context.goToEditarLead(
            lead: infoState.infoLead,
            cubit: context.read<InfoLeadCubit>(),
          );
          if (context.mounted) {
            context.read<LeadDetalleBloc>().add(LeadDetalleRefresh(idLead));
          }
        },
      ),
      appBarLeadingButtons: [
        IconButton(
          icon: const Icon(AppIcons.backIos),
          onPressed: () => context.goBack(),
        ),
      ],
      appBarTrailingButtons: [
        IconButton(
          icon: Icon(AppIcons.phone, color: AppColors.textOnDark),
          onPressed: lead.numero.isEmpty
              ? null
              : () => LauncherUtils.abrirTelefono(
                  '${lead.prefijo}${lead.numero}'.limpiarTelefono,
                ),
        ),
      ],
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LeadDetalleStepper(idEstadoActual: lead.idEstado),
            _UltimaInteraccion(fechaHora: lead.fechaHora),
            LeadContactoCard(lead: lead),
            const SizedBox(height: AppSpacing.sm),
            LeadContextoCard(lead: lead),
            const SizedBox(height: AppSpacing.md),
            LeadDetalleComentarios(comentarios: comentarios),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widgets del AppBar
// ─────────────────────────────────────────────────────────────────────────────

// Etiqueta "LEAD" en verde + nombre bold en blanco.
// AppColors.success (#4CAF50) es el verde más cercano al de la imagen de referencia.
class _AppBarTitulo extends StatelessWidget {
  final String nombre;
  const _AppBarTitulo({required this.nombre});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'LEAD',
          style: AppTextStyles.labelSmall.copyWith(color: AppColors.success),
        ),
        Text(
          nombre,
          style: AppTextStyles.titleSmall.copyWith(
            color: AppColors.textOnDark,
            fontWeight: AppTextStyles.weightBold,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widgets de cuerpo — reales
// ─────────────────────────────────────────────────────────────────────────────

// Línea de última interacción con ícono de reloj.
// Formato: "Última interacción Hoy 09:44 · hace 3 m"
class _UltimaInteraccion extends StatelessWidget {
  final String fechaHora;
  const _UltimaInteraccion({required this.fechaHora});

  @override
  Widget build(BuildContext context) {
    final fecha = DateFormatter.parseDate(fechaHora);
    final elapsed = fecha != null
        ? DateTime.now().difference(fecha)
        : Duration.zero;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              AppIcons.time,
              size: AppSizing.iconSm,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              'Última interacción ${fechaHora.formatConDia()} · hace ${ElapsedTimeUtils.formatHoMoS(elapsed)}',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
