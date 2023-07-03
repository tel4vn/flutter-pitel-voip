import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:plugin_pitel/component/button/action_button.dart';
import 'package:plugin_pitel/component/button/icon_text_button.dart';
import 'package:plugin_pitel/flutter_pitel_voip.dart';
import 'package:wakelock/wakelock.dart';

import 'widgets/voice_header.dart';

class CallPageWidget extends StatefulWidget {
  CallPageWidget({
    Key? key,
    this.receivedBackground = false,
    required this.callState,
    required this.onCallState,
    required this.txtMute,
    required this.txtUnMute,
    required this.txtSpeaker,
    required this.txtOutgoing,
    required this.txtIncoming,
    required this.userName,
    required this.txtTimer,
    this.textStyle,
    this.titleTextStyle,
    this.timerTextStyle,
    this.directionTextStyle,
  }) : super(key: key);

  final PitelCall _pitelCall = PitelClient.getInstance().pitelCall;
  final bool receivedBackground;
  final PitelCallStateEnum callState;
  final Function(PitelCallStateEnum) onCallState;
  final String txtMute;
  final String txtUnMute;
  final String txtSpeaker;
  final String txtOutgoing;
  final String txtIncoming;
  final String txtTimer;
  final String userName;
  final TextStyle? textStyle;
  final TextStyle? titleTextStyle;
  final TextStyle? timerTextStyle;
  final TextStyle? directionTextStyle;

  @override
  State<CallPageWidget> createState() => _MyCallPageWidget();
}

