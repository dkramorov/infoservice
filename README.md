# infoservice

Social service

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

# Design
https://www.figma.com/file/dhPX8eecp5xcJjezwBfIR6/%D0%BF%D1%80%D0%B8%D0%BB%D0%BE%D0%B6%D0%B5%D0%BD%D0%B8%D0%B5-8800

# Problems:
https://github.com/Canardoux/flutter_sound/issues/666
[BUG]: Undefined symbol: ___gxx_personality_v0
add -lc++
to your XCode > Runner > Target > Buld Settings > All > Linking > Other LInker Flags
just add and it does resolves your bug






В чаты для йоси и андроида все должно работать
1) В пуше нужно показывать часть сообщения.
2) При переходе с пуша показывать в чате новое/новые сообщение (как не прочитанное) 10 сек
3) Если находишься в чате, то при получении сообщения также должно быть помечено, как непрочитанные 10 сек и должен быть звук сообщения.
4) Если есть в чате непрочитанные, то на чат сделать красную точку/цифру (сигнализация)
5) Возможность отправить файл/фото/аудио
6) Сохранить/скопировать/переслать сообщение/файл/фото/аудио
Звонки для йоси и дроида (токены)
1) прием на заблокированном экране
2) и прием в активном приложении
3) Убрать ограничение на время разговора


# Если на ios не собирается, но видимых причин для этого нет, то попробовать
    Run flutter clean
    Run flutter pub get
    Remove xcode derived data
    Remove Pods folder form project iOS folder.
    Remove Podfile.lock file from project iOS folder.
    Remove project.workspace file
    Run again in iOS platform.
Если опять не помогло
runner->build setting->other linker flags, and delete bad_framework

// Android problem with flag on registerReceiver
// https://stackoverflow.com/questions/77235063/one-of-receiver-exported-or-receiver-not-exported-should-be-specified-when-a-rec
import android.os.Build;
if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
     registerReceiver(broadcastReceiver, intentFilter, RECEIVER_EXPORTED)
}else {
     registerReceiver(broadcastReceiver, intentFilter)
}


pod repo update
pod update
pod install


2024-04-05 12:08:11.820 2868-2868/ru.masterme.chat.masterme_chat W/OnBackInvokedCallback: OnBackInvokedCallback is not enabled for the application.
Set 'android:enableOnBackInvokedCallback="true"' in the application manifest.

2024-04-05 12:07:41.386 2868-2868/ru.masterme.chat.masterme_chat W/System.err: android.app.BackgroundServiceStartNotAllowedException: Not allowed to start service Intent { cmp=ru.masterme.chat.masterme_chat/id.flutter.flutter_background_service.BackgroundService }: app is in background uid UidRecord{60e25e6 u0a322 RCVR bg:+1m5s44ms idle change:uncachedprocstate procs:0 seq(325948,321269)}
2024-04-05 12:07:41.387 2868-2868/ru.masterme.chat.masterme_chat W/System.err:     at android.app.ContextImpl.startServiceCommon(ContextImpl.java:1922)
2024-04-05 12:07:41.388 2868-2868/ru.masterme.chat.masterme_chat W/System.err:     at android.app.ContextImpl.startService(ContextImpl.java:1872)
2024-04-05 12:07:41.389 2868-2868/ru.masterme.chat.masterme_chat W/System.err:     at android.content.ContextWrapper.startService(ContextWrapper.java:827)
2024-04-05 12:07:41.390 2868-2868/ru.masterme.chat.masterme_chat W/System.err:     at id.flutter.flutter_background_service.WatchdogReceiver.onReceive(WatchdogReceiver.java:82)
2024-04-05 12:07:41.391 2868-2868/ru.masterme.chat.masterme_chat W/System.err:     at android.app.ActivityThread.handleReceiver(ActivityThread.java:4543)
2024-04-05 12:07:41.392 2868-2868/ru.masterme.chat.masterme_chat W/System.err:     at android.app.ActivityThread.-$$Nest$mhandleReceiver(Unknown Source:0)
2024-04-05 12:07:41.393 2868-2868/ru.masterme.chat.masterme_chat W/System.err:     at android.app.ActivityThread$H.handleMessage(ActivityThread.java:2307)
2024-04-05 12:07:41.393 2868-2868/ru.masterme.chat.masterme_chat W/System.err:     at android.os.Handler.dispatchMessage(Handler.java:106)
2024-04-05 12:07:41.394 2868-2868/ru.masterme.chat.masterme_chat W/System.err:     at android.os.Looper.loopOnce(Looper.java:240)
2024-04-05 12:07:41.395 2868-2868/ru.masterme.chat.masterme_chat W/System.err:     at android.os.Looper.loop(Looper.java:351)
2024-04-05 12:07:41.396 2868-2868/ru.masterme.chat.masterme_chat W/System.err:     at android.app.ActivityThread.main(ActivityThread.java:8370)
2024-04-05 12:07:41.397 2868-2868/ru.masterme.chat.masterme_chat W/System.err:     at java.lang.reflect.Method.invoke(Native Method)
2024-04-05 12:07:41.398 2868-2868/ru.masterme.chat.masterme_chat W/System.err:     at com.android.internal.os.RuntimeInit$MethodAndArgsCaller.run(RuntimeInit.java:568)
2024-04-05 12:07:41.399 2868-2868/ru.masterme.chat.masterme_chat W/System.err:     at com.android.internal.os.ZygoteInit.main(ZygoteInit.java:1013)






