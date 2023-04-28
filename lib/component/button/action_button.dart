import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ActionButton extends StatelessWidget {
  final String title;
  final FontWeight fontWeight;
  final TextStyle titleStyle;
  final TextStyle subTitleStyle;
  final String subTitle;
  IconData? icon;
  final bool checked;
  final bool number;
  final Color? fillColor;
  final Function() onPressed;
  Function()? onLongPress;

  ActionButton(
      {Key? key,
      this.title = '',
      this.subTitle = '',
      this.fontWeight = FontWeight.w400,
      this.titleStyle = const TextStyle(),
      this.subTitleStyle = const TextStyle(),
      this.icon,
      required this.onPressed,
      this.onLongPress,
      this.checked = false,
      this.number = false,
      this.fillColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      // mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        GestureDetector(
            onLongPress: onLongPress,
            onTap: onPressed,
            child: RawMaterialButton(
              onPressed: onPressed,
              splashColor: fillColor ?? (checked ? Colors.white : Colors.blue),
              fillColor: fillColor ?? (checked ? Colors.blue : Colors.white),
              elevation: 0,
              shape: const CircleBorder(),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: number
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                            Text(
                              title,
                              style: titleStyle,
                            ),
                            Text(
                              subTitle.toUpperCase(),
                              style: subTitleStyle,
                            )
                          ])
                    : Icon(
                        icon,
                        size: 30.0,
                        color: fillColor != null
                            ? Colors.white
                            : (checked ? Colors.white : Colors.green),
                      ),
              ),
            )),
      ],
    );
  }
}
