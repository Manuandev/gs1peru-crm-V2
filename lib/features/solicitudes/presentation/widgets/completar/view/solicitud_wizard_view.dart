// lib/features/solicitudes/presentation/widgets/completar/view/solicitud_wizard_view.dart

import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/features/solicitudes/index_solicitudes.dart';

/// Wizard de 4 pasos (Solicitante → Participantes → Facturación → Resumen)
/// como una sola page — AppBar, `SolicitudPasosIndicador` y footer nunca se
/// reconstruyen ni animan entre pasos, solo el body interno cambia. Antes
/// cada paso era una ruta empujada aparte (`goToFichaXxxSolicitud`), lo que
/// producía la transición completa de pantalla en cada "Continuar"/"Atrás" y
/// perdía los datos tipeados de un paso si no se llegaba a presionar
/// "Continuar"/"Guardar" antes de retroceder. Ver CLAUDE.md del feature.
///
/// "Carga masiva" (paso 2) sigue siendo una ruta aparte — es un sub-flujo
/// con su propio selector de archivo, no un paso del wizard.
class SolicitudWizardView extends StatefulWidget {
  final Solicitud solicitud;
  final bool modoEdicion;

  const SolicitudWizardView({
    super.key,
    required this.solicitud,
    required this.modoEdicion,
  });

  @override
  State<SolicitudWizardView> createState() => _SolicitudWizardViewState();
}

class _SolicitudWizardViewState extends State<SolicitudWizardView> {
  int _pasoActual = 1;

  // Pasos que ya se visitaron al menos una vez — solo esos se construyen
  // dentro del IndexedStack. Necesario porque el paso 3 (Facturación) tiene
  // un prellenado de una sola vez en `didChangeDependencies` que depende de
  // que el paso 1 ya haya guardado al solicitante: si IndexedStack
  // construyera los 4 pasos de una vez al abrir el wizard, ese prellenado
  // se dispararía antes de tiempo (con el solicitante aún vacío) y se
  // perdería para el resto de la sesión. Una vez construido, el paso se
  // mantiene siempre en el árbol (IndexedStack no lo destruye al cambiar de
  // índice) — así es como se preserva lo tipeado al moverse entre pasos.
  final Set<int> _pasosConstruidos = {1};

  void _irAPaso(int paso) => setState(() {
    _pasoActual = paso;
    _pasosConstruidos.add(paso);
  });

  // Mismo comportamiento que tenían las rutas separadas: el ícono de
  // regreso del AppBar (y el back físico/gesto, vía onPop) retrocede un
  // paso dentro del wizard; en el paso 1 sale del wizard entero (con la
  // misma confirmación condicional que el botón "Cancelar", ver
  // _confirmarSalir).
  void _retroceder() {
    if (_pasoActual > 1) {
      _irAPaso(_pasoActual - 1);
    } else {
      _confirmarSalir();
    }
  }

  // Sale del wizard entero. Solo pide confirmación si de verdad hay algo
  // que se perdería (huboCambiosSinGuardar) — abrir el wizard y salir sin
  // tocar nada no debe interrumpir con ningún diálogo. Único punto que
  // decide esto: tanto el botón "Cancelar" del paso 1 como el back del
  // AppBar/gesto físico (_retroceder, arriba) pasan por acá.
  Future<void> _confirmarSalir() async {
    if (!huboCambiosSinGuardar(context)) {
      context.goBack();
      return;
    }
    final confirmado = await context.showConfirmDialog(
      title: 'Cancelar solicitud',
      message:
          'Tiene cambios sin guardar. ¿Desea cancelar el proceso de '
          'solicitud? Los cambios se perderán.',
      confirmText: 'Sí, cancelar',
      cancelText: 'No',
    );
    if (confirmado && mounted) context.goBack();
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      onPop: _retroceder,
      drawerSide: DrawerSide.none,
      bodyPadding: EdgeInsets.zero,
      title: 'Solicitud de inscripción',
      appBarLeadingButtons: [
        IconButton(
          onPressed: _retroceder,
          icon: Icon(
            AppIcons.back,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      ],
      appBarTrailingButtons: [SolicitudBadgePaso(paso: _pasoActual)],
      body: Column(
        children: [
          SolicitudPasosIndicador(pasoActual: _pasoActual),
          Expanded(
            child: IndexedStack(
              index: _pasoActual - 1,
              children: [
                if (_pasosConstruidos.contains(1))
                  SolicitudCompletarView(
                    solicitud: widget.solicitud,
                    modoEdicion: widget.modoEdicion,
                    onContinuar: () => _irAPaso(2),
                    onCancelar: _confirmarSalir,
                  )
                else
                  const SizedBox.shrink(),
                if (_pasosConstruidos.contains(2))
                  SolicitudParticipantesView(
                    solicitud: widget.solicitud,
                    modoEdicion: widget.modoEdicion,
                    onContinuar: _irAPaso,
                    onAtras: () => _irAPaso(1),
                  )
                else
                  const SizedBox.shrink(),
                if (_pasosConstruidos.contains(3))
                  SolicitudFacturacionView(
                    solicitud: widget.solicitud,
                    modoEdicion: widget.modoEdicion,
                    onContinuar: () => _irAPaso(4),
                    onAtras: () => _irAPaso(2),
                  )
                else
                  const SizedBox.shrink(),
                if (_pasosConstruidos.contains(4))
                  SolicitudResumenView(
                    solicitud: widget.solicitud,
                    modoEdicion: widget.modoEdicion,
                    onEditarPaso: _irAPaso,
                    onAtras: () => _irAPaso(3),
                  )
                else
                  const SizedBox.shrink(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
