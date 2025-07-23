const admin = require('firebase-admin');
admin.initializeApp();

async function run() {
  const db = admin.firestore();
  const snap = await db.collection('properties').get();
  const batchArray = [];
  let batch = db.batch();
  let count = 0;

  snap.forEach(doc => {
    if (doc.data().adminApproved === undefined) {
      batch.update(doc.ref, { adminApproved: true });
      count++;
      if (count % 450 === 0) {
        batchArray.push(batch.commit());
        batch = db.batch();
      }
    }
  });
  batchArray.push(batch.commit());
  await Promise.all(batchArray);
  console.log('Updated', count, 'docs');
  process.exit();
}
run();
