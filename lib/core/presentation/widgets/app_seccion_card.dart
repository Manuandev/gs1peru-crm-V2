// lib/core/presentation/widgets/app_seccion_card.dart
//
// Bloques de las pantallas de "Detalle" (Solicitud, Cobranza): card con
// ícono+título, fila etiqueta/valor y estado vacío compacto para vivir dentro
// de la card. Movidos desde solicitudes/ (SeccionCard/FilaInfo) el 2026-09-11
// para que ambos detalles se vean igual.

import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';

class AppSeccionCard extends StatelessWidget {
  final Color colorIcono;
  final IconData icono;
  final String titulo;
  final List<Widget> children;

  const AppSeccionCard({
    super.key,
    required this.colorIcono,
    required this.icono,
    required this.titulo,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizing.radiusLg),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: AppSizing.shadowBlurXs,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: AppSizing.seccionCardIconContainer,
                height: AppSizing.seccionCardIconContainer,
                decoration: BoxDecoration(
                  color: colorIcono.withValues(
                    alpha: AppColors.opacitySeccionIconBg,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icono,
                  color: colorIcono,
                  size: AppSizing.iconActionSm,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  titulo,
                  style: AppTextStyles.titleSmall.copyWith(
                    fontWeight: AppTextStyles.weightBold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ...children,
        ],
      ),
    );
  }
}

class AppFilaInfo extends StatelessWidget {
  final String etiqueta;
  final String valor;
  final bool mostrarDivisor;
  // Opcional: fila tocable (ej. copiar correo/celular) — el valor se pinta en
  // AppColors.info para que se note que se puede tocar.
  final VoidCallback? onTap;

  const AppFilaInfo({
    super.key,
    required this.etiqueta,
    required this.valor,
    this.mostrarDivisor = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Etiqueta ARRIBA y valor abajo, cada uno a todo el ancho (2026-09-11) —
    // antes iban lado a lado (etiqueta 130px fija + valor), y un valor largo
    // ("BOLETA DE VENTA", un correo, una dirección) quedaba apretado contra
    // la etiqueta y partido en varias líneas.
    final fila = Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            etiqueta,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            valor,
            style: AppTextStyles.bodySmall.copyWith(
              color: onTap != null ? AppColors.info : AppColors.textPrimary,
              fontWeight: AppTextStyles.weightMedium,
            ),
          ),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (onTap != null)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: fila,
          )
        else
          fila,
        if (mostrarDivisor)
          const Divider(color: AppColors.border, height: 1, thickness: 1),
      ],
    );
  }
}

// Estado vacío compacto para usar DENTRO de una AppSeccionCard — mismo
// lenguaje que los vacíos de pantalla completa (ícono + título + subtítulo),
// en versión más chica para no desbalancear la card.
class AppSeccionVacia extends StatelessWidget {
  final IconData icono;
  final Color color;
  final String titulo;
  final String mensaje;

  const AppSeccionVacia({
    super.key,
    required this.icono,
    required this.color,
    required this.titulo,
    required this.mensaje,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.md,
        horizontal: AppSpacing.sm,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: AppSizing.emptyStateIconContainerSm,
              height: AppSizing.emptyStateIconContainerSm,
              decoration: BoxDecoration(
                color: color.withValues(alpha: AppColors.opacitySeccionIconBg),
                shape: BoxShape.circle,
              ),
              child: Icon(icono, size: AppSizing.iconLg, color: color),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              titulo,
              style: AppTextStyles.titleSmall.copyWith(
                fontWeight: AppTextStyles.weightSemiBold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              mensaje,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
