import 'package:infoservice/helpers/phone_mask.dart';
import 'package:infoservice/models/user_settings_model.dart';

import '../models/companies/orgs.dart';
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
    List<RosterModel> rosters =
        await RosterModel().getBy(jid, jid: JabberManager().toJid(phone));
    if (rosters.isNotEmpty) {
      RosterModel item = rosters[0];
      if (item.name != null) {
        name = item.name ?? '';
        if (name != '') {
          JabberManager.cacheRosterNames[phone] = name;
        }
      } else {
        /*
        String itemJid = rosters[0].jid!;
        Orgs? org = await Orgs().getOrgByChat(cleanPhone(itemJid));
        if (org != null && org.name != null && org.name != '') {
          name = org.name ?? '';
          item.name = name;
          await item.updatePartial(item.id, {
            'name': name,
          });
          JabberManager.cacheRosterNames[phone] = name;
        }
        */
      }
    }
  }
  return name;
}
