package org.xrstudio.xmpp.flutter_xmpp.Connection;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Build;

import org.jivesoftware.smack.ConnectionConfiguration;
import org.jivesoftware.smack.ConnectionListener;
import org.jivesoftware.smack.ReconnectionManager;
import org.jivesoftware.smack.SmackException;
import org.jivesoftware.smack.XMPPConnection;
import org.jivesoftware.smack.XMPPException;
import org.jivesoftware.smack.filter.StanzaTypeFilter;
import org.jivesoftware.smack.packet.Message;
import org.jivesoftware.smack.packet.Presence;
import org.jivesoftware.smack.packet.StandardExtensionElement;
import org.jivesoftware.smack.roster.Roster;
import org.jivesoftware.smack.roster.RosterEntry;
import org.jivesoftware.smack.tcp.XMPPTCPConnection;
import org.jivesoftware.smack.tcp.XMPPTCPConnectionConfiguration;
import org.jivesoftware.smack.util.TLSUtils;
import org.jivesoftware.smack.util.PacketParserUtils;

import org.jivesoftware.smackx.chatstates.ChatState;
import org.jivesoftware.smackx.chatstates.packet.ChatStateExtension;
import org.jivesoftware.smackx.iqlast.LastActivityManager;
import org.jivesoftware.smackx.iqlast.packet.LastActivity;
import org.jivesoftware.smackx.iqprivate.PrivateDataManager;
import org.jivesoftware.smackx.iqprivate.packet.DefaultPrivateData;
import org.jivesoftware.smackx.httpfileupload.HttpFileUploadManager;
import org.jivesoftware.smackx.httpfileupload.element.Slot;
import org.jivesoftware.smackx.muc.Affiliate;
import org.jivesoftware.smackx.muc.MucEnterConfiguration;
import org.jivesoftware.smackx.muc.MultiUserChat;
import org.jivesoftware.smackx.muc.MultiUserChatManager;
import org.jivesoftware.smackx.receipts.DeliveryReceipt;
import org.jivesoftware.smackx.receipts.DeliveryReceiptRequest;
import org.jivesoftware.smackx.search.ReportedData;
import org.jivesoftware.smackx.search.UserSearchManager;
import org.jivesoftware.smackx.search.UserSearch;
import org.jivesoftware.smackx.vcardtemp.packet.VCard;
import org.jivesoftware.smackx.vcardtemp.VCardManager;
import org.jivesoftware.smackx.xdata.Form;
import org.jivesoftware.smackx.xdata.FormField;

import org.jxmpp.jid.DomainBareJid;
import org.jxmpp.jid.EntityBareJid;
import org.jxmpp.jid.Jid;
import org.jxmpp.jid.impl.JidCreate;
import org.jxmpp.jid.parts.Resourcepart;
import org.xrstudio.xmpp.flutter_xmpp.Enum.ConnectionState;
import org.xrstudio.xmpp.flutter_xmpp.Enum.ErrorState;
import org.xrstudio.xmpp.flutter_xmpp.Enum.GroupRole;
import org.xrstudio.xmpp.flutter_xmpp.Utils.Constants;
import org.xrstudio.xmpp.flutter_xmpp.Utils.Utils;
import org.xrstudio.xmpp.flutter_xmpp.listner.MessageListener;
import org.xrstudio.xmpp.flutter_xmpp.listner.PresenceListenerAndFilter;
import org.xrstudio.xmpp.flutter_xmpp.listner.StanzaAckListener;


import java.io.IOException;
import java.net.InetAddress;
import java.net.URL;
import java.security.KeyManagementException;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.net.ssl.SSLContext;
import javax.net.ssl.TrustManager;

public class FlutterXmppConnection implements ConnectionListener {

    public static String mHost;
    public static String mUsername = "";
    private static String mPassword;
    private static String mResource = "";
    private static Roster rosterConnection;
    private static String mServiceName = "";
    private static XMPPTCPConnection mConnection;
    private static MultiUserChatManager multiUserChatManager;
    private static PrivateDataManager privateDataManager;
    private static boolean mRequireSSLConnection, mAutoDeliveryReceipt, mAutomaticReconnection = true, mUseStreamManagement = true;
    private static Context mApplicationContext;
    private BroadcastReceiver uiThreadMessageReceiver;//Receives messages from the ui thread.

