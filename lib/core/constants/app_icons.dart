// lib/core/constants/app_icons.dart

import 'package:flutter/material.dart';

/// Catálogo de Íconos del Sistema de Diseño
///
/// PROPÓSITO:
/// - Centralizar todos los íconos usados en la app en un único lugar
/// - Cambiar el ícono de una función afecta TODA la app automáticamente
/// - Nombres descriptivos que comunican propósito, no implementación
///
/// REGLA DE ORO:
/// Nunca uses `Icons.xxx` directamente en un widget.
/// Siempre usa `AppIcons.xxx` para mantener consistencia y facilitar cambios.
///
/// USO:
/// ```dart
/// Icon(AppIcons.user)
/// Icon(AppIcons.search, size: AppSizing.iconMd)
/// IconButton(icon: Icon(AppIcons.close), onPressed: () {})
/// ```
///
/// AÑADIR UN NUEVO ÍCONO:
/// 1. Identifica la sección correcta (navegación, auth, etc.)
/// 2. Agrega la constante con un nombre semántico
/// 3. Documenta cuándo usarlo con un comentario
class AppIcons {
  // Prevenir instanciación
  AppIcons._();

  // ============================================================
  // NAVEGACIÓN
  // ============================================================
  /// Inicio / Home — versión outline (inactivo)
  static const IconData home = Icons.home_outlined;

  /// Inicio / Home — versión rellena (activo)
  static const IconData homeFilled = Icons.home;

  /// Flecha atrás — botón de retroceso en AppBar
  static const IconData back = Icons.arrow_back;

  /// Flecha adelante — avanzar en flujo
  static const IconData forward = Icons.arrow_forward;

  /// Menú hamburguesa — toggle del Drawer
  static const IconData menu = Icons.menu;

  /// Cerrar / X — cerrar dialogs, bottom sheets
  static const IconData close = Icons.close;

  /// Tres puntos verticales — menú popup del AppBar
  static const IconData more = Icons.more_vert;

  /// Tres puntos horizontales — menú inline
  static const IconData moreHorizontal = Icons.more_horiz;

  // ============================================================
  // ACCIONES COMUNES
  // ============================================================
  /// Buscar — barra de búsqueda, filtros
  static const IconData search = Icons.search;

  /// Filtrar lista — drawer de filtros
  static const IconData filter = Icons.filter_list;

  /// Ordenar lista
  static const IconData sort = Icons.sort;

  /// Agregar / Crear — FAB, botones de nueva entidad
  static const IconData add = Icons.add;

  /// Editar — lápiz outline
  static const IconData edit = Icons.edit_outlined;

  /// Eliminar — bote de basura outline
  static const IconData delete = Icons.delete_outline;

  /// Guardar — ícono de guardar outline
  static const IconData save = Icons.save_outlined;

  /// Cancelar — circle con X
  static const IconData cancel = Icons.cancel_outlined;

  /// Check — confirmar acción simple
  static const IconData check = Icons.check;

  /// Check en círculo — éxito en un paso
  static const IconData checkCircle = Icons.check_circle_outline;

  // ============================================================
  // USUARIO Y AUTENTICACIÓN
  // ============================================================
  /// Persona outline — ícono de usuario inactivo / en campos
  static const IconData user = Icons.person_outline;

  /// Persona rellena — ícono de usuario activo / avatar fallback
  static const IconData userFilled = Icons.person;

  /// Grupo de personas — listado de usuarios / equipo
  static const IconData users = Icons.people_outline;

  /// Ingresar — acción de login
  static const IconData login = Icons.login;

  /// Salir — acción de logout
  static const IconData logout = Icons.logout;

  /// Candado cerrado — campo de contraseña, seguridad
  static const IconData lock = Icons.lock_outline;

  /// Candado abierto — sesión activa, permisos desbloqueados
  static const IconData lockOpen = Icons.lock_open_outlined;

  /// Ojo abierto — mostrar contraseña
  static const IconData visibility = Icons.visibility_outlined;

  /// Ojo tachado — ocultar contraseña
  static const IconData visibilityOff = Icons.visibility_off_outlined;

  // ============================================================
  // COMUNICACIÓN
  // ============================================================
  /// Email / sobre — campos de correo, contacto
  static const IconData email = Icons.email_outlined;

  /// Teléfono — campos de celular, llamar
  static const IconData phone = Icons.phone_outlined;

  /// Mensaje de texto — chat simple
  static const IconData message = Icons.message_outlined;

  /// Burbuja de chat — conversación
  static const IconData chat = Icons.chat_bubble_outline;

  /// Campana outline — notificaciones inactivas
  static const IconData notification = Icons.notifications_outlined;

  /// Campana rellena — notificaciones activas / con badge
  static const IconData notificationFilled = Icons.notifications;

  // ============================================================
  // ARCHIVOS Y DOCUMENTOS
  // ============================================================
  /// Archivo genérico outline
  static const IconData file = Icons.insert_drive_file_outlined;

