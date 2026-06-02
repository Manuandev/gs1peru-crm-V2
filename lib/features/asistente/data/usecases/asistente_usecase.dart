
import 'package:app_crm/features/asistente/data/api/asistente_api.dart';
import 'package:app_crm/features/asistente/data/models/asistente_chat.dart';

class AsistenteUseCase {
  final AsistenteApi _api;

  AsistenteUseCase(this._api);

  Future<AsistenteChat?> enviarMensaje(String texto) async {
    if (texto.trim().isEmpty) return null;
    return await _api.enviarMensaje(texto.trim());
  }
}
