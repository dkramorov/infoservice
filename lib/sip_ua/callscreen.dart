import 'dart:async';

import 'package:all_sensors/all_sensors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:sip_ua/sip_ua.dart';
import '../helpers/log.dart';
import '../helpers/phone_mask.dart';
import '../main.dart';
import '../services/jabber_manager.dart';
import '../services/sip_ua_manager.dart';
import '../settings.dart';
import 'package:uuid/uuid.dart';

import '../widgets/action_button.dart';

class CallScreenWidget extends StatefulWidget {
  final SIPUAManager? _sipHelper;
  final JabberManager? _xmppHelper;
  final Object? _arguments;
  const CallScreenWidget(this._sipHelper, this._xmppHelper, this._arguments,
      {Key? key})
      : super(key: key);
  static const String id = '/callscreen';
  @override
  _CallScreenWidget createState() => _CallScreenWidget();
}

class _CallScreenWidget extends State<CallScreenWidget>
    implements SipUaHelperListener {
  static const TAG = 'CallScreenWidget';

  SIPUAManager? get sipHelper => widget._sipHelper;
  JabberManager? get xmppHelper => widget._xmppHelper;

  late StreamSubscription proximitySubscription;

  late Call? call;
  String get direction => call!.direction;
  String? get remoteIdentity => call!.remote_identity;

  RTCVideoRenderer? _localRenderer = RTCVideoRenderer();
  RTCVideoRenderer? _remoteRenderer = RTCVideoRenderer();
  double? _localVideoHeight;
  double? _localVideoWidth;
  EdgeInsetsGeometry? _localVideoMargin;
  MediaStream? _localStream;
  MediaStream? _remoteStream;

  bool _showNumPad = false;
  String _timeLabel = '00:00';
  late Timer _timer;
  bool _audioMuted = false;
  bool _videoMuted = false;
  bool _speakerOn = false;
  bool _hold = false;
  String? _holdOriginator;
  CallStateEnum _state = CallStateEnum.NONE;

  /*
  bool get voiceonly =>
      (_localStream == null || _localStream!.getVideoTracks().isEmpty) &&
      (_remoteStream == null || _remoteStream!.getVideoTracks().isEmpty);
  */
  bool voiceonly = true;

  @override
  initState() {
    super.initState();
    List args = (widget._arguments as Set).toList();
    for (Object? arg in args) {
      if (arg is Call) {
        call = arg;
        Log.d(TAG, '---> call is ${call?.id}');
        /* Для ios тут мы видим звонок - пробуем ответить на него ожидая регистрацию
        */
        callKitIncomingInterceptor();
        //break;
      }
    }
    _initRenderers();
    sipHelper!.addSipUaHelperListener(this);
    _startTimer();

    proximitySubscription = proximityEvents!.listen((ProximityEvent event) {
      Log.d(TAG, 'proximityEvent: $event');
    });
  }

  void callKitIncomingInterceptor() {
    // Тут надо ожидать, CallStateEnum.ACCEPTED и принимать звонок
    //_handleAccept();
  }

  @override
  deactivate() {
    super.deactivate();
    sipHelper!.removeSipUaHelperListener(this);
    proximitySubscription.cancel();
    _disposeRenderers();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      Duration duration = Duration(seconds: timer.tick);
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
    if (_localRenderer != null) {
      await _localRenderer!.initialize();
    }
    if (_remoteRenderer != null) {
      await _remoteRenderer!.initialize();
    }
  }

  void _disposeRenderers() {
    if (_localRenderer != null) {
      _localRenderer!.dispose();
      _localRenderer = null;
    }
    if (_remoteRenderer != null) {
      _remoteRenderer!.dispose();
      _remoteRenderer = null;
    }
  }

  @override
  void callStateChanged(Call call, CallState callState) {
    if (callState.state == CallStateEnum.HOLD ||
        callState.state == CallStateEnum.UNHOLD) {
      _hold = callState.state == CallStateEnum.HOLD;
      _holdOriginator = callState.originator;
      setState(() {});
      return;
    }

    if (callState.state == CallStateEnum.MUTED) {
      if (callState.audio!) _audioMuted = true;
      if (callState.video!) _videoMuted = true;
      setState(() {});
      return;
    }

    if (callState.state == CallStateEnum.UNMUTED) {
      if (callState.audio!) _audioMuted = false;
      if (callState.video!) _videoMuted = false;
      setState(() {});
      return;
    }

    if (callState.state != CallStateEnum.STREAM) {
      _state = callState.state;
    }

    switch (callState.state) {
      case CallStateEnum.STREAM:
        _handelStreams(callState);
        break;
      case CallStateEnum.ENDED:
      case CallStateEnum.FAILED:
        _backToDialPad();
        break;
      case CallStateEnum.UNMUTED:
      case CallStateEnum.MUTED:
      case CallStateEnum.CONNECTING:
      case CallStateEnum.PROGRESS:
      case CallStateEnum.ACCEPTED:
      case CallStateEnum.CONFIRMED:
      case CallStateEnum.HOLD:
      case CallStateEnum.UNHOLD:
      case CallStateEnum.NONE:
      case CallStateEnum.CALL_INITIATION:
      case CallStateEnum.REFER:
        break;
    }
  }

  @override
  void transportStateChanged(TransportState state) {}

  @override
  void registrationStateChanged(RegistrationState state) {}

  void _cleanUp() {
    _localStream?.getTracks().forEach((track) {
      track.stop();
    });
    _localStream?.dispose();
    _localStream = null;
  }

  void _backToDialPad() {
    _timer.cancel();
    Future.delayed(Duration.zero, () {
      Navigator.of(context).popUntil((route) => (route.isFirst));
    });
    _cleanUp();
  }

  void _handelStreams(CallState event) async {
    MediaStream? stream = event.stream;
    if (event.originator == 'local') {
      /* TODO: Вылезает Unhandled Exception: Call initialize before setting the stream
               пока ложим болт на видео
      if (_localRenderer != null) {
        _localRenderer!.srcObject = stream;
      }
      */
      if (!kIsWeb && !WebRTC.platformIsDesktop) {
        event.stream?.getAudioTracks().first.enableSpeakerphone(false);
      }
      _localStream = stream;
    } else if (event.originator == 'remote') {
      if (_remoteRenderer != null) {
        _remoteRenderer!.srcObject = stream;
      }
      _remoteStream = stream;
    }
    /*
    setState(() {
      _resizeLocalVideo();
    });
    */
  }

  void _resizeLocalVideo() {
    _localVideoMargin = _remoteStream != null
        ? const EdgeInsets.only(top: 15, right: 15)
        : const EdgeInsets.all(0);
    _localVideoWidth = _remoteStream != null
        ? MediaQuery.of(context).size.width / 4
        : MediaQuery.of(context).size.width;
    _localVideoHeight = _remoteStream != null
        ? MediaQuery.of(context).size.height / 4
        : MediaQuery.of(context).size.height;
  }

  void _handleHangup() {
    _timer.cancel();
    try {
      call?.hangup();
    } catch (ex) {
      print('_handleHangup exception: $ex');
      Map<String, Object> options = <String, Object>{};
      options['cause'] = 'Terminated';
      options['status_code'] = 487;
      options['reason_phrase'] = 'Request Terminated';
      call?.hangup(options);
    }
  }

  void _handleAccept() async {
    bool remoteHasVideo = call!.remote_has_video;
    final mediaConstraints = <String, dynamic>{
      'audio': true,
      'video': remoteHasVideo
    };
    MediaStream mediaStream;

    if (kIsWeb && remoteHasVideo) {
      mediaStream =
          await navigator.mediaDevices.getDisplayMedia(mediaConstraints);
      mediaConstraints['video'] = false;
      MediaStream userStream =
          await navigator.mediaDevices.getUserMedia(mediaConstraints);
      mediaStream.addTrack(userStream.getAudioTracks()[0], addToNative: true);
    } else {
      mediaConstraints['video'] = remoteHasVideo;
      mediaStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
    }
    call!.answer(sipHelper!.buildCallOptions(!remoteHasVideo),
        mediaStream: mediaStream);

    // Втыкаем в историю входящий
    // все входящие только сипом пока
    await sipHelper?.listener.call2History(call?.remote_identity ?? '',
        direction: 'incoming', isSip: true);
  }

  void _switchCamera() {
    if (_localStream != null) {
      Helper.switchCamera(_localStream!.getVideoTracks()[0]);
    }
  }

  void _muteAudio() {
    if (_audioMuted) {
      call!.unmute(true, false);
    } else {
      call!.mute(true, false);
    }
  }

  void _muteVideo() {
    if (_videoMuted) {
      call!.unmute(false, true);
    } else {
      call!.mute(false, true);
    }
  }

  void _handleHold() {
    if (_hold) {
      call!.unhold();
    } else {
      call!.hold();
    }
  }

  late String _transferTarget;
  void _handleTransfer() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter target to transfer.'),
          content: TextField(
            onChanged: (String text) {
              setState(() {
                _transferTarget = text;
              });
            },
            decoration: const InputDecoration(
              hintText: 'URI or Username',
            ),
            textAlign: TextAlign.center,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                call!.refer(_transferTarget);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _handleDtmf(String tone) {
    print('Dtmf tone => $tone');
    call!.sendDTMF(tone);
  }

  void _handleKeyPad() {
    setState(() {
      _showNumPad = !_showNumPad;
    });
  }

  void _toggleSpeaker() {
    if (_localStream != null) {
      _speakerOn = !_speakerOn;
      if (!kIsWeb) {
        _localStream!.getAudioTracks()[0].enableSpeakerphone(_speakerOn);
      }
    }
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
            padding: const EdgeInsets.all(3),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: row
                    .map((label) => ActionButton(
                          title: label.keys.first,
                          subTitle: label.values.first,
                          onPressed: () => _handleDtmf(label.keys.first),
                          number: true,
                        ))
                    .toList())))
        .toList();
  }

  Widget _buildActionButtons() {
    var hangupBtn = ActionButton(
      title: "Сброс",
      onPressed: () => _handleHangup(),
      icon: Icons.call_end,
      fillColor: Colors.red,
    );

    var hangupBtnInactive = ActionButton(
      title: "Сброс",
      onPressed: () {},
      icon: Icons.call_end,
      fillColor: Colors.grey,
    );

    var basicActions = <Widget>[];
    var advanceActions = <Widget>[];

    switch (_state) {
      case CallStateEnum.NONE:
      case CallStateEnum.CONNECTING:
        if (direction == 'INCOMING') {
          basicActions.add(ActionButton(
            title: "Принять",
            fillColor: tealColor,
            icon: Icons.phone,
            onPressed: () => _handleAccept(),
          ));
          // Принимаем звонок если в CallKit он активный
          Future.delayed(Duration.zero, () async {
            int now = DateTime.now().millisecondsSinceEpoch;
            bool isActual =
                (sipHelper?.stateCallKitUpdated ?? 0) > (now - 3000);
            if (sipHelper?.stateCallKit == 'ACTION_CALL_ACCEPT' && isActual) {
              sipHelper?.stateCallKitUpdated = 0;
              _handleAccept();
            } else if ((await sipHelper?.checkCallKitCall() ?? {})
                .keys
                .isEmpty) {
              if (sipHelper?.stateCallKit == 'ACTION_CALL_DECLINE' &&
                  isActual) {
                sipHelper?.stateCallKitUpdated = 0;
                _handleHangup();
              } else {
                await showCallkitIncoming(const Uuid().v4(),
                    from: phoneMaskHelper(call?.remote_identity ?? ''));
              }
            }
          });
        }
        basicActions.add(hangupBtn);
        break;
      case CallStateEnum.ACCEPTED:
      case CallStateEnum.CONFIRMED:
        {
          advanceActions.add(ActionButton(
            title: _audioMuted ? 'unmute' : 'mute',
            icon: _audioMuted ? Icons.mic_off : Icons.mic,
            checked: _audioMuted,
            onPressed: () => _muteAudio(),
          ));

          if (voiceonly) {
            advanceActions.add(ActionButton(
              title: "keypad",
              icon: Icons.dialpad,
              onPressed: () => _handleKeyPad(),
            ));
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
              checked: _speakerOn,
              onPressed: () => _toggleSpeaker(),
            ));
          } else {
            advanceActions.add(ActionButton(
              title: _videoMuted ? "camera on" : 'camera off',
              icon: _videoMuted ? Icons.videocam : Icons.videocam_off,
              checked: _videoMuted,
              onPressed: () => _muteVideo(),
            ));
          }

          basicActions.add(ActionButton(
            title: _hold ? 'unhold' : 'hold',
            icon: _hold ? Icons.play_arrow : Icons.pause,
            checked: _hold,
            onPressed: () => _handleHold(),
          ));

          basicActions.add(hangupBtn);

          if (_showNumPad) {
            basicActions.add(ActionButton(
              title: "back",
              icon: Icons.keyboard_arrow_down,
              onPressed: () => _handleKeyPad(),
            ));
          } else {
            basicActions.add(ActionButton(
              title: "transfer",
              icon: Icons.phone_forwarded,
              onPressed: () => _handleTransfer(),
            ));
          }
        }
        break;
      case CallStateEnum.FAILED:
      case CallStateEnum.ENDED:
        basicActions.add(hangupBtnInactive);
        break;
      case CallStateEnum.PROGRESS:
        basicActions.add(hangupBtn);
        break;
      default:
        print('Other state => $_state');
        break;
    }

    var actionWidgets = <Widget>[];

    if (_showNumPad) {
      actionWidgets.addAll(_buildNumPad());
    } else {
      if (advanceActions.isNotEmpty) {
        actionWidgets.add(Padding(
            padding: const EdgeInsets.all(3),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: advanceActions)));
      }
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

    if (!voiceonly && _remoteStream != null) {
      stackWidgets.add(Center(
        child: RTCVideoView(_remoteRenderer!),
      ));
    }

    if (!voiceonly && _localStream != null) {
      stackWidgets.add(Container(
        alignment: Alignment.topRight,
        child: AnimatedContainer(
          height: _localVideoHeight,
          width: _localVideoWidth,
          alignment: Alignment.topRight,
          duration: const Duration(milliseconds: 300),
          margin: _localVideoMargin,
          child: RTCVideoView(_localRenderer!),
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
                      (voiceonly ? 'VOICE CALL' : 'VIDEO CALL') +
                          (_hold
                              ? ' PAUSED BY ${_holdOriginator!.toUpperCase()}'
                              : ''),
                      style:
                          const TextStyle(fontSize: 24, color: Colors.black54),
                    ))),
            Center(
                child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Text(
                      '$remoteIdentity',
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
        appBar: AppBar(
            backgroundColor: tealColor,
            automaticallyImplyLeading: false,
            title: Text('[$direction] ${EnumHelper.getName(_state)}')),
        body: Container(
          child: _buildContent(),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Padding(
            padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 24.0),
            child: SizedBox(width: 320, child: _buildActionButtons())));
  }

  @override
  void onNewMessage(SIPMessageRequest msg) {
    // NO OP
  }

  @override
  void onNewNotify(Notify ntf) {
    // TODO: implement onNewNotify
  }
}
