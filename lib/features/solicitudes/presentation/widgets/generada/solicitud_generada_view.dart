// lib/features/solicitudes/presentation/widgets/generada/solicitud_generada_view.dart

import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/features/solicitudes/index_solicitudes.dart';

class SolicitudGeneradaView extends StatelessWidget {
  final Solicitud solicitud;
  final String comprobante;

  const SolicitudGeneradaView({
    super.key,
    required this.solicitud,
    this.comprobante = '',
  });

  @override
  Widget build(BuildContext context) {
    return BasePage(
      // Sin botón de retroceso — esta pantalla es un punto final del flujo
      // de generar solicitud, no tiene sentido volver al wizard. El back
      // del celular (gesto/botón físico) sigue intentando hacer pop, pero
      // onPop lo intercepta y manda a la lista de solicitudes en vez de
      // dejarlo hacer pop normal.
      onPop: () => context.goToSolicitudes(),
      drawerSide: DrawerSide.none,
      bodyPadding: EdgeInsets.zero,
      title: 'Solicitud lista',
      body: Column(
        children: [
          // ── Header azul con bordes redondeados ────────────────
          const _HeaderGenerada(),

          // ── Indicador de pasos fijo bajo el header ────────────
          Transform.translate(
            offset: const Offset(0, -AppSpacing.md),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: _PasosGeneradaIndicador(pasoActual: 4),
            ),
          ),

          // ── Contenido scrollable desplazado sobre el header ───
          Expanded(
            child: Transform.translate(
              offset: const Offset(0, -AppSpacing.md),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Column(
                  children: [
                    const SizedBox(height: AppSpacing.sm),
                    const _MensajeExito(),
                    const SizedBox(height: AppSpacing.sm),
                    _CardInfoSolicitud(
                      solicitud: solicitud,
                      comprobante: comprobante,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const _ListaVerificacion(),
                    const SizedBox(height: AppSpacing.sm),
                    const _TipProximoPaso(),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            ),
          ),

          // ── Botones fijos al pie ───────────────────────────────
          _BotonesFooter(solicitud: solicitud),
        ],
      ),
    );
  }
}

// ── Header azul con bordes redondeados abajo ──────────────────────────────────

class _HeaderGenerada extends StatelessWidget {
  const _HeaderGenerada();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppSizing.homeHeaderBottomRadius),
          bottomRight: Radius.circular(AppSizing.homeHeaderBottomRadius),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.xxs,
        AppSpacing.md,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Solicitud lista',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textOnDark,
              fontWeight: AppTextStyles.weightBold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            'Tu solicitud ha sido generada y está en proceso de validación',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textOnDark.withValues(alpha: 0.85),
              fontWeight: AppTextStyles.weightRegular,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Indicador de pasos del flujo post-generación ─────────────────────────────

class _PasosGeneradaIndicador extends StatelessWidget {
  final int pasoActual;

  const _PasosGeneradaIndicador({required this.pasoActual});

  static const _pasos = [
    'Completar ficha',
    'Validar ficha',
    'Adjuntar docs',
    'Enviar a cobranza',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizing.radiusMd),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              for (int i = 0; i < _pasos.length; i++)
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1.5,
                          color: i == 0
                              ? Colors.transparent
                              : (i <= pasoActual - 1
                                    ? AppColors.purple
                                    : AppColors.border),
                        ),
                      ),
                      _CirculoPaso(
                        numero: i + 1,
                        activo: (i + 1) == pasoActual,
                        completado: (i + 1) < pasoActual,
                      ),
                      Expanded(
                        child: Container(
                          height: 1.5,
                          color: i == _pasos.length - 1
                              ? Colors.transparent
                              : ((i + 1) < pasoActual
                                    ? AppColors.purple
                                    : AppColors.border),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              for (int i = 0; i < _pasos.length; i++)
                Expanded(
                  child: Text(
                    _pasos[i],
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: (i + 1) == pasoActual
                          ? AppTextStyles.weightBold
                          : AppTextStyles.weightRegular,
                      color: (i + 1) == pasoActual
                          ? AppColors.purple
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CirculoPaso extends StatelessWidget {
  final int numero;
  final bool activo;
  final bool completado;

  const _CirculoPaso({
    required this.numero,
    required this.activo,
    required this.completado,
  });

  @override
  Widget build(BuildContext context) {
    if (completado) {
      return Container(
        width: 28,
        height: 28,
        decoration: const BoxDecoration(
          color: AppColors.success,
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Icon(Icons.check, size: 16, color: AppColors.textOnDark),
        ),
      );
    }

    if (activo) {
      return Container(
        width: 28,
        height: 28,
        decoration: const BoxDecoration(
          color: AppColors.purple,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            '$numero',
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textOnDark,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border, width: 1.5),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '$numero',
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// ── Mensaje de éxito compacto ─────────────────────────────────────────────────

class _MensajeExito extends StatelessWidget {
  const _MensajeExito();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSizing.radiusMd),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 56,
            height: 56,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Positioned(top: 4, left: 2, child: _Chispa()),
                const Positioned(bottom: 4, right: 2, child: _Chispa()),
                Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: AppColors.textOnDark,
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¡Listo!',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: AppTextStyles.weightBold,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  'Solicitud validada y lista para enviar a cobranzas.',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 11,
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

class _Chispa extends StatelessWidget {
  const _Chispa();

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.auto_awesome,
      size: 11,
      color: AppColors.success.withValues(alpha: 0.55),
    );
  }
}

// ── Card de información de la solicitud ──────────────────────────────────────

class _CardInfoSolicitud extends StatelessWidget {
  final Solicitud solicitud;
  final String comprobante;

  const _CardInfoSolicitud({required this.solicitud, this.comprobante = ''});

  @override
  Widget build(BuildContext context) {
    final colorEstado = SolicitudCard.colorEstado(solicitud.ibValidado);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizing.radiusLg),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Cabecera: avatar + nombre + empresa ───────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.sm,
              AppSpacing.sm,
              AppSpacing.sm,
              AppSpacing.xs,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: AppSizing.avatarRadiusMd,
                  backgroundColor: AvatarUtils.color(solicitud.nombreCompleto),
                  child: Text(
                    AvatarUtils.initials(solicitud.nombreCompleto),
                    style: AppTextStyles.titleSmall.copyWith(
                      color: AppColors.textOnDark,
                      fontWeight: AppTextStyles.weightBold,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        solicitud.nombreCompleto,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: AppTextStyles.weightBold,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        solicitud.nombreEmpresa,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, thickness: 0.8),

          // ── Cuerpo: info izquierda + divider + ejecutivo derecha
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Columna izquierda — 3 filas
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FilaInfoCard(
                          icono: AppIcons.listAlt,
                          label: 'Oportunidad / Curso',
                          child: Text(
                            solicitud.oportunidad,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: AppTextStyles.weightBold,
                              fontSize: 10,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        _FilaInfoCard(
                          icono: AppIcons.checkCircle,
                          label: 'Condición',
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xs,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: colorEstado.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(
                                AppSizing.radiusCircular,
                              ),
                            ),
                            child: Text(
                              solicitud.estado,
                              style: AppTextStyles.labelSmall.copyWith(
                                color: colorEstado,
                                fontWeight: AppTextStyles.weightSemiBold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        _FilaInfoCard(
                          icono: AppIcons.fileFactura,
                          label: 'Tipo de comprobante',
                          child: Text(
                            comprobante.isEmpty ? '—' : comprobante,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: AppTextStyles.weightBold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Container(width: 1, color: AppColors.border),

                // Columna derecha — ejecutivo + origen
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ejecutivo',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 11,
                              backgroundColor: AvatarUtils.color(
                                solicitud.nombreAsesor,
                              ),
                              child: Text(
                                AvatarUtils.initials(solicitud.nombreAsesor),
                                style: const TextStyle(
                                  fontSize: 8,
                                  color: AppColors.textOnDark,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Expanded(
                              child: Text(
                                solicitud.nombreAsesor,
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: AppTextStyles.weightSemiBold,
                                  fontSize: 10,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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

class _FilaInfoCard extends StatelessWidget {
  final IconData icono;
  final String label;
  final Widget child;

  const _FilaInfoCard({
    required this.icono,
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icono, size: 13, color: AppColors.textSecondary),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 10,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        child,
      ],
    );
  }
}

// ── Lista de verificación decorativa ─────────────────────────────────────────

class _ListaVerificacion extends StatelessWidget {
  const _ListaVerificacion();

  static const _items = [
    ('Ficha completa', 'Toda la información requerida ha sido registrada.'),
    ('Ficha validada', 'La información ha sido revisada y validada.'),
    (
      'Documentos adjuntos',
      'Todos los documentos obligatorios están adjuntos.',
    ),
    (
      'Datos de facturación listos',
      'Información de facturación verificada y completa.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      child: Column(
        children: [
          for (int i = 0; i < _items.length; i++) ...[
            _ItemVerificacion(titulo: _items[i].$1, descripcion: _items[i].$2),
            if (i < _items.length - 1) const Divider(height: 1, thickness: 0.5),
          ],
        ],
      ),
    );
  }
}

class _ItemVerificacion extends StatelessWidget {
  final String titulo;
  final String descripcion;

  const _ItemVerificacion({required this.titulo, required this.descripcion});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              size: 14,
              color: AppColors.textOnDark,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: AppTextStyles.labelSmall.copyWith(
                    fontWeight: AppTextStyles.weightSemiBold,
                    color: AppColors.textPrimary,
                    fontSize: 11,
                  ),
                ),
                Text(
                  descripcion,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 10,
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

// ── Tip próximo paso ──────────────────────────────────────────────────────────

class _TipProximoPaso extends StatelessWidget {
  const _TipProximoPaso();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.purple.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(AppSizing.radiusMd),
        border: Border.all(color: AppColors.purple.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: AppColors.purple,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.assignment_add,
              color: AppColors.textOnDark,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Próximo paso',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: AppTextStyles.weightBold,
                    color: AppColors.purple,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                RichText(
                  text: TextSpan(
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                    children: const [
                      TextSpan(
                        text:
                            'Esta solicitud será enviada a Cobranzas, donde se encargará de ',
                      ),
                      TextSpan(
                        text: 'facturar y realizar el seguimiento de pago.',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
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

// ── Botones fijos al pie ──────────────────────────────────────────────────────

class _BotonesFooter extends StatelessWidget {
  final Solicitud solicitud;

  const _BotonesFooter({required this.solicitud});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Row(
        children: [
          // Volver a solicitudes
          Expanded(
            child: CustomOutlinedButton(
              text: 'Volver a solicitudes',
              icon: Icons.chevron_left,
              foregroundColor: AppColors.textSecondary,
              borderColor: AppColors.border,
              borderWidth: 1.5,
              height: AppSizing.buttonHeight,
              onPressed: () => context.goToSolicitudes(),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          // Enviar a cobranzas
          Expanded(
            child: CustomPrimaryButton(
              text: 'Enviar a cobranzas',
              icon: Icons.send,
              backgroundColor: AppColors.purple,
              onPressed: () async {
                final confirmado = await context.showConfirmDialog(
                  title: 'Enviar a cobranzas',
                  message:
                      '¿Estás seguro que deseas enviar esta solicitud a cobranzas?',
                  confirmText: 'Enviar',
                  cancelText: 'Cancelar',
                );
                if (confirmado && context.mounted) context.goToCobranza();
              },
            ),
          ),
        ],
      ),
    );
  }
}
