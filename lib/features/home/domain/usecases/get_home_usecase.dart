// lib\features\home\domain\usecases\get_home_usecase.dart

import 'package:app_crm/features/home/index_home.dart';

class GetHomeUseCase {
  final HomeRepository repository;
  const GetHomeUseCase(this.repository);

  Future<Home> call() => repository.getData();
}
