// lib/features/lead/index_lead.dart

export 'data/datasources/remote/lead_remote_datasource.dart';

export 'data/models/lead_model.dart';
export 'data/models/lead_detalle_model.dart';
export 'data/models/comentario_lead_model.dart';

export 'data/repositories/lead_repository_impl.dart';

export 'domain/entities/lead.dart';
export 'domain/entities/lead_detalle.dart';
export 'domain/entities/comentario_lead.dart';

export 'domain/enums/types_lead.dart';
export 'domain/enums/lead_filtro.dart';

export 'domain/repositories/lead_repository.dart';

export 'domain/usecases/get_leads_usecase.dart';
export 'domain/usecases/get_lead_detalle_usecase.dart';

export 'presentation/bloc/list/lead_list_bloc.dart';
export 'presentation/bloc/list/lead_list_event.dart';
export 'presentation/bloc/list/lead_list_state.dart';

export 'presentation/bloc/detail/lead_detalle_bloc.dart';
export 'presentation/bloc/detail/lead_detalle_event.dart';
export 'presentation/bloc/detail/lead_detalle_state.dart';

export 'presentation/pages/lead_list_page.dart';
export 'presentation/pages/lead_detalle_page.dart';

export 'presentation/widgets/detalle/lead_detalle_view.dart';
export 'presentation/widgets/detalle/lead_detalle_skeleton.dart';
export 'presentation/widgets/detalle/lead_detalle_stepper.dart';
export 'presentation/widgets/detalle/lead_detalle_info_card.dart';
export 'presentation/widgets/detalle/lead_detalle_comentarios.dart';
export 'presentation/widgets/detalle/lead_detalle_actions.dart';

export 'presentation/widgets/list/lead_list_portrait.dart';
export 'presentation/widgets/list/lead_list_view.dart';
export 'presentation/widgets/list/lead_card_actions.dart';
export 'presentation/widgets/list/lead_card.dart';
export 'presentation/widgets/list/lead_list_filter_chips.dart';

// Blocs + cubit movidos de chat → lead (ver CLAUDE.md del feature lead)
export 'presentation/bloc/edit_lead/edit_lead_bloc.dart';
export 'presentation/bloc/edit_lead/edit_lead_event.dart';
export 'presentation/bloc/edit_lead/edit_lead_state.dart';
export 'presentation/bloc/info_lead/info_lead_cubit.dart';
export 'presentation/bloc/info_lead/info_lead_state.dart';
export 'presentation/pages/edit_lead_page.dart';
export 'presentation/widgets/edit_lead/edit_lead_view.dart';
export 'presentation/widgets/edit_lead/edit_lead_portrait.dart';

// Puente temporal — eliminar cuando InfoLeadCubit use LeadRepository
export '../chat/domain/repositories/chat_repository.dart';
export '../chat/domain/usecases/get_info_lead_usecase.dart';
export '../chat/domain/usecases/update_lead_estado_usecase.dart';
export '../chat/domain/usecases/update_lead_info_usecase.dart';
export '../chat/domain/entities/info_lead.dart';
