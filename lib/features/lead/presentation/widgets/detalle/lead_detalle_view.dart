// lib/features/lead/presentation/widgets/detalle/lead_detalle_view.dart

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
          return Scaffold(
            appBar: AppBar(title: const Text('Prospecto')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        if (state is LeadDetalleError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: AppErrorView(message: state.mensaje, onRetry: () {}),
          );
        }
        if (state is LeadDetalleSuccess) {
          return _DetalleScaffold(
            detalle: state.detalle,
            comentarios: state.comentarios,
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _DetalleScaffold extends StatelessWidget {
  final LeadDetalleCompleto detalle;
  final List<ComentarioLead> comentarios;

  const _DetalleScaffold({required this.detalle, required this.comentarios});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(detalle.nombreCompleto),
        actions: [
          IconButton(
            icon: Icon(AppIcons.phone, color: AppColors.textOnDark),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(AppIcons.more, color: AppColors.textOnDark),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LeadDetalleStepper(idEstadoActual: detalle.idEstado),
            _UltimaInteraccion(fechaHora: detalle.fechaUltimaInteraccion),
            LeadDetalleInfoCard(detalle: detalle),
            const SizedBox(height: AppSpacing.md),
            LeadDetalleComentarios(comentarios: comentarios),
          ],
        ),
      ),
      bottomNavigationBar: const LeadDetalleActions(),
    );
  }
}

class _UltimaInteraccion extends StatelessWidget {
  final String fechaHora;
  const _UltimaInteraccion({required this.fechaHora});

  @override
  Widget build(BuildContext context) {
    final fecha = DateFormatter.parseDate(fechaHora);
    final elapsed =
        fecha != null ? DateTime.now().difference(fecha) : Duration.zero;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Text(
        'Última interacción: ${fechaHora.formatConDia()} '
        '(hace ${ElapsedTimeUtils.formatHoMoS(elapsed)})',
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
        textAlign: TextAlign.center,
      ),
    );
  }
}
