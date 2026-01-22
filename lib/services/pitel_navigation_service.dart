import 'package:flutter/material.dart';

abstract class OverlayService {
  GlobalKey<NavigatorState> get navigatorKey;
  void insertOverlay(OverlayEntry entry);
}

class NavigationService implements OverlayService {
  NavigationService._();
  static final NavigationService _instance = NavigationService._();

  static NavigationService get instance => _instance;

  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void insertOverlay(OverlayEntry entry) {
    navigatorKey.currentState?.overlay?.insert(entry);
  }
}
