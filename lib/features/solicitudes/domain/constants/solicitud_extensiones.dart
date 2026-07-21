// lib/features/solicitudes/domain/constants/solicitud_extensiones.dart
//
// Extensiones de archivo permitidas para los adjuntos del wizard (Voucher/
// O.C., paso 1) — un solo lugar para no desincronizar el filtro del picker
// (FilePicker.allowedExtensions) con la validación posterior.

class SolicitudExtensiones {
  SolicitudExtensiones._();

  // Solo PDF o imágenes (JPG/PNG) — mismo criterio para voucher y O.C.
  static const archivosAdjuntos = ['pdf', 'jpg', 'jpeg', 'png'];
}