2024-04-05 14:53:36.118 30045-30045/ru.masterme.chat.masterme_chat W/FlutterJNI: Tried to send a platform message response, but FlutterJNI was detached from native C++. Could not send. Response ID: 715
2024-04-05 14:53:36.127 30045-30284/ru.masterme.chat.masterme_chat D/SMACK: SENT (0): <presence id='w4JMz-51' type='unavailable'></presence><a xmlns='urn:xmpp:sm:3' h='20'/>
2024-04-05 14:53:36.129 30045-30284/ru.masterme.chat.masterme_chat D/SMACK: SENT (0): </stream:stream>
2024-04-05 14:53:36.132 30045-30087/ru.masterme.chat.masterme_chat I/flutter: I/[ChatScreen]: inUpdateTimer
2024-04-05 14:53:36.554 30045-30285/ru.masterme.chat.masterme_chat D/SMACK: RECV (0): </stream:stream>
2024-04-05 14:53:36.566 30045-30276/ru.masterme.chat.masterme_chat D/flutter_xmpp:  ConnectionClosed():
2024-04-05 14:53:36.577 30045-30276/ru.masterme.chat.masterme_chat D/SMACK: XMPPConnection closed (XMPPTCPConnection[89148959223@chat.masterme.ru/43506347-bdd3-4889-9213-0cbfa9aa5c2f] (0))
2024-04-05 14:53:36.577 30045-30045/ru.masterme.chat.masterme_chat W/FlutterJNI: Tried to send a platform message to Flutter, but FlutterJNI was detached from native C++. Could not send. Channel: flutter_xmpp/connection_event_stream. Response ID: 26
2024-04-05 14:53:36.584 30045-30045/ru.masterme.chat.masterme_chat D/TAG:  RECEIVE_MESSAGE-->> {chatStateType=, customText=null, from=Disconnected, senderJid=, delayTime=0, id=Disconnected, to=null, time=0, type=null, body=Disconnected, msgtype=Disconnected}
2024-04-05 14:53:36.587 30045-30045/ru.masterme.chat.masterme_chat W/FlutterJNI: Tried to send a platform message to Flutter, but FlutterJNI was detached from native C++. Could not send. Channel: flutter_xmpp/stream. Response ID: 27
2024-04-05 14:53:40.946 30045-30045/ru.masterme.chat.masterme_chat W/System.err: android.app.BackgroundServiceStartNotAllowedException: Not allowed to start service Intent { cmp=ru.masterme.chat.masterme_chat/id.flutter.flutter_background_service.BackgroundService }: app is in background uid UidRecord{a076cf2 u0a322 RCVR bg:+1m5s62ms idle change:uncachedprocstateprocadj procs:0 seq(560748,555574)}
2024-04-05 14:53:40.947 30045-30045/ru.masterme.chat.masterme_chat W/System.err:     at android.app.ContextImpl.startServiceCommon(ContextImpl.java:1922)
2024-04-05 14:53:40.948 30045-30045/ru.masterme.chat.masterme_chat W/System.err:     at android.app.ContextImpl.startService(ContextImpl.java:1872)
2024-04-05 14:53:40.949 30045-30045/ru.masterme.chat.masterme_chat W/System.err:     at android.content.ContextWrapper.startService(ContextWrapper.java:827)
2024-04-05 14:53:40.949 30045-30045/ru.masterme.chat.masterme_chat W/System.err:     at id.flutter.flutter_background_service.WatchdogReceiver.onReceive(WatchdogReceiver.java:82)
2024-04-05 14:53:40.950 30045-30045/ru.masterme.chat.masterme_chat W/System.err:     at android.app.ActivityThread.handleReceiver(ActivityThread.java:4543)
2024-04-05 14:53:40.951 30045-30045/ru.masterme.chat.masterme_chat W/System.err:     at android.app.ActivityThread.-$$Nest$mhandleReceiver(Unknown Source:0)
2024-04-05 14:53:40.953 30045-30045/ru.masterme.chat.masterme_chat W/System.err:     at android.app.ActivityThread$H.handleMessage(ActivityThread.java:2307)
2024-04-05 14:53:40.954 30045-30045/ru.masterme.chat.masterme_chat W/System.err:     at android.os.Handler.dispatchMessage(Handler.java:106)
2024-04-05 14:53:40.954 30045-30045/ru.masterme.chat.masterme_chat W/System.err:     at android.os.Looper.loopOnce(Looper.java:240)
2024-04-05 14:53:40.955 30045-30045/ru.masterme.chat.masterme_chat W/System.err:     at android.os.Looper.loop(Looper.java:351)
2024-04-05 14:53:40.956 30045-30045/ru.masterme.chat.masterme_chat W/System.err:     at android.app.ActivityThread.main(ActivityThread.java:8370)
2024-04-05 14:53:40.957 30045-30045/ru.masterme.chat.masterme_chat W/System.err:     at java.lang.reflect.Method.invoke(Native Method)
2024-04-05 14:53:40.958 30045-30045/ru.masterme.chat.masterme_chat W/System.err:     at com.android.internal.os.RuntimeInit$MethodAndArgsCaller.run(RuntimeInit.java:568)
2024-04-05 14:53:40.958 30045-30045/ru.masterme.chat.masterme_chat W/System.err:     at com.android.internal.os.ZygoteInit.main(ZygoteInit.java:1013)



