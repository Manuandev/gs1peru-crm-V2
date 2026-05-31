// lib/core/presentation/widgets/app_snackbar.dart

import 'package:flutter/material.dart';
import 'package:app_crm/core/index_core.dart';

enum SnackType { success, error, warning, info }

enum SnackPosition { top, bottom }

class AppSnackBar {
  AppSnackBar._();

  static void show(
    BuildContext context, {
    required String message,
    String? title,
    SnackType type = SnackType.info,
    Duration duration = const Duration(seconds: 3),
    SnackPosition position = SnackPosition.bottom,
  }) {
    final config = _SnackConfig.of(type);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          padding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          elevation: 0,
          duration: duration,
          behavior: SnackBarBehavior.floating,
          margin: position == SnackPosition.top
              ? EdgeInsets.only(
                  bottom: MediaQuery.of(context).size.height - 120,
                  left: 0,
                  right: 0,
                )
              : EdgeInsets.zero,
          content: _AppSnackContent(
            title: title,
            message: message,
            config: config,
            duration: duration,
          ),
        ),
      );
  }

  static void success(
    BuildContext context,
    String message, {
    String? title,
    SnackPosition position = SnackPosition.bottom,
  }) => show(
    context,
    message: message,
    title: title ?? 'Éxito',
    type: SnackType.success,
    position: position,
  );

  static void error(
    BuildContext context,
    String message, {
    String? title,
    SnackPosition position = SnackPosition.bottom,
  }) => show(
    context,
    message: message,
    title: title ?? 'Error',
    type: SnackType.error,
    duration: const Duration(seconds: 4),
    position: position,
  );

  static void warning(
    BuildContext context,
    String message, {
    String? title,
    SnackPosition position = SnackPosition.bottom,
  }) => show(
    context,
    message: message,
    title: title ?? 'Advertencia',
    type: SnackType.warning,
    position: position,
  );

  static void info(
    BuildContext context,
    String message, {
    String? title,
    SnackPosition position = SnackPosition.bottom,
  }) => show(
    context,
    message: message,
    title: title,
    type: SnackType.info,
    position: position,
  );
}

// ─── Configuración por tipo ───────────────────────────────────────────────────

class _SnackConfig {
  final Color background;
  final Color iconBackground;
  final Color iconColor;
  final Color textColor;
  final Color progressColor;
  final IconData icon;

  const _SnackConfig({
    required this.background,
    required this.iconBackground,
    required this.iconColor,
    required this.textColor,
    required this.progressColor,
    required this.icon,
  });

  factory _SnackConfig.of(SnackType type) => switch (type) {
    SnackType.success => const _SnackConfig(
      background: Color(0xFF1B2E1C),
      iconBackground: Color(0xFF2D4A2F),
      iconColor: Color(0xFF81C784),
      textColor: Color(0xFFD4EDDA),
      progressColor: AppColors.success,
      icon: AppIcons.checkCircle,
    ),
    SnackType.error => const _SnackConfig(
      background: Color(0xFF2E1B1B),
      iconBackground: Color(0xFF4A2D2D),
      iconColor: Color(0xFFE57373),
      textColor: Color(0xFFF8D7DA),
      progressColor: AppColors.error,
      icon: AppIcons.error,
    ),
    SnackType.warning => const _SnackConfig(
      background: Color(0xFF2E2418),
      iconBackground: Color(0xFF4A3820),
      iconColor: Color(0xFFFFB74D),
      textColor: Color(0xFFFFF3CD),
      progressColor: AppColors.warning,
      icon: AppIcons.warning,
    ),
    SnackType.info => const _SnackConfig(
      background: Color(0xFF1B2435),
      iconBackground: Color(0xFF253654),
      iconColor: Color(0xFF64B5F6),
      textColor: Color(0xFFD0E8FB),
      progressColor: AppColors.info,
      icon: AppIcons.infoCircle,
    ),
  };
}

// ─── Widget del contenido ─────────────────────────────────────────────────────

class _AppSnackContent extends StatefulWidget {
  final String? title;
  final String message;
  final _SnackConfig config;
  final Duration duration;

  const _AppSnackContent({
    required this.title,
    required this.message,
    required this.config,
    required this.duration,
  });

  @override
  State<_AppSnackContent> createState() => _AppSnackContentState();
}

class _AppSnackContentState extends State<_AppSnackContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progress;

  @override
  void initState() {
    super.initState();
    _progress = AnimationController(vsync: this, duration: widget.duration)
      ..forward();
  }

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.config;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(
        color: c.background,
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ícono
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: c.iconBackground,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(c.icon, color: c.iconColor, size: 18),
                ),
                const SizedBox(width: 12),
                // Texto
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.title != null) ...[
                        Text(
                          widget.title!,
                          style: TextStyle(
                            color: c.textColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                      ],
                      Text(
                        widget.message,
                        style: TextStyle(
                          color: c.textColor.withValues(alpha: 0.85),
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                // Cerrar
                GestureDetector(
                  onTap: () =>
                      ScaffoldMessenger.of(context).hideCurrentSnackBar(),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      AppIcons.close,
                      color: c.textColor.withValues(alpha: 0.5),
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Barra de progreso
          AnimatedBuilder(
            animation: _progress,
            builder: (_, _) => FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: 1 - _progress.value,
              child: Container(height: 3, color: c.progressColor),
            ),
          ),
        ],
      ),
    );
  }
}
