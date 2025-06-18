// functions/index.js
const functions = require("firebase-functions");
// Force all Functions V2 to live in asia-south1
functions.setGlobalOptions({region:["asia-south1"]});

const admin = require("firebase-admin");
admin.initializeApp();

// Bring in your trigger factories
const {onNewProperty} = require("./propertyTriggers");
const {onBuyerUpdate} = require("./buyerTriggers");
const {onSellerUpdate} = require("./sellerTriggers");
const {onAgentUpdate} = require("./agentTriggers");
const {sendNotification} = require("./sendNotifications");

// Re-export them
exports.onNewProperty = onNewProperty;
exports.onBuyerUpdate = onBuyerUpdate;
exports.onSellerUpdate = onSellerUpdate;
exports.onAgentUpdate = onAgentUpdate;
exports.sendNotification = sendNotification;
