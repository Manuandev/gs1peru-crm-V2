// lib/features/lead/presentation/widgets/lead_detail_sheet/tabs/negociaciones_tab.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class NegociacionesTab extends StatefulWidget {
  final int leadId;
  final int idNumero;
  final VoidCallback? onCerrar;

  const NegociacionesTab({
    super.key,
    required this.leadId,
    required this.idNumero,
    this.onCerrar,
  });

  @override
  State<NegociacionesTab> createState() => _NegociacionesTabState();
}

class _NegociacionesTabState extends State<NegociacionesTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    context.read<NegociacionesCubit>().cargarNegociaciones(widget.leadId);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocBuilder<NegociacionesCubit, NegociacionesState>(
      builder: (context, state) {
        return switch (state) {
          NegociacionesInitial() ||
          NegociacionesLoading() => const AppLoadingView(),
          NegociacionesError(:final mensaje) => AppErrorView(
            message: mensaje,
            onRetry: () => context
                .read<NegociacionesCubit>()
                .cargarNegociaciones(widget.leadId),
          ),
          NegociacionesSuccess(:final negociaciones) => _ListaNegociaciones(
            negociaciones: negociaciones,
            leadId: widget.leadId,
            idNumero: widget.idNumero,
            onCerrar: widget.onCerrar,
          ),
        };
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Lista con header + cards + info banner
// ─────────────────────────────────────────────────────────────────────────────

enum _FiltroNeg { todas, activa, ganadas }

class _ListaNegociaciones extends StatefulWidget {
  final List<Negociacion> negociaciones;
  final int leadId;
  final int idNumero;
  final VoidCallback? onCerrar;

  const _ListaNegociaciones({
    required this.negociaciones,
    required this.leadId,
    required this.idNumero,
    this.onCerrar,
  });

  @override
  State<_ListaNegociaciones> createState() => _ListaNegociacionesState();
}

class _ListaNegociacionesState extends State<_ListaNegociaciones> {
  _FiltroNeg _filtro = _FiltroNeg.todas;

  @override
  Widget build(BuildContext context) {
    if (widget.negociaciones.isEmpty) {
      return const _EstadoVacio();
    }

    final visibles = widget.negociaciones;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.xxl,
      ),
      children: [
        // ── Chips de filtro ───────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Row(
            children: [
              const Spacer(),
              _FiltroChip(
                label: 'Todas',
                seleccionado: _filtro == _FiltroNeg.todas,
                onTap: () => setState(() => _filtro = _FiltroNeg.todas),
              ),
              const SizedBox(width: AppSpacing.xs),
              _FiltroChip(
                label: 'Activa',
                seleccionado: _filtro == _FiltroNeg.activa,
                onTap: () => setState(() => _filtro = _FiltroNeg.activa),
              ),
              const SizedBox(width: AppSpacing.xs),
              _FiltroChip(
                label: 'Ganadas',
                seleccionado: _filtro == _FiltroNeg.ganadas,
                onTap: () => setState(() => _filtro = _FiltroNeg.ganadas),
              ),
            ],
          ),
        ),

        // ── Cards ─────────────────────────────────────────────────────────────
        ...visibles.map(
          (negociacion) => NegociacionCard(
            negociacion: negociacion,
            leadId: widget.leadId,
            onGenerarSolicitud: () {},
            onEdited: () => context
                .read<NegociacionesCubit>()
                .cargarNegociaciones(widget.leadId),
          ),
        ),

        // ── Info banner ───────────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.info.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppSizing.radiusMd),
            border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                AppIcons.infoCircle,
                size: AppSizing.iconSm,
                color: AppColors.info,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  'La negociación seleccionada es la que se utiliza para actualizar el CRM y, en su caso, cerrar como ganada para generar una solicitud.',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
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
                AppIcons.negociacion,
                size: AppSizing.iconXl,
                color: AppColors.grey400,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Sin negociaciones',
              style: AppTextStyles.titleSmall.copyWith(
                fontWeight: AppTextStyles.weightSemiBold,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Este lead aún no tiene negociaciones registradas.',
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

// ─────────────────────────────────────────────────────────────────────────────
// Chip de filtro compacto
// ─────────────────────────────────────────────────────────────────────────────

class _FiltroChip extends StatelessWidget {
  final String label;
  final bool seleccionado;
  final VoidCallback onTap;

  const _FiltroChip({
    required this.label,
    required this.seleccionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xxs,
        ),
        decoration: BoxDecoration(
          color: seleccionado
              ? color.withValues(alpha: 0.08)
              : AppColors.transparent,
          borderRadius: BorderRadius.circular(AppSizing.radiusCircular),
          border: Border.all(
            color: seleccionado ? color : AppColors.border,
            width: AppSizing.hairline,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: seleccionado ? color : AppColors.textSecondary,
            fontWeight: seleccionado
                ? AppTextStyles.weightSemiBold
                : AppTextStyles.weightRegular,
          ),
        ),
      ),
    );
  }
}
