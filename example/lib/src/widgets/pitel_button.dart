import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plugin_pitel_example/color.dart';

class PitelButton extends StatefulWidget {
  PitelButton({this.key, required this.onPressed, required this.text});
  @override
  Key? key;
  final Function() onPressed;
  final String text;

  @override
  State<StatefulWidget> createState() {
    return _PitelButtonState();
  }
}

class _PitelButtonState extends State<PitelButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      key: widget.key,
      onPressed: widget.onPressed,
      style: ElevatedButton.styleFrom(primary: Colors.white),
      child: Text(
        widget.text,
        style: TextStyle(
          color: ColorApp.primaryColor,
        ),
      ),
    );
  }
}
