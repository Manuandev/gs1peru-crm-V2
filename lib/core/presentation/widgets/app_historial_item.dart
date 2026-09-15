// lib/core/presentation/widgets/app_historial_item.dart
//
// Historial unificado (2026-09-14) — UNA sola regla visual para las 4
// pantallas con historial: Conversaciones, Seguimiento, Detalle de Solicitud
// y Detalle de cobro.
//   · Ícono según el tipo de evento: seguimiento / comentario / recordatorio.
//   · Color según quién lo hizo: Bot IA verde · Asesor/Cliente azul.
//   · Descripción a todo el ancho; debajo, a la izquierda la oportunidad
//     (o el tipo de evento si no se muestra la oportunidad) y a la derecha
//     "actor · fecha".
//   · Línea vertical que une los eventos.
// Conversaciones/Seguimiento muestran la oportunidad (hay varias
// negociaciones); Solicitud/Cobranza no (es una sola) — ver mostrarOportunidad.

import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';

extension HistorialFiltroX on List<HistorialComentario> {
  /// null = Todos. "Asesor" engloba asesor y cliente (acción del contacto).
  List<HistorialComentario> filtrarPorActor(TipoActor? filtro) {
    if (filtro == null) return this;
    if (filtro == TipoActor.asesor) {
      return where(
        (e) =>
            e.tipoActor == TipoActor.asesor ||
            e.tipoActor == TipoActor.cliente,
      ).toList();
    }
    return where((e) => e.tipoActor == filtro).toList();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Chips de filtro (Todos / Bot IA / Asesor)
// ─────────────────────────────────────────────────────────────────────────────

class AppHistorialFiltroChips extends StatelessWidget {
  final TipoActor? filtroSeleccionado;
  final ValueChanged<TipoActor?> onFiltroChanged;
  final EdgeInsetsGeometry padding;

  const AppHistorialFiltroChips({
    super.key,
    required this.filtroSeleccionado,
    required this.onFiltroChanged,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: padding,
      child: Row(
        spacing: AppSpacing.xs,
        children: [
          _ChipFiltro(
            label: 'Todos',
            color: AppColors.primary,
            seleccionado: filtroSeleccionado == null,
            onTap: () => onFiltroChanged(null),
          ),
          _ChipFiltro(
            label: 'Bot IA',
            color: AppHistorialEventoItem.colorActor(TipoActor.botIA),
            seleccionado: filtroSeleccionado == TipoActor.botIA,
            onTap: () => onFiltroChanged(TipoActor.botIA),
          ),
          _ChipFiltro(
            label: 'Asesor',
            color: AppHistorialEventoItem.colorActor(TipoActor.asesor),
            seleccionado: filtroSeleccionado == TipoActor.asesor,
            onTap: () => onFiltroChanged(TipoActor.asesor),
          ),
        ],
      ),
    );
  }
}

class _ChipFiltro extends StatelessWidget {
  final String label;
  final Color color;
  final bool seleccionado;
  final VoidCallback onTap;

  const _ChipFiltro({
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
          color: seleccionado
              ? color
              : color.withValues(alpha: AppColors.opacityCodeBackground),
          borderRadius: BorderRadius.circular(AppSizing.radiusCircular),
          border: Border.all(
            color: color.withValues(
              alpha: seleccionado ? 0 : AppColors.opacityDisabledBorder,
            ),
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
// Ítem de la línea de tiempo
// ─────────────────────────────────────────────────────────────────────────────

class AppHistorialEventoItem extends StatelessWidget {
  final HistorialComentario evento;
  // true en Conversaciones/Seguimiento (varias negociaciones del contacto);
  // false en Solicitud/Cobranza (una sola) — ahí va el tipo de evento.
  final bool mostrarOportunidad;
  final bool esUltimo;

  const AppHistorialEventoItem({
    super.key,
    required this.evento,
    this.mostrarOportunidad = true,
    this.esUltimo = false,
  });

  static IconData iconoEvento(TipoEventoHistorial tipo) => switch (tipo) {
    TipoEventoHistorial.seguimiento => AppIcons.historial,
    TipoEventoHistorial.comentario => AppIcons.chat,
    TipoEventoHistorial.recordatorio => AppIcons.recordatorio,
  };

  static String etiquetaEvento(TipoEventoHistorial tipo) => switch (tipo) {
    TipoEventoHistorial.seguimiento => 'Seguimiento',
    TipoEventoHistorial.comentario => 'Comentario',
    TipoEventoHistorial.recordatorio => 'Recordatorio',
  };

  static Color colorActor(TipoActor actor) => switch (actor) {
    TipoActor.botIA => AppColors.success,
    TipoActor.cliente => AppColors.info,
    TipoActor.asesor => AppColors.info,
  };

  @override
  Widget build(BuildContext context) {
    final color = colorActor(evento.tipoActor);
    final oportunidad = evento.oportunidad.aTitulo;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Ícono + línea vertical ─────────────────────────────
          Column(
            children: [
              Container(
                width: AppSizing.actorCircleSize,
                height: AppSizing.actorCircleSize,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: AppColors.opacitySeccionIconBg),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: color.withValues(alpha: AppColors.opacityDivider),
                    width: AppSizing.actorCircleBorder,
                  ),
                ),
                child: Icon(
                  iconoEvento(evento.tipoEvento),
                  size: AppSizing.iconSm,
                  color: color,
                ),
              ),
              if (!esUltimo)
                Expanded(
                  child: Container(
                    width: AppSizing.borderWidthThin * 2,
                    color: AppColors.border,
                    margin: const EdgeInsets.symmetric(
                      vertical: AppSpacing.xxs,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppSpacing.sm),

          // ── Contenido ──────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: esUltimo ? 0 : AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    evento.notas,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: mostrarOportunidad && oportunidad.isNotEmpty
                              ? _ChipOportunidad(label: oportunidad)
                              : Text(
                                  etiquetaEvento(evento.tipoEvento),
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: evento.actorLabel,
                              style: TextStyle(
                                color: color,
                                fontWeight: AppTextStyles.weightMedium,
                              ),
                            ),
                            TextSpan(
                              text: ' · ${evento.fechaHora.formatConDia()}',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        style: AppTextStyles.labelSmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipOportunidad extends StatelessWidget {
  final String label;

  const _ChipOportunidad({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(
          alpha: AppColors.opacityCodeBackground,
        ),
        borderRadius: BorderRadius.circular(AppSizing.radiusSm),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.primary,
          fontWeight: AppTextStyles.weightMedium,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sin resultados para el filtro elegido
// ─────────────────────────────────────────────────────────────────────────────

class AppHistorialSinResultados extends StatelessWidget {
  const AppHistorialSinResultados({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Center(
        child: Text(
          'Sin resultados para este filtro',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sección "Historial" dentro de una card (Detalle de Solicitud / de cobro)
// ─────────────────────────────────────────────────────────────────────────────

class AppHistorialSeccion extends StatefulWidget {
  final List<HistorialComentario> eventos;
  final String mensajeVacio;

  const AppHistorialSeccion({
    super.key,
    required this.eventos,
    required this.mensajeVacio,
  });

  @override
  State<AppHistorialSeccion> createState() => _AppHistorialSeccionState();
}

class _AppHistorialSeccionState extends State<AppHistorialSeccion> {
  // null = Todos
  TipoActor? _filtro;

  @override
  Widget build(BuildContext context) {
    final visibles = widget.eventos.filtrarPorActor(_filtro);

    return AppSeccionCard(
      colorIcono: AppColors.warning,
      icono: AppIcons.time,
      titulo: 'Historial',
      children: [
        if (widget.eventos.isEmpty)
          AppSeccionVacia(
            icono: AppIcons.historial,
            color: AppColors.warning,
            titulo: 'Sin movimientos registrados',
            mensaje: widget.mensajeVacio,
          )
        else ...[
          AppHistorialFiltroChips(
            filtroSeleccionado: _filtro,
            onFiltroChanged: (f) => setState(() => _filtro = f),
          ),
          const SizedBox(height: AppSpacing.md),
          if (visibles.isEmpty)
            const AppHistorialSinResultados()
          else
            for (int i = 0; i < visibles.length; i++)
              AppHistorialEventoItem(
                evento: visibles[i],
                mostrarOportunidad: false,
                esUltimo: i == visibles.length - 1,
              ),
        ],
      ],
    );
  }
}
