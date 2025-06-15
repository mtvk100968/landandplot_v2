// functions/propertyTriggers.js

const functions = require("firebase-functions");
const admin = require("firebase-admin");
const {sendFcm} = require("./utils/fcmHelper");

// no admin.initializeApp() here — it lives in index.js

exports.onNewProperty = functions
    .firestore
    .onDocumentCreated("properties/{propId}", async (snap, ctx) => {
      const property = snap.data();
      const propId = ctx.params.propId;
      const area = property.district || property.city;
      const message = `New property listed in ${area}`;

      // 1) Find all users subscribed to this area
      const usersSnap = await admin
          .firestore()
          .collection("users")
          .where("searchedAreas", "array-contains", area)
          .get();

      if (usersSnap.empty) return;

      // 2) Batch-write notifications
      const batch = admin.firestore().batch();
      const tokens = [];

      usersSnap.forEach((userDoc) => {
        const user = userDoc.data();
        const notifRef = admin
            .firestore()
            .collection("notifications")
            .doc();

        batch.set(notifRef, {
          userId: userDoc.id,
          type: "newProperty",
          message,
          propertyId: propId,
          agentAlert: false,
          timestamp: admin.firestore.FieldValue.serverTimestamp(),
          read: false,
        });

        if (Array.isArray(user.fcmTokens)) {
          tokens.push(...user.fcmTokens);
        }
      });

      await batch.commit();

      // 3) Send FCM pushes
      if (tokens.length) {
        await sendFcm(tokens, {
          notification: {title: "New Property", body: message},
          data: {type: "newProperty", propertyId: propId},
        });
      }
    });
