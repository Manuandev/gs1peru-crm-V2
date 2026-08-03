// lib/core/presentation/widgets/app_process_overlay.dart

import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/index_dependencies.dart';

// Estado del proceso en curso — controla qué tarjeta muestra AppProcessOverlay.
enum AppProcessStatus { cargando, exito }

// Overlay de pantalla completa para operaciones asíncronas con feedback
// visual de dos pasos: "Guardando/Subiendo/Procesando..." (logo de marca con
// resplandor + puntos animados) → check verde animado (éxito), con
// transición animada entre ambos (`AnimatedSwitcher` + scale/fade).
// Generaliza el patrón "loading card → check card" que antes se repetía a
// mano por pantalla (ej. Guardar negociación en lead/) — pensado para
// reusarse en cualquier flujo con el mismo patrón: guardar formularios,
// subir archivos/multimedia, etc.
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
const _kGlowDuration = Duration(milliseconds: 1400);
const _kDotsDuration = Duration(milliseconds: 1200);
const _kDotBounceHeight = 7.0;

// Aspect ratio real del logo GS1 Perú (assets/images/logo_gs1*.svg,
// 1142x767) — el "1" del wordmark queda fuera del círculo del isotipo, así
// que se muestra el logo completo con este ratio en vez de forzarlo a un
// cuadrado/círculo (un recorte cuadrado dejaría el isotipo diciendo "GS"
// nada más).
const _kLogoAspectRatio = 1142 / 767;

// ── Tarjeta base compartida ──────────────────────────────────────────────

class _ProcessCard extends StatelessWidget {
  final Widget child;

  const _ProcessCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      // Fijo (no mínimo) — ver comentario de AppSizing.processCardWidth/
      // processCardHeight: es la única forma de garantizar el mismo tamaño
      // exacto entre "cargando" y "éxito" sin importar el contenido.
      width: AppSizing.processCardWidth,
      height: AppSizing.processCardHeight,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSizing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.black(0.25),
            blurRadius: AppSizing.elevationHigh,
            offset: const Offset(0, AppSpacing.xs),
          ),
        ],
      ),
      child: child,
    );
  }
}

// Resplandor radial detrás del logo/check — le da profundidad a la tarjeta
// en vez de un ícono plano sobre fondo blanco liso.
class _Resplandor extends StatelessWidget {
  final Color color;
  final double escala;
  final double size;

  const _Resplandor({
    required this.color,
    required this.escala,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: escala,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, color.withAlpha(0)]),
        ),
      ),
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
        // Centra el contenido dentro del alto fijo compartido con
        // _ExitoCard (ver AppSizing.processCardHeight) — sin esto, cuando
        // el contenido es más chico que la tarjeta, quedaría pegado arriba
        // en vez de centrado.
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const _LogoCargando(),
          const SizedBox(height: AppSpacing.sm),
          Text(
            mensaje,
            textAlign: TextAlign.center,
            style: AppTextStyles.titleSmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: AppTextStyles.weightSemiBold,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          const _PuntosCarga(),
        ],
      ),
    );
  }
}

// Logo de marca con resplandor detrás (ambos respirando en loop, ver
// _kGlowDuration) — reemplaza al spinner genérico. El logo se muestra
// completo (isotipo + "GS1" + "Perú", ver _kLogoAspectRatio) para no
// arriesgar un recorte que corte el wordmark a la mitad.
class _LogoCargando extends StatefulWidget {
  const _LogoCargando();

  @override
  State<_LogoCargando> createState() => _LogoCargandoState();
}

class _LogoCargandoState extends State<_LogoCargando>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _escalaResplandor;
  late final Animation<double> _escalaLogo;
  late final Animation<double> _opacidadResplandor;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _kGlowDuration)
      ..repeat(reverse: true);
    final curva = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _escalaResplandor = Tween<double>(begin: 0.85, end: 1.08).animate(curva);
    _opacidadResplandor = Tween<double>(begin: 0.55, end: 1.0).animate(curva);
    _escalaLogo = Tween<double>(begin: 0.94, end: 1.0).animate(curva);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Stack(
        alignment: Alignment.center,
        children: [
          Opacity(
            opacity: _opacidadResplandor.value,
            child: _Resplandor(
              color: AppColors.primaryWithOpacity(0.18),
              escala: _escalaResplandor.value,
              size: AppSizing.processGlowSize,
            ),
          ),
          Transform.scale(scale: _escalaLogo.value, child: child),
        ],
      ),
      child: SizedBox(
        width: AppSizing.processLogoWidth,
        child: AspectRatio(
          aspectRatio: _kLogoAspectRatio,
          child: SvgPicture.asset(
            AppImages.logoTheme(context),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

// 3 puntos que rebotan en secuencia (mismo lenguaje de "escribiendo..." de
// apps de mensajería) — comunica "procesando" con más carácter que un
// spinner circular. Colores de marca alternados (primary/secondary).
class _PuntosCarga extends StatefulWidget {
  const _PuntosCarga();

  @override
  State<_PuntosCarga> createState() => _PuntosCargaState();
}

class _PuntosCargaState extends State<_PuntosCarga>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const _colores = [
    AppColors.primary,
    AppColors.secondary,
    AppColors.primary,
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _kDotsDuration)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(_colores.length, (i) {
            final fase = i / _colores.length;
            final t = (_controller.value + fase) % 1.0;
            // Triángulo 0→1→0 dentro del ciclo, suavizado — sube y baja.
            final subida = t < 0.5 ? t * 2 : (1 - t) * 2;
            final curva = Curves.easeInOut.transform(subida);
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xxs,
              ),
              child: Transform.translate(
                offset: Offset(0, -_kDotBounceHeight * curva),
                child: Container(
                  width: AppSizing.splashDotSize,
                  height: AppSizing.splashDotSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _colores[i],
                  ),
                ),
              ),
            );
          }),
        );
      },
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const _CheckAnimado(),
          const SizedBox(height: AppSpacing.sm),
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
// que apps de pago/subida de archivos, en vez de un ícono estático. Lleva el
// mismo resplandor radial (en verde) que el estado "cargando", para que
// ambas tarjetas se sientan parte de la misma familia visual.
class _CheckAnimado extends StatefulWidget {
  const _CheckAnimado();

  @override
  State<_CheckAnimado> createState() => _CheckAnimadoState();
}

class _CheckAnimadoState extends State<_CheckAnimado>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _escalaResplandor;
  late final Animation<double> _escalaCirculo;
  late final Animation<double> _escalaCheck;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _kCheckDuration,
    );
    _escalaResplandor = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 1.0, curve: Curves.easeOut),
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Stack(
        alignment: Alignment.center,
        children: [
          _Resplandor(
            color: AppColors.success.withAlpha(38),
            escala: _escalaResplandor.value,
            size: AppSizing.processGlowSizeCheck,
          ),
          child!,
        ],
      ),
      child: ScaleTransition(
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
      ),
    );
  }
}
