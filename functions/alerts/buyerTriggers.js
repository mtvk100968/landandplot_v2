// functions/buyerTriggers.js

const functions = require("firebase-functions");
const admin = require("firebase-admin");
const {sendFcm} = require("../utils/fcmHelper");

// no admin.initializeApp() here — it’s in index.js

exports.onBuyerUpdate = functions
    .firestore
    .onDocumentUpdated("properties/{propId}", async (change, ctx) => {
      const before = change.before.data();
      const after = change.after.data();
      const propId = ctx.params.propId;
      const db = admin.firestore();

      // compare buyers arrays to catch new dates or status changes
      const oldList = before.buyers || [];
      const newList = after.buyers || [];

      for (let i = 0; i < newList.length; i++) {
        const oldB = oldList[i] || {};
        const newB = newList[i];

        // (1) visit date just set
        if (!oldB.date && newB.date) {
          const msg = `Reminder: your visit is scheduled on ${newB.date.toDate()}`;
          await createBuyerNotif(newB.userId, propId, "visitReminder", msg);
        }

        // (2) status changed (negotiating, accepted, rejected, bought)
        if (oldB.status !== newB.status) {
          const msg = `Your offer is now “${newB.status}”`;
          await createBuyerNotif(newB.userId, propId, "saleStage", msg);
        }
      }

      async function createBuyerNotif(userId, propertyId, type, message) {
      // 1) write doc
        const notifRef = db.collection("notifications").doc();
        await notifRef.set({
          userId,
          type,
          message,
          propertyId,
          agentAlert: false,
          timestamp: admin.firestore.FieldValue.serverTimestamp(),
          read: false,
        });

        // 2) fetch tokens
        const userDoc = await db.collection("users").doc(userId).get();
        const tokens = userDoc.data()?.fcmTokens ?? [];

        // 3) push
        if (tokens.length) {
          await sendFcm(tokens, {
            notification: {title: "Update", body: message},
            data: {type, propertyId},
          });
        }
      }
    });
