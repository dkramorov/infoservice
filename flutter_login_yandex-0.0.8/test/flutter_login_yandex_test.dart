import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_login_yandex_updated/flutter_login_yandex.dart';
import 'package:flutter_login_yandex_updated/flutter_login_yandex_platform_interface.dart';
import 'package:flutter_login_yandex_updated/flutter_login_yandex_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterLoginYandexPlatform
    with MockPlatformInterfaceMixin
    implements FlutterLoginYandexPlatform {
  @override
  Future<Map<String, String>?> signIn() => Future.value({'42': '42'});

  @override
  Future<Map<Object?, Object?>?> signOut() {
    // TODO: implement signOut
    throw UnimplementedError();
  }
}

void main() {
  final FlutterLoginYandexPlatform initialPlatform =
      FlutterLoginYandexPlatform.instance;

  test('$MethodChannelFlutterLoginYandex is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterLoginYandex>());
  });

  test('getPlatformVersion', () async {
    FlutterLoginYandex flutterLoginYandexPlugin = FlutterLoginYandex();
    MockFlutterLoginYandexPlatform fakePlatform =
        MockFlutterLoginYandexPlatform();
    FlutterLoginYandexPlatform.instance = fakePlatform;

    expect(await flutterLoginYandexPlugin.signIn(), '42');
  });
}
