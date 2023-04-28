import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'call_page.dart';

class CallScreen extends StatelessWidget {
  final VoidCallback goBack;
  final Color bgColor;

  const CallScreen({
    Key? key,
    required this.goBack,
    required this.bgColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: bgColor,
        child: CallPageWidget(
          goBack: goBack,
        ),
      ),
    );
  }
}
