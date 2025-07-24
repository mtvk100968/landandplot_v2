/* eslint-disable */
const functions = require('firebase-functions/v1'); // force v1 style API
const admin = require('firebase-admin');
admin.initializeApp();

const REGION = 'asia-south1';

// /* ---------- FIRESTORE / FCM TRIGGERS ---------- */

 const { onNewProperty }   = require('./alerts/newPropertyTriggers');
 const { onBuyerUpdate }   = require('./alerts/buyerTriggers');
 const { onSellerUpdate }  = require('./alerts/sellerTriggers');
 const { onAgentUpdate }   = require('./alerts/agentTriggers');
 const { sendNotification } = require('./alerts/sendNotifications');

exports.onNewProperty = functions.region('asia-south1')
  .firestore.document('properties/{propId}')
  .onCreate(async (snap, context) => {
    console.log('✅ Dummy function ran for propId:', context.params.propId);
    console.log('📦 onNewProperty triggered');
    return null;
  });

// exports.onNewProperty = onNewProperty;

 exports.onBuyerUpdate    = functions.region(REGION)
   .firestore.document('buyers/{buyerId}')
   .onUpdate(onBuyerUpdate);

 exports.onSellerUpdate   = functions.region(REGION)
   .firestore.document('sellers/{sellerId}')
   .onUpdate(onSellerUpdate);

 exports.onAgentUpdate    = functions.region(REGION)
   .firestore.document('agents/{agentId}')
   .onUpdate(onAgentUpdate);

 exports.sendNotification = functions.region(REGION)
   .https.onCall(sendNotification);

/* ---------- PHONEPE HTTP ENDPOINTS ---------- */
const { createOrder } = require('./phonepe/createOrder');
const { getStatus }   = require('./phonepe/getStatus');
const { webhook }     = require('./phonepe/webhook');

exports.phonepeCreateOrder = functions.region(REGION).https.onRequest(createOrder);
exports.phonepeGetStatus   = functions.region(REGION).https.onRequest(getStatus);
exports.phonepeWebhook     = functions.region(REGION).https.onRequest(webhook);
