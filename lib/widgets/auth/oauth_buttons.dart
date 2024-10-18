import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../helpers/dialogs.dart';
import '../../helpers/log.dart';
import '../../helpers/network.dart';
import '../../models/bg_tasks_model.dart';
import '../../pages/app_asset_lib.dart';
import '../../pages/themes.dart';
import '../../settings.dart';
import '../rounded_button_widget.dart';

class YandexOauthButton extends StatelessWidget {
  const YandexOauthButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RoundedButtonWithIconWidget(
      icon: SvgPicture.asset(AssetLib.yandexIcon),
      text: const Text(
        'Яндекс',
        style: TextStyle(fontSize: 12),
      ),
      color: white,
      onPressed: () async {
        Map<String, dynamic> auth = await yandexOauth();
        Log.d('yandexOauth', auth.toString());
        if (auth['id'] != null && auth['token'] != null) {
          // Шлем на сервер токен, сервер с токеном сам реганет пользователя
          const uri = 'https://$JABBER_SERVER$JABBER_REG_OAUTH_ENDPOINT';
          Log.d('REGISTER OAUTH QUERY', 'query: $uri');

          final userInfo =
              await requestsGetJson(uri, authHeader: 'Yandex ${auth['token']}');
          Log.d('REGISTER OAUTH RESULT', userInfo.toString());
          Log.d('AUTH', '${userInfo["passwd"]}, ${userInfo["phone"]}');
          if (userInfo['passwd'] != null && userInfo['phone'] != null) {
            Map<String, dynamic> userData = {
              'login': userInfo['phone'],
              'passwd': userInfo['passwd'],
            };
            BGTasksModel.createRegisterTask(userData);
            showLoading(removeAfterSec: 5);
          } else {
            Future.delayed(Duration.zero, () {
              openInfoDialog(
                  context,
                  () {},
                  'Ошибка',
                  'Произошла ошибка, попробуйте поздже. ${userInfo["message"]}',
                  'Хорошо');
            });
          }
        } else {
          Future.delayed(Duration.zero, () {
            openInfoDialog(context, () {}, 'Ошибка',
                'Произошла ошибка, попробуйте поздже', 'Хорошо');
          });
        }
      },
    );
  }
}

class GoogleOauthButton extends StatelessWidget {
  //https://developers.google.com/identity/protocols/oauth2/scopes#people
  //https://developers.google.com/people/api/rest/v1/people.connections/list

  const GoogleOauthButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RoundedButtonWithIconWidget(
      icon: SvgPicture.asset(
          AssetLib.googleIcon,
          width: 24,
          height: 24,
      ),
      text: const Text(
        'Google',
        style: TextStyle(fontSize: 12),
      ),
      color: white,
      onPressed: () async {
        GoogleSignIn googleSignIn = GoogleSignIn(
          scopes: [
            'email', 'phone',
            //'https://www.googleapis.com/auth/userinfo.profile',
            //'https://www.googleapis.com/auth/contacts.readonly',
            //'https://www.googleapis.com/auth/user.birthday.read',
            //'https://www.googleapis.com/auth/user.gender.read',
            //'https://www.googleapis.com/auth/user.phonenumbers.read',
            //'https://www.googleapis.com/auth/admin.directory.user.readonly', // phone
          ],
        );

        try {
          await googleSignIn.signIn();
          GoogleSignInAccount? account = googleSignIn.currentUser;
          if (account != null) {
            // https://developers.google.com/oauthplayground/
            GoogleSignInAuthentication? auth =
                await googleSignIn.currentUser?.authentication;
            if (auth != null) {
              // Шлем на сервер токен, сервер с токеном сам реганет пользователя
              const uri = 'https://$JABBER_SERVER$JABBER_REG_OAUTH_ENDPOINT';
              Log.d('REGISTER OAUTH QUERY',
                  'query: $uri, token ${auth.accessToken}');

              final userInfo = await requestsGetJson(uri,
                  authHeader: 'Google ${auth.accessToken}');
              Log.d('REGISTER OAUTH RESULT', userInfo.toString());
              Log.d('AUTH', '${userInfo["passwd"]}, ${userInfo["phone"]}');
              if (userInfo['passwd'] != null && userInfo['phone'] != null) {
                Map<String, dynamic> userData = {
                  'login': userInfo['phone'],
                  'passwd': userInfo['passwd'],
                };
                BGTasksModel.createRegisterTask(userData);
                showLoading(removeAfterSec: 5);
              } else {
                Future.delayed(Duration.zero, () {
                  openInfoDialog(
                      context,
                      () {},
                      'Ошибка',
                      'Произошла ошибка, попробуйте поздже. ${userInfo["message"]}',
                      'Хорошо');
                });
              }
            } else {
              Future.delayed(Duration.zero, () {
                openInfoDialog(context, () {}, 'Ошибка',
                    'Произошла ошибка, попробуйте поздже', 'Хорошо');
              });
            }
          } else {
            Future.delayed(Duration.zero, () {
              openInfoDialog(context, () {}, 'Ошибка',
                  'Произошла ошибка, попробуйте поздже', 'Хорошо');
            });
          }
        } catch (error) {
          Future.delayed(Duration.zero, () {
            openInfoDialog(
                context,
                () {},
                'Ошибка',
                'Произошла ошибка, попробуйте поздже. ${error.toString()}',
                'Хорошо');
          });
        }
      },
    );
  }
}
