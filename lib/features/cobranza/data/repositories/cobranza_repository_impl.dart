// lib/features/cobranza/data/repositories/cobranza_repository_impl.dart

import 'package:app_crm/features/cobranza/index_cobranza.dart';

class CobranzaRepositoryImpl implements CobranzaRepository {
  final CobranzaRemoteDatasource _remote;

  CobranzaRepositoryImpl(this._remote);

  @override
  Future<List<Cobranza>> getCobranzas() => _remote.getCobranzas();
}
