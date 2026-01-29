import 'package:flutter/material.dart';
import 'call_timer.dart';

class VoiceHeader extends StatelessWidget {
  const VoiceHeader({
    Key? key,
    required this.voiceonly,
    required this.isStartTimer,
    required this.height,
    required this.remoteIdentity,
    required this.direction,
    required this.txtDirection,
    this.titleTextStyle,
    this.timerTextStyle,
    this.directionTextStyle,
    required this.txtTimer,
    required this.txtWaiting,
    this.startTime,
  }) : super(key: key);

  final DateTime? startTime;

  final bool voiceonly;
  final bool isStartTimer;
  final double height;
  final String? remoteIdentity;
  final String? direction;
  final String? txtDirection;
  final TextStyle? titleTextStyle;
  final TextStyle? timerTextStyle;
  final TextStyle? directionTextStyle;
  final String txtTimer;
  final String txtWaiting;

  @override
  Widget build(BuildContext context) {
    var directionDisplay = '${txtDirection ?? direction}...';

    return Positioned(
      top: voiceonly ? 60 : 6,
      left: 0,
      right: 0,
      child: Center(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            directionDisplay,
            style: directionTextStyle ??
                const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black),
          ),
          Container(
            padding: const EdgeInsets.all(6),
            margin: EdgeInsets.only(top: height * 0.1),
            child: Text(
              '$remoteIdentity',
              style: titleTextStyle ??
                  const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                      color: Colors.black),
            ),
          ),
          CallTimer(
            timerTextStyle: timerTextStyle,
            isStartTimer: isStartTimer,
            txtTimer: txtTimer,
            txtWaiting: txtWaiting,
            startTime: startTime,
          ),
        ],
      )),
    );
  }
}
