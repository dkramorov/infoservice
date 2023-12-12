//
//  XMPPController+PrivateStorage.swift
//  xmpp_plugin
//

import Foundation
import XMPPFramework

//MARK: - PrivateStorage
extension XMPPController {

    public func getPrivateStorage(withCategory: String,
                                  withName: String,
                                  withStrem: XMPPStream,
                                  objXMPP: XMPPController) {
        /* Личное хранилище - Чтение
         SENT
           <iq id='Emly6-35' type='get'>
             <query xmlns='jabber:iq:private'>
               <chats xmlns='chats:new_messages'/>
             </query>
           </iq>
         RECV
           <iq xml:lang='en' to='89016598623@chat.masterme.ru/57827693-950f-49d8-9358-99b5162ba556' from='89016598623@chat.masterme.ru' type='result' id='Emly6-35'>
             <query xmlns='jabber:iq:private'>
               <chats xmlns='chats:new_messages'>
                 <chat_id_1>value_long_long_text and etc...</chat_id_1>
               </chats>
             </query>
           </iq>
        */

        print("\(#function) | getPrivateStorage | withCategory: \(withCategory) | withName: \(withName)")

        let query = DDXMLElement(name: CustomXmlStorageConstants.queryElement, xmlns: CustomXmlStorageConstants.xmlns_private_storage)
        let param = DDXMLElement(name: withCategory, xmlns: withCategory + ":" + withName)
        query.addChild(param)

        let iq = XMPPIQ(iqType: .get, elementID: XMPPStream.generateUUID, child: query)
        objXMPP.xmppStream.send(iq)
    }

    public func setPrivateStorage(withCategory: String,
                                  withName: String,
                                  withDict: [String: String],
                                  withStrem: XMPPStream,
                                  objXMPP: XMPPController) {
        /* Личное хранилище - Запись
         SENT
           <iq id='Emly6-33' type='set'>
             <query xmlns='jabber:iq:private'>
               <chats xmlns="chats:new_messages">
                 <chat_id_1>value_long_long_text and etc...</chat_id_1>
               </chats>
             </query>
           </iq>
         RECV
           <iq xml:lang='en' to='89016598623@chat.masterme.ru/57827693-950f-49d8-9358-99b5162ba556' from='89016598623@chat.masterme.ru' type='result' id='Emly6-33'/>
        */

        print("\(#function) | setPrivateStorage | withCategory: \(withCategory) | withName: \(withName) | withDict: \(withDict)")

        let query = DDXMLElement(name: CustomXmlStorageConstants.queryElement, xmlns: CustomXmlStorageConstants.xmlns_private_storage)
        let param = DDXMLElement(name: withCategory, xmlns: withCategory + ":" + withName)
        for (dictKey, dictValue) in withDict {
            let paramValue = DDXMLElement(name: dictKey, stringValue: dictValue)
            param.addChild(paramValue)
        }
        query.addChild(param)
        let iq = XMPPIQ(iqType: .set, elementID: XMPPStream.generateUUID, child: query)
        objXMPP.xmppStream.send(iq)
    }
}

// MARK: - Constants
fileprivate struct CustomXmlStorageConstants {
    static let xmlns_private_storage = "jabber:iq:private"
    static let queryElement = "query"
}