class _MyCallPageWidget extends State<CallPageWidget>
    implements SipPitelHelperListener {
  PitelCall get pitelCall => widget._pitelCall;

  bool _speakerOn = false;
  bool calling = false;
  bool _isBacked = false;
  PitelCallStateEnum _state = PitelCallStateEnum.NONE;
  bool isStartTimer = false;

  bool get voiceonly => pitelCall.isVoiceOnly();

  String? get remoteIdentity => pitelCall.remoteIdentity;

  String? get direction => pitelCall.direction;
  String _callId = '';

  @override
  initState() {
    super.initState();
    pitelCall.addListener(this);
    _state = widget.callState;
    handleCall();
    if (voiceonly) {
      _initRenderers();
    }
  }

  void handleCall() {
    if (Platform.isAndroid) {
      Wakelock.enable();
      if (direction != 'OUTGOING') {
        pitelCall.answer();
      }
    }
  }

  @override
  deactivate() {
    super.deactivate();
    _handleHangup();
    pitelCall.removeListener(this);
    _disposeRenderers();
  }

  void _initRenderers() async {
    if (!voiceonly) {
      await pitelCall.initializeLocal();
      await pitelCall.initializeRemote();
    }
  }

  void _disposeRenderers() {
    pitelCall.disposeLocalRenderer();
    pitelCall.disposeRemoteRenderer();
  }

  void _backToDialPad() {
    if (mounted && !_isBacked) {
      if (direction != 'OUTGOING') {
        FlutterCallkitIncoming.endAllCalls();
      }
      _isBacked = true;
    }
  }

  void _handleHangup() {
    if (Platform.isAndroid) {
      Wakelock.disable();
    }
    pitelCall.hangup(callId: _callId);
  }

  void _toggleSpeaker() {
    if (pitelCall.localStream != null) {
      setState(() {
        _speakerOn = !_speakerOn;
      });
      pitelCall.enableSpeakerphone(_speakerOn);
    }
  }

  var basicActions = <Widget>[];

  List<Widget> _renderAdvanceAction() {
    return <Widget>[
      IconTextButton(
        textDisplay: pitelCall.audioMuted ? widget.txtUnMute : widget.txtMute,
        textStyle: widget.textStyle,
        icon: pitelCall.audioMuted ? Icons.mic_off : Icons.mic,
        onPressed: () {
          pitelCall.mute(callId: _callId);
        },
      ),
      IconTextButton(
        textDisplay: widget.txtSpeaker,
        textStyle: widget.textStyle,
        icon: _speakerOn ? Icons.volume_up : Icons.volume_off,
        onPressed: () => _toggleSpeaker(),
      ),
    ];
  }

  Widget _buildActionButtons() {
    var hangupBtn = ActionButton(
      onPressed: () {
        _handleHangup();
        _backToDialPad();
      },
      icon: Icons.call_end,
      fillColor: Colors.red,
    );

    var hangupBtnInactive = ActionButton(
      title: "hangup",
      onPressed: () {},
      icon: Icons.call_end,
      fillColor: Colors.grey,
    );

    var advanceActions =
        direction == 'OUTGOING' ? _renderAdvanceAction() : <Widget>[];

    switch (_state) {
      case PitelCallStateEnum.NONE:
      case PitelCallStateEnum.PROGRESS:
        if (direction == 'OUTGOING') {
          basicActions = [hangupBtn];
        }
        break;
      case PitelCallStateEnum.STREAM:
        advanceActions = _renderAdvanceAction();
        basicActions = [hangupBtn];
        break;
      case PitelCallStateEnum.CONNECTING:
      case PitelCallStateEnum.MUTED:
      case PitelCallStateEnum.UNMUTED:
      case PitelCallStateEnum.ACCEPTED:
      case PitelCallStateEnum.CONFIRMED:
      case PitelCallStateEnum.FAILED:
        advanceActions = _renderAdvanceAction();
        basicActions = [hangupBtn];
        break;
      case PitelCallStateEnum.ENDED:
        basicActions = [hangupBtnInactive];
        break;
      default:
        break;
    }

    var actionWidgets = <Widget>[];

    if (advanceActions.isNotEmpty) {
      actionWidgets.add(Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white.withOpacity(0.6),
        ),
        margin: const EdgeInsets.only(left: 30, right: 30, bottom: 30),
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: advanceActions,
        ),
      ));
    }
    final height = MediaQuery.of(context).size.height;
    actionWidgets.add(
      Column(
        children: [
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: basicActions),
          SizedBox(height: height * 0.07),
        ],
      ),
    );
    return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: actionWidgets);
  }

  Widget _buildContent() {
    final height = MediaQuery.of(context).size.height;

    var stackWidgets = <Widget>[];

    if (!voiceonly &&
        pitelCall.remoteStream != null &&
        pitelCall.remoteRenderer != null) {
      stackWidgets.add(Center(
        child: PitelRTCVideoView(pitelCall.remoteRenderer!),
      ));
    }

    if (!voiceonly &&
        pitelCall.localStream != null &&
        pitelCall.localRenderer != null) {
      stackWidgets.add(Container(
        alignment: Alignment.topRight,
        child: AnimatedContainer(
          height: 0,
          width: 0,
          alignment: Alignment.topRight,
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.all(0),
          child: PitelRTCVideoView(pitelCall.localRenderer!),
        ),
      ));
    }

    stackWidgets.addAll([
      pitelCall.isConnected && pitelCall.isHaveCall
          ? VoiceHeader(
              voiceonly: voiceonly,
              height: height,
              remoteIdentity: widget.userName.isNotEmpty
                  ? widget.userName
                  : remoteIdentity ?? 'Something went wrong',
              direction: direction ?? 'Please go back',
              txtDirection: direction == 'OUTGOING'
                  ? widget.txtOutgoing
                  : widget.txtIncoming,
              titleTextStyle: widget.titleTextStyle,
              timerTextStyle: widget.timerTextStyle,
              directionTextStyle: widget.directionTextStyle,
              isStartTimer: isStartTimer,
              txtTimer: widget.txtTimer,
            )
          : VoiceHeader(
              voiceonly: voiceonly,
              height: height,
              remoteIdentity: "Waiting",
              direction: 'Incoming',
              txtDirection: direction == 'OUTGOING'
                  ? widget.txtOutgoing
                  : widget.txtIncoming,
              titleTextStyle: widget.titleTextStyle,
              timerTextStyle: widget.timerTextStyle,
              directionTextStyle: widget.directionTextStyle,
              isStartTimer: isStartTimer,
              txtTimer: widget.txtTimer,
            ),
    ]);

    return Stack(
      children: [
        ...stackWidgets,
        pitelCall.isConnected && pitelCall.isHaveCall
            ? _buildActionButtons()
            : Container(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildContent();
  }

  @override
  void callStateChanged(String callId, PitelCallState callState) {
    setState(() {
      _state = callState.state;
    });
    widget.onCallState(callState.state);
    switch (callState.state) {
      case PitelCallStateEnum.HOLD:
      case PitelCallStateEnum.UNHOLD:
        break;
      case PitelCallStateEnum.MUTED:
      case PitelCallStateEnum.UNMUTED:
        break;
      case PitelCallStateEnum.STREAM:
        // _handelStreams(callState);
        break;
      case PitelCallStateEnum.ENDED:
        break;
      case PitelCallStateEnum.FAILED:
        break;
      case PitelCallStateEnum.CONNECTING:
      case PitelCallStateEnum.PROGRESS:
      case PitelCallStateEnum.CONFIRMED:
        setState(() {
          _callId = callId;
        });
        break;
      case PitelCallStateEnum.ACCEPTED:
        setState(() {
          _callId = callId;
          isStartTimer = true;
        });
        break;
      case PitelCallStateEnum.NONE:
      case PitelCallStateEnum.CALL_INITIATION:
      case PitelCallStateEnum.REFER:
        break;
    }
  }

  @override
  void onNewMessage(PitelSIPMessageRequest msg) {}

  @override
  void registrationStateChanged(PitelRegistrationState state) {}

  @override
  void transportStateChanged(PitelTransportState state) {}

  @override
  void onCallReceived(String callId) {}

  @override
  void onCallInitiated(String callId) {}
}
