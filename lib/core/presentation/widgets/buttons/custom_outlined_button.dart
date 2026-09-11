// lib/core/presentation/widgets/buttons/custom_outlined_button.dart

import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';

class CustomOutlinedButton extends StatelessWidget {
  // Texto del botón. Vacío + `icon` = botón solo-ícono.
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final Object? icon;
  final double? width;
  final double? height;
  final Color? borderColor;
  final Color? foregroundColor;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? padding;
  final double? borderWidth;
  // Radio de las esquinas. null = AppSizing.radiusMd.
  final double? borderRadius;
  // Tamaño del ícono. null = AppSizing.iconActionSm.
  final double? iconSize;
  // true = botón chico que se ajusta a su contenido: sin ancho completo (salvo
  // que se pase `width`), sin alto mínimo (salvo `height`) y sin el área de
  // toque extra de 48px que reserva Material — para acciones en encabezados
  // de sección ("Editar", "Carga masiva", ícono de eliminar...).
  final bool compacto;

  const CustomOutlinedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.icon,
    this.width,
    this.height,
    this.borderColor,
    this.foregroundColor,
    this.textStyle,
    this.padding,
    this.borderWidth,
    this.borderRadius,
    this.iconSize,
    this.compacto = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final bool enabled = isEnabled && !isLoading && onPressed != null;
    final bool soloIcono = text.isEmpty && icon != null;

    final Color resolvedFg = foregroundColor ??
        (enabled ? colorScheme.primary : Theme.of(context).disabledColor);

    final Color resolvedBorder = borderColor ??
        (enabled
            ? colorScheme.primary
            : Theme.of(context)
                .disabledColor
                .withValues(alpha: AppColors.opacityDisabledBorder));

    final double tamanioIcono = iconSize ?? AppSizing.iconActionSm;

    final buttonStyle = OutlinedButton.styleFrom(
      foregroundColor: resolvedFg,
      side: BorderSide(color: resolvedBorder, width: borderWidth ?? 1.0),
      minimumSize: compacto
          ? Size(0, height ?? 0)
          : Size.fromHeight(height ?? AppSizing.buttonHeightSmall),
      tapTargetSize: compacto ? MaterialTapTargetSize.shrinkWrap : null,
      padding: padding,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          borderRadius ?? AppSizing.radiusMd,
        ),
      ),
      textStyle: (textStyle ??
              AppTextStyles.labelMedium.copyWith(
                fontWeight: AppTextStyles.weightSemiBold,
              ))
          .copyWith(inherit: true),
    );

    final Widget child = isLoading
        ? SizedBox(
            height: AppSizing.iconMd,
            width: AppSizing.iconMd,
            child: CircularProgressIndicator(
              strokeWidth: AppSizing.spinnerStrokeSmall,
              valueColor: AlwaysStoppedAnimation<Color>(resolvedFg),
            ),
          )
        : Text(text, maxLines: 1, overflow: TextOverflow.ellipsis);

    final Widget boton;
    if (icon != null && !isLoading && soloIcono) {
      boton = OutlinedButton(
        onPressed: enabled ? onPressed : null,
        style: buttonStyle,
        child: resolveIcon(icon!, tamanioIcono, resolvedFg),
      );
    } else if (icon != null && !isLoading) {
      boton = OutlinedButton.icon(
        onPressed: enabled ? onPressed : null,
        style: buttonStyle,
        icon: resolveIcon(icon!, tamanioIcono, resolvedFg),
        label: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis),
      );
    } else {
      boton = OutlinedButton(
        onPressed: enabled ? onPressed : null,
        style: buttonStyle,
        child: child,
      );
    }

    // Compacto sin ancho explícito: se ajusta a su contenido.
    if (compacto && width == null) return boton;

    return SizedBox(width: width ?? double.infinity, child: boton);
  }
}
