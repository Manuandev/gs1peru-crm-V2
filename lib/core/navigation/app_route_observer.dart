// lib/core/navigation/app_route_observer.dart

import 'package:flutter/material.dart';

/// Singleton que trackea la ruta activa y el lead abierto (para detalleChat).
/// Regístralo en MaterialApp(navigatorObservers: [AppRouteObserver.instance])
class AppRouteObserver extends RouteObserver<ModalRoute<Object?>> {
  AppRouteObserver._();
  static final AppRouteObserver instance = AppRouteObserver._();

  String? _currentRoute;
  int? _activeLeadId; // seteado por ChatDetailPage

  String? get currentRoute => _currentRoute;
  int? get activeLeadId => _activeLeadId;

  void setActiveLead(int? id) => _activeLeadId = id;

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    _currentRoute = route.settings.name;
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    _currentRoute = previousRoute?.settings.name;
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _currentRoute = newRoute?.settings.name;
  }
}