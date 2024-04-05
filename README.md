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