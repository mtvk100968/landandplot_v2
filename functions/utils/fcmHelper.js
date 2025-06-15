const admin = require("firebase-admin");

/**
 * Send an FCM payload to a list of device tokens.
 *
 * @param {string[]} tokens   List of FCM registration tokens.
 * @param {object} payload    FCM message payload.
 */
async function sendFcm(tokens, payload) {
  if (!tokens || !tokens.length) return;
  try {
    const response = await admin.messaging().sendToDevice(tokens, payload);
    console.log("FCM sent successfully:", response);
    return response;
  } catch (err) {
    console.error("Error sending FCM:", err);
    throw err;
  }
}

module.exports = {sendFcm};
