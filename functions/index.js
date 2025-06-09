// functions/index.js
const { onNewProperty }    = require('./propertyTriggers');
const { onBuyerUpdate }    = require('./buyerTriggers');
const { onSellerUpdate }   = require('./sellerTriggers');
const { onAgentUpdate }    = require('./agentTriggers');
const { sendNotification } = require('./sendNotification');

// Firestore triggers
exports.onNewProperty    = onNewProperty;
exports.onBuyerUpdate    = onBuyerUpdate;
exports.onSellerUpdate   = onSellerUpdate;
exports.onAgentUpdate    = onAgentUpdate;

// HTTPS callable
exports.sendNotification = sendNotification;
