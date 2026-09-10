// lib/features/home/presentation/widgets/notifications/notifications_portrait.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/features/home/index_home.dart';

class NotificationsPortrait extends StatefulWidget {
  final NotificationsLoaded state;
  const NotificationsPortrait({super.key, required this.state});

  @override
  State<NotificationsPortrait> createState() => _NotificationsPortraitState();
}

class _NotificationsPortraitState extends State<NotificationsPortrait> {
  // Con paginación el filtro ya no se aplica en memoria: vive en el bloc y
  // viaja al SP (ver FiltroNotificacion.codigoSp). La lista del state SIEMPRE
  // es la del chip activo.
  final _scroll = ScrollController();

  // Umbral en px desde el final para disparar la página siguiente.
  static const double _umbralPaginar = 320;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final falta = _scroll.position.maxScrollExtent - _scroll.position.pixels;
    if (falta <= _umbralPaginar && widget.state.puedePaginar) {
      context.read<NotificationsBloc>().add(
        const NotificationsPaginaSolicitada(),
      );
    }
  }

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
          filtro: state.filtro,
          // Totales calculados por el SP sobre el universo completo — con
          // paginación `lista.length` solo vería la página actual.
          totTodas: state.conteos.todas,
          totActividades: state.conteos.actividades,
          totDerivaciones: state.conteos.derivaciones,
          totMensajes: state.conteos.mensajes,
          onCambio: (f) => context.read<NotificationsBloc>().add(
            NotificationsFiltroCambiado(f),
          ),
        ),

        // ── Contenido scrolleable ──────────────────────────────────────────
        //
        // CustomScrollView + SliverList.builder: la lista se construye PEREZOSA.
        // Antes era un SingleChildScrollView con un Column que metía TODOS los
        // tiles como hijos — con cientos de notificaciones eso construía cientos
        // de widgets de golpe en el hilo de UI y la app se congelaba (ANR real
        // con 824 filas). Con slivers solo se construye lo visible.
        Expanded(
          child: CustomScrollView(
            controller: _scroll,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xs)),
              SliverToBoxAdapter(child: _TarjetaContadores(state: state)),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sm)),

              if (state.recargandoLista)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: _SpinnerPagina()),
                )
              else if (state.notificaciones.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: _EmptyNotifications()),
                )
              else ...[
                _buildSliverLista(state.notificaciones),
                SliverToBoxAdapter(child: _PieLista(state: state)),
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// Aplana los grupos por fecha en una sola lista de filas para que el
  /// SliverList pueda construirlas por índice (encabezado / tile / divisor).
  Widget _buildSliverLista(List<Notificacion> lista) {
    final filas = <_Fila>[];

    for (final entry in _agruparPorFecha(lista).entries) {
      filas.add(_Fila.encabezado(entry.key, entry.value.length));
      for (int i = 0; i < entry.value.length; i++) {
        filas.add(_Fila.tile(entry.value[i]));
        if (i < entry.value.length - 1) filas.add(const _Fila.divisor());
      }
    }

    return SliverList.builder(
      itemCount: filas.length,
      itemBuilder: (context, index) {
        final f = filas[index];
        return switch (f.tipo) {
          _TipoFila.encabezado => _EncabezadoFecha(
            fecha: f.fecha!,
            count: f.count!,
          ),
          _TipoFila.tile => NotificacionTile(
            notificacion: f.notificacion!,
            onAccion: () => _onAccion(f.notificacion!),
          ),
          _TipoFila.divisor => const Divider(
            height: 1,
            indent: AppSpacing.md,
            endIndent: AppSpacing.md,
          ),
        };
      },
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

// ── Fila aplanada de la lista (encabezado / tile / divisor) ─────────────────

enum _TipoFila { encabezado, tile, divisor }

class _Fila {
  final _TipoFila tipo;
  final String? fecha;
  final int? count;
  final Notificacion? notificacion;

  const _Fila._(this.tipo, {this.fecha, this.count, this.notificacion});

  const _Fila.encabezado(String fecha, int count)
    : this._(_TipoFila.encabezado, fecha: fecha, count: count);
  const _Fila.tile(Notificacion n)
    : this._(_TipoFila.tile, notificacion: n);
  const _Fila.divisor() : this._(_TipoFila.divisor);
}

// ── Spinner de página ───────────────────────────────────────────────────────

class _SpinnerPagina extends StatelessWidget {
  const _SpinnerPagina();

  @override
  Widget build(BuildContext context) => const SizedBox(
    width: AppSizing.iconMd,
    height: AppSizing.iconMd,
    child: CircularProgressIndicator(
      strokeWidth: AppSizing.spinnerStrokeSmall,
      color: AppColors.primary,
    ),
  );
}

// ── Barra de filtros (sticky) ─────────────────────────────────────────────────

class _BarraFiltros extends StatelessWidget {
  final FiltroNotificacion filtro;
  final int totTodas;
  final int totActividades;
  final int totDerivaciones;
  final int totMensajes;
  final ValueChanged<FiltroNotificacion> onCambio;

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
            seleccionado: filtro == FiltroNotificacion.todas,
            colorBadge: AppColors.info,
            onTap: () => onCambio(FiltroNotificacion.todas),
          ),
          const SizedBox(width: AppSpacing.sm),
          _FiltroChip(
            label: 'Actividades',
            count: totActividades,
            seleccionado: filtro == FiltroNotificacion.actividades,
            colorBadge: AppColors.secondary,
            onTap: () => onCambio(FiltroNotificacion.actividades),
          ),
          const SizedBox(width: AppSpacing.sm),
          _FiltroChip(
            label: 'Derivaciones bot',
            count: totDerivaciones,
            seleccionado: filtro == FiltroNotificacion.derivaciones,
            colorBadge: AppColors.brandLavenderAccessible,
            onTap: () => onCambio(FiltroNotificacion.derivaciones),
          ),
          const SizedBox(width: AppSpacing.sm),
          _FiltroChip(
            label: 'Mensajes',
            count: totMensajes,
            seleccionado: filtro == FiltroNotificacion.mensajes,
            colorBadge: AppColors.brandSlateAccessible,
            onTap: () => onCambio(FiltroNotificacion.mensajes),
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
                valor: state.conteos.actividades,
              ),
            ),
            Container(width: 1, height: 48, color: AppColors.border),
            Expanded(
              child: _ContadorItem(
                icono: AppIcons.ia,
                colorIcono: AppColors.brandLavenderAccessible,
                titulo: 'Derivaciones',
                valor: state.conteos.derivaciones,
              ),
            ),
            Container(width: 1, height: 48, color: AppColors.border),
            Expanded(
              child: _ContadorItem(
                icono: AppIcons.chatDots,
                colorIcono: AppColors.brandSlateAccessible,
                titulo: 'Mensajes sin leer',
                valor: state.conteos.mensajes,
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

// ── Pie de la lista paginada ─────────────────────────────────────────────────

class _PieLista extends StatelessWidget {
  final NotificationsLoaded state;
  const _PieLista({required this.state});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (state.loadMoreError != null) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Center(
          child: Column(
            children: [
              Text(
                state.loadMoreError!,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(
                  color: colorScheme.error,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              CustomTextButton(
                text: 'Reintentar',
                onPressed: () => context.read<NotificationsBloc>().add(
                  const NotificationsReintentarPagina(),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (state.cargandoMas) {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Center(child: _SpinnerPagina()),
      );
    }

    return const SizedBox(height: AppSpacing.md);
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
