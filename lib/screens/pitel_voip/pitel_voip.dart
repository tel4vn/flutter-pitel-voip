import 'dart:io';

import 'package:flutter/material.dart';
import 'package:plugin_pitel/component/app_life_cycle/app_life_cycle.dart';

class PitelVoip extends StatelessWidget {
  final VoidCallback handleRegister;
  final Widget child;

  const PitelVoip({
    Key? key,
    required this.handleRegister,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppLifecycleTracker(
      didChangeAppState: (state) {
        if (Platform.isAndroid && state == AppState.opened) {
          handleRegister();
        }
        if (Platform.isAndroid && state == AppState.resumed) {
          handleRegister();
        }
        if (Platform.isIOS && state == AppState.resumed) {
          handleRegister();
        }
      },
      child: child,
    );
  }
}
