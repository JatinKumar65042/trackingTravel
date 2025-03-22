import 'package:flutter/material.dart';

class AppState {
  static String currentRoute = "/";
}

class RouteObserverService extends RouteObserver<PageRoute<dynamic>> {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route is PageRoute) {
      AppState.currentRoute = route.settings.name ?? "/";
      print("Navigated to: ${AppState.currentRoute}");
    }
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute is PageRoute) {
      AppState.currentRoute = previousRoute.settings.name ?? "/";
      print("Returned to: ${AppState.currentRoute}");
    }
    super.didPop(route, previousRoute);
  }
}
