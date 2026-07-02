// lib/core/network/crud_result.dart

import 'package:app_crm/core/index_core.dart';

sealed class CrudResult {
  const CrudResult();
}

class CrudOk extends CrudResult {
  final String message;
  /// Dato extra opcional que algunos SP devuelven tras el 'OK' — ej. el
  /// ID_LEAD generado al crear un lead nuevo (ver [CSV_LEADS_CUD_APP] task 'U').
  final String? data;
  const CrudOk(this.message, {this.data});
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
      return CrudOk(
        parte.length > 1 ? parte[1] : '',
        data: parte.length > 2 ? parte[2] : null,
      );
    case 'ALERTA':
      return CrudAlert(parte.length > 1 ? parte[1] : '');
    case 'ERROR':
      return CrudError(parte.length > 1 ? parte[1] : 'Error desconocido');
    default:
      return const CrudEmpty();
  }
}
