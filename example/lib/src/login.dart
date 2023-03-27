import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plugin_pitel_example/color.dart';
import 'package:plugin_pitel_example/image.dart';
import 'package:plugin_pitel_example/navigator.dart';
import 'package:plugin_pitel_example/src/dialpad.dart';
import 'package:plugin_pitel_example/src/widgets/pitel_button.dart';
import 'package:plugin_pitel_example/src/widgets/pitel_textfield.dart';

class LoginWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginState();
  }
}

class _LoginState extends State<LoginWidget> {
  TextEditingController usernameController =
      TextEditingController(text: 'jack');
  TextEditingController passwordController =
      TextEditingController(text: 'jackSecret');

  void login() {
    var username = usernameController.text;
    var password = passwordController.text;
    if (username.isNotEmpty && password.isNotEmpty) {
      NavigatorSerivce.getInstance().pushReplacementNamed(
        '/main',
        arguments: DialPadArguments(
          username,
          password,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pitel SDK Example"),
      ),
      body: SizedBox.expand(
        child: Container(
          color: ColorApp.primaryColor,
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    height: 20,
                  ),
                  Image(
                    image: AssetImage(ImageApp.iconApp),
                    height: 150,
                  ),
                  Container(
                    height: 20,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    child: PitelTextField(
                      controller: usernameController,
                      keyboardType: TextInputType.text,
                      hintText: 'Username',
                    ),
                  ),
                  Container(
                    height: 10,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    child: PitelTextField(
                      controller: passwordController,
                      keyboardType: TextInputType.text,
                      hintText: 'Password',
                    ),
                  ),
                  Container(
                    height: 20,
                  ),
                  PitelButton(
                    onPressed: login,
                    text: 'Login',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
