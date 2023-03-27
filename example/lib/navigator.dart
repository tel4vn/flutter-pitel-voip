import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NavigatorSerivce {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  static NavigatorSerivce? _instance;

  static NavigatorSerivce getInstance() {
    _instance ??= NavigatorSerivce();
    return _instance!;
  }

  GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  Future<dynamic> navigateTo(String routeName, {Object? arguments}) {
    log('DUYJACK navigateTo $routeName');
    return navigatorKey.currentState!
        .pushNamed(routeName, arguments: arguments);
  }

  Future<dynamic> pushReplacementNamed(String routeName, {Object? arguments}) {
    log('DUYJACK pushReplacementNamed $routeName');
    return _navigatorKey.currentState!
        .pushReplacementNamed(routeName, arguments: arguments);
  }

  void goBack() {
    log('DUYJACK goBack');
    return navigatorKey.currentState!.pop();
  }
}
