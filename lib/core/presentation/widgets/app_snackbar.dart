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
          backgroundColor: AppColors.transparent,
          elevation: AppSizing.elevationNone,
          duration: duration,
          behavior: SnackBarBehavior.floating,
          margin: position == SnackPosition.top
              ? EdgeInsets.only(
                  bottom: MediaQuery.of(context).size.height - AppSizing.snackTopOffset,
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
      background: AppColors.snackSuccessBg,
      iconBackground: AppColors.snackSuccessIconBg,
      iconColor: AppColors.snackSuccessIcon,
      textColor: AppColors.snackSuccessText,
      progressColor: AppColors.success,
      icon: AppIcons.checkCircle,
    ),
    SnackType.error => const _SnackConfig(
      background: AppColors.snackErrorBg,
      iconBackground: AppColors.snackErrorIconBg,
      iconColor: AppColors.snackErrorIcon,
      textColor: AppColors.snackErrorText,
      progressColor: AppColors.error,
      icon: AppIcons.error,
    ),
    SnackType.warning => const _SnackConfig(
      background: AppColors.snackWarningBg,
      iconBackground: AppColors.snackWarningIconBg,
      iconColor: AppColors.snackWarningIcon,
      textColor: AppColors.snackWarningText,
      progressColor: AppColors.warning,
      icon: AppIcons.warning,
    ),
    SnackType.info => const _SnackConfig(
      background: AppColors.snackInfoBg,
      iconBackground: AppColors.snackInfoIconBg,
      iconColor: AppColors.snackInfoIcon,
      textColor: AppColors.snackInfoText,
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
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.snackGap,
        0,
        AppSpacing.snackGap,
        AppSpacing.snackGap,
      ),
      decoration: BoxDecoration(
        color: c.background,
        borderRadius: BorderRadius.circular(AppSizing.radiusMd),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.snackPadding,
              AppSpacing.snackPadding,
              AppSpacing.snackPaddingEnd,
              AppSpacing.snackPadding,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ícono
                Container(
                  width: AppSizing.snackIconContainer,
                  height: AppSizing.snackIconContainer,
                  decoration: BoxDecoration(
                    color: c.iconBackground,
                    borderRadius: BorderRadius.circular(AppSizing.radiusSm),
                  ),
                  child: Icon(c.icon, color: c.iconColor, size: AppSizing.iconActionSm),
                ),
                const SizedBox(width: AppSpacing.snackGap),
                // Texto
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.title != null) ...[
                        Text(
                          widget.title!,
                          style: AppTextStyles.snackTitle.copyWith(
                            color: c.textColor,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                      ],
                      Text(
                        widget.message,
                        style: AppTextStyles.snackBody.copyWith(
                          color: c.textColor.withValues(alpha: AppColors.opacityBodyText),
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
                    padding: const EdgeInsets.all(AppSpacing.xs),
                    child: Icon(
                      AppIcons.close,
                      color: c.textColor.withValues(alpha: AppColors.opacityHint),
                      size: AppSizing.iconSm,
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
              child: Container(
                height: AppSizing.snackProgressBar,
                color: c.progressColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
