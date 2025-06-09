const functions = require('firebase-functions');
const admin = require('firebase-admin');
const { sendFcm } = require('./utils/fcmHelper');

admin.initializeApp();

exports.sendNotification = functions.https.onCall(async (data, context) => {
  const { notificationId } = data;
  if (!notificationId) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'notificationId is required'
    );
  }

  // 1) Fetch the notification record
  const notifSnap = await admin
    .firestore()
    .collection('notifications')
    .doc(notificationId)
    .get();

  if (!notifSnap.exists) {
    throw new functions.https.HttpsError(
      'not-found',
      `Notification ${notificationId} not found`
    );
  }
  const notif = notifSnap.data();

  // 2) Get the user’s FCM tokens
  const userSnap = await admin
    .firestore()
    .collection('users')
    .doc(notif.userId)
    .get();
  const tokens = userSnap.data()?.fcmTokens ?? [];

  if (!tokens.length) {
    return { success: false, message: 'No device tokens to send to.' };
  }

  // 3) Build FCM payload
  const payload = {
    notification: {
      title: notif.type === 'newProperty'
        ? 'New Property'
        : notif.type === 'visitReminder'
        ? 'Visit Reminder'
        : 'Update',
      body: notif.message,
    },
    data: {
      type: notif.type,
      propertyId: notif.propertyId || '',
      notificationId,
    },
  };

  // 4) Send push
  await sendFcm(tokens, payload);

  return { success: true };
});
