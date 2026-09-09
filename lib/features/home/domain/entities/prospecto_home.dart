// lib/features/home/domain/entities/prospecto_home.dart

import 'package:app_crm/core/utils/string/string_utils.dart';

class ProspectoHome {
  final int idLead;
  final String nombre;
  final String nombreEmpresa;
  final String fechaHora;
  final String telefono;
  final String prefijoTelefono;

  const ProspectoHome({
    required this.idLead,
    required this.nombre,
    required this.nombreEmpresa,
    required this.fechaHora,
    required this.telefono,
    required this.prefijoTelefono,
  });

  String get telefonoCompleto => "$prefijoTelefono $telefono";

  /// Nombre a mostrar en UI. Si el contacto no tiene nombre registrado,
  /// muestra el número de teléfono como identificador.
  String get nombreMostrar =>
      nombre.trim().isNotEmpty ? nombre.aTitulo : telefonoCompleto;
}
