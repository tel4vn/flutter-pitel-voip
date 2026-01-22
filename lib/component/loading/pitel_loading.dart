import 'package:flutter/material.dart';

class NavigationService {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}

class PitelLoading {
  PitelLoading._internal();

  static final PitelLoading instance = PitelLoading._internal();

  OverlayEntry? _overlayEntry;

  void show({String message = "Connecting..."}) {
    final context = NavigationService.navigatorKey.currentContext;
    if (context == null || _overlayEntry != null) return;

    _overlayEntry = OverlayEntry(
      builder: (context) => _LoadingWidget(message: message),
    );

    NavigationService.navigatorKey.currentState?.overlay
        ?.insert(_overlayEntry!);
  }

  void hide() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}

class _LoadingWidget extends StatelessWidget {
  const _LoadingWidget({this.message = "Connecting..."});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: AbsorbPointer(
        absorbing: true,
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const RepaintBoundary(
                  child: CircularProgressIndicator(
                      strokeWidth: 3, color: Colors.white),
                ),
                const SizedBox(height: 20),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
