// lib\core\index.dart

// #region constants
export 'constants/app_constants.dart';
export 'constants/api_constants.dart';
export 'constants/app_colors.dart';
export 'constants/app_icons.dart';
export 'constants/app_text_styles.dart';
export 'constants/app_breakpoints.dart';
export 'constants/app_images.dart';
export 'constants/app_menu_items.dart';
export 'constants/app_spacing.dart';
export 'constants/app_icons_social.dart';
// #endregion constants

// #region database
export 'database/i_local_database.dart';
export 'database/local_database.dart';
// #endregion database

export 'domain/enums/enums_core.dart';
export 'domain/usecases/get_catalogs_usecase.dart';

export 'errors/app_exception.dart';

export 'extensions/badge_extensions.dart';

export 'helpers/canal_helper.dart';

export 'mixins/comboable.dart';
export 'mixins/double_back_to_exit_mixin.dart';

// #region models
export 'models/combo_item.dart';
export 'models/user_model.dart';
export 'models/catalog_item.dart';
// #endregion models

export 'navigation/app_route_observer.dart';

// #region network
export 'network/api_client.dart';
export 'network/api_result.dart';
export 'network/crud_result.dart';
export 'network/catalog_remote_datasource.dart';

export 'network/interceptors/error_interceptor.dart';
export 'network/interceptors/interceptors.dart';
export 'network/interceptors/clean_response_interceptor.dart';
export 'network/interceptors/token_interceptor.dart';

export 'network/websocket/connection/i_signalr_service.dart';
export 'network/websocket/connection/signalr_service.dart';
export 'network/websocket/connection/websocket_connection_state.dart';
export 'network/websocket/connection/message_dispatcher.dart';

export 'network/websocket/parser/websocket_message.dart';
export 'network/websocket/parser/websocket_message_parser.dart';

export 'network/websocket/payloads/whatsapp_message_payload.dart';
export 'network/websocket/payloads/update_pantalla_whatsapp_payload.dart';
export 'network/websocket/payloads/update_mensaje_whatsapp_payload.dart';
// #endregion network

// #region notificaciones
export 'notifications/models/app_notification.dart';

export 'notifications/services/notification_service.dart';
export 'notifications/services/local_notification_service.dart';
export 'notifications/services/firebase_notification_service.dart';
export 'notifications/services/notification_permission_manager.dart';

export 'notifications/handlers/notification_handler.dart';
export 'notifications/handlers/notification_navigator.dart';
// #endregion notificaciones

// #region presentation
export 'presentation/bloc/drawer/drawer_bloc.dart';
export 'presentation/bloc/drawer/drawer_event.dart';
export 'presentation/bloc/drawer/drawer_state.dart';

export 'presentation/bloc/catalog/catalog_bloc.dart';
export 'presentation/bloc/catalog/catalog_event.dart';
export 'presentation/bloc/catalog/catalog_state.dart';

export 'presentation/pages/base_page.dart';
export 'presentation/pages/under_construction_page.dart';

export 'presentation/widgets/buttons/custom_google_button.dart';
export 'presentation/widgets/buttons/custom_outlined_button.dart';
export 'presentation/widgets/buttons/custom_primary_button.dart';
export 'presentation/widgets/buttons/custom_secondary_button.dart';
export 'presentation/widgets/buttons/custom_text_button.dart';

export 'presentation/widgets/inputs/custom_email_field.dart';
export 'presentation/widgets/inputs/custom_password_field.dart';
export 'presentation/widgets/inputs/custom_text_field.dart';

export 'presentation/widgets/inputs/custom_combo_field.dart';
export 'presentation/widgets/inputs/custom_combo_search_field.dart';
export 'presentation/widgets/inputs/custom_combo_multi_search_field.dart';

export 'presentation/widgets/navigation/app_drawer_widget.dart';
export 'presentation/widgets/navigation/custom_app_bar.dart';
export 'presentation/widgets/navigation/drawer_item_model.dart';
export 'presentation/widgets/navigation/exit_on_back_wrapper.dart';

export 'presentation/widgets/app_error_view.dart';
export 'presentation/widgets/app_loading_view.dart';
export 'presentation/widgets/app_empty_view.dart';
export 'presentation/widgets/app_snackbar.dart';
// #endregion presentation

export 'services/session_service.dart';
export 'services/device_info_service.dart';

export 'services/catalog_repository_impl.dart';
export 'services/catalog_repository.dart';

export 'theme/app_theme.dart';
export 'theme/theme_cubit.dart';

// #region utils
export 'utils/responsive_helper.dart';
export 'utils/elapsed_time_utils.dart';

export 'utils/date/date_extensions.dart';
export 'utils/date/date_formats.dart';
export 'utils/date/date_formatter.dart';

export 'utils/launcher/launcher_utils.dart';

export 'utils/string/string_utils.dart';
export 'utils/string/parse_utils.dart';  

// ui
export 'utils/ui/avatar_utils.dart';
export 'utils/ui/avatar_extensions.dart';
export 'utils/ui/file_type_utils.dart';
export 'utils/ui/color_utils.dart';

// #endregion utils
