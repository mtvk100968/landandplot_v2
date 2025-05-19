/**
 * seed_firestore.js
 * 
 * Usage:  
 *   npm install firebase-admin  
 *   node seed_firestore.js
 */

const admin = require('firebase-admin')

// Initialize with your service account
const serviceAccount = require('./serviceAccountKey.json')
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
})

const db = admin.firestore()

// Replace these with actual UIDs from your Auth/users
const testUserId = 'M9y8LJ8D01eUwvOf7M89jzm1Gg93'
const testAgentId = 'KiK33WLvM7Mn0tQS870bCLrF6Jk1'

async function seed() {
  // 1) Create the test user
  await db.collection('users').doc(testUserId).set({
    uid: testUserId,
    name: 'Test User',
    email: 'test.user@example.com',
    phoneNumber: '+911234567890',
    userType: 'user',
    favoritedPropertyIds: ['RASE0002', 'RASE0004'],
    interestedPropertyIds: ['RASE0002', 'RASE0003', 'RASE0005'],
    boughtPropertyIds: ['RASE0001'],
  })

  // 2) Create properties with this user as a buyer in every possible state
  const now = admin.firestore.Timestamp.now()
  const props = [
    {
      id: 'RASE0001',
      stage: 'findingBuyers',
      propertyType: 'Land',
      totalPrice: 50000,
      landArea: 100,
      address: '123 Test Lane',
      images: [],
      buyers: [
        {
          name: 'Test User',
          phone: '+911234567890',
          status: 'accepted',
          currentStep: 'Possession',
          date: now.toDate(),
          priceOffered: 50000,
          notes: ['Deal completed'],
          lastUpdated: now.toDate(),
          interestDocs: [],
          docVerifyDocs: [],
          legalCheckDocs: [],
          agreementDocs: [],
          registrationDocs: [],
          mutationDocs: [],
          possessionDocs: [],
        }
      ],
      userId: testAgentId,
      propertyOwner: 'Agent A',
      createdAt: now,
    },
    {
      id: 'RASE0002',
      stage: 'findingBuyers',
      propertyType: 'Plot',
      totalPrice: 75000,
      landArea: 150,
      address: '456 Sample Rd',
      images: [],
      buyers: [
        {
          name: 'Test User',
          phone: '+911234567890',
          status: 'visitPending',
          currentStep: 'Interest',
          date: null,
          priceOffered: null,
          notes: [],
          lastUpdated: now.toDate(),
          interestDocs: [],
          docVerifyDocs: [],
          legalCheckDocs: [],
          agreementDocs: [],
          registrationDocs: [],
          mutationDocs: [],
          possessionDocs: [],
        }
      ],
      userId: testAgentId,
      propertyOwner: 'Agent B',
      createdAt: now,
    },
    {
      id: 'RASE0003',
      stage: 'findingBuyers',
      propertyType: 'Agricultural Land',
      totalPrice: 120000,
      landArea: 200,
      address: '789 Demo Blvd',
      images: [],
      buyers: [
        {
          name: 'Test User',
          phone: '+911234567890',
          status: 'negotiating',
          currentStep: 'LegalCheck',
          date: new Date(),
          priceOffered: 115000,
          notes: ['Asked for discount'],
          lastUpdated: now.toDate(),
          interestDocs: ['https://example.com/doc1.pdf'],
          docVerifyDocs: [],
          legalCheckDocs: [],
          agreementDocs: [],
          registrationDocs: [],
          mutationDocs: [],
          possessionDocs: [],
        }
      ],
      userId: testAgentId,
      propertyOwner: 'Agent C',
      createdAt: now,
    },
    {
      id: 'RASE0004',
      stage: 'saleInProgress',
      propertyType: 'Farmhouse',
      totalPrice: 200000,
      landArea: 300,
      address: '101 Test Pkwy',
      images: [],
      buyers: [
        {
          name: 'Test User',
          phone: '+911234567890',
          status: 'rejected',
          currentStep: 'DocVerify',
          date: new Date(),
          priceOffered: 190000,
          notes: ['Offer too low'],
          lastUpdated: now.toDate(),
          interestDocs: ['https://example.com/interest.pdf'],
          docVerifyDocs: ['https://example.com/docverify.pdf'],
          legalCheckDocs: [],
          agreementDocs: [],
          registrationDocs: [],
          mutationDocs: [],
          possessionDocs: [],
        }
      ],
      userId: testAgentId,
      propertyOwner: 'Agent D',
      createdAt: now,
    },
    // you can add more if necessary
  ]

  for (const p of props) {
    const data = { ...p }
    // Convert JS Date → Firestore Timestamp
    data.buyers = data.buyers.map(b => ({
      ...b,
      date: b.date ? admin.firestore.Timestamp.fromDate(b.date) : null,
      lastUpdated: admin.firestore.Timestamp.fromDate(b.lastUpdated),
    }))
    if (data.createdAt instanceof Date) {
        data.createdAt = admin.firestore.Timestamp.fromDate(data.createdAt);
      }
    await db.collection('properties').doc(p.id).set(data)
  }

  // 3) Seed some notifications for the user
  const notifData = [
    {
      userId: testUserId,
      type: 'visitReminder',
      message: 'Your visit for property RASE0002 is coming up tomorrow.',
      timestamp: now.toDate(),
      read: false,
    },
    {
      userId: testUserId,
      type: 'negotiationUpdate',
      message: 'Agent C has sent you a counter-offer on RASE0003.',
      timestamp: now.toDate(),
      read: false,
    },
    {
      userId: testUserId,
      type: 'purchaseComplete',
      message: 'Congratulations! Your purchase of RASE0001 is complete.',
      timestamp: now.toDate(),
      read: true,
    },
  ]
  for (const n of notifData) {
    await db.collection('notifications').add({
      ...n,
      timestamp: admin.firestore.Timestamp.fromDate(n.timestamp),
    })
  }

  console.log('✅ Seed complete')
  process.exit(0)
}

seed().catch(err => {
  console.error(err)
  process.exit(1)
})
