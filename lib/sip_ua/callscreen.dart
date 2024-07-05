import 'dart:async';

import 'package:all_sensors/all_sensors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:infoservice/helpers/phone_mask.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sip_ua/sip_ua.dart';
import 'package:wakelock/wakelock.dart';
import '../helpers/log.dart';
import '../helpers/model_utils.dart';
import '../main.dart';
import '../models/companies/orgs.dart';
import '../pages/app_asset_lib.dart';
import '../pages/themes.dart';
import '../services/jabber_manager.dart';
import '../services/sip_ua_manager.dart';
import '../settings.dart';
import 'package:uuid/uuid.dart';

import '../widgets/action_button.dart';
import '../widgets/companies/company_logo.dart';
import '../widgets/phone_call_button.dart';

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

  Call? call;
  String callerName = '';
  String ringOnCallIdStarted = '';
  String get direction => call != null ? call!.direction : 'unknown';
  String? get remoteIdentity {
    if (call == null) {
      return '89111111111';
    }
    return callerName == '' ? call!.remote_identity : callerName;
  }

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

  Orgs? company;

  // TEST TODO: убрать
  //CallStateEnum _state = CallStateEnum.CONFIRMED;
  /*
  bool get voiceonly =>
      (_localStream == null || _localStream!.getVideoTracks().isEmpty) &&
      (_remoteStream == null || _remoteStream!.getVideoTracks().isEmpty);
  */
  bool voiceonly = true;

  late AudioPlayer player;

  @override
  initState() {
    super.initState();
    if (widget._arguments != null) {
      List args = (widget._arguments as Set).toList();
      for (Object? arg in args) {
        if (arg is Call) {
          call = arg;
          Log.d(TAG, '---> call is ${call?.id}');
          /* Для ios тут мы видим звонок - пробуем ответить на него ожидая регистрацию */
          callKitIncomingInterceptor();
          //break;

          // Находим компанию
          updateCallMeta();
        }
      }
    } else {}
    _initRenderers();
    sipHelper!.addSipUaHelperListener(this);
    _startTimer();

    proximitySubscription = proximityEvents!.listen((ProximityEvent event) {
      Log.d(TAG, 'proximityEvent: $event');
    });

    player = AudioPlayer();
    Wakelock.enable();
  }

  Future<void> updateCallMeta() async {
    final preferences = await SharedPreferences.getInstance();
    String dest = preferences.getString('dest') ?? '';
    int companyId = preferences.getInt('company_id') ?? 0;
    if (call != null && call!.remote_identity != null && dest != '' && companyId != 0) {
      company = await Orgs().getOrg(companyId);
      if (company != null && mounted) {
        setState(() {});
      }
    }
  }

  void callKitIncomingInterceptor() {
    // Тут надо ожидать, CallStateEnum.ACCEPTED и принимать звонок
    //_handleAccept();
  }

  @override
  void dispose() {
    player.dispose();
    Wakelock.disable();
    super.dispose();
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
    Log.d(TAG,
        'callStateChanged to ${callState.state.toString()}, ${DateTime.now().toIso8601String()}');
    if (callState.state == CallStateEnum.HOLD ||
        callState.state == CallStateEnum.UNHOLD) {
      _hold = callState.state == CallStateEnum.HOLD;
      _holdOriginator = callState.originator;
      return;
    }

    if (callState.state == CallStateEnum.MUTED) {
      if (callState.audio!) _audioMuted = true;
      if (callState.video!) _videoMuted = true;
      return;
    }

    if (callState.state == CallStateEnum.UNMUTED) {
      if (callState.audio!) _audioMuted = false;
      if (callState.video!) _videoMuted = false;
      return;
    }

    if (callState.state != CallStateEnum.STREAM) {
      _state = callState.state;
      setState(() {});
    }

    switch (callState.state) {
      case CallStateEnum.STREAM:
        if (direction == 'OUTGOING' && call.id != ringOnCallIdStarted) {
          print('______________${call.remote_identity}');
          getRosterNameByPhone(xmppHelper, call.remote_identity ?? '')
              .then((name) {
            setState(() {
              if (mounted) {
                callerName = name;
              }
            });
          });
          Future.delayed(Duration.zero, () async {
            ringOnCallIdStarted = call.id ?? '';
            player.setLoopMode(LoopMode.one);
            await player.setAsset('assets/call/ringbacktone.wav');
            player.play();
          });
        }
        _handelStreams(callState);
        break;

      case CallStateEnum.ENDED:
      case CallStateEnum.FAILED:
        player.stop();
        _backToDialPad();
        break;
      case CallStateEnum.ACCEPTED:
      case CallStateEnum.CONFIRMED:
        player.stop();
        break;
      case CallStateEnum.UNMUTED:
      case CallStateEnum.MUTED:
      case CallStateEnum.CONNECTING:
      case CallStateEnum.PROGRESS:
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
    String name =
        await getRosterNameByPhone(xmppHelper, call?.remote_identity ?? '');
    await sipHelper?.listener.call2History(call?.remote_identity ?? '',
        name: name, direction: 'incoming', isSip: true);
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
          title: const Text('Переадресация вызова'),
          content: TextField(
            onChanged: (String text) {
              setState(() {
                _transferTarget = text;
              });
            },
            decoration: const InputDecoration(
              hintText: 'Назначение',
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
              child: const Text('Отмена'),
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
    var labels = [
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

    return labels
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

  Widget _buildActionButtons({size=300}) {
    /*
    var hangupBtn = ActionButton(
      title: 'Сброс',
      onPressed: () => _handleHangup(),
      icon: Icons.call_end,
      fillColor: Colors.red,
    );
    */
    var hangupBtn = PhoneCallButton(
      asset: AssetLib.closeCallButton,
      backgroundColor: const Color.fromRGBO(230, 36, 36, 1),
      onPressed: () async {
        _handleHangup();
      },
    );

    /*
    var hangupBtnInactive = ActionButton(
      title: 'Сброс',
      onPressed: () {},
      icon: Icons.call_end,
      fillColor: Colors.grey,
    );
    */
    var hangupBtnInactive = PhoneCallButton(
      asset: AssetLib.closeCallButton,
      backgroundColor: const Color.fromRGBO(136, 136, 136, 1),
      onPressed: () async {},
    );

    var basicActions = <Widget>[];
    var advanceActions = <Widget>[];

    switch (_state) {
      case CallStateEnum.NONE:
      case CallStateEnum.CONNECTING:
        if (direction == 'INCOMING') {

          basicActions.add(PhoneCallButton(
            asset: AssetLib.phoneButton,
            backgroundColor: const Color.fromRGBO(112, 191, 43, 1),
            onPressed: () async {
              _handleAccept();
            },
          ));
          /*
          basicActions.add(ActionButton(
            title: 'Принять',
            fillColor: tealColor,
            icon: Icons.phone,
            onPressed: () => _handleAccept(),
          ));
          */
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
                String phone = call?.remote_identity ?? '';
                String name = await getRosterNameByPhone(xmppHelper, phone);
                setState(() {
                  if (mounted) {
                    callerName = name;
                  }
                });
                await showCallkitIncoming(const Uuid().v4(), from: name);
              }
            }
          });
        }
        basicActions.add(hangupBtn);
        break;
      case CallStateEnum.ACCEPTED:
      case CallStateEnum.CONFIRMED:
        {
          advanceActions.add(PhoneCallButton(
            asset: AssetLib.micro,
            onPressed: () {
              _muteAudio();
            },
          ));

          advanceActions.add(PhoneCallButton(
            asset: AssetLib.number,
            onPressed: () {
              _handleKeyPad();
            },
          ));

          advanceActions.add(PhoneCallButton(
            asset: AssetLib.volumeFull,
            onPressed: () {
              _toggleSpeaker();
            },
          ));
          /*
          advanceActions.add(ActionButton(
            title: _audioMuted ? 'unmute' : 'mute',
            icon: _audioMuted ? Icons.mic_off : Icons.mic,
            checked: _audioMuted,
            onPressed: () => _muteAudio(),
          ));

          if (voiceonly) {
            advanceActions.add(ActionButton(
              title: 'keypad',
              icon: Icons.dialpad,
              onPressed: () => _handleKeyPad(),
            ));
          } else {
            advanceActions.add(ActionButton(
              title: 'switch camera',
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
              title: _videoMuted ? 'camera on' : 'camera off',
              icon: _videoMuted ? Icons.videocam : Icons.videocam_off,
              checked: _videoMuted,
              onPressed: () => _muteVideo(),
            ));
          }
          */

          /*
          basicActions.add(ActionButton(
            title: _hold ? 'unhold' : 'hold',
            icon: _hold ? Icons.play_arrow : Icons.pause,
            checked: _hold,
            onPressed: () => _handleHold(),
          ));
          */

          if (!_showNumPad) {
            basicActions.add(PhoneCallButton(
              asset: AssetLib.pause,
              onPressed: () {
                _handleHold();
              },
            ));
          }

          basicActions.add(hangupBtn);

          if (_showNumPad) {
            /*
            basicActions.add(ActionButton(
              title: 'back',
              icon: Icons.keyboard_arrow_down,
              onPressed: () => _handleKeyPad(),
            ));
            */
            basicActions.add(PhoneCallButton(
              asset: AssetLib.number,
              onPressed: () {
                _handleKeyPad();
              },
            ));
          } else {
            /*
            basicActions.add(ActionButton(
              title: 'transfer',
              icon: Icons.phone_forwarded,
              onPressed: () => _handleTransfer(),
            ));
            */
            basicActions.add(PhoneCallButton(
              asset: AssetLib.phoneAndCall,
              onPressed: () {
                _handleTransfer();
              },
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
      // Старый вариант
      //actionWidgets.addAll(_buildNumPad());
      actionWidgets.add(Wrap(
        runSpacing: size.width * 0.05,
        children: [
          for (int i = 1; i <= 9; i++)
            buildDigitButton(
              i.toString(),
                  () => _handleDtmf(i.toString()),
            ),
          buildDigitButton('*', () => _handleDtmf('*')),
          buildDigitButton('0', () => _handleDtmf('0')),
          buildDigitButton('#', () => _handleDtmf('#')),
        ],
      ));
    } else {
      if (advanceActions.isNotEmpty) {
        actionWidgets.add(Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: advanceActions)));
      }
    }

    actionWidgets.add(Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: basicActions,
        )));

    return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: actionWidgets);
  }

  Widget buildDigitButton(String text, VoidCallback onTap) {
    final size = MediaQuery.of(context).size;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        width: size.width * 0.33,
        height: size.width * 0.15,
        color: transparent,
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 24,
              fontWeight: w400,
              color: black,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildImg() {
    if (company != null) {
      //Image.network("https://sun6-21.userapi.com/s/v1/ig2/6nBCZiIVxXgCQ4iTX9g_JXKu-uB12fl6IArEM_PeaAQHmqENhV7W5-QwOAHKf32oUGFb4Ttj5NvZDV2hJ2BVr1ef.jpg?size=2007x2008&quality=96&crop=149,76,2007,2008&ava=1")
      return CompanyLogoWidget(company!);
    }
    return Image.asset('assets/avatars/user.png');
  }

  Widget _buildContent({size=300}) {
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
            /*
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

            */
          ],
        )),
      ),
    ]);

    Column col = Column(children: [
      SIZED_BOX_H30,
      _showNumPad ? Container() :
      Container(
        width: 80,
        height: 80,
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.only(top: 6, bottom: 16),
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            width: 1,
            color: borderPrimary,
          ),
        ),
        child: buildImg(),
      ),
      Text(
        (voiceonly ? 'VOICE CALL' : 'VIDEO CALL') +
            (_hold ? ' PAUSED BY ${_holdOriginator!.toUpperCase()}' : ''),
        style: TextStyle(
          fontSize: 18,
          fontWeight: w400,
          color: gray100,
        ),
      ),
      const SizedBox(height: 8),
      Text(
        phoneMaskHelper('$remoteIdentity'),
        style: TextStyle(
          fontSize: 20,
          fontWeight: w500,
          color: black,
        ),
      ),
      const SizedBox(height: 14),
      Text(
        _timeLabel,
        style: TextStyle(
          fontSize: 14,
          fontWeight: w400,
          color: gray100,
        ),
      ),
      const Spacer(flex: 7),
      _buildActionButtons(size: size),
      /*
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PhoneCallButton(
                  asset: AssetLib.micro,
                  onPressed: () {},
                ),
                const SizedBox(width: 30),
                PhoneCallButton(
                  asset: AssetLib.number,
                  onPressed: () {},
                ),
                const SizedBox(width: 30),
                PhoneCallButton(
                  asset: AssetLib.volumeFull,
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PhoneCallButton(
                  asset: AssetLib.pause,
                  onPressed: () {},
                ),
                const SizedBox(width: 30),
                PhoneCallButton(
                  asset: AssetLib.closeCallButton,
                  backgroundColor: const Color.fromRGBO(230, 36, 36, 1),
                  onPressed: () async {
                    /*
                        stopSipCall();
                        await FlutterCallkitIncoming.endAllCalls()
                            .then((value) {
                          Navigator.pop(context);
                        });
                        */
                  },
                ),
                const SizedBox(width: 30),
                PhoneCallButton(
                  asset: AssetLib.phoneAndCall,
                  onPressed: () {},
                ),
              ],
            )
          ],
        ),
        */
      const Spacer(flex: 1),
    ]);
    stackWidgets.add(col);

    return Stack(
      children: stackWidgets,
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return Scaffold(
      body: Container(
        child: _buildContent(size: size),
      ),
    );

    /* /// Старый вариант
    return Scaffold(
        appBar: AppBar(
            backgroundColor: tealColor,
            automaticallyImplyLeading: false,
            title: Text(
                '[$direction] ${EnumHelper.getName(_state)}, $callerName')),
        body: Container(
          child: _buildContent(),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Padding(
            padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 24.0),
            child: SizedBox(width: 320, child: _buildActionButtons())));
    */
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
