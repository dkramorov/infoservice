import 'package:infoservice/helpers/phone_mask.dart';
import 'package:infoservice/models/user_settings_model.dart';

import '../models/roster_model.dart';
import '../services/jabber_manager.dart';

Future<String> getRosterNameByPhone(
    JabberManager? xmppHelper, String phone) async {
  /* Возвращает имя по телефону (логину),
     например, для звонка String phone = call?.remote_identity ?? '';
  */
  if (JabberManager.cacheRosterNames[phone] != null) {
    return JabberManager.cacheRosterNames[phone]!;
  }
  String name = phoneMaskHelper(phone);
  UserSettingsModel? userSettings = await UserSettingsModel().getUser();
  if (userSettings != null) {
    String jid = userSettings.jid ?? '';
    List<RosterModel> rosters = await RosterModel().getBy(jid,
        jid: JabberManager().toJid(phone));
    if (rosters.isNotEmpty && rosters[0].name != null) {
      name = rosters[0].name!;
      if (name != '') {
        JabberManager.cacheRosterNames[phone] = name;
      }
    }
  }
  return name;
}
