// lib/features/solicitudes/domain/enums/solicitud_accion_tipo.dart

/// Tipo de acción que muestra la card, según [Solicitud.ibValidado] — regla
/// simplificada el 2026-07-16 (antes también miraba `idEstado`, ver
/// solicitudes/CLAUDE.md): ya no existe "Completar" como acción de la card,
/// solo "Validar"/"Ver". Qué puede hacerse dentro del detalle (editar vs.
/// solo continuar) se decide ahí con `Solicitud.puedeEditar` (`idEstado`),
/// no acá.
///
/// [ninguna]    → validada: solo "Ver"
/// [sinValidar] → sin validar: "Ver" + "Validar"
enum SolicitudAccionTipo { ninguna, sinValidar }
