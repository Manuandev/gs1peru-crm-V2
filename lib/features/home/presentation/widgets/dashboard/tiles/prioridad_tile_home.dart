import 'dart:async';
import 'package:flutter/material.dart';

import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/home/index_home.dart';

class PrioridadTileHome extends StatefulWidget {
  final PrioridadHome prioridad;
  const PrioridadTileHome({super.key, required this.prioridad});

  @override
  State<PrioridadTileHome> createState() => _PrioridadTileHomeState();
}

class _PrioridadTileHomeState extends State<PrioridadTileHome> {
  late Duration _elapsed;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _elapsed = Duration.zero;
    _updateElapsed();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      setState(() => _updateElapsed());
    });
  }

  void _updateElapsed() {
    final fecha = DateFormatter.parseDate(widget.prioridad.fechaHora);
    if (fecha == null) return;
    _elapsed = DateTime.now().difference(fecha);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prioridad = widget.prioridad;

    final theme = Theme.of(context);
    final themeText = theme.textTheme;
    final colorScheme = theme.colorScheme;

    final titleStyle = themeText.titleSmall?.copyWith(
      fontWeight: FontWeight.w700,
      color: themeText.titleSmall!.color,
    );

    final labelSmallStyle = themeText.labelSmall?.copyWith(
      color: themeText.labelSmall!.color,
    );

    final avatarStyle = themeText.labelMedium?.copyWith(
      color: AppColors.textOnDark,
    );

    final elapsedColor = ElapsedTimeUtils.colorFromElapsed(_elapsed);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Avatar ──────────────────────────────────────
          CircleAvatar(
            radius: AppSizing.avatarRadiusSm + 4,
            backgroundColor: prioridad.nombre.avatarColor,
            child: Text(
              prioridad.nombre.initials,
              style: avatarStyle?.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),

          // ─── Info central (Nombre + Canal + Estado) ──────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Fila 1: Nombre
                Text(
                  prioridad.nombre,
                  style: titleStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),

                // Fila 2: Canal + Estado
                Row(
                  children: [
                    if (prioridad.idCanal > 0) ...[
                      AppIconsSocial.widgetCanal(prioridad.idCanal, size: 12),
                      const SizedBox(width: AppSpacing.xxs),
                      Flexible(
                        child: Text(
                          CanalHelper.get(prioridad.idCanal).nombre,
                          style: labelSmallStyle?.copyWith(fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                    ],
                    if (prioridad.idEstado.isNotEmpty)
                      AppIconsSocial.chipEstado(
                        prioridad.idEstado,
                        label: prioridad.estado,
                      ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: AppSpacing.xs),

          // ─── Columna derecha: Timer + Botones ────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Timer elapsed
              Text(
                ElapsedTimeUtils.formatHyM(_elapsed),
                style: themeText.labelMedium?.copyWith(
                  color: elapsedColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
              Text(
                'sin respuesta',
                style: themeText.labelSmall?.copyWith(
                  color: elapsedColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),

              // Botones de acción
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _MiniActionButton(
                    icon: AppIcons.message,
                    color: const Color(0xFF25D366),
                    onTap: () {
                      context.goToDetalleChatDesdeHome(
                        idLead: prioridad.idLead,
                      );
                    },
                    tooltip: 'WhatsApp',
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  _MiniActionButton(
                    icon: AppIcons.phone,
                    color: colorScheme.primary,
                    onTap: () async {
                      await LauncherUtils.abrirTelefono(prioridad.telefono);
                    },
                    tooltip: 'Llamar',
                  ),
                  // const SizedBox(width: AppSpacing.xs),
                  // _MiniActionButton(
                  //   icon: AppIcons.check,
                  //   color: const Color(0xFF7C4DFF),
                  //   onTap: () {
                  //     context.goToDetalleChatDesdeHome(
                  //       idLead: prioridad.idLead,
                  //     );
                  //   },
                  //   tooltip: 'Ver detalle',
                  // ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Botón de acción compacto para el tile ──────────────
class _MiniActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final String tooltip;

  const _MiniActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizing.radiusMd),
        onTap: onTap,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppSizing.radiusMd),
          ),
          child: Icon(icon, color: Colors.white, size: 16),
        ),
      ),
    );
  }
}
