/* eslint-disable */
const functions = require('firebase-functions/v1'); // ✅ Add this
const admin = require('firebase-admin');
const { sendFcm } = require('../utils/fcmHelper');

console.log("✅ newPropertyTriggers.js loaded successfully");

exports.onNewProperty = functions.region('asia-south1')
  .firestore.document('properties/{propId}')
  .onCreate(async (snap, ctx) => {
    console.log("📦 onNewProperty triggered");

  const property = snap.data();
  const propId = ctx.params.propId;

  const area = property.district || property.city || 'unknown area';
  const message = `New property listed in ${area}`;

  const db = admin.firestore();

  // 1) Users interested in this area
  const usersSnap = await db.collection('users')
    .where('searchedAreas', 'array-contains', area)
    .get();

  if (usersSnap.empty) return null;

  // 2) Notification docs + collect tokens
  const batch = db.batch();
  const tokens = [];

  usersSnap.forEach((doc) => {
    const user = doc.data();
    batch.set(db.collection('notifications').doc(), {
      userId: doc.id,
      type: 'newProperty',
      message,
      propertyId: propId,
      agentAlert: false,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      read: false,
    });
    if (Array.isArray(user.fcmTokens)) tokens.push(...user.fcmTokens);
  });

  await batch.commit();

  // 3) Send FCM
  if (tokens.length) {
    await sendFcm(tokens, {
      notification: { title: 'New Property', body: message },
      data: { type: 'newProperty', propertyId: propId },
    });
  }
  return null;
});
