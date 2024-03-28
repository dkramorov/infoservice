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