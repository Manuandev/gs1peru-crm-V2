// lib/features/auth/presentation/widgets/login/login_ola_clipper.dart

import 'package:flutter/material.dart';

/// Recorta la zona azul del login con una curva tipo ola en el borde inferior.
///
/// La ola desciende ~30dp en los extremos y sube ~40dp en el centro,
/// generando una transición suave hacia la zona blanca inferior.
class LoginOlaClipper extends CustomClipper<Path> {
  const LoginOlaClipper();

  @override
  Path getClip(Size size) {
    const double descenso = 30.0;
    const double ascenso = 40.0;

    final path = Path()
      ..lineTo(0, size.height - descenso)
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height + ascenso,
        size.width * 0.5,
        size.height - descenso * 0.3,
      )
      ..quadraticBezierTo(
        size.width * 0.75,
        size.height - ascenso - descenso,
        size.width,
        size.height - descenso,
      )
      ..lineTo(size.width, 0)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
