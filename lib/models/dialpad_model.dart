import 'package:infoservice/models/user_chat_model.dart';

import 'companies/orgs.dart';

class DialpadModel {
  static const TAG = 'DialpadModel';

  final String phone;
  final bool isSip;
  final bool startCall;
  final Orgs? company;
  final UserChatModel? user;

  DialpadModel(
      {required this.phone, required this.isSip, this.startCall=false, this.company, this.user});

  @override
  String toString() {
    return 'phone: $phone, isSip: $isSip, startCall: $startCall' +
        ' company: ${company.toString()},' +
        ' user: ${user.toString()}';
  }
}
