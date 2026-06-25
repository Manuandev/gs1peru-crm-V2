// lib/features/solicitudes/presentation/widgets/detail/solicitud_detalle_view.dart

import 'package:app_crm/config/router/navigation_extensions.dart';
import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/solicitudes/index_solicitudes.dart';

class SolicitudDetalleView extends StatelessWidget {
  final Solicitud solicitud;

  const SolicitudDetalleView({super.key, required this.solicitud});

  @override
  Widget build(BuildContext context) {
    return BasePage(
      onPop: () => context.goBack(),
      drawerSide: DrawerSide.none,
      bodyPadding: EdgeInsets.zero,
      title: 'Detalle de Solicitud',
      appBarLeadingButtons: [
        IconButton(
          onPressed: () => context.goBack(),
          icon: Icon(
            AppIcons.back,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      ],
      footer: const _BotonesDetalle(),
      body: Column(
        children: [
          // ── Header azul — conectado con el AppBar ─────────────
          const _DetalleHeader(),

          // ── Indicador de pasos — superpuesto al header ─────────
          // Transform.translate no afecta layout: visualmente sube
          // 16 px sobre el header sin romper el flujo del Column.
          Transform.translate(
            offset: const Offset(0, -AppSpacing.md),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: const _PasosIndicador(pasoActual: 1),
            ),
          ),

          // ── Contenido scrollable — también sube 16 px para ────
          // eliminar el hueco que deja el transform del indicador.
          // padding.top = md compensa el recorte del SingleChildScrollView.
          Expanded(
            child: Transform.translate(
              offset: const Offset(0, -AppSpacing.md),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.lg,
                ),
                child: Column(
                  children: [
                    SolicitudCard(
                      solicitud: solicitud,
                      mostrarBotones: false,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _SeccionDatosParticipante(solicitud: solicitud),
                    const SizedBox(height: AppSpacing.sm),
                    _SeccionDatosFacturacion(solicitud: solicitud),
                    const SizedBox(height: AppSpacing.sm),
                    _SeccionHistorial(fechaCreacion: solicitud.fechaCreacion),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Header azul bajo el AppBar ────────────────────────────────────────────────

class _DetalleHeader extends StatelessWidget {
  const _DetalleHeader();

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
        AppSpacing.xs,
        AppSpacing.md,
        AppSpacing.lg,
      ),
      child: Text(
        'Revisa la información y continúa con el proceso',
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textOnDark.withValues(alpha: 0.85),
        ),
      ),
    );
  }
}

// ── Indicador de pasos ────────────────────────────────────────────────────────

class _PasosIndicador extends StatelessWidget {
  final int pasoActual;

  const _PasosIndicador({required this.pasoActual});

  static const _etiquetas = [
    'Completar',
    'Validar',
    'Adjuntar',
    'Cobranza',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < _etiquetas.length; i++)
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      // Línea izquierda — transparente en el primer paso
                      Expanded(
                        child: Container(
                          height: 2,
                          color: i > 0
                              ? (i <= pasoActual
                                    ? AppColors.primary
                                    : AppColors.border)
                              : Colors.transparent,
                        ),
                      ),
                      _CirculoPaso(
                        numero: i + 1,
                        activo: (i + 1) == pasoActual,
                        completado: (i + 1) < pasoActual,
                      ),
                      // Línea derecha — transparente en el último paso
                      Expanded(
                        child: Container(
                          height: 2,
                          color: i < _etiquetas.length - 1
                              ? ((i + 1) <= pasoActual
                                    ? AppColors.primary
                                    : AppColors.border)
                              : Colors.transparent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    _etiquetas[i],
                    style: AppTextStyles.labelSmall.copyWith(
                      color: (i + 1) <= pasoActual
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      fontWeight: (i + 1) == pasoActual
                          ? AppTextStyles.weightSemiBold
                          : AppTextStyles.weightRegular,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
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
    final bool destacado = activo || completado;
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: destacado ? AppColors.primary : AppColors.surface,
        border: Border.all(
          color: destacado ? AppColors.primary : AppColors.border,
          width: 1.5,
        ),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '$numero',
          style: AppTextStyles.labelSmall.copyWith(
            color: destacado ? AppColors.textOnDark : AppColors.textSecondary,
            fontWeight: AppTextStyles.weightBold,
          ),
        ),
      ),
    );
  }
}

// ── Sección genérica reutilizable ─────────────────────────────────────────────

class _SeccionCard extends StatelessWidget {
  final Color colorIcono;
  final IconData icono;
  final String titulo;
  final List<Widget> children;

  const _SeccionCard({
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
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: colorIcono.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icono,
                  color: colorIcono,
                  size: AppSizing.iconActionSm,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                titulo,
                style: AppTextStyles.titleSmall.copyWith(
                  fontWeight: AppTextStyles.weightBold,
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

// ── Fila etiqueta / valor ─────────────────────────────────────────────────────

class _FilaInfo extends StatelessWidget {
  final String etiqueta;
  final String valor;
  final bool mostrarDivisor;

  const _FilaInfo({
    required this.etiqueta,
    required this.valor,
    this.mostrarDivisor = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 130,
                child: Text(
                  etiqueta,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  valor,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: AppTextStyles.weightMedium,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (mostrarDivisor)
          const Divider(color: AppColors.border, height: 1, thickness: 1),
      ],
    );
  }
}

// ── Datos del participante ────────────────────────────────────────────────────

class _SeccionDatosParticipante extends StatelessWidget {
  final Solicitud solicitud;

  const _SeccionDatosParticipante({required this.solicitud});

  @override
  Widget build(BuildContext context) {
    return _SeccionCard(
      colorIcono: AppColors.primary,
      icono: AppIcons.user,
      titulo: 'Datos del participante',
      children: [
        _FilaInfo(etiqueta: 'Correo', valor: solicitud.correo),
        _FilaInfo(etiqueta: 'Celular', valor: solicitud.telefono),
        const _FilaInfo(etiqueta: 'Documento', valor: 'DNI 45678912'),
        const _FilaInfo(
          etiqueta: 'Cargo',
          valor: 'Jefe de Logística',
          mostrarDivisor: false,
        ),
      ],
    );
  }
}

// ── Datos de facturación ──────────────────────────────────────────────────────

class _SeccionDatosFacturacion extends StatelessWidget {
  final Solicitud solicitud;

  const _SeccionDatosFacturacion({required this.solicitud});

  @override
  Widget build(BuildContext context) {
    return _SeccionCard(
      colorIcono: AppColors.purple,
      icono: AppIcons.receipt,
      titulo: 'Datos de facturación',
      children: [
        const _FilaInfo(etiqueta: 'Tipo de comprobante', valor: 'Factura'),
        _FilaInfo(etiqueta: 'Razón social', valor: solicitud.nombreEmpresa),
        const _FilaInfo(etiqueta: 'RUC', valor: '20501234567'),
        const _FilaInfo(
          etiqueta: 'Dirección fiscal',
          valor: 'Av. Javier Prado Este 1234, San Isidro, Lima',
          mostrarDivisor: false,
        ),
      ],
    );
  }
}

// ── Historial ─────────────────────────────────────────────────────────────────

class _SeccionHistorial extends StatelessWidget {
  final String fechaCreacion;

  const _SeccionHistorial({required this.fechaCreacion});

  @override
  Widget build(BuildContext context) {
    final fechaFormateada = fechaCreacion.formatDate(AppDateFormat.shortDate);

    final entradas = [
      (fechaFormateada, '10:35', 'Solicitud creada',
          'La solicitud fue registrada por el ejecutivo.', true),
      (fechaFormateada, '10:40', 'Ficha iniciada',
          'Se comenzó a completar la información del participante.', false),
      (fechaFormateada, '11:05', 'Guardado parcial',
          'La información fue guardada como borrador.', false),
    ];

    return _SeccionCard(
      colorIcono: AppColors.warning,
      icono: AppIcons.time,
      titulo: 'Historial',
      children: [
        for (int i = 0; i < entradas.length; i++)
          _EntradaHistorial(
            fecha: entradas[i].$1,
            hora: entradas[i].$2,
            titulo: entradas[i].$3,
            descripcion: entradas[i].$4,
            activo: entradas[i].$5,
            esUltimo: i == entradas.length - 1,
          ),
      ],
    );
  }
}

class _EntradaHistorial extends StatelessWidget {
  final String fecha;
  final String hora;
  final String titulo;
  final String descripcion;
  final bool activo;
  final bool esUltimo;

  const _EntradaHistorial({
    required this.fecha,
    required this.hora,
    required this.titulo,
    required this.descripcion,
    required this.activo,
    required this.esUltimo,
  });

  @override
  Widget build(BuildContext context) {
    final Color colorDot = activo ? AppColors.warning : AppColors.border;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Columna: punto + línea vertical
        SizedBox(
          width: 16,
          child: Column(
            children: [
              const SizedBox(height: 3),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: colorDot,
                  shape: BoxShape.circle,
                ),
              ),
              if (!esUltimo)
                Container(
                  width: 2,
                  height: 52,
                  margin: const EdgeInsets.only(top: 3),
                  color: AppColors.border,
                ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),

        // Contenido del evento
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: esUltimo ? 0 : AppSpacing.xs),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      fecha,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      hora,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  titulo,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: AppTextStyles.weightSemiBold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  descripcion,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Botones de acción al pie ──────────────────────────────────────────────────

class _BotonesDetalle extends StatelessWidget {
  const _BotonesDetalle();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.md,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(AppIcons.edit, size: AppSizing.iconActionSm),
              label: const Text('Editar ficha'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.border),
                minimumSize: const Size.fromHeight(AppSizing.buttonHeight),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizing.radiusMd),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: FilledButton.icon(
              onPressed: () {},
              icon: const Icon(
                AppIcons.forward,
                size: AppSizing.iconActionSm,
              ),
              label: const Text('Continuar'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnDark,
                minimumSize: const Size.fromHeight(AppSizing.buttonHeight),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizing.radiusMd),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
