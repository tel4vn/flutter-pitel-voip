import 'dart:async';

import 'package:flutter/material.dart';

class CallTimer extends StatefulWidget {
  final TextStyle? timerTextStyle;
  final bool isStartTimer;
  final String txtTimer;
  final String txtWaiting;

  const CallTimer({
    Key? key,
    this.timerTextStyle,
    required this.isStartTimer,
    required this.txtTimer,
    required this.txtWaiting,
  }) : super(key: key);

  @override
  State<CallTimer> createState() => _CallTimerState();
}

class _CallTimerState extends State<CallTimer> {
  Timer? _timer;
  String _timeLabel = '00:00';

  @override
  void initState() {
    _timeLabel = widget.txtWaiting;
    super.initState();
  }

  @override
  void didUpdateWidget(oldWidget) {
    if (widget.isStartTimer) {
      _startTimer();
    }
    super.didUpdateWidget(oldWidget);
  }

  void _startTimer() {
    if (_timer != null) {
      _cancelTimer();
    }
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
  void dispose() {
    _cancelTimer();
    super.dispose();
  }

  void _cancelTimer() {
    if (_timer != null) {
      if (_timer!.isActive == true) {
        _timeLabel = '00:00';
        _timer!.cancel();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Text(
          _timeLabel,
          style: widget.timerTextStyle ??
              const TextStyle(fontSize: 14, color: Colors.black54),
        ),
      ),
    );
  }
}
