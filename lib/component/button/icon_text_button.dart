import 'package:flutter/material.dart';

class IconTextButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String textDisplay;
  final TextStyle? textStyle;
  final double width;
  final double height;

  const IconTextButton({
    Key? key,
    required this.icon,
    required this.onPressed,
    required this.textDisplay,
    required this.width,
    required this.height,
    this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
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
      ),
    );
  }
}
