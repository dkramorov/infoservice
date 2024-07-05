import 'dart:async';
import 'dart:math';

import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:infoservice/helpers/context_extensions.dart';
import 'package:infoservice/helpers/phone_mask.dart';
import 'package:infoservice/models/roster_model.dart';
import 'package:infoservice/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/dialogs.dart';
import '../models/bg_tasks_model.dart';
import '../models/user_settings_model.dart';
import '../pages/app_asset_lib.dart';
import '../pages/chat/chat_page.dart';
import '../pages/static_values.dart';
import '../pages/themes.dart';
import '../services/shared_preferences_manager.dart';

class UserSupportButton extends StatelessWidget {
  const UserSupportButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: context.screenSize.width - 32,
      child: ElevatedButton(
        style: UIs.elevatedButtonDefault,
        onPressed: () async {
          String login = '89025768473@${JABBER_SERVER}';
          //String login = '89016598623@${JABBER_SERVER}';
          BGTasksModel.addRosterTask({
            'login': login,
          });
          int counter = 0;
          Timer.periodic(const Duration(seconds: 1), (timer) async {
            if (counter > 5) {
              timer.cancel();
            }
            UserSettingsModel? userSettings = await UserSettingsModel().getUser();
            if (userSettings != null) {
              timer.cancel();
              List<RosterModel> rosterModels = await RosterModel().getBy(
                  userSettings.jid ?? '', jid: login,
              );
              if (rosterModels.isNotEmpty) {
                RosterModel rosterModel = rosterModels[0];
                Future.delayed(Duration.zero, () async {
                  Navigator.pushNamed(context, ChatScreen.id, arguments: {
                    null,
                    null,
                    ChatUser(
                      id: rosterModel.jid ?? '',
                      jid: rosterModel.jid ?? '',
                      name: rosterModel.name,
                      phone: cleanPhone(rosterModel.jid ?? ''),
                    ),
                  });
                });
              }
            }
          });
        },
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                vertical: 9,
                horizontal: 12,
              ),
              decoration: BoxDecoration(
                color: white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.08),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: SvgPicture.asset(AssetLib.logoColor),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Служба поддержки',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: w500,
                    color: black,
                  ),
                ),
                Text(
                  'Мы всегда готовы вам помочь',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: w500,
                    color: gray100,
                  ),
                ),
              ],
            ),
            const Spacer(),
            SvgPicture.asset(AssetLib.smallArrow),
          ],
        ),
      ),
    );
  }
}
