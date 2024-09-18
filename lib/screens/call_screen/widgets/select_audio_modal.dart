import 'package:flutter/material.dart';
import 'package:flutter_pitel_voip/flutter_pitel_voip.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class SelectAudioModal extends StatefulWidget {
  const SelectAudioModal({
    Key? key,
    required this.setAudioValue,
  });
  final Function(String value) setAudioValue;

  @override
  State<StatefulWidget> createState() => _SelectAudioModalState();
}

class _SelectAudioModalState extends State<SelectAudioModal> {
  List<MediaDeviceInfo> mediaDeviceInfoList = [];
  String _audioValue = "";
  final PitelCall _pitelCall = PitelClient.getInstance().pitelCall;

  @override
  void initState() {
    super.initState();
    _getMediaDeviceInfo();
  }

  void _getMediaDeviceInfo() async {
    final audioOutput = await Helper.audiooutputs;
    setState(() {
      mediaDeviceInfoList = audioOutput;
      _audioValue = _pitelCall.audioSelected;
    });
  }

  void _handleSelectAudio(MediaDeviceInfo item) async {
    _pitelCall.selectAudioRoute(speakerSelected: item.deviceId);
    setState(() {
      _audioValue = item.deviceId;
    });
    widget.setAudioValue(item.deviceId);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16.0))),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Padding(
          padding: EdgeInsets.only(top: 14, bottom: 12),
          child: Text(
            "Select audio output",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        const Divider(),
        ...mediaDeviceInfoList.map((item) {
          return InkWell(
            onTap: () {
              _handleSelectAudio(item);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item.label,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  Radio(
                    value: _audioValue,
                    groupValue: item.deviceId,
                    onChanged: (value) => _handleSelectAudio(item),
                  )
                ],
              ),
            ),
          );
        }).toList(),
      ]),
    );
  }
}
