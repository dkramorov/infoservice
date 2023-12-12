//
//  XMPPController+HTTPFileUpload.swift
//  xmpp_plugin
//

import Foundation
import XMPPFramework

//MARK: - HTTPFileUpload
extension XMPPController {
    func requestSlot(filename : String,
                     filesize : Int,
                     withStrem : XMPPStream,
                     objXMPP : XMPPController) {

        print("\(#function) | requestSlot | filename : \(filename)")
        let hostName = "upload." + withStrem.hostName!
        let serviceJID = XMPPJID(string: hostName)
        objXMPP.xmppFileUpload?.requestSlot(fromService:serviceJID!,
                                            filename:filename,
                                            size:UInt(filesize),
                                            contentType:"image/jpeg",
                                            completion: { (slot, resultIq, error) in
                                                self.sendSlot(slot: slot, resultIq: resultIq, error: error)
                                            })
    }
}

