// lib\features\prospectos\index.dart

export 'data/datasources/remote/prospecto_remote_datasource.dart';

export 'data/models/prospecto_model.dart';
export 'data/models/prospecto_detail_model.dart';

export 'data/repositories/prospecto_repository_impl.dart';

export 'domain/entities/prospecto.dart';
export 'domain/entities/prospecto_detail.dart';

export 'domain/repositories/prospecto_repository.dart';

export 'domain/usecases/get_prospectos_usecase.dart';

export 'presentation/bloc/prospecto_list_bloc.dart';
export 'presentation/bloc/prospecto_list_event.dart';
export 'presentation/bloc/prospecto_list_state.dart';

export 'presentation/pages/prospecto_list_page.dart';

export 'presentation/widgets/prospecto_list_landscape.dart';
export 'presentation/widgets/prospecto_list_portrait.dart';
export 'presentation/widgets/prospecto_list_view.dart';
