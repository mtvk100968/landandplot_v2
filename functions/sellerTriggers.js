// functions/sellerTriggers.js

const functions = require("firebase-functions");
const admin = require("firebase-admin");
const {sendFcm} = require("./utils/fcmHelper");

// admin.initializeApp() stays only in index.js

exports.onSellerUpdate = functions
    .firestore
    .onDocumentUpdated("properties/{propId}", async (change, ctx) => {
      const before = change.before.data();
      const after = change.after.data();
      const propId = ctx.params.propId;
      const db = admin.firestore();
      const ownerId = after.userId;

      // 1) New agent assigned
      const oldAgents = before.assignedAgentIds || [];
      const newAgents = after.assignedAgentIds || [];
      const addedAgents = newAgents.filter((id) => !oldAgents.includes(id));
      if (addedAgents.length) {
        await createNotif(ownerId, "agentAssigned", "An agent was assigned to your listing.");
      }

      // 2) New buyer interest
      const oldBuyers = before.buyers || [];
      const newBuyers = after.buyers || [];
      if (newBuyers.length > oldBuyers.length) {
        const latest = newBuyers[newBuyers.length - 1];
        await createNotif(ownerId, "newInterest", `New interest from ${latest.name}.`);
      }

      // 3) Buyer status change
      for (let i = 0; i < newBuyers.length; i++) {
        const o = oldBuyers[i] || {};
        const n = newBuyers[i];
        if (o.status !== n.status) {
          await createNotif(ownerId, "saleStage", `Buyer ${n.name} is now "${n.status}".`);
        }
      }

      async function createNotif(userId, type, message) {
      // write notification doc
        await db.collection("notifications").doc().set({
          userId,
          type,
          message,
          propertyId: propId,
          agentAlert: false,
          timestamp: admin.firestore.FieldValue.serverTimestamp(),
          read: false,
        });

        // push via FCM
        const userDoc = await db.collection("users").doc(userId).get();
        const tokens = userDoc.data()?.fcmTokens ?? [];
        if (tokens.length) {
          await sendFcm(tokens, {
            notification: {title: "Update for Your Listing", body: message},
            data: {type, propertyId: propId},
          });
        }
      }
    });
