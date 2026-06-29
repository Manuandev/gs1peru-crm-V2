// lib/features/lead/presentation/widgets/contacto_detalle/contacto_negociaciones_tab.dart

import 'package:flutter/material.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class ContactoNegociacionesTab extends StatelessWidget {
  final List<Negociacion> negociaciones;

  const ContactoNegociacionesTab({super.key, required this.negociaciones});

  @override
  Widget build(BuildContext context) {
    if (negociaciones.isEmpty) {
      return _EstadoVacio(context: context);
    }
    return _ListaNegociaciones(negociaciones: negociaciones);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Lista con agrupación por mes
// ─────────────────────────────────────────────────────────────────────────────

class _ListaNegociaciones extends StatelessWidget {
  final List<Negociacion> negociaciones;

  const _ListaNegociaciones({required this.negociaciones});

  @override
  Widget build(BuildContext context) {
    final grupos = _agruparPorMes(negociaciones);

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.xxl,
      ),
      itemCount: grupos.length + 1, // +1 para el botón al final
      itemBuilder: (context, index) {
        if (index == grupos.length) {
          return _BotonNuevaNegociacion();
        }
        final grupo = grupos[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _MesHeader(mes: grupo.mes),
            ...grupo.negociaciones.map(
              (negociacion) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: ContactoNegociacionCard(negociacion: negociacion),
              ),
            ),
          ],
        );
      },
    );
  }

  List<_GrupoMes> _agruparPorMes(List<Negociacion> negociaciones) {
    final mapa = <String, List<Negociacion>>{};
    for (final negociacion in negociaciones) {
      final mes = negociacion.fechaHora.formatDate(AppDateFormat.monthYear);
      mapa.putIfAbsent(mes, () => []).add(negociacion);
    }
    return mapa.entries
        .map((e) => _GrupoMes(mes: e.key, negociaciones: e.value))
        .toList();
  }
}

class _GrupoMes {
  final String mes;
  final List<Negociacion> negociaciones;
  const _GrupoMes({required this.mes, required this.negociaciones});
}

class _MesHeader extends StatelessWidget {
  final String mes;

  const _MesHeader({required this.mes});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: AppSpacing.xs,
        top: AppSpacing.xs,
      ),
      child: Text(
        mes.isEmpty ? '—' : _capitalizar(mes),
        style: AppTextStyles.labelMedium.copyWith(
          color: AppColors.textSecondary,
          fontWeight: AppTextStyles.weightSemiBold,
        ),
      ),
    );
  }

  String _capitalizar(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

// ─────────────────────────────────────────────────────────────────────────────
// Botón + Nueva negociación
// ─────────────────────────────────────────────────────────────────────────────

class _BotonNuevaNegociacion extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: CustomOutlinedButton(
        text: '+ Nueva negociación',
        // TODO: navegar a pantalla de nueva negociación cuando esté definida
        onPressed: () {},
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Estado vacío
// ─────────────────────────────────────────────────────────────────────────────

class _EstadoVacio extends StatelessWidget {
  // ignore: unused_element
  final BuildContext context;

  const _EstadoVacio({required this.context});

  @override
  Widget build(BuildContext _) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ContenedorIcono(),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Sin negociaciones',
              style: AppTextStyles.titleSmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: AppTextStyles.weightSemiBold,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Este contacto aún no tiene negociaciones registradas.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            CustomPrimaryButton(
              text: '+ Crear negociación',
              backgroundColor: AppColors.success,
              // TODO: navegar a pantalla de nueva negociación cuando esté definida
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _ContenedorIcono extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(
        color: AppColors.grey400,
        radius: AppSizing.radiusXl,
        strokeWidth: AppSizing.borderWidthDashed,
      ),
      child: SizedBox(
        width: AppSizing.emptyStateContainer,
        height: AppSizing.emptyStateContainer,
        child: Center(
          child: Icon(
            AppIcons.inbox,
            size: AppSizing.iconXl,
            color: AppColors.grey400,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Painter de borde discontinuo
// ─────────────────────────────────────────────────────────────────────────────

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;
  final double strokeWidth;

  const _DashedBorderPainter({
    required this.color,
    required this.radius,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    const dashLength = 6.0;
    const gapLength = 4.0;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(strokeWidth / 2, strokeWidth / 2,
          size.width - strokeWidth, size.height - strokeWidth),
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        final end = (distance + dashLength).clamp(0, metric.length);
        canvas.drawPath(
          metric.extractPath(distance, end.toDouble()),
          paint,
        );
        distance += dashLength + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) =>
      old.color != color || old.radius != radius || old.strokeWidth != strokeWidth;
}
