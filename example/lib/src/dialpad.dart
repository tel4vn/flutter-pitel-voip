import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:plugin_pitel/component/pitel_call_state.dart';
import 'package:plugin_pitel/component/sip_pitel_helper_listener.dart';
import 'package:plugin_pitel/pitel_sdk/pitel_call.dart';
import 'package:plugin_pitel/pitel_sdk/pitel_client.dart';
import 'package:plugin_pitel/sip/sip_ua.dart';
import 'package:plugin_pitel_example/color.dart';
import 'package:plugin_pitel_example/local_store.dart';
import 'package:plugin_pitel_example/navigator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'widgets/action_button.dart';

class DialPadArguments {
  final String username;
  final String password;
  DialPadArguments(this.username, this.password);
}

class DialPadWidget extends StatefulWidget {
  final PitelCall _pitelCall = PitelClient.getInstance().pitelCall;
  final DialPadArguments arguments;
  DialPadWidget({Key? key, required this.arguments}) : super(key: key);
  @override
  _MyDialPadWidget createState() => _MyDialPadWidget();
}

class _MyDialPadWidget extends State<DialPadWidget>
    implements SipPitelHelperListener {
  late String _dest;
  PitelCall get pitelCall => widget._pitelCall;
  final TextEditingController _textController = TextEditingController();
  NavigatorSerivce navigatorService = NavigatorSerivce.getInstance();
  late SharedPreferences _preferences;

  String receivedMsg = '';
  PitelClient pitelClient = PitelClient.getInstance();
  String state = '';

  @override
  initState() {
    super.initState();
    state = pitelCall.getRegisterState();
    receivedMsg = '';
    _bindEventListeners();
    _loadSettings();
    login();
  }

  @override
  void deactivate() {
    super.deactivate();
    _removeEventListeners();
  }

  void login() async {
    var token = await FirebaseMessaging.instance.getToken();
    debugPrint(
        'login dialpad ${widget.arguments.username} ${widget.arguments.password} ${token}');
    if (!pitelCall.isConnected) {
      pitelClient
          .login(widget.arguments.username, widget.arguments.password,
              fcmToken: token)
          .then((success) async {
        if (success) {
          var localStorage = LocalStorage();
          await localStorage.saveAccount(
              Account(widget.arguments.username, widget.arguments.password));
          debugPrint('login success');
        } else {
          debugPrint('login failed');
          goBack();
        }
      });
    }
  }

  void goBack() {
    pitelClient.release();
    navigatorService.pushReplacementNamed('/');
  }

  void _loadSettings() async {
    _preferences = await SharedPreferences.getInstance();
    _dest = _preferences.getString('dest') ?? '';
    _textController.text = _dest;
  }

  void _bindEventListeners() {
    pitelCall.addListener(this);
  }

  void _removeEventListeners() {
    pitelCall.removeListener(this);
  }

  void _handleCall(BuildContext context, [bool voiceonly = false]) {
    var dest = _textController.text;
    if (dest.isEmpty) {
      showDialog<Null>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Target is empty.'),
            content: Text('Please enter a SIP URI or username!'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  navigatorService.goBack();
                },
                child: Text('Ok'),
              ),
            ],
          );
        },
      );
    } else {
      pitelClient.call(dest, voiceonly);
      _preferences.setString('dest', dest);
    }
  }

  void _handleBackSpace([bool deleteAll = false]) {
    var text = _textController.text;
    if (text.isNotEmpty) {
      setState(() {
        text = deleteAll ? '' : text.substring(0, text.length - 1);
        _textController.text = text;
      });
    }
  }

  void _handleNum(String number) {
    setState(() {
      _textController.text += number;
    });
  }

  List<Widget> _buildNumPad() {
    var lables = [
      [
        {'1': ''},
        {'2': 'abc'},
        {'3': 'def'}
      ],
      [
        {'4': 'ghi'},
        {'5': 'jkl'},
        {'6': 'mno'}
      ],
      [
        {'7': 'pqrs'},
        {'8': 'tuv'},
        {'9': 'wxyz'}
      ],
      [
        {'*': ''},
        {'0': '+'},
        {'#': ''}
      ],
    ];

    return lables
        .map((row) => Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: row
                    .map((label) => ActionButton(
                          title: '${label.keys.first}',
                          subTitle: '${label.values.first}',
                          onPressed: () => _handleNum(label.keys.first),
                          number: true,
                        ))
                    .toList())))
        .toList();
  }

  List<Widget> _buildDialPad() {
    return [
      Container(
          width: 360,
          child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                    width: 360,
                    child: TextField(
                      keyboardType: TextInputType.text,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 24, color: ColorApp.textColor),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                      controller: _textController,
                      readOnly: true,
                    )),
              ])),
      Container(
          width: 300,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: _buildNumPad())),
      Container(
          width: 300,
          child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Opacity(
                    opacity: 0,
                    child: ActionButton(
                      icon: Icons.videocam,
                      onPressed: () => {
                        // _handleCall(context)
                      },
                    ),
                  ),
                  ActionButton(
                    icon: Icons.dialer_sip,
                    fillColor: Colors.green,
                    onPressed: () => _handleCall(context, true),
                  ),
                  Opacity(
                    opacity: _textController.text.isNotEmpty ? 1 : 0,
                    child: ActionButton(
                      icon: Icons.keyboard_arrow_left,
                      onPressed: () => _handleBackSpace(),
                      onLongPress: () => _handleBackSpace(true),
                    ),
                  ),
                ],
              )))
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorApp.primaryColor,
      appBar: AppBar(
        title: const Text("Pitel SDK Example"),
        brightness: Brightness.dark,
      ),
      body: Align(
        alignment: const Alignment(0, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(6.0),
              child: Center(
                  child: Text(
                'Status: $state',
                style: const TextStyle(fontSize: 14, color: ColorApp.textColor),
              )),
            ),
            Padding(
              padding: const EdgeInsets.all(6.0),
              child: Center(
                  child: Text(
                'Received Message: $receivedMsg',
                style: const TextStyle(fontSize: 14, color: ColorApp.textColor),
              )),
            ),
            Container(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: _buildDialPad(),
            )),
          ],
        ),
      ),
    );
  }

  @override
  void registrationStateChanged(PitelRegistrationState state) {
    debugPrint('registrationStateChanged ${state.state.toString()}');
    switch (state.state) {
      case PitelRegistrationStateEnum.REGISTRATION_FAILED:
        goBack();
        break;
      case PitelRegistrationStateEnum.NONE:
      case PitelRegistrationStateEnum.UNREGISTERED:
      case PitelRegistrationStateEnum.REGISTERED:
        setState(() {
          this.state = pitelCall.getRegisterState();
        });
        break;
    }
  }

  @override
  void onNewMessage(PitelSIPMessageRequest msg) {
    //Save the incoming message to DB
    var msgBody = msg.request.body as String;
    setState(() {
      receivedMsg = msgBody;
    });
  }

  @override
  void callStateChanged(String callId, PitelCallState state) {}

  @override
  void transportStateChanged(PitelTransportState state) {}

  @override
  void onCallReceived(String callId) {
    pitelCall.setCallCurrent(callId);
    navigatorService.navigateTo('/callscreen');
  }

  @override
  void onCallInitiated(String callId) {
    pitelCall.setCallCurrent(callId);
    navigatorService.navigateTo('/callscreen');
  }
}
