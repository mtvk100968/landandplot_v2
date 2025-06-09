const functions = require('firebase-functions');
const admin = require('firebase-admin');
const { sendFcm } = require('./utils/fcmHelper');

admin.initializeApp();

exports.onAgentUpdate = functions
  .firestore
  .document('properties/{propId}')
  .onUpdate(async (change, ctx) => {
    const before = change.before.data();
    const after  = change.after.data();
    const propId = ctx.params.propId;
    const db     = admin.firestore();
    const agents = after.assignedAgentIds || [];

    const oldBuyers = before.buyers || [];
    const newBuyers = after.buyers  || [];

    // 1) New buyer interest
    if (newBuyers.length > oldBuyers.length) {
      const latest = newBuyers[newBuyers.length - 1];
      const message = `Buyer ${latest.name} showed interest.`;
      await notifyAgents('newInterest', message);
    }

    // 2) Visit date set
    for (let i = 0; i < newBuyers.length; i++) {
      const o = oldBuyers[i] || {};
      const n = newBuyers[i];
      if (!o.date && n.date) {
        const message = `Visit scheduled on ${n.date.toDate()}.`;
        await notifyAgents('visitReminder', message);
      }
      // 3) Status change
      if (o.status !== n.status) {
        const message = `Buyer ${n.name} status is now "${n.status}".`;
        await notifyAgents('saleStage', message);
      }
    }

    async function notifyAgents(type, message) {
      for (const agentId of agents) {
        // write Firestore
        const ref = db.collection('notifications').doc();
        await ref.set({
          userId:     agentId,
          type,
          message,
          propertyId: propId,
          agentAlert: true,
          timestamp:  admin.firestore.FieldValue.serverTimestamp(),
          read:       false,
        });
        // push via FCM
        const userDoc = await db.collection('users').doc(agentId).get();
        const tokens  = userDoc.data()?.fcmTokens ?? [];
        if (tokens.length) {
          await sendFcm(tokens, {
            notification: { title: 'Agent Alert', body: message },
            data:         { type, propertyId: propId },
          });
        }
      }
    }
  });
