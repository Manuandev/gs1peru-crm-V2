// lib/features/lead/index_lead.dart

export 'data/datasources/remote/lead_remote_datasource.dart';

export 'data/models/negociacion_model.dart';
export 'data/models/comentario_lead_model.dart';
export 'data/models/historial_comentario_model.dart';
export 'data/models/contacto_model.dart';
export 'data/models/numero_model.dart';
export 'data/models/contacto_negociacion_model.dart';

export 'data/repositories/lead_repository_impl.dart';

export 'domain/entities/contacto.dart';
export 'domain/entities/numero.dart';
export 'domain/entities/contacto_negociacion.dart';
export 'domain/entities/comentario_lead.dart';
export 'domain/entities/negociacion.dart';
export 'domain/entities/historial_comentario.dart';

export 'domain/enums/lead_filtro.dart';
export 'domain/enums/lead_detail_tab_enum.dart';

export 'domain/repositories/lead_repository.dart';

export 'domain/usecases/get_leads_usecase.dart';
export 'domain/usecases/get_lead_detalle_usecase.dart';
export 'domain/usecases/get_lead_detalle_por_numero_usecase.dart';
export 'domain/usecases/get_negociaciones_lead.dart';
export 'domain/usecases/get_historial_comentarios.dart';
export 'domain/usecases/get_historial_seguimiento.dart';

export 'presentation/bloc/list/lead_list_bloc.dart';
export 'presentation/bloc/list/lead_list_event.dart';
export 'presentation/bloc/list/lead_list_state.dart';

export 'presentation/pages/lead_list_page.dart';
export 'presentation/pages/contacto_detalle_page.dart';

export 'presentation/widgets/contacto_detalle/contacto_detalle_skeleton.dart';
export 'presentation/widgets/contacto_detalle/contacto_acciones_footer.dart';
export 'presentation/widgets/contacto_detalle/contacto_detalle_view.dart';
export 'presentation/widgets/contacto_detalle/contacto_negociaciones_tab.dart';
export 'presentation/widgets/contacto_detalle/contacto_negociacion_card.dart';
export 'presentation/widgets/lead_detail_sheet/tabs/historial_tab.dart';
export 'presentation/widgets/contacto_detalle/contacto_info_tab.dart';
export 'presentation/widgets/lead_detail_sheet/negociacion_card.dart';
export 'presentation/widgets/lead_detail_sheet/tabs/datos_tab.dart';


export 'presentation/widgets/list/lead_list_portrait.dart';
export 'presentation/widgets/list/lead_list_view.dart';
export 'presentation/widgets/list/lead_list_skeleton.dart';
export 'presentation/widgets/list/lead_card_actions.dart';
export 'presentation/widgets/list/lead_card.dart';
export 'presentation/widgets/list/lead_list_filter_chips.dart';
export 'presentation/widgets/list/lead_list_stats_row.dart';

// Blocs + cubit movidos de chat → lead (ver CLAUDE.md del feature lead)
export 'presentation/bloc/edit_lead/edit_lead_bloc.dart';
export 'presentation/bloc/edit_lead/edit_lead_event.dart';
export 'presentation/bloc/edit_lead/edit_lead_state.dart';
export 'presentation/bloc/info_lead/info_lead_cubit.dart';
export 'presentation/bloc/info_lead/info_lead_state.dart';
export 'presentation/pages/edit_lead_page.dart';
export 'presentation/widgets/edit_lead/edit_lead_view.dart';
export 'presentation/widgets/edit_lead/edit_lead_portrait.dart';
export 'presentation/widgets/edit_lead/edit_lead_contacto_section.dart';
export 'presentation/widgets/edit_lead/edit_lead_negociacion_section.dart';
export 'presentation/widgets/edit_lead/edit_lead_financiera_section.dart';
export 'presentation/widgets/edit_lead/edit_lead_adicional_section.dart';
export 'presentation/widgets/edit_lead/lead_edit_header_card.dart';
export 'presentation/widgets/edit_lead/negociacion_resumen_card.dart';
export 'presentation/widgets/edit_lead/agregar_numero_panel.dart';
export 'presentation/widgets/edit_lead/agregar_correo_panel.dart';
export 'presentation/widgets/edit_lead/agregar_empresa_panel.dart';


// Cubits de LeadDetailSheet
export 'presentation/cubit/negociaciones/negociaciones_state.dart';
export 'presentation/cubit/negociaciones/negociaciones_cubit.dart';
export 'presentation/cubit/historial/historial_lead_state.dart';
export 'presentation/cubit/historial/historial_lead_cubit.dart';

export 'presentation/widgets/lead_detail_sheet/tabs/negociaciones_tab.dart';


