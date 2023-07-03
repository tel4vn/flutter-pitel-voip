import 'dart:async';

import 'package:flutter/material.dart';

class CallTimer extends StatefulWidget {
  final TextStyle? timerTextStyle;
  final bool isStartTimer;
  final String txtTimer;

  const CallTimer({
    Key? key,
    this.timerTextStyle,
    required this.isStartTimer,
    required this.txtTimer,
  }) : super(key: key);

  @override
  State<CallTimer> createState() => _CallTimerState();
}

class _CallTimerState extends State<CallTimer> {
  Timer? _timer;
  String _timeLabel = '00:00';

  @override
  void initState() {
    super.initState();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      final duration = Duration(seconds: timer.tick);
      if (mounted) {
        setState(() {
          _timeLabel = [duration.inMinutes, duration.inSeconds]
              .map((seg) => seg.remainder(60).toString().padLeft(2, '0'))
              .join(':');
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void didUpdateWidget(oldWidget) {
    if (widget.isStartTimer) {
      _startTimer();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    if (_timer != null) {
      if (_timer!.isActive) {
        _timer?.cancel();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Text(
          widget.txtTimer.isNotEmpty ? widget.txtTimer : _timeLabel,
          style: widget.timerTextStyle ??
              const TextStyle(fontSize: 14, color: Colors.black54),
        ),
      ),
    );
  }
}
