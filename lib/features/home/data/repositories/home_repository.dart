import 'package:app_crm/features/home/data/datasources/remote/home_remote_datasource.dart';
import 'package:app_crm/features/home/data/models/lead_model.dart';
import 'package:app_crm/features/home/domain/repositories/i_home_repository.dart';

class HomeRepository implements IHomeRepository {
  final HomeRemoteDatasource _remote;

  HomeRepository({required HomeRemoteDatasource remote}) : _remote = remote;

  @override
  Future<List<LeadItem>> listarLeads() => _remote.listarLeads();
}
