import 'package:flutter/material.dart';

class IconTextButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String textDisplay;
  final TextStyle? textStyle;

  const IconTextButton({
    Key? key,
    required this.icon,
    required this.onPressed,
    required this.textDisplay,
    this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(
          color: const Color(0xFF000000),
          icon: Icon(icon),
          onPressed: onPressed,
        ),
        Text(
          textDisplay,
          style: textStyle,
        )
      ],
    );
  }
}
