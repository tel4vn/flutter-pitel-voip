import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plugin_pitel_example/color.dart';

class PitelTextField extends StatefulWidget {
  PitelTextField(
      {this.key,
      required this.controller,
      required this.keyboardType,
      this.obscureText = false,
      this.hintText = ''});

  @override
  Key? key;

  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool obscureText;
  String hintText;

  @override
  State<StatefulWidget> createState() {
    return _PitelTextFieldState();
  }
}

class _PitelTextFieldState extends State<PitelTextField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      key: widget.key,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: ColorApp.primaryColor),
        ),
        hintText: widget.hintText,
        hintStyle: TextStyle(
          color: Colors.grey,
        ),
      ),
      cursorColor: ColorApp.primaryColor,
      controller: widget.controller,
      autocorrect: false,
      keyboardType: widget.keyboardType,
      maxLines: 1,
      obscureText: widget.obscureText,
      style: TextStyle(color: ColorApp.primaryColor),
    );
  }
}
