// lib/features/solicitudes/domain/enums/solicitud_accion_tipo.dart

/// Tipo de acción que muestra la card según el filtro activo.
///
/// [ninguna]    → filtros "Todas" y "Asesores": solo lectura
/// [sinValidar] → filtro "Sin validar": botones Ver + Validar
/// [cobranza]   → filtro "Enviar a cobranza": botones Ver + Completar
enum SolicitudAccionTipo {
  ninguna,
  sinValidar,
  cobranza,
}
