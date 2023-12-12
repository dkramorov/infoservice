import Flutter
import UIKit

public class FlutterXmppPlugin: NSObject, FlutterPlugin {
    
    static var  objEventChannel : FlutterEventChannel  =  FlutterEventChannel.init()
    static var  objConnectionEventChannel : FlutterEventChannel  =  FlutterEventChannel.init()
    static var  objSuccessEventChannel : FlutterEventChannel  =  FlutterEventChannel.init()
    static var  objErrorEventChannel : FlutterEventChannel  =  FlutterEventChannel.init()
   
    var objEventData : FlutterEventSink?
    var objConnectionEventData : FlutterEventSink?
    var objSuccessEventData : FlutterEventSink?
    var objErrorEventData : FlutterEventSink?

    var objXMPP : XMPPController = XMPPController.sharedInstance
    var objXMPPConnStatus : xmppConnectionStatus = xmppConnectionStatus.None {
        didSet {
            postNotification(Name: .xmpp_ConnectionStatus)
        }
    }
    var singalCallBack : FlutterResult?
    
    var objXMPPLogger : xmppLoggerInfo?
    
    //MARK:-
    override init() {
        super.init()
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_xmpp/method", binaryMessenger: registrar.messenger())
        let instance = FlutterXmppPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        
        objEventChannel = FlutterEventChannel(name: "flutter_xmpp/stream", binaryMessenger: registrar.messenger())
        objEventChannel.setStreamHandler(SwiftStreamHandler())
        
        objConnectionEventChannel = FlutterEventChannel(name: "flutter_xmpp/connection_event_stream", binaryMessenger: registrar.messenger())
        objConnectionEventChannel.setStreamHandler(ConnectionStreamHandler())
                
        objSuccessEventChannel = FlutterEventChannel(name: "flutter_xmpp/success_event_stream", binaryMessenger: registrar.messenger())
        objSuccessEventChannel.setStreamHandler(SuccessStreamHandler())
        
        objErrorEventChannel = FlutterEventChannel(name: "flutter_xmpp/error_event_stream", binaryMessenger: registrar.messenger())
        objErrorEventChannel.setStreamHandler(ErrorStreamHandler())
        
        APP_DELEGATE.manange_NotifcationObservers()
    }
    //MARK: -
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        addLogger(.receiveFromFlutter, call)
        
        let vMethod : String = call.method.trim()
        printLog(" \(#function) |vMethod \(vMethod)")
        
