//
//  XMPPController+VCard.swift
//  xmpp_plugin
//

import Foundation
import XMPPFramework

//MARK: - VCard
extension XMPPController {
    func getVCard(withUserJid jid: String, withStrem: XMPPStream, objXMPP : XMPPController) {

        var vCard = [String : String]()
        printLog("\(#function) | withUserJid: \(jid)")
        if jid.trim().isEmpty {
            print("\(#function) | getting userJid is emtpy.")
            return
        }

        let vJid : XMPPJID? = XMPPJID(string: getJIDNameForUser(jid.trim(), withStrem: withStrem))
        guard let user = objXMPP.xmppVCardTemp?.vCardTemp(for: vJid!, shouldFetch: true) else {
            printLog("\(#function) | Not getting VCard.")
            self.sendVCard(withVCard: vCard)
            return
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy HH:mm:ss"

        vCard["FN"] = user.formattedName
        vCard["NICKNAME"] = user.nickname
        vCard["URL"] = user.url
        if (user.bday != nil) {
            vCard["BDAY"] = formatter.string(from: user.bday!)
        }
        vCard["DESC"] = user.desc
        self.sendVCard(withVCard: vCard)
    }

    func saveVCard(withDesc desc: String, withStrem: XMPPStream, objXMPP : XMPPController) {
        guard let user = objXMPP.xmppVCardTemp?.vCardTemp(for: objXMPP.userJID, shouldFetch: true) else {
            return
        }
        user.desc = desc
        objXMPP.xmppVCardTemp?.updateMyvCardTemp(user)
    }


}
