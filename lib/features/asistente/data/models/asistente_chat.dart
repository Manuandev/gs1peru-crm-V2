enum RemitenteChat { usuario, ia }

class AsistenteChat {
  final String texto;
  final RemitenteChat remitente;
  final DateTime timestamp;

  AsistenteChat({
    required this.texto,
    required this.remitente,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}