    public FlutterXmppConnection(Context context, String jid_user, String password, String host, Integer port, boolean requireSSLConnection,
                                 boolean autoDeliveryReceipt, boolean useStreamManagement, boolean automaticReconnection) {

        Utils.printLog(" Connection Constructor called: ");

        mApplicationContext = context.getApplicationContext();
        mPassword = password;
        Constants.PORT_NUMBER = port;
        mHost = host;
        mRequireSSLConnection = requireSSLConnection;
        mAutoDeliveryReceipt = autoDeliveryReceipt;
        mUseStreamManagement = useStreamManagement;
        mAutomaticReconnection = automaticReconnection;
        if (jid_user != null && jid_user.contains(Constants.SYMBOL_COMPARE_JID)) {
            String[] jid_list = jid_user.split(Constants.SYMBOL_COMPARE_JID);
            mUsername = jid_list[0];
            if (jid_list[1].contains(Constants.SYMBOL_FORWARD_SLASH)) {
                String[] domain_resource = jid_list[1].split(Constants.SYMBOL_FORWARD_SLASH);
                mServiceName = domain_resource[0];
                mResource = domain_resource[1];
            } else {
                mServiceName = jid_list[1];
                mResource = Constants.ANDROID;
            }
        }
    }

    public static Context getApplicationContext() {
        return mApplicationContext;
    }

    public static XMPPTCPConnection getConnection() {
        return mConnection == null ? new XMPPTCPConnection(null) : mConnection;
    }

    public static String requestSlot(String filename, Integer filesize) {
        HttpFileUploadManager manager = HttpFileUploadManager.getInstanceFor(mConnection);
        try {
            Slot slot = manager.requestSlot(filename, filesize);
            URL url = slot.getPutUrl();
            Utils.printLog("requestSlot received url: " + url);
            return url.toString();
        } catch (InterruptedException e) {
            e.printStackTrace();
        } catch (XMPPException.XMPPErrorException e) {
            e.printStackTrace();
        } catch (SmackException e) {
            e.printStackTrace();
        }
        return "";
    }