  /// Carpeta outline — directorio
  static const IconData folder = Icons.folder_outlined;

  /// Subir a la nube — upload
  static const IconData upload = Icons.cloud_upload_outlined;

  /// Bajar de la nube — download
  static const IconData download = Icons.cloud_download_outlined;

  /// Adjunto — clip de archivo
  static const IconData attach = Icons.attach_file;

  /// Imagen outline — galería, foto
  static const IconData image = Icons.image_outlined;

  /// PDF outline — documento PDF
  static const IconData pdf = Icons.picture_as_pdf_outlined;

  // ============================================================
  // CONFIGURACIÓN Y HERRAMIENTAS
  // ============================================================
  /// Engranaje outline — pantalla de configuración
  static const IconData settings = Icons.settings_outlined;

  /// Info outline — información contextual
  static const IconData info = Icons.info_outline;

  /// Signo de pregunta — ayuda, FAQ
  static const IconData help = Icons.help_outline;

  /// Globo — idioma / región
  static const IconData language = Icons.language;

  /// Luna — modo oscuro
  static const IconData darkMode = Icons.dark_mode_outlined;

  /// Sol — modo claro
  static const IconData lightMode = Icons.light_mode_outlined;

  // ============================================================
  // ESTADO Y FEEDBACK
  // ============================================================
  /// Check en círculo — estado de éxito (snackbar, paso completado)
  static const IconData success = Icons.check_circle_outline;

  /// Círculo con X — estado de error (snackbar, formulario inválido)
  static const IconData error = Icons.error_outline;

  /// Triángulo de advertencia — alerta, warning
  static const IconData warning = Icons.warning_amber_outlined;

  /// Info en círculo — estado informativo
  static const IconData infoCircle = Icons.info_outline;

  // ============================================================
  // FECHAS Y TIEMPO
  // ============================================================
  /// Calendario simple — fecha puntual
  static const IconData calendar = Icons.calendar_today_outlined;

  /// Reloj — hora
  static const IconData time = Icons.access_time_outlined;

  /// Rango de fechas — período, filtro de fechas
  static const IconData date = Icons.date_range_outlined;

  // ============================================================
  // UBICACIÓN
  // ============================================================
  /// Marcador de mapa — dirección, ubicación exacta
  static const IconData location = Icons.location_on_outlined;

  /// Mapa outline — vista de mapa
  static const IconData map = Icons.map_outlined;

  /// Indicaciones — rutas
  static const IconData directions = Icons.directions;

  // ============================================================
  // COMERCIO
  // ============================================================
  /// Carrito de compras outline
  static const IconData cart = Icons.shopping_cart_outlined;

  /// Pago — método de pago
  static const IconData payment = Icons.payment_outlined;

  /// Tarjeta de crédito
  static const IconData creditCard = Icons.credit_card;

  /// Recibo / comprobante outline
  static const IconData receipt = Icons.receipt_outlined;

  // ============================================================
  // TRANSPORTE
  // ============================================================
  /// Camión / envío outline — logística, delivery
  static const IconData truck = Icons.local_shipping_outlined;

  /// Bus — transporte público
  static const IconData bus = Icons.directions_bus_outlined;

  /// Delivery — igual que truck, alias semántico
  static const IconData delivery = Icons.local_shipping_outlined;

  // ============================================================
  // FAVORITOS Y RATINGS
  // ============================================================
  /// Corazón outline — favorito inactivo
  static const IconData favorite = Icons.favorite_outline;

  /// Corazón relleno — favorito activo
  static const IconData favoriteFilled = Icons.favorite;

  /// Estrella outline — rating / favorito alternativo
  static const IconData star = Icons.star_outline;

  /// Estrella rellena — rating activo
  static const IconData starFilled = Icons.star;

  /// Media estrella — rating parcial
  static const IconData starHalf = Icons.star_half;

  // ============================================================
  // OTROS
  // ============================================================
  /// Copiar al portapapeles
  static const IconData copy = Icons.content_copy_outlined;

  /// Compartir
  static const IconData share = Icons.share_outlined;

  /// Imprimir
  static const IconData print = Icons.print_outlined;

  /// Refrescar / recargar
  static const IconData refresh = Icons.refresh;

  /// Sincronizar — sync en progreso
  static const IconData sync = Icons.sync;

  /// Ojo abierto(mostrar)
  // ignore: constant_identifier_names
  static const IconData visibility_icon = Icons.visibility_outlined;

  /// Ojo cerrado (ocultar)
  // ignore: constant_identifier_names
  static const IconData visibilityOff_icon = Icons.visibility_off_outlined;

  // ============================================================
  // SPLASH / BRANDING
  // ============================================================

  /// Rayo / Flash — ícono de splash screen y branding de la app.
  /// Se muestra en tamaño AppSizing.iconDisplay (120px) sobre el gradiente.
  static const IconData lightning = Icons.flash_on;
}
