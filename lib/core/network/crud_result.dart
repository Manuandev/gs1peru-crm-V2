// lib/core/network/crud_result.dart

import 'package:app_crm/core/index_core.dart';

sealed class CrudResult {
  const CrudResult();
}

class CrudOk extends CrudResult {
  final String message;
  const CrudOk(this.message);
}

class CrudAlert extends CrudResult {
  final String message;
  const CrudAlert(this.message);
}

class CrudError extends CrudResult {
  final String message;
  const CrudError(this.message);
}

class CrudNoInternet extends CrudResult {
  const CrudNoInternet();
}

class CrudEmpty extends CrudResult {
  const CrudEmpty();
}

CrudResult parseCrudResponse(String raw) {
  final parte = raw.split(AppConstants.sepListas);

  switch (parte[0].toUpperCase()) {
    case 'OK':
      return CrudOk(parte.length > 1 ? parte[1] : '');
    case 'ALERTA':
      return CrudAlert(parte.length > 1 ? parte[1] : '');
    case 'ERROR':
      return CrudError(parte.length > 1 ? parte[1] : 'Error desconocido');
    default:
      return const CrudEmpty();
  }
}
