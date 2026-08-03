// lib/core/presentation/widgets/app_process_overlay.dart

import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';

// Estado del proceso en curso — controla qué tarjeta muestra AppProcessOverlay.
enum AppProcessStatus { cargando, exito }

// Overlay de pantalla completa para operaciones asíncronas con feedback
// visual de dos pasos: "Guardando/Subiendo/Procesando..." (spinner) → check
// verde animado (éxito). Generaliza el patrón que ya usaban por separado
// AppLoadingOverlay + un check hardcodeado en cada pantalla (ej. Guardar
// negociación en lead/) — pensado para reusarse en cualquier flujo con el
// mismo patrón: guardar formularios, subir archivos/multimedia, etc.
//
// Uso típico (dentro de un Stack, como último hijo, junto al contenido):
// ```dart
// Stack(
//   children: [
//     MiFormulario(),
//     if (_status != null)
//       AppProcessOverlay(
//         status: _status!,
//         loadingMessage: 'Guardando...',
//         successMessage: 'Se guardó correctamente',
//       ),
//   ],
// )
// ```
// El caller decide cuándo mostrar `exito` (ej. tras un guardado exitoso) y
// cuándo ocultar el overlay por completo (dejar de renderizarlo) — este
// widget solo anima la transición entre sus dos estados, no controla
// temporizadores de auto-cierre.
class AppProcessOverlay extends StatelessWidget {
  final AppProcessStatus status;
  final String loadingMessage;
  final String successMessage;

  const AppProcessOverlay({
    super.key,
    required this.status,
    this.loadingMessage = 'Procesando...',
    this.successMessage = 'Listo',
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: AppColors.black(0.45),
        child: Center(
          child: AnimatedSwitcher(
            duration: _kTransitionDuration,
            switchInCurve: Curves.easeOutBack,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, animation) => ScaleTransition(
              scale: animation,
              child: FadeTransition(opacity: animation, child: child),
            ),
            child: status == AppProcessStatus.cargando
                ? _CargandoCard(
                    key: const ValueKey('cargando'),
                    mensaje: loadingMessage,
                  )
                : _ExitoCard(
                    key: const ValueKey('exito'),
                    mensaje: successMessage,
                  ),
          ),
        ),
      ),
    );
  }
}

// ── Timings de animación — locales a este widget, mismo criterio que las
// constantes privadas de estilo en custom_text_field.dart ──────────────────
const _kTransitionDuration = Duration(milliseconds: 350);
const _kCheckDuration = Duration(milliseconds: 550);

// ── Tarjeta base compartida ──────────────────────────────────────────────

class _ProcessCard extends StatelessWidget {
  final Widget child;

  const _ProcessCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 180),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSizing.radiusLg),
      ),
      child: child,
    );
  }
}

class _CargandoCard extends StatelessWidget {
  final String mensaje;

  const _CargandoCard({super.key, required this.mensaje});

  @override
  Widget build(BuildContext context) {
    return _ProcessCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: AppSizing.avatarXl,
            height: AppSizing.avatarXl,
            child: CircularProgressIndicator(
              strokeWidth: AppSizing.spinnerStrokeMedium,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            mensaje,
            textAlign: TextAlign.center,
            style: AppTextStyles.titleSmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: AppTextStyles.weightSemiBold,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExitoCard extends StatelessWidget {
  final String mensaje;

  const _ExitoCard({super.key, required this.mensaje});

  @override
  Widget build(BuildContext context) {
    return _ProcessCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _CheckAnimado(),
          const SizedBox(height: AppSpacing.md),
          Text(
            mensaje,
            textAlign: TextAlign.center,
            style: AppTextStyles.titleSmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: AppTextStyles.weightSemiBold,
            ),
          ),
        ],
      ),
    );
  }
}

// Círculo verde que aparece con un "pop" (easeOutBack) y el check adentro
// con un pequeño delay y rebote (elasticOut) — mismo patrón de confirmación
// que apps de pago/subida de archivos, en vez de un ícono estático.
class _CheckAnimado extends StatefulWidget {
  const _CheckAnimado();

  @override
  State<_CheckAnimado> createState() => _CheckAnimadoState();
}

class _CheckAnimadoState extends State<_CheckAnimado>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _escalaCirculo;
  late final Animation<double> _escalaCheck;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _kCheckDuration,
    );
    _escalaCirculo = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
    );
    _escalaCheck = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.45, 1.0, curve: Curves.elasticOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _escalaCirculo,
      child: Container(
        width: AppSizing.avatarXl,
        height: AppSizing.avatarXl,
        decoration: const BoxDecoration(
          color: AppColors.success,
          shape: BoxShape.circle,
        ),
        child: ScaleTransition(
          scale: _escalaCheck,
          child: const Icon(
            AppIcons.check,
            color: AppColors.textOnDark,
            size: AppSizing.iconXl,
          ),
        ),
      ),
    );
  }
}
