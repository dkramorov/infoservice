package org.xrstudio.xmpp.flutter_xmpp.managers;

import org.jxmpp.jid.EntityBareJid;
import org.jxmpp.jid.impl.JidCreate;

import org.jivesoftware.smack.packet.Message;
import org.jivesoftware.smack.tcp.XMPPTCPConnection;
import org.jivesoftware.smackx.mam.MamManager;
import org.jivesoftware.smackx.muc.MultiUserChat;
import org.jivesoftware.smackx.muc.MultiUserChatManager;
import org.jxmpp.jid.Jid;
import org.xrstudio.xmpp.flutter_xmpp.Connection.FlutterXmppConnection;
import org.xrstudio.xmpp.flutter_xmpp.Utils.Utils;

import java.util.Date;
import java.util.List;

public class MAMManager {

    public static void requestMAM(String userJid, String requestBefore, String requestSince, String limit, Boolean lastFlag) {
        XMPPTCPConnection connection = FlutterXmppConnection.getConnection();
        boolean isMuc = false;
        if (connection.isAuthenticated()) {
            try {
                MamManager mamManager = MamManager.getInstanceFor(connection);

                if (userJid.contains("@conference.")) {
                    MultiUserChatManager manager = MultiUserChatManager.getInstanceFor(connection);
                    EntityBareJid jid = JidCreate.entityBareFrom(userJid);
                    MultiUserChat multiUserChat = manager.getMultiUserChat(jid);
                    mamManager = MamManager.getInstanceFor(connection, multiUserChat.getRoom());
                    Utils.printLog("--- MAM MUC staff ---");
                    isMuc = true;
                }

                MamManager.MamQueryArgs.Builder queryArgs = MamManager.MamQueryArgs.builder();

                if (requestBefore != null && !requestBefore.isEmpty()) {
                    long requestBeforets = Long.parseLong(requestBefore);
                    if (requestBeforets > 0)
                        queryArgs.limitResultsBefore(new Date(requestBeforets));
                }
                if (requestSince != null && !requestSince.isEmpty()) {
                    long requestAfterts = Long.parseLong(requestSince);
                    if (requestAfterts > 0)
                        queryArgs.limitResultsSince(new Date(requestAfterts));
                }
                if (limit != null && !limit.isEmpty()) {
                    int limitMessage = Integer.parseInt(limit);
                    if (limitMessage > 0) {
                        queryArgs.setResultPageSizeTo(limitMessage);
                    } else {
                        queryArgs.setResultPageSizeTo(Integer.MAX_VALUE);
                    }
                }
                if (!isMuc) {
                    userJid = Utils.getValidJid(userJid);
                    if (userJid != null && !userJid.isEmpty()) {
                        Jid jid = Utils.getFullJid(userJid);
                        queryArgs.limitResultsToJid(jid);
                    }
                }

                if (lastFlag) {
                    queryArgs.queryLastPage();
                }

                org.jivesoftware.smackx.mam.MamManager.MamQuery query = mamManager.queryArchive(queryArgs.build());
                List<Message> messageList = query.getMessages();

                for (Message message : messageList) {
                    Utils.printLog("Received Message " + message.toXML(null));
                    Utils.broadcastMessageToFlutter(FlutterXmppConnection.getApplicationContext(), message);
                }

            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
}
