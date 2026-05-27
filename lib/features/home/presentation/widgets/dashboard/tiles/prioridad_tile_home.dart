
import 'dart:async';
import 'package:flutter/material.dart';

import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/home/index_home.dart';

class PrioridadTileHome extends StatefulWidget {
  final Prioridad prioridad;
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

    final errorStyle = themeText.labelMedium?.copyWith(
      color: theme.colorScheme.error,
      fontWeight: FontWeight.w700,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.xs,
        horizontal: AppSpacing.xs,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: AppSizing.avatarRadiusSm,
            backgroundColor: prioridad.nombre.avatarColor,
            child: Text(prioridad.nombre.initials, style: labelMediumStyle),
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(prioridad.nombre, style: titleStyle),
                SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    if (prioridad.idCanal.isNotEmpty) ...[
                      AppIconsSocial.widgetCanal(prioridad.idCanal),
                      SizedBox(width: AppSpacing.xxs),
                      Text(
                        CanalHelper.get(prioridad.idCanal).nombre,
                        style: labelSmallStyle,
                      ),
                      SizedBox(width: AppSpacing.xs),
                    ],
                    if (prioridad.idEstado.isNotEmpty) ...[
                      AppIconsSocial.chipEstado(
                        prioridad.idEstado,
                        label: prioridad.estado,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(ElapsedTimeUtils.format(_elapsed), style: errorStyle),
            ],
          ),
          SizedBox(width: AppSpacing.sm),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ActionButtonWidget(
                icon: AppIcons.message,
                color: Colors.green,
                onTap: () {
                  context.goToDetalleChatDesdeHome(idLead: prioridad.idLead);
                },
                tooltip: 'Mensaje',
              ),
              ActionButtonWidget(
                icon: AppIcons.phone,
                color: Colors.blue,
                onTap: () {},
                tooltip: 'Llamar',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
