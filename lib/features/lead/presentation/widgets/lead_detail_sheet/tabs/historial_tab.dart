// lib/features/lead/presentation/widgets/lead_detail_sheet/tabs/historial_tab.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/presentation/cubit/historial/historial_lead_cubit.dart';
import 'package:app_crm/features/lead/presentation/cubit/historial/historial_lead_state.dart';

class HistorialTab extends StatefulWidget {
  final int leadId;

  const HistorialTab({super.key, required this.leadId});

  @override
  State<HistorialTab> createState() => _HistorialTabState();
}

class _HistorialTabState extends State<HistorialTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    context.read<HistorialLeadCubit>().cargarHistorial(widget.leadId);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocBuilder<HistorialLeadCubit, HistorialLeadState>(
      builder: (context, state) {
        return switch (state) {
          HistorialLeadInitial() || HistorialLeadLoading() =>
            const AppLoadingView(),
          HistorialLeadError(:final mensaje) => AppErrorView(
            message: mensaje,
            onRetry: () => context
                .read<HistorialLeadCubit>()
                .cargarHistorial(widget.leadId),
          ),
          HistorialLeadSuccess(:final eventos) =>
            eventos.isEmpty
                ? const _EstadoVacio()
                : _ListaHistorial(eventos: eventos),
        };
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Lista de eventos
// ─────────────────────────────────────────────────────────────────────────────

class _ListaHistorial extends StatelessWidget {
  final List<HistorialItemFake> eventos;

  const _ListaHistorial({required this.eventos});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      itemCount: eventos.length,
      separatorBuilder: (_, _) => const Divider(height: AppSizing.hairline),
      itemBuilder: (_, index) => _HistorialItem(item: eventos[index]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Item individual del historial
// ─────────────────────────────────────────────────────────────────────────────

class _HistorialItem extends StatelessWidget {
  final HistorialItemFake item;

  const _HistorialItem({required this.item});

  static IconData _iconActor(TipoActor tipo) => switch (tipo) {
    TipoActor.sistema => AppIcons.settings,
    TipoActor.botIA => AppIcons.ia,
    TipoActor.cliente => AppIcons.user,
    TipoActor.asesor => AppIcons.user,
  };

  static Color _colorActor(TipoActor tipo) => switch (tipo) {
    TipoActor.sistema => AppColors.textSecondary,
    TipoActor.botIA => AppColors.success,
    TipoActor.cliente => AppColors.info,
    TipoActor.asesor => AppColors.warning,
  };

  @override
  Widget build(BuildContext context) {
    final colorActor = _colorActor(item.tipoActor);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Ícono circular del actor ─────────────────────────────────────
          Container(
            width: AppSizing.actorCircleSize,
            height: AppSizing.actorCircleSize,
            decoration: BoxDecoration(
              color: colorActor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(
                color: colorActor.withValues(alpha: 0.35),
                width: AppSizing.actorCircleBorder,
              ),
            ),
            child: Icon(
              _iconActor(item.tipoActor),
              size: AppSizing.iconSm,
              color: colorActor,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),

          // ── Descripción ─────────────────────────────────────────────────
          Expanded(
            child: Text(
              item.descripcion,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),

          // ── Fecha + Actor ────────────────────────────────────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item.fechaHora,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                item.actor,
                style: AppTextStyles.labelSmall.copyWith(
                  color: colorActor,
                  fontWeight: AppTextStyles.weightMedium,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Estado vacío
// ─────────────────────────────────────────────────────────────────────────────

class _EstadoVacio extends StatelessWidget {
  const _EstadoVacio();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: AppSizing.iconXxl,
              height: AppSizing.iconXxl,
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(AppSizing.radiusXl),
              ),
              child: const Icon(
                AppIcons.historial,
                size: AppSizing.iconXl,
                color: AppColors.grey400,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Sin historial',
              style: AppTextStyles.titleSmall.copyWith(
                fontWeight: AppTextStyles.weightSemiBold,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'No hay eventos registrados para este lead.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
