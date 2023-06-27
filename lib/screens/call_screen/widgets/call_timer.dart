import 'dart:async';

import 'package:flutter/material.dart';

class CallTimer extends StatefulWidget {
  final TextStyle? timerTextStyle;

  const CallTimer({Key? key, this.timerTextStyle}) : super(key: key);

  @override
  State<CallTimer> createState() => _CallTimerState();
}

class _CallTimerState extends State<CallTimer> {
  late Timer _timer;
  String _timeLabel = '00:00';

  @override
  void initState() {
    _startTimer();
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
        _timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    if (_timer.isActive) {
      _timer.cancel();
    }
    super.dispose();
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
