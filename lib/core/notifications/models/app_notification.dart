// lib/core/notifications/models/app_notification.dart

class AppNotification {
  final String title;
  final String body;
  final String? route;
  final Map<String, String>? payload;

  const AppNotification({
    required this.title,
    required this.body,
    this.route,
    this.payload,
  });

  String toPayloadString() {
    final map = <String, String>{
      'title': title, // necesitas incluir title y body
      'body': body, // para poder recuperarlos en fromPayloadString
      if (route != null) 'route': route!,
      ...?payload,
    };
    return map.entries.map((e) => '${e.key}=${e.value}').join('&');
  }

  static AppNotification fromPayloadString(String raw) {
    final map = Map.fromEntries(
      raw.split('&').where((e) => e.contains('=')).map((e) {
        final parts = e.split('=');
        return MapEntry(parts[0], parts.sublist(1).join('='));
      }),
    );
    return AppNotification(
      title: map.remove('title') ?? '',
      body: map.remove('body') ?? '',
      route: map.remove('route'),
      payload: map.isEmpty ? null : map,
    );
  }
}
