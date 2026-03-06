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
// #endregion constants

// #region database
export 'database/i_local_database.dart';
export 'database/local_database.dart';

export 'models/user_model.dart';
// #endregion database

export 'errors/app_exception.dart';

export 'extensions/badge_extensions.dart';

export 'mixins/double_back_to_exit_mixin.dart';

// #region network
export 'network/api_client.dart';

export 'network/interceptors/error_interceptor.dart';
export 'network/interceptors/interceptors.dart';
export 'network/interceptors/clean_response_interceptor.dart';
export 'network/interceptors/token_interceptor.dart';

export 'network/websocket/i_signalr_service.dart';
export 'network/websocket/signalr_service.dart';
export 'network/websocket/websocket.dart';
export 'network/websocket/websocket_connection_state.dart';
export 'network/websocket/websocket_message.dart';
export 'network/websocket/websocket_message_parser.dart';
// #endregion network

// #region presentation
export 'presentation/bloc/drawer/drawer_bloc.dart';
export 'presentation/bloc/drawer/drawer_event.dart';
export 'presentation/bloc/drawer/drawer_state.dart';

export 'presentation/pages/base_page.dart';

export 'presentation/widgets/buttons/custom_google_button.dart';
export 'presentation/widgets/buttons/custom_outlined_button.dart';
export 'presentation/widgets/buttons/custom_primary_button.dart';
export 'presentation/widgets/buttons/custom_secondary_button.dart';
export 'presentation/widgets/buttons/custom_text_button.dart';

export 'presentation/widgets/inputs/custom_email_field.dart';
export 'presentation/widgets/inputs/custom_password_field.dart';
export 'presentation/widgets/inputs/custom_text_field.dart';

export 'presentation/widgets/navigation/app_drawer_widget.dart';
export 'presentation/widgets/navigation/custom_app_bar.dart';
export 'presentation/widgets/navigation/drawer_item_model.dart';

export 'presentation/widgets/navigation/exit_on_back_wrapper.dart';
// #endregion presentation

export 'services/session_service.dart';
export 'services/device_info_service.dart';

export 'theme/app_theme.dart';
export 'theme/theme_cubit.dart';

// #region utils
export 'utils/responsive_helper.dart';

export 'utils/date/date_extensions.dart';
export 'utils/date/date_formats.dart';
export 'utils/date/date_formatter.dart';

export 'utils/string/string_utils.dart';
export 'utils/string/string_validators.dart';
// #endregion utils

// #region widgets
export 'presentation/widgets/app_error_view.dart';
export 'presentation/widgets/app_loading_view.dart';
export 'presentation/widgets/app_empty_view.dart';
// #endregion widgets