// lib/features/cobranza/domain/repositories/cobranza_repository.dart

import 'package:app_crm/features/cobranza/index_cobranza.dart';

abstract class CobranzaRepository {
  Future<List<Cobranza>> getCobranzas();
}
