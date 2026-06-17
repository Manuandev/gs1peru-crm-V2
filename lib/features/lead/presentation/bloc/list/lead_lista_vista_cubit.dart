// lib/features/lead/presentation/bloc/list/lead_lista_vista_cubit.dart

import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/core/index_core.dart';

/// Controla el modo de visualización de la lista de leads.
///
/// Estado emitido:
///   false → vista detallada (por defecto)
///   true  → vista compacta
///
/// La preferencia se persiste en LocalDatabase con clave [_kKey],
/// siguiendo el mismo patrón que ThemeCubit (setSetting / getSetting).
class LeadListVistaCubit extends Cubit<bool> {
  static const _kKey = 'lead_lista_compacta';

  LeadListVistaCubit() : super(false);

  Future<void> cargar() async {
    final valor = await LocalDatabase().getSetting(_kKey);
    emit(valor == '1');
  }

  Future<void> alternar() async {
    final nuevo = !state;
    await LocalDatabase().setSetting(_kKey, nuevo ? '1' : '0');
    emit(nuevo);
  }
}