    public static List<String> searchUsers(String username) {
        // https://github.com/igniterealtime/jxmpp/blob/master/jxmpp-jid/src/main/java/org/jxmpp/jid/impl/JidCreate.java
        List<String> searchUsersResult = new ArrayList();
        try {
            String searchDomain = mUsername + "@" + "vjud." + mHost;
            UserSearchManager searchManager = new UserSearchManager(mConnection);
            DomainBareJid domainBareJid =  JidCreate.domainBareFrom(searchDomain);
            Form searchForm = searchManager.getSearchForm(domainBareJid);
            List<FormField> fields = searchForm.getFields();
            /*
            for (FormField field : fields) {
                Utils.printLog("_____field::" + field.getVariable());
            }
            */
            Form answerForm = searchForm.createAnswerForm();
            answerForm.setAnswer("user", username);
            UserSearch userSearch = new UserSearch();
            ReportedData sdata = userSearch.sendSearchForm(mConnection, answerForm, domainBareJid);

            List<ReportedData.Row> rows = sdata.getRows();
            for (ReportedData.Row row : rows) {
                searchUsersResult.add(row.getValues("jid").toString());
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return searchUsersResult;
    }

    public static void sendCustomMessage(String body, String toJid, String msgId, String customText, boolean isDm, String time) {

        try {

            Message xmppMessage = new Message();
            xmppMessage.setStanzaId(msgId);

            xmppMessage.setBody(body);
            xmppMessage.setType(isDm ? Message.Type.chat : Message.Type.groupchat);

            if (mAutoDeliveryReceipt) {
                DeliveryReceiptRequest.addTo(xmppMessage);
            }

            StandardExtensionElement timeElement = StandardExtensionElement.builder(Constants.TIME, Constants.URN_XMPP_TIME)
                    .addElement(Constants.TS, time).build();
            xmppMessage.addExtension(timeElement);

            StandardExtensionElement element = StandardExtensionElement.builder(Constants.CUSTOM, Constants.URN_XMPP_CUSTOM)
                    .addElement(Constants.custom, customText).build();
            xmppMessage.addExtension(element);

            if (isDm) {
                xmppMessage.setTo(JidCreate.from(toJid));
                mConnection.sendStanza(xmppMessage);
            } else {
                EntityBareJid jid = JidCreate.entityBareFrom(toJid);
                xmppMessage.setTo(jid);
                EntityBareJid mucJid = (EntityBareJid) JidCreate.bareFrom(Utils.getRoomIdWithDomainName(toJid, mHost));
                MultiUserChat muc = multiUserChatManager.getMultiUserChat(mucJid);
                muc.sendMessage(xmppMessage);
            }

            Utils.addLogInStorage("Action: sentCustomMessageToServer, Content: " + xmppMessage.toXML(null).toString());

            Utils.printLog("Sent custom message from: " + xmppMessage.toXML(null) + "  sent.");

        } catch (SmackException.NotConnectedException e) {
            e.printStackTrace();
        } catch (InterruptedException e) {
            e.printStackTrace();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static void send_delivery_receipt(String toJid, String msgId, String receiptId) {

        try {

            if (!toJid.contains(mHost)) {
                toJid = toJid + Constants.SYMBOL_COMPARE_JID + mHost;
            }

            Message deliveryMessage = new Message();
            deliveryMessage.setStanzaId(receiptId);
            deliveryMessage.setTo(JidCreate.from(toJid));

            DeliveryReceipt deliveryReceipt = new DeliveryReceipt(msgId);
            deliveryMessage.addExtension(deliveryReceipt);

            mConnection.sendStanza(deliveryMessage);

            Utils.addLogInStorage("Action: sentDeliveryReceiptToServer, Content: " + deliveryMessage.toXML(null).toString());

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static void manageAddMembersInGroup(GroupRole groupRole, String groupName, ArrayList<String> membersJid) {

        try {

            List<Jid> jidList = new ArrayList<>();
            MultiUserChat muc = multiUserChatManager.getMultiUserChat((EntityBareJid) JidCreate.from(Utils.getRoomIdWithDomainName(groupName, mHost)));

            for (String memberJid : membersJid) {
                if (!memberJid.contains(mHost)) {
                    memberJid = memberJid + Constants.SYMBOL_COMPARE_JID + mHost;
                }
                Jid jid = JidCreate.from(memberJid);
                jidList.add(jid);

            }

            if (groupRole == GroupRole.ADMIN) {
                muc.grantAdmin(jidList);
            } else if (groupRole == GroupRole.MEMBER) {
                muc.grantMembership(jidList);
            }

            for (Jid jid : jidList) {
                muc.invite(jid.asEntityBareJidIfPossible(), Constants.INVITE_MESSAGE);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static void manageRemoveFromGroup(GroupRole groupRole, String groupName, ArrayList<String> membersJid) {

        try {

            List<Jid> jidList = new ArrayList<>();
            for (String memberJid : membersJid) {
                if (!memberJid.contains(mHost)) {
                    memberJid = memberJid + Constants.SYMBOL_COMPARE_JID + mHost;
                }
                Jid jid = JidCreate.from(memberJid);
                jidList.add(jid);
            }

            MultiUserChat muc = multiUserChatManager.getMultiUserChat((EntityBareJid) JidCreate.from(Utils.getRoomIdWithDomainName(groupName, mHost)));
            if (groupRole == GroupRole.ADMIN) {

                for (Jid jid : jidList) {
                    muc.revokeAdmin(jid.asEntityJidOrThrow());
                }

            } else if (groupRole == GroupRole.MEMBER) {
                muc.revokeMembership(jidList);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static List<String> getMembersOrAdminsOrOwners(GroupRole groupRole, String groupName) {
        List<String> jidList = new ArrayList<>();

        try {
            List<Affiliate> affiliates;

            MultiUserChat muc = multiUserChatManager.getMultiUserChat((EntityBareJid) JidCreate.from(Utils.getRoomIdWithDomainName(groupName, mHost)));
            if (groupRole == GroupRole.ADMIN) {
                affiliates = muc.getAdmins();
            } else if (groupRole == GroupRole.MEMBER) {
                affiliates = muc.getMembers();
            } else if (groupRole == GroupRole.OWNER) {
                affiliates = muc.getOwners();
            } else {
                affiliates = new ArrayList<>();
            }
            if (affiliates.size() > 0) {
                for (Affiliate affiliate : affiliates) {
                    String jid = affiliate.getJid().toString();
                    jidList.add(jid);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return jidList;
    }

    public static int getOnlineMemberCount(String groupName) {
        try {

            MultiUserChat muc = multiUserChatManager.getMultiUserChat((EntityBareJid) JidCreate.from(Utils.getRoomIdWithDomainName(groupName, mHost)));
            return muc.getOccupants().size();

        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public static long getLastSeen(String userJid) {
        long userLastActivity = Constants.RESULT_DEFAULT;
        try {
            LastActivityManager lastActivityManager = LastActivityManager.getInstanceFor(mConnection);
            LastActivity lastActivity = lastActivityManager.getLastActivity(JidCreate.from(Utils.getJidWithDomainName(userJid, mHost)));
            userLastActivity = lastActivity.lastActivity;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return userLastActivity;
    }

    public static Map<String, Object> getVCard(String userJid) {
        /* https://xmpp.org/extensions/xep-0054.html
           <FN>Peter Saint-Andre</FN>
           <NICKNAME>stpeter</NICKNAME>
           <URL>http://www.xmpp.org/xsf/people/stpeter.shtml</URL>
           <BDAY>1966-08-06</BDAY>
           <TITLE>Executive Director</TITLE>
           <ROLE>Patron Saint</ROLE>
           <TEL><WORK/><VOICE/><NUMBER>303-308-3282</NUMBER></TEL>
           <TEL><HOME/><MSG/><NUMBER/></TEL>
           <JABBERID>stpeter@jabber.org</JABBERID>
           <DESC>More information about me is located on my personal website: http://www.saint-andre.com/</DESC>
           https://docs.ejabberd.im/developer/ejabberd-api/admin-api/#get-vcard
        */
        Map<String, Object> result = new HashMap<>();
        Utils.printLog("Receiving VCard for " + userJid);
        VCard vCard = new VCard();
        try {
            //EntityBareJid jid = JidCreate.entityBareFrom(mUsername + "@" + mHost);
            EntityBareJid jid = JidCreate.entityBareFrom(userJid);
            VCardManager vCardManager = VCardManager.getInstanceFor(mConnection);
            vCard = vCardManager.loadVCard(jid);
            result.put("FN", vCard.getField("FN"));
            result.put("NICKNAME", vCard.getField("NICKNAME"));
            result.put("URL", vCard.getField("URL"));
            result.put("BDAY", vCard.getField("BDAY"));
            result.put("DESC", vCard.getField("DESC"));
        } catch (SmackException.NotConnectedException e) {
            e.printStackTrace();
        } catch (InterruptedException e) {
            e.printStackTrace();
        } catch (Exception e) {
            e.printStackTrace();
        }
        //byte[] bs = vCard.getAvatar(); // Avtar in byte array convert it to Bitmap
        return result;
    }

    public static void saveVCard(String desc) {
        /* https://xmpp.org/extensions/xep-0054.html
        */
        Utils.printLog("Save VCard");
        VCard vCard = new VCard();
        try {
            EntityBareJid jid = JidCreate.entityBareFrom(mUsername + "@" + mHost);
            VCardManager vCardManager = VCardManager.getInstanceFor(mConnection);
            vCard = vCardManager.loadVCard(jid);
            vCard.setField("DESC", desc);
            vCardManager.saveVCard(vCard);
        } catch (SmackException.NotConnectedException e) {
            e.printStackTrace();
        } catch (InterruptedException e) {
            e.printStackTrace();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static List<String> getMyRosters() {
        List<String> muRosterList = new ArrayList<>();
        try {
            Set<RosterEntry> allRoster = rosterConnection.getEntries();
            for (RosterEntry rosterEntry : allRoster) {
                muRosterList.add(rosterEntry.toString());
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return muRosterList;
    }

    public static void createRosterEntry(String userJid) {
        try {
            rosterConnection.createEntry(JidCreate.bareFrom(Utils.getJidWithDomainName(userJid, mHost)), userJid, null);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static void dropRosterEntry(String userJid) {
        try {
            //rosterConnection.removeEntry(JidCreate.bareFrom(Utils.getJidWithDomainName(userJid, mHost)));
            RosterEntry entry = rosterConnection.getEntry(JidCreate.bareFrom(Utils.getJidWithDomainName(userJid, mHost)));
            rosterConnection.removeEntry(entry);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static List<String> getMyMUCs() {
        List<String> roomList = new ArrayList<>();
        Set<EntityBareJid> joinedRooms = multiUserChatManager.getJoinedRooms();
        for (EntityBareJid room : joinedRooms) {
            roomList.add(room.toString());
        }
        return roomList;
    }

    public static boolean createMUC(String groupName, String persistent) {
        boolean isGroupCreatedSuccessfully = false;
        try {
            MultiUserChat multiUserChat = multiUserChatManager.getMultiUserChat((EntityBareJid) JidCreate.from(Utils.getRoomIdWithDomainName(groupName, mHost)));
            multiUserChat.create(Resourcepart.from(mUsername));
            if (persistent.equals(Constants.TRUE)) {
                Form form = multiUserChat.getConfigurationForm();
                Form answerForm = form.createAnswerForm();
                answerForm.setAnswer(Constants.MUC_PERSISTENT_ROOM, true);
                answerForm.setAnswer(Constants.MUC_MEMBER_ONLY, false);
                multiUserChat.sendConfigurationForm(answerForm);
            }
            isGroupCreatedSuccessfully = true;
        } catch (Exception e) {
            e.printStackTrace();
            String groupCreateError = e.getLocalizedMessage();
            Utils.printLog("createMUC : exception: " + groupCreateError);
            Utils.broadcastErrorMessageToFlutter(mApplicationContext, ErrorState.GROUP_CREATION_FAILED, groupCreateError, groupName);
        }
        return isGroupCreatedSuccessfully;
    }

    public static String joinAllGroups(ArrayList<String> allGroupsIds) {
        String response = "FAIL";
        for (String groupId : allGroupsIds) {
            try {

                String groupName = groupId;
                String lastMsgTime = "0";

                if (groupName.contains(",")) {
                    String[] groupData = groupName.split(",");
                    groupName = groupData[0];
                    lastMsgTime = groupData[1];
                }

                MultiUserChat multiUserChat = multiUserChatManager.getMultiUserChat((EntityBareJid) JidCreate.from(Utils.getRoomIdWithDomainName(groupName, mHost)));
                Resourcepart resourcepart = Resourcepart.from(mUsername);

                long currentTime = new Date().getTime();
                long lastMessageTime = Long.valueOf(lastMsgTime);
                long diff = currentTime - lastMessageTime;

                MucEnterConfiguration mucEnterConfiguration = multiUserChat.getEnterConfigurationBuilder(resourcepart)
                        .requestHistorySince((int) diff)
                        .build();

                if (!multiUserChat.isJoined()) {
                    multiUserChat.join(mucEnterConfiguration);
                }
            } catch (Exception e) {
                e.printStackTrace();
                String allGroupJoinError = e.getLocalizedMessage();
                Utils.printLog(" joinAllGroup : exception: " + allGroupJoinError);
                Utils.broadcastErrorMessageToFlutter(mApplicationContext, ErrorState.GROUP_JOINED_FAILED, allGroupJoinError, groupId);
            }

        }
        response = Constants.SUCCESS;
        return response;
    }

    public static boolean joinGroupWithResponse(String groupId) {

        boolean isJoinedSuccessfully = false;
        try {

            String groupName = groupId;
            String lastMsgTime = "0";

            if (groupName.contains(",")) {
                String[] groupData = groupName.split(",");
                groupName = groupData[0];
                lastMsgTime = groupData[1];
            }

            MultiUserChat multiUserChat = multiUserChatManager.getMultiUserChat((EntityBareJid) JidCreate.from(Utils.getRoomIdWithDomainName(groupName, mHost)));
            Resourcepart resourcepart = Resourcepart.from(mUsername);

            long currentTime = new Date().getTime();
            long lastMessageTime = Long.valueOf(lastMsgTime);
            long diff = currentTime - lastMessageTime;

            MucEnterConfiguration mucEnterConfiguration = multiUserChat.getEnterConfigurationBuilder(resourcepart)
                    .requestHistorySince((int) diff)
                    .build();

            if (!multiUserChat.isJoined()) {
                multiUserChat.join(mucEnterConfiguration);
            }

            isJoinedSuccessfully = true;
        } catch (Exception e) {
            String groupJoinError = e.getLocalizedMessage();
            Utils.printLog(" joinGroup : exception: " + groupJoinError);
            Utils.broadcastErrorMessageToFlutter(mApplicationContext, ErrorState.GROUP_JOINED_FAILED, groupJoinError, groupId);
            e.printStackTrace();
        }

        return isJoinedSuccessfully;
    }

    public static void updateChatState(String jid, String status) {

        try {

            Jid toJid = Utils.getFullJid(jid);

            Message message = new Message(toJid);
            ChatState chatState = ChatState.valueOf(status);
            message.addExtension(new ChatStateExtension(chatState));

            Utils.printLog("Sending Typing status " + message.toXML(null));
            mConnection.sendStanza(message);

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static void updatePresence(String presenceType, String presenceMode) {

        try {

            Presence presence = null;

            Presence.Type type = Presence.Type.valueOf(presenceType);
            Presence.Mode mode = Presence.Mode.valueOf(presenceMode);

            presence = new Presence(type);
            presence.setMode(mode);
            mConnection.sendStanza(presence);

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static Map<String, Map<String, String>> getPrivateStorage(String storageCategory, String storageName) {
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
        Map<String, Map<String, String>> privateStorage = new HashMap<String, Map<String, String>>();
        try {
            DefaultPrivateData data = (DefaultPrivateData) privateDataManager.getPrivateData(storageCategory, storageCategory + ":" + storageName);
            String namespace = data.getNamespace();
            privateStorage.put(namespace, new HashMap<String, String>());
            Set<String> names = data.getNames();
            for (String name: names) {
                privateStorage.get(namespace).put(name, data.getValue(name));
            }
        }
        catch (Exception e) {
            Utils.printLog("Error in getPrivateStorage " + e.toString());
        }
        return privateStorage;
    }

    public static void setPrivateStorage(String category, String name, Map<String, String> dict) {
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
        try {
            DefaultPrivateData data = new DefaultPrivateData(category, category + ":" + name);
            for (String dictKey: dict.keySet()) {
                data.setValue(dictKey, dict.get(dictKey));
            }
            privateDataManager.setPrivateData(data);
        }
        catch (Exception e) {
            Utils.printLog("Error in setPrivateStorage " + e.toString());
        }
    }

    public void connect() throws IOException, XMPPException, SmackException {
        FlutterXmppConnectionService.sConnectionState = ConnectionState.CONNECTING;
        XMPPTCPConnectionConfiguration.Builder conf = XMPPTCPConnectionConfiguration.builder();
        conf.setXmppDomain(mServiceName);

        // Check if the Host address is the ip then set up host and host address.
        if (Utils.validIP(mHost)) {

            Utils.printLog(" connecting via ip: " + Utils.validIP(mHost));
            InetAddress address = InetAddress.getByName(mHost);
            conf.setHostAddress(address);
            conf.setHost(mHost);
        } else {

            Utils.printLog(" connecting via host: " + mHost);
            conf.setHost(mHost);
        }

        if (Constants.PORT_NUMBER != 0) {
            conf.setPort(Constants.PORT_NUMBER);
        }

        conf.setUsernameAndPassword(mUsername, mPassword);
        conf.setResource(mResource);
        conf.setCompressionEnabled(true);
        conf.enableDefaultDebugger();


        if (mRequireSSLConnection) {
            SSLContext context = null;
            try {
                context = SSLContext.getInstance(Constants.TLS);
                context.init(null, new TrustManager[]{new TLSUtils.AcceptAllTrustManager()}, new SecureRandom());
            } catch (NoSuchAlgorithmException e) {
                e.printStackTrace();
            } catch (KeyManagementException e) {
                e.printStackTrace();
            }
            conf.setCustomSSLContext(context);

            conf.setKeystoreType(null);
            conf.setSecurityMode(ConnectionConfiguration.SecurityMode.required);
        }

        Utils.printLog(" connect 1 mServiceName: " + mServiceName + " mHost: " + mHost + " mPort: " + Constants.PORT + " mUsername: " + mUsername + " mPassword: " + mPassword + " mResource:" + mResource);

        //Set up the ui thread broadcast message receiver.
        try {

            mConnection = new XMPPTCPConnection(conf.build());
            mConnection.addConnectionListener(this);


            Utils.printLog(" Calling connect(): ");
            mConnection.connect();

            rosterConnection = Roster.getInstanceFor(mConnection);
            rosterConnection.setSubscriptionMode(Roster.SubscriptionMode.accept_all);

            if (mUseStreamManagement) {
                mConnection.setUseStreamManagement(true);
                mConnection.setUseStreamManagementResumption(true);
            }

            mConnection.login();

            setupUiThreadBroadCastMessageReceiver();

            mConnection.addSyncStanzaListener(new PresenceListenerAndFilter(mApplicationContext), StanzaTypeFilter.PRESENCE);

            mConnection.addStanzaAcknowledgedListener(new StanzaAckListener(mApplicationContext));

            mConnection.addSyncStanzaListener(new MessageListener(mApplicationContext), StanzaTypeFilter.MESSAGE);

            if (mAutomaticReconnection) {
                ReconnectionManager reconnectionManager = ReconnectionManager.getInstanceFor(mConnection);
                ReconnectionManager.setEnabledPerDefault(true);
                reconnectionManager.enableAutomaticReconnection();
            }


        } catch (InterruptedException e) {
            FlutterXmppConnectionService.sConnectionState = ConnectionState.FAILED;
            e.printStackTrace();
        }

    }

    private void setupUiThreadBroadCastMessageReceiver() {

        uiThreadMessageReceiver = new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {

                //Check if the Intents purpose is to send the message.
                String action = intent.getAction();
                Utils.printLog(" action: " + action);
                if (action.equals(Constants.X_SEND_MESSAGE)
                        || action.equals(Constants.GROUP_SEND_MESSAGE)) {
                    //Send the message.
                    sendMessage(intent.getStringExtra(Constants.BUNDLE_MESSAGE_BODY),
                            intent.getStringExtra(Constants.BUNDLE_TO),
                            intent.getStringExtra(Constants.BUNDLE_MESSAGE_PARAMS),
                            action.equals(Constants.X_SEND_MESSAGE),
                            intent.getStringExtra(Constants.BUNDLE_MESSAGE_SENDER_TIME));

                }
            }
        };

        IntentFilter filter = new IntentFilter();
        filter.addAction(Constants.X_SEND_MESSAGE);
        filter.addAction(Constants.READ_MESSAGE);
        filter.addAction(Constants.GROUP_SEND_MESSAGE);

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            mApplicationContext.registerReceiver(uiThreadMessageReceiver, filter, mApplicationContext.RECEIVER_EXPORTED);
        }else {
            mApplicationContext.registerReceiver(uiThreadMessageReceiver, filter);
        }
    }

    private void sendMessage(String body, String toJid, String msgId, boolean isDm, String time) {

        try {

            Message xmppMessage = new Message();
            xmppMessage.setStanzaId(msgId);

            xmppMessage.setBody(body);
            xmppMessage.setType(isDm ? Message.Type.chat : Message.Type.groupchat);

            StandardExtensionElement timeElement = StandardExtensionElement.builder(Constants.TIME, Constants.URN_XMPP_TIME)
                    .addElement(Constants.TS, time).build();
            xmppMessage.addExtension(timeElement);

            if (mAutoDeliveryReceipt) {
                DeliveryReceiptRequest.addTo(xmppMessage);
            }

            if (isDm) {
                xmppMessage.setTo(JidCreate.from(toJid));
                mConnection.sendStanza(xmppMessage);
            } else {
                EntityBareJid jid = JidCreate.entityBareFrom(toJid);
                xmppMessage.setTo(jid);
                EntityBareJid mucJid = (EntityBareJid) JidCreate.bareFrom(Utils.getRoomIdWithDomainName(toJid, mHost));
                MultiUserChat muc = multiUserChatManager.getMultiUserChat(mucJid);
                muc.sendMessage(xmppMessage);
            }

            Utils.addLogInStorage("Action: sentMessageToServer, Content: " + xmppMessage.toXML(null).toString());

            Utils.printLog(" Sent message from: " + xmppMessage.toXML(null) + "  sent.");

        } catch (SmackException.NotConnectedException e) {
            e.printStackTrace();
        } catch (InterruptedException e) {
            e.printStackTrace();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void disconnect() {

        Utils.printLog(" Disconnecting from server: " + mServiceName);

        if (mConnection != null) {
            mConnection.disconnect();
            mConnection = null;
        }

        // Unregister the message broadcast receiver.
        if (uiThreadMessageReceiver != null) {
            mApplicationContext.unregisterReceiver(uiThreadMessageReceiver);
            uiThreadMessageReceiver = null;
        }
    }

    @Override
    public void connected(XMPPConnection connection) {
        Utils.printLog(" Connected Successfully: ");

        FlutterXmppConnectionService.sConnectionState = ConnectionState.CONNECTED;

        Utils.broadcastConnectionMessageToFlutter(mApplicationContext, ConnectionState.CONNECTED, "");

        //Bundle up the intent and send the broadcast.
        Intent intent = new Intent(Constants.RECEIVE_MESSAGE);
        intent.setPackage(mApplicationContext.getPackageName());
        intent.putExtra(Constants.BUNDLE_FROM_JID, mUsername);
        intent.putExtra(Constants.BUNDLE_MESSAGE_BODY, Constants.CONNECTED);
        intent.putExtra(Constants.BUNDLE_MESSAGE_PARAMS, Constants.CONNECTED);
        intent.putExtra(Constants.BUNDLE_MESSAGE_TYPE, Constants.CONNECTED);
        mApplicationContext.sendBroadcast(intent);

    }

    @Override
    public void authenticated(XMPPConnection connection, boolean resumed) {
        Utils.printLog(" Flutter Authenticated Successfully: ");

        multiUserChatManager = MultiUserChatManager.getInstanceFor(connection);
        privateDataManager = PrivateDataManager.getInstanceFor(connection);
        FlutterXmppConnectionService.sConnectionState = ConnectionState.AUTHENTICATED;
//        showContactListActivityWhenAuthenticated();

        Utils.broadcastConnectionMessageToFlutter(mApplicationContext, ConnectionState.AUTHENTICATED, "");

        //Bundle up the intent and send the broadcast.
        Intent intent = new Intent(Constants.RECEIVE_MESSAGE);
        intent.setPackage(mApplicationContext.getPackageName());
        intent.putExtra(Constants.BUNDLE_FROM_JID, mUsername);
        intent.putExtra(Constants.BUNDLE_MESSAGE_BODY, Constants.AUTHENTICATED);
        intent.putExtra(Constants.BUNDLE_MESSAGE_PARAMS, Constants.AUTHENTICATED);
        intent.putExtra(Constants.BUNDLE_MESSAGE_TYPE, Constants.AUTHENTICATED);
        mApplicationContext.sendBroadcast(intent);
    }

    @Override
    public void connectionClosed() {
        Utils.printLog(" ConnectionClosed(): ");

        FlutterXmppConnectionService.sConnectionState = ConnectionState.DISCONNECTED;

        Utils.broadcastConnectionMessageToFlutter(mApplicationContext, ConnectionState.DISCONNECTED, "");

        //Bundle up the intent and send the broadcast.
        Intent intent = new Intent(Constants.RECEIVE_MESSAGE);
        intent.setPackage(mApplicationContext.getPackageName());
        intent.putExtra(Constants.BUNDLE_FROM_JID, Constants.DISCONNECTED);
        intent.putExtra(Constants.BUNDLE_MESSAGE_BODY, Constants.DISCONNECTED);
        intent.putExtra(Constants.BUNDLE_MESSAGE_PARAMS, Constants.DISCONNECTED);
        intent.putExtra(Constants.BUNDLE_MESSAGE_TYPE, Constants.DISCONNECTED);
        mApplicationContext.sendBroadcast(intent);

    }

    @Override
    public void connectionClosedOnError(Exception e) {
        Utils.printLog(" ConnectionClosedOnError, error:  " + e.toString());

        FlutterXmppConnectionService.sConnectionState = ConnectionState.FAILED;

        Utils.broadcastConnectionMessageToFlutter(mApplicationContext, ConnectionState.FAILED, e.getLocalizedMessage());

        //Bundle up the intent and send the broadcast.
        Intent intent = new Intent(Constants.RECEIVE_MESSAGE);
        intent.setPackage(mApplicationContext.getPackageName());
        intent.putExtra(Constants.BUNDLE_FROM_JID, Constants.DISCONNECTED);
        intent.putExtra(Constants.BUNDLE_MESSAGE_BODY, Constants.DISCONNECTED);
        intent.putExtra(Constants.BUNDLE_MESSAGE_PARAMS, Constants.DISCONNECTED);
        intent.putExtra(Constants.BUNDLE_MESSAGE_TYPE, Constants.DISCONNECTED);
        mApplicationContext.sendBroadcast(intent);

    }

}
