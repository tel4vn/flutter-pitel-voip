import 'package:flutter/material.dart';
import 'call_timer.dart';

class VoiceHeader extends StatelessWidget {
  const VoiceHeader({
    Key? key,
    required this.voiceonly,
    required this.height,
    required this.remoteIdentity,
    required this.direction,
  }) : super(key: key);

  final bool voiceonly;
  final double height;
  final String? remoteIdentity;
  final String? direction;

  @override
  Widget build(BuildContext context) {
    var directionDisplay = '$direction...';

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
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),
          ),
          Container(
            padding: const EdgeInsets.all(6),
            margin: EdgeInsets.only(top: height * 0.1),
            child: Text(
              '$remoteIdentity',
              style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: Colors.black),
            ),
          ),
          const CallTimer(),
        ],
      )),
    );
  }
}
