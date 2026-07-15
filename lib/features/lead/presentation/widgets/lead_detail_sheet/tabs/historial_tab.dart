// lib/features/lead/presentation/widgets/lead_detail_sheet/tabs/historial_tab.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';
import 'package:app_crm/features/lead/presentation/cubit/historial/historial_lead_cubit.dart';
import 'package:app_crm/features/lead/presentation/cubit/historial/historial_lead_state.dart';

class HistorialTab extends StatefulWidget {
  // Comentarios de todos los leads del número (SP 'LCG') — usado en Contacto.
  final int? idNumero;
  // Seguimiento de un lead puntual (SP 'LH') — usado en el chat.
  final int? idLead;

  const HistorialTab({super.key, this.idNumero, this.idLead})
    : assert(
        idNumero != null || idLead != null,
        'HistorialTab requiere idNumero o idLead',
      );

  @override
  State<HistorialTab> createState() => _HistorialTabState();
}

class _HistorialTabState extends State<HistorialTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  // null = Todos
  TipoActor? _filtro;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  void _cargar() {
    final cubit = context.read<HistorialLeadCubit>();
    final idLead = widget.idLead;
    if (idLead != null) {
      cubit.cargarHistorialSeguimiento(idLead);
    } else {
      cubit.cargarHistorial(widget.idNumero!);
    }
  }

  List<HistorialComentario> _aplicarFiltro(List<HistorialComentario> eventos) {
    if (_filtro == null) return eventos;
    // El filtro "Asesor" engloba tanto asesor como cliente (acción del contacto)
    if (_filtro == TipoActor.asesor) {
      return eventos
          .where((e) =>
              e.tipoActor == TipoActor.asesor ||
              e.tipoActor == TipoActor.cliente)
          .toList();
    }
    return eventos.where((e) => e.tipoActor == _filtro).toList();
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
            onRetry: _cargar,
          ),
          // Los chips de filtro siempre se muestran, incluso sin eventos —
          // solo lo de abajo cambia entre lista y estado vacío.
          HistorialLeadSuccess(:final eventos) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ChipsFilter(
                filtroSeleccionado: _filtro,
                onFiltroChanged: (f) => setState(() => _filtro = f),
              ),
              Expanded(
                child: eventos.isEmpty
                    ? const _EstadoVacio()
                    : _ListaHistorial(eventos: _aplicarFiltro(eventos)),
              ),
            ],
          ),
        };
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Chips de filtro
// ─────────────────────────────────────────────────────────────────────────────

class _ChipsFilter extends StatelessWidget {
  final TipoActor? filtroSeleccionado;
  final ValueChanged<TipoActor?> onFiltroChanged;

  const _ChipsFilter({
    required this.filtroSeleccionado,
    required this.onFiltroChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        spacing: AppSpacing.xs,
        children: [
          _Chip(
            label: 'Todos',
            color: AppColors.primary,
            seleccionado: filtroSeleccionado == null,
            onTap: () => onFiltroChanged(null),
          ),
          _Chip(
            label: 'Bot IA',
            color: AppColors.success,
            seleccionado: filtroSeleccionado == TipoActor.botIA,
            onTap: () => onFiltroChanged(TipoActor.botIA),
          ),
          _Chip(
            label: 'Asesor',
            color: AppColors.info,
            seleccionado: filtroSeleccionado == TipoActor.asesor,
            onTap: () => onFiltroChanged(TipoActor.asesor),
          ),
          _Chip(
            label: 'Sistema',
            color: AppColors.textSecondary,
            seleccionado: filtroSeleccionado == TipoActor.sistema,
            onTap: () => onFiltroChanged(TipoActor.sistema),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  final bool seleccionado;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.color,
    required this.seleccionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: seleccionado ? color : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppSizing.radiusCircular),
          border: Border.all(
            color: color.withValues(alpha: seleccionado ? 0 : 0.4),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: seleccionado ? AppColors.textOnDark : color,
            fontWeight: AppTextStyles.weightMedium,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Lista de eventos
// ─────────────────────────────────────────────────────────────────────────────

class _ListaHistorial extends StatelessWidget {
  final List<HistorialComentario> eventos;

  const _ListaHistorial({required this.eventos});

  @override
  Widget build(BuildContext context) {
    if (eventos.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Text(
            'Sin resultados para este filtro',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }
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
  final HistorialComentario item;

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
    TipoActor.asesor => AppColors.info,
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
              item.notas,
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
                item.fechaHora.formatConDia(),
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                item.actorLabel,
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
