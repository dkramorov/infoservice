//
//  XMPPController+XMPPMUC.swift
//  xmpp_plugin
//

import Foundation
import XMPPFramework

//MARK: - XMPPMUC
extension XMPPController : XMPPMUCDelegate {
    func getMUCSubscriptions(withStrem : XMPPStream,
                             objXMPP : XMPPController) {
        /* Получает ВСЕ комнаты
        print("\(#function) | getMyRooms")
        let hostName = "conference." + withStrem.hostName!
        //var serviceJID = XMPPJID(string: hostName)
        objXMPP.xmppMUC?.discoverRooms(forServiceNamed: hostName)
        // Прием в iqstanza (XMPPRoomDelegate)
        */

        /* Получем подписки на MUC - только то, что сейчас подписано (пусто будет)
           т/к, когда пользователь выходит - все MUC подписки убираются
        <iq from='hag66@shakespeare.example'
            to='muc.shakespeare.example'
            type='get'
            id='E6E10350-76CF-40C6-B91B-1EA08C332FC7'>
          <subscriptions xmlns='urn:xmpp:mucsub:0' />
        </iq>
        */
        /*
        print("\(#function) | getMUCSubscriptions")
        let searchingServer = "conference." + withStrem.hostName!
        let query = DDXMLElement(name: "subscriptions", xmlns: "urn:xmpp:mucsub:0")
        let iq = XMPPIQ(iqType: .get, to: XMPPJID(string: searchingServer), elementID: XMPPStream.generateUUID, child: query)
        objXMPP.xmppStream.send(iq)
        */

        objXMPP.xmppMUC?.discoverRooms(forServiceNamed: "conference." + withStrem.hostName!) // Вернет все комнаты
    }

    func xmppMUC(_ sender: XMPPMUC, didDiscoverRooms rooms: [Any], forServiceNamed serviceName: String) {
        var result = [String]()
        for item in rooms {
            if let room = item as? DDXMLElement,
            let jid = room.attribute(forName: "jid")?.stringValue,
            let _ = room.attribute(forName: "name")?.stringValue {
                //let roomjid = XMPPJID(string: jid)
                result.append(jid)
                //printLog(roomjid)
                /*
                self.room = XMPPRoom(roomStorage: XMPPRoomCoreDataStorage.sharedInstance(), jid: roomjid)
                self.room.addDelegate(self, delegateQueue: self.moduleQueue)
                self.room.activate(self.xmppStream)
                self.room.join(usingNickname: "helloworld", history: nil)
                */
            }
        }
        self.sendRosters(withUsersJid: result)
    }
    
    func xmppMUC(_ sender: XMPPMUC, failedToDiscoverRoomsForServiceNamed serviceName: String, withError error: Error) {
        printLog("-------------------------------")
        printLog(error)
        printLog("-------------------------------")
    }
/*
    public func xmppMUC(_ sender: XMPPMUC, roomJID: XMPPJID, didReceiveInvitation message: XMPPMessage) {
        let storage = XMPPRoomCoreDataStorage.sharedInstance()
        room = XMPPRoom(roomStorage: storage, jid: roomJID)!
        room.join(usingNickname: "potestua-user", history: nil)
    }
*/
    func xmppMUC(_ sender: XMPPMUC, roomJID: XMPPJID, didReceiveInvitationDecline message: XMPPMessage) {
        printLog("-------------------------------")
        printLog(message)
        printLog("-------------------------------")
    }

}
