// lib/core/presentation/widgets/skeleton/skeleton_box.dart

import 'package:flutter/material.dart';
import 'package:app_crm/core/index_core.dart';

/// Caja placeholder animada para estados de carga (skeleton loading).
///
/// Pulsa entre AppColors.grey300 y AppColors.grey200 en un ciclo de 900ms.
/// Funciona sobre fondos blancos (AppColors.surface) y grises claros
/// (AppColors.surfaceLightVariant) — grey300 es suficientemente visible en ambos.
///
/// [width] null → ocupa todo el ancho disponible del padre.
/// [height] requerido — usar AppSizing.skeletonLineHeight (12dp) para cuerpo
///   o AppSizing.skeletonTitleHeight (14dp) para títulos.
/// [borderRadius] default AppSizing.radiusXs (4dp, token ya documentado para skeletons).
class SkeletonBox extends StatefulWidget {
  final double? width;
  final double height;
  final double borderRadius;

  const SkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = AppSizing.radiusXs,
  });

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Color?> _color;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _color = ColorTween(
      begin: AppColors.grey300,
      end: AppColors.grey200,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _color,
      builder: (_, _) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: _color.value,
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
      ),
    );
  }
}
