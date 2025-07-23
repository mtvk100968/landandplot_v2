/* eslint-disable */
const admin = require('firebase-admin');

exports.sendFcm = async (tokens, payload) => {
  const chunks = [];
  const size = 500;
  for (let i = 0; i < tokens.length; i += size) {
    chunks.push(tokens.slice(i, i + size));
  }
  for (const chunk of chunks) {
    await admin.messaging().sendMulticast({ tokens: chunk, ...payload });
  }
};
