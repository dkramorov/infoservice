//
//  XMPPController+SearchUsers.swift
//  xmpp_plugin
//

import Foundation
import XMPPFramework

//MARK: - SearchUsers
extension XMPPController {

    public func searchUsers(username : String,
                     withStrem : XMPPStream,
                     objXMPP : XMPPController) {

        print("\(#function) | searchUsers | username : \(username)")

        let searchingServer = "vjud." + withStrem.hostName!
        var serviceJID = XMPPJID(string: searchingServer)

        let query = DDXMLElement(name: "query", xmlns: "jabber:iq:search")
        let x = DDXMLElement(name: "x", xmlns: "jabber:x:data")
        x.addAttribute(withName: "type", stringValue: "submit")
        /*
        let field1 = DDXMLElement(name: "field")
        let value1 = DDXMLElement(name: "value", stringValue: "jabber:iq:search")
        field1.addAttribute(withName: "type", stringValue: "hidden")
        field1.addAttribute(withName: "var", stringValue: "FORM_TYPE")
        field1.addChild(value1)
        */
        let field2 = DDXMLElement(name: "field")
        let value2 = DDXMLElement(name: "value", stringValue: username)
        field2.addAttribute(withName: "type", stringValue: "text-single")
        //field2.addAttribute(withName: "var", stringValue: "search")
        field2.addAttribute(withName: "var", stringValue: "user")
        field2.addChild(value2)
        /*
        let field3 = DDXMLElement(name: "field")
        let value3 = DDXMLElement(name: "value", stringValue: "1")
        field3.addAttribute(withName: "type", stringValue: "boolean")
        field3.addAttribute(withName: "var", stringValue: "user")
        field3.addChild(value3)
        */
        //x.addChild(field1)
        x.addChild(field2)
        //x.addChild(field3)
        query.addChild(x)

        let iq = XMPPIQ(iqType: .set, to: XMPPJID(string: searchingServer), elementID: XMPPStream.generateUUID, child: query)
        objXMPP.xmppStream.send(iq)
    }
}

