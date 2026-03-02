import 'package:app_crm/features/recordatorios/data/datasources/remote/recordatorios_remote_datasource.dart';
import 'package:app_crm/features/recordatorios/data/models/recordatorio_model.dart';
import 'package:app_crm/features/recordatorios/domain/repositories/i_recordatorios_repository.dart';

class RecordatoriosRepository implements IRecordatoriosRepository {
  final RecordatoriosRemoteDatasource _remote;

  RecordatoriosRepository({required RecordatoriosRemoteDatasource remote}) : _remote = remote;

  @override
  Future<List<RecordatorioItem>> listarRecordatorios() => _remote.listarRecordatorios();

}
