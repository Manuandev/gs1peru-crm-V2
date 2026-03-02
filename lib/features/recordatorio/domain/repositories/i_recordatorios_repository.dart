import 'package:app_crm/features/recordatorio/data/models/recordatorio_model.dart';

abstract class IRecordatoriosRepository {
  Future<List<RecordatorioItem>> listarRecordatorios();
}
