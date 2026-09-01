// lib/features/home/presentation/widgets/notifications/notifications_portrait.dart

import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/config/index_config.dart';
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

  List<Notificacion> get _notificacionesFiltradas => switch (_filtro) {
    _Filtro.todas => widget.state.notificaciones,
    _Filtro.actividades => widget.state.actividades,
    _Filtro.derivaciones => widget.state.derivaciones,
    _Filtro.mensajes => widget.state.mensajes,
  };

  // Agrupa la lista por etiqueta de fecha ("Hoy", "Ayer", fecha corta)
  // Preserva el orden de inserción (LinkedHashMap implícito en Dart).
  Map<String, List<Notificacion>> _agruparPorFecha(List<Notificacion> lista) {
    final grupos = <String, List<Notificacion>>{};
    for (final n in lista) {
      final clave = _etiquetaFecha(n.fechaHora);
      grupos.putIfAbsent(clave, () => []).add(n);
    }
    return grupos;
  }

  String _etiquetaFecha(String fechaHora) {
    try {
      final dt = DateTime.parse(fechaHora);
      final hoy = DateTime.now();
      if (dt.year == hoy.year && dt.month == hoy.month && dt.day == hoy.day) {
        return 'Hoy';
      }
      final ayer = hoy.subtract(const Duration(days: 1));
      if (dt.year == ayer.year &&
          dt.month == ayer.month &&
          dt.day == ayer.day) {
        return 'Ayer';
      }
      return fechaHora.formatDate(AppDateFormat.shortDate);
    } catch (_) {
      return 'Hoy';
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;

    return Column(
      children: [
        // ── Filtros — fijos, no scrollean ─────────────────────────────────
        _BarraFiltros(
          filtro: _filtro,
          totTodas: state.notificaciones.length,
          totActividades: state.actividades.length,
          totDerivaciones: state.derivaciones.length,
          totMensajes: state.mensajes.length,
          onCambio: (f) => setState(() => _filtro = f),
        ),

        // ── Contenido scrolleable ──────────────────────────────────────────
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final lista = _notificacionesFiltradas;

              // Con minHeight = alto del viewport + IntrinsicHeight, el Expanded
              // interno reparte el espacio sobrante y centra el estado vacío
              // aunque el contenido esté dentro de un scroll (pull-to-refresh).
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: AppSpacing.xs),
                        _TarjetaContadores(state: state),
                        const SizedBox(height: AppSpacing.sm),
                        if (lista.isEmpty)
                          const Expanded(
                            child: Center(child: _EmptyNotifications()),
                          )
                        else
                          _buildLista(lista),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLista(List<Notificacion> lista) {
    final grupos = _agruparPorFecha(lista);
    final widgets = <Widget>[];

    for (final entry in grupos.entries) {
      widgets.add(
        _EncabezadoFecha(fecha: entry.key, count: entry.value.length),
      );
      for (int i = 0; i < entry.value.length; i++) {
        widgets.add(
          NotificacionTile(
            notificacion: entry.value[i],
            onAccion: () => _onAccion(entry.value[i]),
          ),
        );
        if (i < entry.value.length - 1) {
          widgets.add(
            const Divider(
              height: 1,
              indent: AppSpacing.md,
              endIndent: AppSpacing.md,
            ),
          );
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  // Mensaje/derivación → chat de la conversación. Recordatorio/lead por
  // contactar/reasignado → detalle de contacto (idContacto viene en DATOS,
  // ver notificacion_model.dart). Actividad genérica → sin acción todavía,
  // el SP no manda ID_CONTACTO para ese tipo (ver home/CLAUDE.md).
  void _onAccion(Notificacion notificacion) {
    if (notificacion.idChatCab != null) {
      context.goToDetalleChatDesdeHome(idChatCab: notificacion.idChatCab!);
    } else if (notificacion.idContacto != null) {
      context.goToDetalleContacto(idContacto: notificacion.idContacto!);
    }
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
            colorBadge: AppColors.secondary,
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
            colorBadge: AppColors.brandSlateAccessible,
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
    final badgeBg = seleccionado ? AppColors.textOnDark : colorBadge;
    final badgeText = seleccionado ? colorSeleccionado : AppColors.textOnDark;

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
                  color: badgeText,
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
                colorIcono: AppColors.secondary,
                titulo: 'Pendientes hoy',
                valor: state.actividades.length,
              ),
            ),
            Container(width: 1, height: 48, color: AppColors.border),
            Expanded(
              child: _ContadorItem(
                icono: AppIcons.ia,
                colorIcono: AppColors.brandLavenderAccessible,
                titulo: 'Derivaciones',
                valor: state.derivaciones.length,
              ),
            ),
            Container(width: 1, height: 48, color: AppColors.border),
            Expanded(
              child: _ContadorItem(
                icono: AppIcons.chatDots,
                colorIcono: AppColors.brandSlateAccessible,
                titulo: 'Mensajes sin leer',
                valor: state.mensajes.length,
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
                  style: AppTextStyles.labelSmall.copyWith(
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

// ── Encabezado de grupo por fecha ─────────────────────────────────────────────

class _EncabezadoFecha extends StatelessWidget {
  final String fecha;
  final int count;

  const _EncabezadoFecha({required this.fecha, required this.count});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.xs,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            fecha,
            style: AppTextStyles.titleSmall.copyWith(
              fontWeight: AppTextStyles.weightBold,
            ),
          ),
          Text(
            '$count ${count == 1 ? 'notificación' : 'notificaciones'}',
            style: AppTextStyles.labelSmall.copyWith(
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

// ── Estado vacío ──────────────────────────────────────────────────────────────

class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
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
    );
  }
}
