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
Приоритетные 4, 5 пункты и звонки

TODO:
писать в базу и проверять доступны ли пути к файлам из база
на медиа сообщения чата, например,
грузим из /data/sd/ файл и этот файл сразу можно проверить,
но если снова получить сообщения, тогда будет только ссылка
и придется качать, без записи в базу пути к файлу так и будет


https://github.com/igniterealtime/Smack/blob/master/smack-extensions/src/main/java/org/jivesoftware/smackx/muc/MultiUserChatManager.java
https://github.com/igniterealtime/Smack/blob/f65cf45b5c1aecb6cbfef94890523bc3a1906ac8/smack-extensions/src/integration-test/java/org/jivesoftware/smackx/muc/MultiUserChatTest.java#L368
/Users/jocker/StudioProjects/infoservice/ios/.symlinks/plugins/xmpp_plugin/android/src/main/java/org/xrstudio/xmpp/flutter_xmpp/Connection/FlutterXmppConnection.java
    // Возвращает пустой список
    Utils.printLog("---------------------------------------");
    Utils.printLog(multiUserChatManager.getJoinedRooms().toString());
    Utils.printLog(multiUserChatManager.getJoinedRooms(Utils.getFullJid("89016598623@chat.masterme.ru").asEntityJidOrThrow()).toString());
    // Тоже пусто
    Utils.printLog("---------------------------------------1");
    Jid me = Utils.getFullJid(groupName + "@" + "conference." + mHost);
    Utils.printLog(multiUserChatManager.isServiceEnabled(me) + "");
    Utils.printLog(multiUserChatManager.getJoinedRooms().toString());
    Utils.printLog("---------------------------------------2");

https://discourse.igniterealtime.org/t/muc-getjoinedrooms-userjid-returns-empty/62517/2
    // Возвращает все
    Utils.printLog("---------------------------------------");
    String searchDomain = mUsername + "@" + "conference." + mHost;
    Utils.printLog(multiUserChatManager.getHostedRooms(JidCreate.domainBareFrom(searchDomain)).toString());

Чтобы войти в группу
https://xmpp.org/extensions/xep-0045.html#enter

Search Module
https://github.com/dbsGen/XEP-0055
https://github.com/dbsGen/XEP-0055/issues/1
https://stackoverflow.com/questions/51758226/how-to-check-if-a-user-jid-is-already-taken-in-xmppframework