2024-04-05 16:42:30.918 829-829/ru.masterme.chat.masterme_chat W/System.err: java.lang.NullPointerException: Attempt to invoke virtual method 'void org.jivesoftware.smack.tcp.XMPPTCPConnection.sendStanza(org.jivesoftware.smack.packet.Stanza)' on a null object reference
2024-04-05 16:42:30.919 829-829/ru.masterme.chat.masterme_chat W/System.err:     at org.xrstudio.xmpp.flutter_xmpp.Connection.FlutterXmppConnection.send_delivery_receipt(FlutterXmppConnection.java:236)
2024-04-05 16:42:30.920 829-829/ru.masterme.chat.masterme_chat W/System.err:     at org.xrstudio.xmpp.flutter_xmpp.FlutterXmppPlugin.onMethodCall(FlutterXmppPlugin.java:675)
2024-04-05 16:42:30.921 829-829/ru.masterme.chat.masterme_chat W/System.err:     at io.flutter.plugin.common.MethodChannel$IncomingMethodCallHandler.onMessage(MethodChannel.java:267)
2024-04-05 16:42:30.922 829-829/ru.masterme.chat.masterme_chat W/System.err:     at io.flutter.embedding.engine.dart.DartMessenger.invokeHandler(DartMessenger.java:292)
2024-04-05 16:42:30.923 829-829/ru.masterme.chat.masterme_chat W/System.err:     at io.flutter.embedding.engine.dart.DartMessenger.lambda$dispatchMessageToQueue$0$io-flutter-embedding-engine-dart-DartMessenger(DartMessenger.java:319)
2024-04-05 16:42:30.924 829-829/ru.masterme.chat.masterme_chat W/System.err:     at io.flutter.embedding.engine.dart.DartMessenger$$ExternalSyntheticLambda0.run(Unknown Source:12)
2024-04-05 16:42:30.925 829-829/ru.masterme.chat.masterme_chat W/System.err:     at android.os.Handler.handleCallback(Handler.java:942)
2024-04-05 16:42:30.926 829-829/ru.masterme.chat.masterme_chat W/System.err:     at android.os.Handler.dispatchMessage(Handler.java:99)
2024-04-05 16:42:30.927 829-829/ru.masterme.chat.masterme_chat W/System.err:     at android.os.Looper.loopOnce(Looper.java:240)
2024-04-05 16:42:30.928 829-829/ru.masterme.chat.masterme_chat W/System.err:     at android.os.Looper.loop(Looper.java:351)
2024-04-05 16:42:30.929 829-829/ru.masterme.chat.masterme_chat W/System.err:     at android.app.ActivityThread.main(ActivityThread.java:8370)
2024-04-05 16:42:30.930 829-829/ru.masterme.chat.masterme_chat W/System.err:     at java.lang.reflect.Method.invoke(Native Method)
2024-04-05 16:42:30.930 829-829/ru.masterme.chat.masterme_chat W/System.err:     at com.android.internal.os.RuntimeInit$MethodAndArgsCaller.run(RuntimeInit.java:568)
2024-04-05 16:42:30.931 829-829/ru.masterme.chat.masterme_chat W/System.err:     at com.android.internal.os.ZygoteInit.main(ZygoteInit.java:1013)