import 'package:flutter/material.dart';
import 'package:flutter_pitel_voip/services/pitel_navigation_service.dart';

/// Enum for toast position
enum PitelToastPosition { top, center, bottom }

/// Extension for PitelToastPosition with Map-based alignment (OCP - Open/Closed)
extension PitelToastPositionExtension on PitelToastPosition {
  static const Map<PitelToastPosition, Alignment> alignmentMap = {
    PitelToastPosition.top: Alignment.topCenter,
    PitelToastPosition.center: Alignment.center,
    PitelToastPosition.bottom: Alignment.bottomCenter,
  };

  static const Map<PitelToastPosition, EdgeInsets> paddingMap = {
    PitelToastPosition.top: EdgeInsets.only(top: 80),
    PitelToastPosition.center: EdgeInsets.zero,
    PitelToastPosition.bottom: EdgeInsets.only(bottom: 80),
  };

  Alignment get alignment => alignmentMap[this] ?? Alignment.center;
  EdgeInsets get padding => paddingMap[this] ?? EdgeInsets.zero;
}

/// Loading service - Single Responsibility: Manage loading overlay only
class PitelLoading {
  PitelLoading._internal(this._overlayService);

  static final PitelLoading instance = PitelLoading._internal(
    NavigationService.instance,
  );

  final OverlayService _overlayService;
  OverlayEntry? _overlayEntry;

  void show({String message = "Connecting..."}) {
    final context = _overlayService.navigatorKey.currentContext;
    if (context == null || _overlayEntry != null) return;

    _overlayEntry = OverlayEntry(
      builder: (context) => _LoadingWidget(message: message),
    );

    _overlayService.insertOverlay(_overlayEntry!);
  }

  void hide() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}

/// Toast service - Single Responsibility: Manage toast overlay only
class PitelToast {
  PitelToast._internal(this._overlayService);

  static final PitelToast instance = PitelToast._internal(
    NavigationService.instance,
  );

  final OverlayService _overlayService;
  OverlayEntry? _toastEntry;

  void show({
    String message = "Toast is here",
    Duration duration = const Duration(seconds: 2),
    PitelToastPosition position = PitelToastPosition.bottom,
  }) {
    final context = _overlayService.navigatorKey.currentContext;
    if (context == null) return;

    _toastEntry?.remove();

    _toastEntry = OverlayEntry(
      builder: (context) => _ToastWidget(
        message: message,
        duration: duration,
        position: position,
        onDismiss: () {
          _toastEntry?.remove();
          _toastEntry = null;
        },
      ),
    );

    _overlayService.insertOverlay(_toastEntry!);
  }

  void hide() {
    _toastEntry?.remove();
    _toastEntry = null;
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

class _ToastWidget extends StatefulWidget {
  const _ToastWidget({
    required this.message,
    required this.duration,
    required this.position,
    required this.onDismiss,
  });

  final String message;
  final Duration duration;
  final PitelToastPosition position;
  final VoidCallback onDismiss;

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    _controller.forward();

    // Tự động đóng sau khoảng thời gian duration
    Future.delayed(widget.duration - const Duration(milliseconds: 300), () {
      if (mounted) {
        _controller.reverse().then((_) => widget.onDismiss());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: widget.position.alignment,
        child: FadeTransition(
          opacity: _opacity,
          child: Padding(
            padding: widget.position.padding,
            child: Material(
              color: Colors.transparent,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Text(
                  widget.message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
