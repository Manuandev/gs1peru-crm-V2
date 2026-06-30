// lib/features/home/presentation/widgets/notifications/notifications_portrait.dart

import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/home/index_home.dart';

enum _Filtro { todas, actividades, derivaciones, mensajes }

class NotificationsPortrait extends StatefulWidget {
  final NotificationsLoaded state;
  const NotificationsPortrait({super.key, required this.state});

  @override
  State<NotificationsPortrait> createState() => _NotificationsPortraitState();
}

class _NotificationsPortraitState extends State<NotificationsPortrait> {
  _Filtro _filtro = _Filtro.todas;

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final empty =
        state.leadsReasignados.isEmpty &&
        state.leadsNuevos.isEmpty &&
        state.recordatorios.isEmpty;

    return Column(
      children: [
        // ── Filtros — fijos, no scrollean ─────────────────────────────────
        _BarraFiltros(
          filtro: _filtro,
          totTodas: state.totNotificaciones,
          totActividades: state.totLeadsNuevos,
          totDerivaciones: state.totLeadsReasignados,
          totMensajes: state.totRecordatorios,
          onCambio: (f) => setState(() => _filtro = f),
        ),
        // ── Contenido scrolleable ──────────────────────────────────────────
        Expanded(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.xs),
                _TarjetaContadores(state: state),
                const SizedBox(height: AppSpacing.sm),
                if (empty)
                  const _EmptyNotifications()
                else ...[
                  if (_filtro == _Filtro.todas ||
                      _filtro == _Filtro.actividades)
                    CollapsibleSection(
                      icon: AppIcons.leadNuevo,
                      label: 'Leads Nuevos',
                      count: state.totLeadsNuevos,
                      children: state.leadsNuevos
                          .map((e) => LeadNuevoTile(lead: e))
                          .toList(),
                    ),
                  if (_filtro == _Filtro.todas ||
                      _filtro == _Filtro.derivaciones)
                    CollapsibleSection(
                      icon: AppIcons.reasignar,
                      label: 'Leads Reasignados',
                      count: state.totLeadsReasignados,
                      children: state.leadsReasignados
                          .map((e) => LeadReasignadoTile(lead: e))
                          .toList(),
                    ),
                  if (_filtro == _Filtro.todas || _filtro == _Filtro.mensajes)
                    CollapsibleSection(
                      icon: AppIcons.notificationActive,
                      label: 'Recordatorios',
                      count: state.totRecordatorios,
                      children: state.recordatorios
                          .map((e) => RecordatorioTile(recordatorio: e))
                          .toList(),
                    ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Barra de filtros (sticky) ─────────────────────────────────────────────────

class _BarraFiltros extends StatelessWidget {
  final _Filtro filtro;
  final int totTodas;
  final int totActividades;
  final int totDerivaciones;
  final int totMensajes;
  final ValueChanged<_Filtro> onCambio;

  const _BarraFiltros({
    required this.filtro,
    required this.totTodas,
    required this.totActividades,
    required this.totDerivaciones,
    required this.totMensajes,
    required this.onCambio,
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
        children: [
          _FiltroChip(
            label: 'Todas',
            count: totTodas,
            seleccionado: filtro == _Filtro.todas,
            colorBadge: AppColors.info,
            onTap: () => onCambio(_Filtro.todas),
          ),
          const SizedBox(width: AppSpacing.sm),
          _FiltroChip(
            label: 'Actividades',
            count: totActividades,
            seleccionado: filtro == _Filtro.actividades,
            colorBadge: AppColors.warning,
            onTap: () => onCambio(_Filtro.actividades),
          ),
          const SizedBox(width: AppSpacing.sm),
          _FiltroChip(
            label: 'Derivaciones bot',
            count: totDerivaciones,
            seleccionado: filtro == _Filtro.derivaciones,
            colorBadge: AppColors.brandLavenderAccessible,
            onTap: () => onCambio(_Filtro.derivaciones),
          ),
          const SizedBox(width: AppSpacing.sm),
          _FiltroChip(
            label: 'Mensajes',
            count: totMensajes,
            seleccionado: filtro == _Filtro.mensajes,
            colorBadge: AppColors.info,
            onTap: () => onCambio(_Filtro.mensajes),
          ),
        ],
      ),
    );
  }
}

class _FiltroChip extends StatelessWidget {
  final String label;
  final int count;
  final bool seleccionado;
  final Color colorBadge;
  final VoidCallback onTap;

  const _FiltroChip({
    required this.label,
    required this.count,
    required this.seleccionado,
    required this.colorBadge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    const colorSeleccionado = AppColors.brandSlateAccessible;
    final bgColor = seleccionado ? colorSeleccionado : colorScheme.surface;
    final borderColor = seleccionado ? colorSeleccionado : colorScheme.outline;
    final textColor = seleccionado
        ? AppColors.textOnDark
        : colorScheme.onSurface;
    // No seleccionado: círculo sólido con texto blanco
    // Seleccionado: círculo blanco con texto del color del chip
    final badgeBg = seleccionado ? AppColors.textOnDark : colorBadge;
    final badgeTextColor = seleccionado
        ? colorSeleccionado
        : AppColors.textOnDark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppSizing.radiusCircular),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTextStyles.labelLarge.copyWith(
                color: textColor,
                fontWeight: AppTextStyles.weightRegular,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xs,
                vertical: AppSpacing.xxs,
              ),
              decoration: BoxDecoration(
                color: badgeBg,
                borderRadius: BorderRadius.circular(AppSizing.radiusCircular),
              ),
              child: Text(
                '$count',
                style: AppTextStyles.labelSmall.copyWith(
                  color: badgeTextColor,
                  fontWeight: AppTextStyles.weightBold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tarjeta única de contadores ───────────────────────────────────────────────

class _TarjetaContadores extends StatelessWidget {
  final NotificationsLoaded state;
  const _TarjetaContadores({required this.state});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm2),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(AppSizing.radiusMd),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: _ContadorItem(
                icono: AppIcons.calendar,
                colorIcono: AppColors.warning,
                titulo: 'Pendientes hoy',
                valor: state.totLeadsNuevos,
              ),
            ),
            Container(width: 1, height: 48, color: AppColors.border),
            Expanded(
              child: _ContadorItem(
                icono: AppIcons.ia,
                colorIcono: AppColors.brandLavenderAccessible,
                titulo: 'Derivaciones',
                valor: state.totLeadsReasignados,
              ),
            ),
            Container(width: 1, height: 48, color: AppColors.border),
            Expanded(
              child: _ContadorItem(
                icono: AppIcons.chatDots,
                colorIcono: AppColors.brandSlateAccessible,
                titulo: 'Mensajes sin leer',
                valor: state.totRecordatorios,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContadorItem extends StatelessWidget {
  final IconData icono;
  final Color colorIcono;
  final String titulo;
  final int valor;

  const _ContadorItem({
    required this.icono,
    required this.colorIcono,
    required this.titulo,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: colorIcono.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icono, size: AppSizing.iconActionSm, color: colorIcono),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  titulo,
                  style: AppTextStyles.labelExtraSmall.copyWith(
                    color: colorScheme.onSurface.withValues(
                      alpha: AppColors.opacityEmptyText,
                    ),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '$valor',
                  style: AppTextStyles.titleSmall.copyWith(
                    fontWeight: AppTextStyles.weightBold,
                    color: colorIcono,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Estado vacío ──────────────────────────────────────────────────────────────

class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.emptyStateTop),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            AppIcons.notificationOff,
            size: AppSizing.iconXl,
            color: colorScheme.onSurface.withValues(
              alpha: AppColors.opacityDivider,
            ),
          ),
          const SizedBox(height: AppSpacing.sm2),
          Text(
            'No tienes notificaciones',
            style: AppTextStyles.bodyMedium.copyWith(
              color: colorScheme.onSurface.withValues(
                alpha: AppColors.opacityEmptyText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
