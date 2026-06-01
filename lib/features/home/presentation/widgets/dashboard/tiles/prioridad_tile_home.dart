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

    final labelMediumStyle = themeText.labelMedium?.copyWith(
      color: themeText.labelMedium!.color,
    );

    final labelSmallStyle = themeText.labelSmall?.copyWith(
      color: themeText.labelSmall!.color,
    );

    final elapsedStyle = themeText.labelSmall?.copyWith(
      color: colorScheme.error,
      fontWeight: FontWeight.w700,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  prioridad.nombre,
                  style: titleStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: AppSpacing.xs),
              Text(
                '${ElapsedTimeUtils.formatHyM(_elapsed)} sin responder',
                style: elapsedStyle,
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xs),
          Divider(
            height: 1,
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
          const SizedBox(height: AppSpacing.xs),

          Row(
            children: [
              CircleAvatar(
                radius: AppSizing.avatarRadiusSm,
                backgroundColor: prioridad.nombre.avatarColor,
                child: Text(
                  prioridad.nombre.initials,
                  style: labelMediumStyle?.copyWith(
                    color: AppColors.textOnDark,
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (prioridad.idCanal > 0) ...[
                      Row(
                        children: [
                          AppIconsSocial.widgetCanal(prioridad.idCanal),
                          SizedBox(width: AppSpacing.xs),
                          Flexible(
                            child: Text(
                              CanalHelper.get(prioridad.idCanal).nombre,
                              style: labelSmallStyle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppSpacing.xs),
                    ],
                    if (prioridad.idEstado.isNotEmpty)
                      AppIconsSocial.chipEstado(
                        prioridad.idEstado,
                        label: prioridad.estado,
                      ),
                  ],
                ),
              ),
              SizedBox(width: AppSpacing.xs),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ActionButtonWidget(
                    icon: AppIcons.message,
                    color: Colors.green,
                    onTap: () {
                      context.goToDetalleChatDesdeHome(
                        idLead: prioridad.idLead,
                      );
                    },
                    tooltip: 'Mensaje',
                  ),
                  ActionButtonWidget(
                    icon: AppIcons.phone,
                    color: Colors.blue,
                    onTap: () async {
                      await LauncherUtils.abrirTelefono(prioridad.telefono);
                    },
                    tooltip: 'Llamar',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
