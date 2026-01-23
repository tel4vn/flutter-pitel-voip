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
    this.startTime,
  }) : super(key: key);

  final DateTime? startTime;

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
      Duration duration;
      if (widget.startTime != null) {
        duration = DateTime.now().difference(widget.startTime!);
      } else {
        duration = Duration(seconds: timer.tick);
      }

      if (mounted) {
        setState(() {
          _timeLabel = [
            duration.inHours,
            duration.inMinutes,
            duration.inSeconds
          ]
              .map((seg) => seg.remainder(60).toString().padLeft(2, '0'))
              .join(':');
          // If hour is 00, remove it for cleaner look like 00:00
          if (_timeLabel.startsWith("00:")) {
            _timeLabel = _timeLabel.substring(3);
          }
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
