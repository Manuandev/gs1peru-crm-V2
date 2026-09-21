// Regresión del onboarding responsive (2026-09-21).
//
// Bug real: en celulares antiguos el primer frame llega con pantalla 0×0 y el
// slide 1 calculaba una altura negativa ("BoxConstraints has a negative minimum
// height"); en pantallas chicas los slides se desbordaban. Cada slide debe
// dibujarse sin errores de layout en cualquier tamaño, incluso 0×0 y con la
// fuente del sistema agrandada.
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart' show FontLoader;
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/auth/presentation/widgets/splash/onboarding_slide1.dart';
import 'package:app_crm/features/auth/presentation/widgets/splash/onboarding_slide2.dart';
import 'package:app_crm/features/auth/presentation/widgets/splash/onboarding_slide3.dart';
import 'package:app_crm/features/auth/presentation/widgets/splash/onboarding_slide4.dart';
import 'package:app_crm/features/auth/presentation/widgets/splash/onboarding_slide5.dart';
import 'package:app_crm/features/auth/presentation/widgets/splash/onboarding_slide6.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _slides = <String, Widget>{
  'slide 1': OnboardingSlide1(),
  'slide 2': OnboardingSlide2(),
  'slide 3': OnboardingSlide3(),
  'slide 4': OnboardingSlide4(),
  'slide 5': OnboardingSlide5(),
  'slide 6': OnboardingSlide6(),
};

// Tamaño del área del slide (sin el footer del carrusel).
const _tamanos = <Size>[
  Size.zero, // primer frame en celulares antiguos
  Size(320, 40), // frame transitorio casi sin alto
  Size(320, 170), // apenas sobre el mínimo de contenido
  Size(320, 400), // celular chico
  Size(360, 460), // celular normal
  Size(393, 670), // celular grande (tamaño de diseño)
  Size(800, 1120), // tablet
];

Future<void> _dibujar(
  WidgetTester tester,
  Widget slide,
  Size tamano, {
  double escalaTexto = 1.0,
}) {
  return tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.lightTheme,
      // Material igual que OnboardingCarousel — sin él el texto cae al estilo
      // de respaldo (monospace) y los anchos no se parecen a la app real.
      home: Material(
        child: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(escalaTexto)),
          child: Center(
            child: SizedBox(
              width: tamano.width,
              height: tamano.height,
              child: slide,
            ),
          ),
        ),
      ),
    ),
  );
}

/// Carga Roboto + Material Icons del SDK de Flutter (`FLUTTER_ROOT` siempre
/// está definido en `flutter test`). Sin esto los tests usan la fuente
/// `FlutterTest`, donde cada letra mide 1 em de ancho (~2× Roboto) y los
/// mockups "desbordan" en falso.
Future<void> _cargarFuentesReales() async {
  final raiz = Platform.environment['FLUTTER_ROOT'];
  if (raiz == null) return;
  final carpeta = '$raiz/bin/cache/artifacts/material_fonts';
  // Lectura síncrona: la IO asíncrona real no avanza dentro del binding de test.
  Future<ByteData> leer(String archivo) => Future.value(
        ByteData.view(File('$carpeta/$archivo').readAsBytesSync().buffer),
      );

  if (!File('$carpeta/roboto-regular.ttf').existsSync()) return;
  await (FontLoader('Roboto')
        ..addFont(leer('roboto-regular.ttf'))
        ..addFont(leer('roboto-medium.ttf'))
        ..addFont(leer('roboto-bold.ttf')))
      .load();
  await (FontLoader('MaterialIcons')..addFont(leer('materialicons-regular.otf')))
      .load();
}

void main() {
  setUpAll(_cargarFuentesReales);

  setUp(() {
    // La vista de prueba debe contener hasta el tamaño más grande (tablet).
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.platformDispatcher.views.first.physicalSize = const Size(1000, 1300);
    binding.platformDispatcher.views.first.devicePixelRatio = 1;
  });
  tearDown(() {
    TestWidgetsFlutterBinding.instance.platformDispatcher.views.first.reset();
  });

  for (final slide in _slides.entries) {
    for (final tamano in _tamanos) {
      testWidgets('${slide.key} sin errores de layout en $tamano', (tester) async {
        await _dibujar(tester, slide.value, tamano);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('${slide.key} sin errores con fuente del sistema al 130 %',
        (tester) async {
      await _dibujar(tester, slide.value, const Size(320, 400), escalaTexto: 1.3);
      expect(tester.takeException(), isNull);
    });
  }

  group('ResponsiveHelper.escalaLienzo', () {
    const diseno = Size(390, 430);

    test('0 si no hay espacio real', () {
      expect(ResponsiveHelper.escalaLienzo(Size.zero, diseno), 0);
    });

    test('toma el lado que más limita', () {
      expect(
        ResponsiveHelper.escalaLienzo(const Size(195, 1000), diseno),
        closeTo(0.5, 1e-9),
      );
      expect(
        ResponsiveHelper.escalaLienzo(const Size(1000, 215), diseno),
        closeTo(0.5, 1e-9),
      );
    });

    test('nunca pasa de escalaMaxima', () {
      expect(
        ResponsiveHelper.escalaLienzo(
          const Size(4000, 4000),
          diseno,
          escalaMaxima: 1.4,
        ),
        1.4,
      );
    });

    test('una dimensión infinita no limita', () {
      expect(
        ResponsiveHelper.escalaLienzo(
          const Size(195, double.infinity),
          diseno,
          escalaMaxima: 2,
        ),
        closeTo(0.5, 1e-9),
      );
    });
  });
}
