// lib/features/cobranza/domain/entities/archivo_cobranza.dart

class ArchivoCobranza {
  final String tipo; // 'voucher' | 'oc' | otros que defina el backend
  final String archivoId;
  final String nombre;
  final String extension;

  String get nombreCompleto => '$nombre$extension';

  const ArchivoCobranza({
    required this.tipo,
    required this.archivoId,
    required this.nombre,
    required this.extension,
  });
}
