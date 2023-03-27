import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:plugin_pitel/component/pitel_call_state.dart';
import 'package:plugin_pitel/component/pitel_rtc_video_view.dart';
import 'package:plugin_pitel/component/sip_pitel_helper_listener.dart';
import 'package:plugin_pitel/pitel_sdk/pitel_call.dart';
import 'package:plugin_pitel/pitel_sdk/pitel_client.dart';
import 'package:plugin_pitel/sip/sip_ua.dart';
import 'package:plugin_pitel_example/color.dart';
import 'package:plugin_pitel_example/local_store.dart';
import 'package:plugin_pitel_example/navigator.dart';

import 'widgets/action_button.dart';

class CallScreenWidget extends StatefulWidget {
  CallScreenWidget({Key? key, this.receivedBackground = false})
      : super(key: key);
  final PitelCall _pitelCall = PitelClient.getInstance().pitelCall;
  final bool receivedBackground;
  @override
  _MyCallScreenWidget createState() => _MyCallScreenWidget();
}

class _MyCallScreenWidget extends State<CallScreenWidget>
    implements SipPitelHelperListener {
  PitelCall get pitelCall => widget._pitelCall;
  double _localVideoHeight = 0;
  double _localVideoWidth = 0;
  EdgeInsetsGeometry _localVideoMargin = const EdgeInsets.all(0);

  String _timeLabel = '00:00';
  late Timer _timer;
  bool _speakerOn = false;
  PitelCallStateEnum _state = PitelCallStateEnum.NONE;
  bool calling = false;
  bool _isBacked = false;

  bool get voiceonly => pitelCall.isVoiceOnly();

  String? get remote_identity => pitelCall.remoteIdentity;

  String? get direction => pitelCall.direction;

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      if (!pitelCall.isConnected) {
        var localStorage = LocalStorage();
        var account = await localStorage.getAccountLocal();
        if (account != null) {
          PitelClient.getInstance()
              .login(account.username, account.password)
              .then((value) {
            if (value) {
              setState(() {});
            }
          });
        }
      }
    });
    pitelCall.addListener(this);
    if (voiceonly) {
      _initRenderers();
    }
    _startTimer();
  }

  @override
  deactivate() {
    super.deactivate();
    _handleHangup();
    pitelCall.removeListener(this);
    _disposeRenderers();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      final duration = Duration(seconds: timer.tick);
      if (mounted) {
        setState(() {
          _timeLabel = [duration.inMinutes, duration.inSeconds]
              .map((seg) => seg.remainder(60).toString().padLeft(2, '0'))
              .join(':');
        });
      } else {
        _timer.cancel();
      }
    });
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
      _isBacked = true;
      log('DUYJACK _backToDialPad');
      NavigatorSerivce.getInstance().goBack();
    }
  }

  void _handelStreams(PitelCallState event) async {
    _resizeLocalVideo();
  }

  void _resizeLocalVideo() {
    setState(() {
      _localVideoMargin = pitelCall.remoteStream != null
          ? const EdgeInsets.only(top: 15, right: 15)
          : const EdgeInsets.all(0);
      _localVideoWidth = pitelCall.remoteStream != null
          ? MediaQuery.of(context).size.width / 4
          : MediaQuery.of(context).size.width;
      _localVideoHeight = pitelCall.remoteStream != null
          ? MediaQuery.of(context).size.height / 4
          : MediaQuery.of(context).size.height;
    });
  }

  void _handleHangup() {
    pitelCall.hangup();
    if (_timer != null) {
      if (_timer.isActive) {
        _timer.cancel();
      }
    }
  }

  void _handleAccept() {
    pitelCall.answer();
  }

  void _switchCamera() {
    if (pitelCall.localStream != null) {
      pitelCall.localStream?.getVideoTracks()[0].switchCamera();
    }
  }

  void _toggleSpeaker() {
    if (pitelCall.localStream != null) {
      _speakerOn = !_speakerOn;
      pitelCall.enableSpeakerphone(_speakerOn);
    }
  }

  Widget _buildActionButtons() {
    var hangupBtn = ActionButton(
      title: "hangup",
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

    var basicActions = <Widget>[];
    var advanceActions = <Widget>[];
    debugPrint('_state ${_state} direction $direction');
    switch (_state) {
      case PitelCallStateEnum.NONE:
      case PitelCallStateEnum.PROGRESS:
        if (direction == 'INCOMING') {
          basicActions.add(ActionButton(
            title: "Accept",
            fillColor: Colors.green,
            icon: Icons.phone,
            onPressed: () => _handleAccept(),
          ));
          basicActions.add(hangupBtn);
        } else {
          basicActions.add(hangupBtn);
        }
        break;
      case PitelCallStateEnum.CONNECTING:
        break;
      case PitelCallStateEnum.MUTED:
      case PitelCallStateEnum.UNMUTED:
      case PitelCallStateEnum.ACCEPTED:
      case PitelCallStateEnum.CONFIRMED:
        {
          advanceActions.add(ActionButton(
            title: pitelCall.audioMuted ? 'unmute' : 'mute',
            icon: pitelCall.audioMuted ? Icons.mic_off : Icons.mic,
            checked: pitelCall.audioMuted,
            fillColor: ColorApp.primaryColor,
            onPressed: () => pitelCall.mute(),
          ));

          if (voiceonly) {
          } else {
            advanceActions.add(ActionButton(
              title: "switch camera",
              icon: Icons.switch_video,
              onPressed: () => _switchCamera(),
            ));
          }

          if (voiceonly) {
            advanceActions.add(ActionButton(
              title: _speakerOn ? 'speaker off' : 'speaker on',
              icon: _speakerOn ? Icons.volume_off : Icons.volume_up,
              fillColor: ColorApp.primaryColor,
              checked: _speakerOn,
              onPressed: () => _toggleSpeaker(),
            ));
          } else {
            advanceActions.add(ActionButton(
              title: pitelCall.videoIsOff ? "camera on" : 'camera off',
              icon: pitelCall.videoIsOff ? Icons.videocam : Icons.videocam_off,
              checked: pitelCall.videoIsOff,
              fillColor: ColorApp.primaryColor,
              onPressed: () => pitelCall.toggleCamera(),
            ));
          }

          basicActions.add(hangupBtn);
        }
        break;
      case PitelCallStateEnum.FAILED:
      case PitelCallStateEnum.ENDED:
        basicActions.add(hangupBtnInactive);
        break;
      default:
        print('Other state => $_state');
        break;
    }

    var actionWidgets = <Widget>[];

    if (advanceActions.isNotEmpty) {
      actionWidgets.add(Padding(
          padding: const EdgeInsets.all(3),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: advanceActions)));
    }

    actionWidgets.add(Padding(
        padding: const EdgeInsets.all(3),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: basicActions)));

    return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: actionWidgets);
  }

  Widget _buildContent() {
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
          height: _localVideoHeight,
          width: _localVideoWidth,
          alignment: Alignment.topRight,
          duration: const Duration(milliseconds: 300),
          margin: _localVideoMargin,
          child: PitelRTCVideoView(pitelCall.localRenderer!),
        ),
      ));
    }

    stackWidgets.addAll([
      Positioned(
        top: voiceonly ? 48 : 6,
        left: 0,
        right: 0,
        child: Center(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Center(
                child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Text(
                      (voiceonly ? 'VOICE CALL' : 'VIDEO CALL'),
                      style:
                          const TextStyle(fontSize: 24, color: Colors.black54),
                    ))),
            Center(
                child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Text(
                      '$remote_identity',
                      style:
                          const TextStyle(fontSize: 18, color: Colors.black54),
                    ))),
            Center(
                child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Text(_timeLabel,
                        style: const TextStyle(
                            fontSize: 14, color: Colors.black54))))
          ],
        )),
      ),
    ]);

    return Stack(
      children: stackWidgets,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorApp.secondaryHeaderColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('[$direction] ${_state}'),
        brightness: Brightness.light,
      ),
      body: Container(
        child: pitelCall.isConnected && pitelCall.isHaveCall
            ? _buildContent()
            : const Center(
                child: CircularProgressIndicator(),
              ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: pitelCall.isConnected && pitelCall.isHaveCall
          ? Padding(
              padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 24.0),
              child: SizedBox(
                width: 320,
                child: _buildActionButtons(),
              ),
            )
          : const SizedBox(),
    );
  }

  @override
  void callStateChanged(String callId, PitelCallState callState) {
    // if (callState.state != PitelCallStateEnum.STREAM) {
    //   _state = callState.state;
    // }
    setState(() {
      _state = callState.state;
    });
    switch (callState.state) {
      case PitelCallStateEnum.HOLD:
      case PitelCallStateEnum.UNHOLD:
        break;
      case PitelCallStateEnum.MUTED:
      case PitelCallStateEnum.UNMUTED:
        break;
      case PitelCallStateEnum.STREAM:
        _handelStreams(callState);
        break;
      case PitelCallStateEnum.ENDED:
      case PitelCallStateEnum.FAILED:
        _backToDialPad();
        break;
      case PitelCallStateEnum.CONNECTING:
      case PitelCallStateEnum.PROGRESS:
      case PitelCallStateEnum.ACCEPTED:
      case PitelCallStateEnum.CONFIRMED:
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
  void onCallReceived(String callId) {
    pitelCall.setCallCurrent(callId);
    setState(() {});
  }

  @override
  void onCallInitiated(String callId) {}
}
