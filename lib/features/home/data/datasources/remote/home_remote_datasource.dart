// lib/features/home/data/datasources/remote/home_remote_datasource.dart
// ============================================================
// Llama a la API y retorna UserModel con todos los datos.
// ============================================================

import 'package:app_crm/core/constants/api_constants.dart';
import 'package:app_crm/core/network/api_client.dart';
import 'package:app_crm/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:app_crm/features/home/data/models/lead_model.dart';

class HomeRemoteDatasource {
  final ApiClient _api = ApiClient();
  final IAuthRepository _authRepository;

  HomeRemoteDatasource({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  Future<List<LeadItem>> listarLeads() async {
    // ✅ Tomas el codUser del usuario en sesión
    final codUser = _authRepository.currentUser?.codUser ?? '';

    if (codUser.isEmpty) {
      throw HomeException('No hay sesión activa.');
    }

    final String body = '$codUser¯L';

    final String raw = await _api.postJsonGetText(ApiConstants.urlLeads, body);

    if (raw.isEmpty) {
      throw HomeException(
        'No se pudo conectar al servidor. Verifica tu conexión a Internet.',
      );
    }

    try {
      return LeadItem.parseLeadList(raw);
    } on FormatException catch (e) {
      throw HomeException(e.message);
    }
  }
}

class HomeException implements Exception {
  final String message;
  const HomeException(this.message);

  @override
  String toString() => message;
}