        switch vMethod {
        case pluginMethod.login:
            self.performLoginActivity(call, result)
               
        case pluginMethod.logout:
            self.performLogoutActivity(call, result)

        case pluginMethod.potestua:
            self.performPotestuaActivity(call, result)

        case pluginMethod.requestSlot:
            self.performRequestSlotActivity(call, result)

        case pluginMethod.searchUsers:
            self.performSearchUsersActivity(call, result)

        case pluginMethod.sendMessage,
             pluginMethod.sendMessageInGroup,
             pluginMethod.sendCustomMessage,
             pluginMethod.sendCustomMessageInGroup:
            self.performSendMessageActivity(call, result)

        case pluginMethod.getMyMUCs:
            self.performGetMyMUCsActivity(call, result)
                        
        case pluginMethod.createMUC:
            self.performCreateMUCActivity(call, result)
            
        case pluginMethod.joinMUCGroups:
            self.performJoinMUCGroupsActivity(call, result)
        
        case pluginMethod.joinMUCGroup:
            self.performJoinMUCGroupActivity(call, result)
            
        case pluginMethod.sendReceiptDelivery:
            self.performReceiptDeliveryActivity(call, result)
            
        case pluginMethod.addMembersInGroup:
            self.performAddRemoveMembersInGroupActivity(withMemeberType: .Member, actionType: .Add, call, result)
            
        case pluginMethod.addAdminsInGroup:
            self.performAddRemoveMembersInGroupActivity(withMemeberType: .Admin, actionType: .Add, call, result)
            
        case pluginMethod.addOwnersInGroup:
            self.performAddRemoveMembersInGroupActivity(withMemeberType: .Owner, actionType: .Add, call, result)
            
        case pluginMethod.getMembers:
            self.performGetMembersInGroupActivity(withMemeberType: .Member, call, result)
            
        case pluginMethod.getAdmins:
            self.performGetMembersInGroupActivity(withMemeberType: .Admin, call, result)
            
        case pluginMethod.getOwners:
            self.performGetMembersInGroupActivity(withMemeberType: .Owner, call, result)
            
        case pluginMethod.removeMembersInGroup:
            self.performAddRemoveMembersInGroupActivity(withMemeberType: .Member, actionType: .Remove, call, result)
        
        case pluginMethod.removeAdminsInGroup:
            self.performAddRemoveMembersInGroupActivity(withMemeberType: .Admin, actionType: .Remove, call, result)
            
        case pluginMethod.removeOwnersInGroup:
            self.performAddRemoveMembersInGroupActivity(withMemeberType: .Owner, actionType: .Remove, call, result)
        
        case pluginMethod.getLastSeen:
            self.performLastActivity(call, result)
            
        case pluginMethod.createRosters:
            self.createRostersActivity(call, result)

        case pluginMethod.dropRosters:
            self.dropRostersActivity(call, result)

        case pluginMethod.getMyRosters:
            self.getMyRostersActivity(call, result)

        case pluginMethod.getVCard:
            self.getVCardActivity(call, result)

        case pluginMethod.saveVCard:
            self.saveVCardActivity(call, result)
           
        case pluginMethod.reqMAM:
            self.manageMAMActivity(call, result)
        
        case pluginMethod.getPresence:
            self.getPresenceActivity(call, result)
                    
        case pluginMethod.changeTypingStatus:
            self.changeTypingStatus(call, result)
            
        case pluginMethod.changePresenceType :
            self.changePresence(call, result)
            
        case pluginMethod.getConnectionStatus :
            self.getConnectionStatus(call, result)

        case pluginMethod.getPrivateStorage:
            self.getPrivateStorageActivity(call, result)

        case pluginMethod.setPrivateStorage:
            self.setPrivateStorageActivity(call, result)
            
        default:
            guard let vData = call.arguments as? [String : Any] else {
                print("Getting invalid/nil arguments-data by pluging.... | \(vMethod) | arguments: \(String(describing: call.arguments))")
                
                result(xmppConstants.ERROR)
                return
            }
            print("\(#function) | Not handel arguments-data by pluging.... | \(vMethod) | arguments: \(vData)")
            break
        }
        //result("iOS " + UIDevice.current.systemVersion)
    }
    
    func performLoginActivity(_ call: FlutterMethodCall, _ result: @escaping FlutterResult)  {
        guard let vData = call.arguments as? [String : Any] else {
            result(xmppConstants.DataNil);
            return
        }
        let vMethod : String = call.method.trim()
        
        let vHost : String = (vData["host"] as? String ?? "").trim()
        let vPort : String = (vData["port"] as? String ?? "0").trim()
        let vUserId : String = (vData["user_jid"] as? String ?? "").trim()
        let vUserJid = (vUserId.components(separatedBy: "@").first ?? "").trim()
        
        var vResource : String = xmppConstants.Resource
        let arrResource = vUserId.components(separatedBy: "/")
        if arrResource.count == 2 {
            vResource = (arrResource.last ?? vResource).trim()
        }
        let vPassword : String = (vData["password"] as? String ?? "").trim()
        let vLogPath : String = (vData["nativeLogFilePath"] as? String ?? "").trim()
        
        if [vHost.count, vUserJid.count, vPassword.count].contains(0) {
            result(xmppConstants.DataNil)
            return
        }
        if APP_DELEGATE.objXMPP.isSendMessage() {
            result(xmppConstants.SUCCESS)
            return
        }
        // Logs
        if self.setupXMPPLoggerSetting(withLogFileUrl: vLogPath) {
            addLogger(.receiveFromFlutter, call)
        }
        
        // autoDeliveryReceipt
        var vRequiSSLConn : Bool = false
        if let value = vData["requireSSLConnection"] as? Int {
            vRequiSSLConn = (value == 1)
        }
        
        // requireSSLConnection
        var vAutoDelivReceipt : Bool = false
        if let value = vData["autoDeliveryReceipt"] as? Int {
            vAutoDelivReceipt = (value == 1)
        }
        
        // AutoReconnection configuration
        var vAutoReconnection : Bool = true
        if let value = vData["automaticReconnection"] as? Int {
            vAutoReconnection = (value == 1)
        }
        
        // Use Stream Managment
        var vUseStream : Bool = true
        if let value = vData["useStreamManagement"] as? Int {
            vUseStream = (value == 1)
        }
        
        xmpp_HostName = vHost
        xmpp_HostPort = Int16(vPort) ?? 0
        xmpp_UserId = vUserJid
        xmpp_UserPass = vPassword
        xmpp_Resource = vResource
        xmpp_RequireSSLConnection = vRequiSSLConn
        xmpp_AutoDeliveryReceipt = vAutoDelivReceipt
        xmpp_AutoReConnection = vAutoReconnection
        xmpp_UseStream = vUseStream
        
        self.performXMPPConnectionActivity()
        result(xmppConstants.SUCCESS)
    }
    
    func setupXMPPLoggerSetting(withLogFileUrl urlString: String) -> Bool {
        if urlString.trim().isEmpty {
            printLog("\(#function) | Getting nativeLogFilePath is empty.")
            return false
        }
        guard let urlLogFile = URL(string: urlString) else {
            printLog("\(#function) | Invalid nativeLogFilePath | path: \(urlString)")
            return false
        }
        let objLogger = xmppLoggerInfo.init()
        objLogger.isLogEnable = true
        objLogger.logPath = urlLogFile.absoluteString
        
        APP_DELEGATE.objXMPPLogger = objLogger
        return true
    }
    
    func performLogoutActivity(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        var dicData : [String : Any] = [:]
        if let dic = call.arguments as? [String : Any] {
            dicData = dic
        }
        let vMethod : String = call.method.trim()
        printLog("\(#function) | \(vMethod) | arguments: \(dicData)")
        self.objXMPP.disconnect(withStrem: self.objXMPP.xmppStream)
    }

    func performPotestuaActivity(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        var dicData : [String : Any] = [:]
        if let dic = call.arguments as? [String : Any] {
            dicData = dic
        }
        let vMethod : String = call.method.trim()
        printLog("\(#function) | \(vMethod) | arguments: \(dicData)")
        NSLog("--------------------------------------------ios")
    }

    func performRequestSlotActivity(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let vData = call.arguments as? [String : Any] else {
            result(xmppConstants.DataNil);
            return
        }
        var filename : String = ""
        var filesize : Int = 0

        if let value = vData["filename"] as? String { filename = value }
        if let value = vData["size"] as? Int {filesize = value}
        printLog([filename, filesize])

        APP_DELEGATE.singalCallBack = result
        APP_DELEGATE.objXMPP.requestSlot(filename: filename,
                                         filesize: filesize,
                                         withStrem: self.objXMPP.xmppStream,
                                         objXMPP: self.objXMPP)
        NSLog("--------------------------------------------performRequestSlotActivity ios")
    }

    func performSearchUsersActivity(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let vData = call.arguments as? [String : Any] else {
            result(xmppConstants.DataNil);
            return
        }
        var username : String = ""

        if let value = vData["username"] as? String { username = value }
        printLog([username])

        APP_DELEGATE.singalCallBack = result
        APP_DELEGATE.objXMPP.searchUsers(username: username,
                                         withStrem: self.objXMPP.xmppStream,
                                         objXMPP: self.objXMPP)
        NSLog("--------------------------------------------performSearchUsersActivity ios")
    }

    func performSendMessageActivity(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let vData = call.arguments as? [String : Any] else {
            result(xmppConstants.ERROR)
            return
        }
        let vMethod : String = call.method.trim()
        printLog("\(#function) | \(vMethod) | arguments: \(vData)")
        
        let toJid : String = (vData["to_jid"] as? String ?? "").trim()
        let body : String = vData["body"] as? String ?? ""
        let id : String = (vData["id"] as? String ?? "").trim()
        let time : String = (vData["time"] as? String ?? "0").trim()
        
        var customElement : String = ""
        if [pluginMethod.sendCustomMessage, pluginMethod.sendCustomMessageInGroup].contains(vMethod) {
            customElement = (vData["customText"] as? String ?? "").trim()
        }
        let isGroupMess : Bool = [pluginMethod.sendMessageInGroup, pluginMethod.sendCustomMessageInGroup].contains(vMethod)
        self.objXMPP.sendMessage(messageBody: body,
                                 time: time,
                                 reciverJID: toJid,
                                 messageId: id,
                                 isGroup: isGroupMess,
                                 customElement: customElement,
                                 withStrem: self.objXMPP.xmppStream)
        result(xmppConstants.SUCCESS)
    }


    func performGetMyMUCsActivity(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        let vMethod : String = call.method.trim()
        printLog("\(#function) | \(vMethod)")
        APP_DELEGATE.singalCallBack = result
        APP_DELEGATE.objXMPP.getMUCSubscriptions(withStrem: self.objXMPP.xmppStream, objXMPP: self.objXMPP)
        //result(xmppConstants.SUCCESS)
    }
    
    func performCreateMUCActivity(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let vData = call.arguments as? [String : Any] else {
            result(xmppConstants.ERROR)
            return
        }
        let vMethod : String = call.method.trim()
        printLog("\(#function) | \(vMethod) | arguments: \(vData)")
        
        let vGroupName : String = (vData["group_name"] as? String ?? "").trim()
        var isPersistent : Bool = default_isPersistent
        if let value = vData["persistent"] as? Bool {
            isPersistent = value
        }
        else if let value = vData["persistent"] as? String {
            isPersistent = value.boolValue
        }
        
        if !self.isValidMUCInfo(withRoomName: vGroupName) {
            printLog("\(#function) | \(vMethod) | invalid groupname validation : \(vGroupName)")
            APP_DELEGATE.updateMUCCreateStatus(withRoomname: vGroupName, status: false, error : "Invalid Room Name")
            result(false)
            return
        }
        
    
        printLog("\(#function) | \(vMethod) | after validation : \(vData)")
        
        let objGroupInfo : groupInfo = groupInfo.init()
        objGroupInfo.name = vGroupName
        objGroupInfo.isPersistent = isPersistent
        
        APP_DELEGATE.singalCallBack = result
        APP_DELEGATE.objXMPP.createRoom(withRooms: [objGroupInfo], withStrem: self.objXMPP.xmppStream)
        //result(xmppConstants.SUCCESS)
    }
    
    func performJoinMUCGroupsActivity(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let vData = call.arguments as? [String : Any] else {
            result(xmppConstants.ERROR)
            return
        }
        let vMethod : String = call.method.trim()
        printLog("\(#function) | \(vMethod) | arguments: \(vData)")
        
        let arrRooms = vData["all_groups_ids"] as? [String] ?? []
        for vRoom  in arrRooms {
            let arrRoomCompo : [String] = vRoom.components(separatedBy: ",")
            if arrRoomCompo.count != 2 { continue }
            
            let vRoomName : String = arrRoomCompo.first ?? ""
            let vRoomTS : String = arrRoomCompo.last ?? "0"
            let vRoomTSLongFormat : Int64 = Int64(vRoomTS) ?? 0
            
            if !self.isValidMUCInfo(withRoomName: vRoomName, timeStamp: vRoomTSLongFormat) {
                result(false)
                continue
            }
            APP_DELEGATE.objXMPP.joinRoom(roomName: vRoomName, time: vRoomTSLongFormat, withStrem: self.objXMPP.xmppStream)
        }
        //result(xmppConstants.SUCCESS)
        result(true)
    }
    
    func performJoinMUCGroupActivity(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let vData = call.arguments as? [String : Any] else {
            result(xmppConstants.ERROR)
            return
        }
        let vMethod : String = call.method.trim()
        printLog("\(#function) | \(vMethod) | arguments: \(vData)")
        
        let vRoom = vData["group_id"] as? String ?? ""
        var arrRoomCompo : [String] = vRoom.components(separatedBy: ",")
        // Нихуя не понял зачем тут через запятую название группы с какой-то цифирой
        if arrRoomCompo.count != 2 {
            //result(false)
            //return
            arrRoomCompo = [vRoom, "0"]
        }
        let vRoomName : String = arrRoomCompo.first ?? ""
        let vRoomTS : String = arrRoomCompo.last ?? "0"
        let vRoomTSLongFormat : Int64 = Int64(vRoomTS) ?? 0
        
        if !self.isValidMUCInfo(withRoomName: vRoomName, timeStamp: vRoomTSLongFormat) {
            result(false)
            APP_DELEGATE.updateMUCJoinStatus(withRoomname: vRoomName, status: false, error : "Invalid Room Name")
            return
        }
        APP_DELEGATE.singalCallBack = result
        APP_DELEGATE.objXMPP.joinRoom(roomName: vRoomName, time: vRoomTSLongFormat, withStrem: self.objXMPP.xmppStream)
        //result(true)
    }
    
    func performReceiptDeliveryActivity(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let vData = call.arguments as? [String : Any] else {
            result(xmppConstants.ERROR)
            return
        }
        let vMethod : String = call.method.trim()
        let toJid : String = (vData["toJid"] as? String ?? "").trim()
        let msgId : String = vData["msgId"] as? String ?? ""
        let receiptId : String = (vData["receiptId"] as? String ?? "").trim()
        printLog("\(#function) | \(vMethod) | arguments: \(vData) | toJid: \(toJid) | msgId : \(msgId) | receiptId: \(receiptId)")
        
        self.objXMPP.sentMessageDeliveryReceipt(withReceiptId: receiptId,
                                                jid: toJid,
                                                messageId: msgId,
                                                withStrem: self.objXMPP.xmppStream)
        result(xmppConstants.SUCCESS)
    }
    
    func performAddRemoveMembersInGroupActivity(withMemeberType type : xmppMUCUserType,
                                              actionType: xmppMUCUserActionType,
                                              _ call: FlutterMethodCall,
                                              _ result: @escaping FlutterResult) {
        guard let vData = call.arguments as? [String : Any] else {
            result(xmppConstants.ERROR)
            return
        }
        let vMethod : String = call.method.trim()
        let vGroupName : String = (vData["group_name"] as? String ?? "").trim()
        let membersJids : [String] = vData["members_jid"] as? [String] ?? []
        printLog("\(#function) | \(vMethod) | arguments: \(vData) | vGroupName: \(vGroupName) | membersJids : \(membersJids)")
        
        APP_DELEGATE.objXMPP.addRemoveMemberInRoom(withUserRole: type,
                                                   actionType: actionType,
                                                   withRoomName: vGroupName,
                                                   withUsers: membersJids,
                                                   withStrem: self.objXMPP.xmppStream)
        
        result(xmppConstants.SUCCESS)
    }
    
    func performGetMembersInGroupActivity(withMemeberType type : xmppMUCUserType,
                                        _ call: FlutterMethodCall,
                                        _ result: @escaping FlutterResult) {
        guard let vData = call.arguments as? [String : Any] else {
            result(xmppConstants.ERROR)
            return
        }
        let vMethod : String = call.method.trim()
        let vGroupName : String = (vData["group_name"] as? String ?? "").trim()
        printLog("\(#function) | \(vMethod) | arguments: \(vData) | vGroupName: \(vGroupName)")
        
        APP_DELEGATE.singalCallBack = result
        APP_DELEGATE.objXMPP.getRoomMember(withUserType: type,
                                           forRoomName: vGroupName,
                                           withStrem: self.objXMPP.xmppStream,
                                           objXMPP: self.objXMPP)
    }
    
    func performLastActivity(_ call: FlutterMethodCall, _ result: @escaping FlutterResult)  {
        guard let vData = call.arguments as? [String : Any] else {
            result(xmppConstants.DataNil);
            return
        }
        let vMethod : String = call.method.trim()
        printLog("\(#function) | \(vMethod) | arguments: \(vData)")
        
        var vUserId : String = (vData["user_jid"] as? String ?? "").trim()
        vUserId = (vUserId.components(separatedBy: "@").first ?? "").trim()
        
        if vUserId.isEmpty {
            result(xmppConstants.DataNil)
            return
        }
        APP_DELEGATE.singalCallBack = result
        APP_DELEGATE.objXMPP.getLastActivity(withUserJid: vUserId,
                                             withStrem: self.objXMPP.xmppStream,
                                             objXMPP: self.objXMPP)
        printLog("\(#function) | \(vMethod) | vUserId: \(vUserId)")
        //result(xmppConstants.SUCCESS)
    }
    
    func createRostersActivity(_ call: FlutterMethodCall, _ result: @escaping FlutterResult)  {
        guard let vData = call.arguments as? [String : Any] else {
            result(xmppConstants.DataNil);
            return
        }
        let vMethod : String = call.method.trim()
        printLog("\(#function) | \(vMethod) | arguments: \(vData)")
        
        var vUserId : String = (vData["user_jid"] as? String ?? "").trim()
        vUserId = (vUserId.components(separatedBy: "@").first ?? "").trim()
        
        if vUserId.isEmpty {
            result(xmppConstants.DataNil)
            return
        }
        APP_DELEGATE.objXMPP.createRosters(withUserJid: vUserId, withStrem: self.objXMPP.xmppStream, objXMPP: self.objXMPP)
        //result(xmppConstants.SUCCESS)
    }

    func dropRostersActivity(_ call: FlutterMethodCall, _ result: @escaping FlutterResult)  {
        guard let vData = call.arguments as? [String : Any] else {
            result(xmppConstants.DataNil);
            return
        }
        let vMethod : String = call.method.trim()
        printLog("\(#function) | \(vMethod) | arguments: \(vData)")

        var vUserId : String = (vData["user_jid"] as? String ?? "").trim()
        vUserId = (vUserId.components(separatedBy: "@").first ?? "").trim()

        if vUserId.isEmpty {
            result(xmppConstants.DataNil)
            return
        }
        APP_DELEGATE.objXMPP.dropRosters(withUserJid: vUserId, withStrem: self.objXMPP.xmppStream, objXMPP: self.objXMPP)
        //result(xmppConstants.SUCCESS)
    }

    func getMyRostersActivity(_ call: FlutterMethodCall, _ result: @escaping FlutterResult)  {
        var vData : [String : Any]?
        if let data = call.arguments as? [String : Any] { vData = data }
        
        let vMethod : String = call.method.trim()
        printLog("\(#function) | \(vMethod) | arguments: \(String(describing: vData))")
        APP_DELEGATE.singalCallBack = result
        APP_DELEGATE.objXMPP.getMyRosters(withStrem: self.objXMPP.xmppStream, objXMPP: self.objXMPP)
        //result(xmppConstants.SUCCESS)
    }

    func getVCardActivity(_ call: FlutterMethodCall, _ result: @escaping FlutterResult)  {
        var vData : [String : Any]?
        if let data = call.arguments as? [String : Any] { vData = data }

        let vMethod : String = call.method.trim()
        printLog("\(#function) | \(vMethod) | arguments: \(String(describing: vData))")

        var vUserId : String = (vData!["user_jid"] as? String ?? "").trim()
        vUserId = (vUserId.components(separatedBy: "@").first ?? "").trim()

        if vUserId.isEmpty {
            result(xmppConstants.DataNil)
            return
        }

        APP_DELEGATE.singalCallBack = result
        APP_DELEGATE.objXMPP.getVCard(withUserJid: vUserId, withStrem: self.objXMPP.xmppStream, objXMPP: self.objXMPP)
        //result(xmppConstants.SUCCESS)
    }

    func saveVCardActivity(_ call: FlutterMethodCall, _ result: @escaping FlutterResult)  {
        var vData : [String : Any]?
        if let data = call.arguments as? [String : Any] { vData = data }

        let vMethod : String = call.method.trim()
        printLog("\(#function) | \(vMethod) | arguments: \(String(describing: vData))")

        let desc : String = (vData!["DESC"] as? String ?? "").trim()

        APP_DELEGATE.objXMPP.saveVCard(withDesc: desc, withStrem: self.objXMPP.xmppStream, objXMPP: self.objXMPP)
        result(xmppConstants.SUCCESS)
    }
    
    func manageMAMActivity(_ call: FlutterMethodCall, _ result: @escaping FlutterResult)  {
        //var vData : [String : Any]?
        //if let data = call.arguments as? [String : Any] { vData = data }
        guard let vData = call.arguments as? [String : Any] else {
            result(xmppConstants.DataNil);
            return
        }
        var vJid : String = ""
        var vTSBefore : Int64 = 0
        var vTSSince : Int64 = 0
        var vLimit : Int = 0
        var lastFlag : Bool = false

        if let value = vData["userJid"] as? String { vJid = value }
        if let value = vData["requestBefore"] as? String {
            vTSBefore = Int64(value) ?? vTSBefore
        }
        if let value = vData["requestSince"] as? String {
            vTSSince = Int64(value) ?? vTSSince
        }
        if let value = vData["limit"] as? String {
            vLimit = Int(value) ?? vLimit
        }
        if let value = vData["lastFlag"] as? Bool {
            lastFlag = value
        }
        printLog([vJid, vTSBefore, vTSSince, vLimit])
        APP_DELEGATE.objXMPP.getMAMMessage(withDMChatJid: vJid,
                                           tsBefore: vTSBefore,
                                           tsSince: vTSSince,
                                           limit: vLimit,
                                           withStrem: self.objXMPP.xmppStream,
                                           objXMPP: self.objXMPP,
                                           lastFlag: lastFlag)
    }
    
    func getPresenceActivity(_ call: FlutterMethodCall, _ result: @escaping FlutterResult)  {
        guard let vData = call.arguments as? [String : Any] else {
            result(xmppConstants.DataNil);
            return
        }
        let vMethod : String = call.method.trim()
        printLog("\(#function) | \(vMethod) | arguments: \(String(describing: vData))")
          /*
        var vUserId : String = ""
        if let value = vData["user_jid"] as? String { vUserId = value }
        if vUserId.isEmpty {
            result(xmppConstants.DataNil)
            return
        }
        
        APP_DELEGATE.singalCallBack = result
        APP_DELEGATE.objXMPP.getPresenceOfUser(withJid: vUserId,
                                               withStrem: self.objXMPP.xmppStream,
                                               objXMPP: self.objXMPP)
        return
        
        APP_DELEGATE.singalCallBack = result
        APP_DELEGATE.objXMPP.getMyRosters(withStrem: self.objXMPP.xmppStream, objXMPP: self.objXMPP)
        //result(xmppConstants.SUCCESS)
        */
    }
    
    func changeTypingStatus(_ call: FlutterMethodCall, _ result: @escaping FlutterResult)  {
        guard let vData = call.arguments as? [String : Any] else {
            result(xmppConstants.DataNil);
            return
        }
        let vMethod : String = call.method.trim()
        printLog("\(#function) | \(vMethod) | arguments: \(String(describing: vData))")
                
        var vUserId : String = ""
        var vTypingStatus : String = ""
        if let value = vData["userJid"] as? String { vUserId = value }
        if let value = vData["typingStatus"] as? String { vTypingStatus = value }
        
        if vUserId.isEmpty {
            result(xmppConstants.DataNil)
            return
        }
        APP_DELEGATE.objXMPP.sendTypingStatus(withJid: vUserId, status: vTypingStatus, withStrem: self.objXMPP.xmppStream)
        result(xmppConstants.SUCCESS)
    }
    
    func changePresence (_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        printLog("\(#function) | changepresence")

        guard let vData = call.arguments as? [String : Any] else {
            result(xmppConstants.DataNil);
            return
        }
        let vMethod : String = call.method.trim()
        printLog("\(#function) | \(vMethod) | arguments: \(String(describing: vData))")
        
        var vPresenceType : String = "available"
        var vPresenceMode : String = "available"
        
        if let value = vData["presenceType"] as? String { vPresenceType = value }
        if let value = vData["presenceMode"] as? String { vPresenceMode = value }
        
        APP_DELEGATE.objXMPP.changePresenceWithMode( withMode: vPresenceMode, withType : vPresenceType , withXMPPStrem: self.objXMPP.xmppStream)
       
        result(xmppConstants.SUCCESS)
    }
    
    func getConnectionStatus (_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
       
        var valueStatus : String = ""
        
        if objXMPP.isAuthenticated() {
            valueStatus = "authenticated"
        } else if objXMPP.isConnected() {
            valueStatus = "connected"
        }
        
        if valueStatus.isEmpty {
           
            print("\(#function) | XMPPConnetion status nil/empty.")
            switch objXMPPConnStatus {
            case .Processing:
                valueStatus = "connecting"
                break
            case .Failed:
                valueStatus = "failed"
                break
            case .Disconnect,
                 .None:
                valueStatus = "disconnected"
                break
            default:
                valueStatus = "disconnected"
                break
            }
        }
    
        printLog("\(#function) connection status \(valueStatus) ")
        result(valueStatus)
        
    }
    
    //MARK: - perform XMPP Connection
    func performXMPPConnectionActivity() {
        switch APP_DELEGATE.objXMPPConnStatus {
        case .None,
             .Failed:
            APP_DELEGATE.objXMPPConnStatus = .Processing
            do {
                try self.objXMPP = XMPPController.init(hostName: xmpp_HostName,
                                                       hostPort: xmpp_HostPort,
                                                       userId: xmpp_UserId,
                                                       password: xmpp_UserPass,
                                                       resource: xmpp_Resource)
                self.objXMPP.xmppStream.addDelegate(self, delegateQueue: DispatchQueue.main)
                self.objXMPP.connect()
            } catch let err {
                print("\(#function) | Getting error on XMPP Connect | error : \(err.localizedDescription)")
            }
            
        case .Processing:
            break
            
        case .Disconnect:
            APP_DELEGATE.objXMPPConnStatus = .None
            
        default:
            break
        }
    }

    func getPrivateStorageActivity(_ call: FlutterMethodCall, _ result: @escaping FlutterResult)  {
        guard let vData = call.arguments as? [String : Any] else {
            result(xmppConstants.DataNil);
            return
        }
        var storageCategory : String = ""
        var storageName : String = ""

        if let value = vData["category"] as? String { storageCategory = value }
        if let value = vData["name"] as? String { storageName = value }

        let vMethod : String = call.method.trim()
        printLog("\(#function) | \(vMethod) | arguments: \(String(describing: vData))")
        APP_DELEGATE.singalCallBack = result
        APP_DELEGATE.objXMPP.getPrivateStorage(withCategory: storageCategory,
                                               withName: storageName,
                                               withStrem: self.objXMPP.xmppStream,
                                               objXMPP: self.objXMPP)
        //result(xmppConstants.SUCCESS)
    }

    func setPrivateStorageActivity(_ call: FlutterMethodCall, _ result: @escaping FlutterResult)  {
        guard let vData = call.arguments as? [String : Any] else {
            result(xmppConstants.DataNil);
            return
        }
        var storageCategory: String = ""
        var storageName: String = ""
        var dictValue: [String: String] = [:]

        if let value = vData["category"] as? String { storageCategory = value }
        if let value = vData["name"] as? String { storageName = value }
        if let value = vData["dict"] as? [String: String] { dictValue = value }
        printLog("\(#function) | \(dictValue)")

        let vMethod : String = call.method.trim()
        printLog("\(#function) | \(vMethod) | arguments: \(String(describing: vData))")
        APP_DELEGATE.objXMPP.setPrivateStorage(withCategory: storageCategory,
                                               withName: storageName,
                                               withDict: dictValue,
                                               withStrem: self.objXMPP.xmppStream,
                                               objXMPP: self.objXMPP)
        result(xmppConstants.SUCCESS)
    }
    
    public func manange_NotifcationObservers()  {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(notiObs_XMPPConnectionStatus(notfication:)), name: .xmpp_ConnectionStatus, object: nil)
    }
    
    @objc func notiObs_XMPPConnectionStatus(notfication: NSNotification) {
        var valueStatus : String = ""
        print("\(#function) | XMPPConnetion status \(objXMPPConnStatus)")
        switch objXMPPConnStatus {
        case .Processing:
            //valueStatus = xmppConnStatus.Processing
            break
            
        case .Connected:
            valueStatus = xmppConnStatus.Connected
            
        case .Sucess:
            valueStatus = xmppConnStatus.Authenticated
            
        case .Failed:
            valueStatus = xmppConnStatus.Failed
                        
        case .Disconnect,
             .None:
            valueStatus = xmppConnStatus.Disconnect
        }
        if valueStatus.isEmpty {
            print("\(#function) | XMPPConnetion status nil/empty.")
            return
        }
        
        var dicDate : [String : Any] = [:]
        dicDate["type"] = valueStatus
        dicDate["error"] = ""
        
        /// Send data back to flutter event handler.
        guard let objConnectionEventData = APP_DELEGATE.objConnectionEventData else {
            printLog("\(#function) | Nil/Empty of APP_DELEGATE.objEventData | \(dicDate)")
            return
        }
        objConnectionEventData(dicDate)
    }
    
    //MARK: - MUC Validation
    func isValidMUCInfo(withRoomName vRoom : String) -> Bool {
        if vRoom.trim().isEmpty {
            printLog("\(#function) | MUCRoomName is empty.")
            return false
        }
        
        if vRoom.containsWhitespace {
            printLog("\(#function) | MUCRoomName is invalid | Its contail whitespapce | MUCRoomName: \(vRoom)")
            return false
        }
        printLog("returning true ")
        return true
    }
    
    func isValidMUCInfo(withRoomName vRoom : String, timeStamp : Int64) -> Bool {
        if !self.isValidMUCInfo(withRoomName: vRoom) {
            return false
        }
        
        let vCurretTimeStamp = getTimeStamp()
        if timeStamp > vCurretTimeStamp {
            printLog("\(#function) | Timestamp is invalid | timeStamp is more then curretTimeStamp | curretTimestamp: \(vCurretTimeStamp) | timeStamp: \(timeStamp)")
            return false
        }
        return true
    }
    
    func updateMUCJoinStatus(withRoomname Roomname:  String, status : Bool,error : String) {
        print(" Roomname \(Roomname) status \(status)")
        
        var dicDate : [String : Any] = [:]
        dicDate["from"] = Roomname
        
        if(status){
            dicDate["type"] = "group_joined_success"
            
            /// Send data back to flutter event handler.
            guard let objSuccessEventData = APP_DELEGATE.objSuccessEventData else {
                printLog("\(#function) | Nil/Empty of APP_DELEGATE.objEventData | \(dicDate)")
                return
            }
            objSuccessEventData(dicDate)
            
        } else {
            dicDate["type"] = "group_joined_success"
            dicDate["exception"] = error
            
            /// Send data back to flutter event handler.
            guard let objErrorEventData = APP_DELEGATE.objErrorEventData else {
                printLog("\(#function) | Nil/Empty of APP_DELEGATE.objEventData | \(dicDate)")
                return
            }
            objErrorEventData(dicDate)
            
        }
   
    }
    
    func updateMUCCreateStatus(withRoomname Roomname:  String, status : Bool,error : String) {
        print(" Roomname \(Roomname) status \(status)")
        
        var dicDate : [String : Any] = [:]
        dicDate["from"] = Roomname

            dicDate["type"] = "group_creation_failed"
            dicDate["exception"] = error
            
            /// Send data back to flutter event handler.
            guard let objErrorEventData = APP_DELEGATE.objErrorEventData else {
                printLog("\(#function) | Nil/Empty of APP_DELEGATE.objEventData | \(dicDate)")
                return
            }
            objErrorEventData(dicDate)
               
    }
}

class SwiftStreamHandler: NSObject, FlutterStreamHandler {
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        APP_DELEGATE.objEventData = events
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        return nil
    }
}

class ConnectionStreamHandler: NSObject, FlutterStreamHandler {
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        APP_DELEGATE.objConnectionEventData = events
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        return nil
    }
}

class SuccessStreamHandler: NSObject, FlutterStreamHandler {
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        APP_DELEGATE.objSuccessEventData = events
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        return nil
    }
}

class ErrorStreamHandler: NSObject, FlutterStreamHandler {
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        APP_DELEGATE.objErrorEventData = events
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        return nil
    }
}
