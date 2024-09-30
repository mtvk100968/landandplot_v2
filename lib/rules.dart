service cloud.firestore {
  match /databases/{database}/documents {

    // Rules for the users collection
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // Rules for the properties collection
    match /properties/{propertyId} {
      // Allow read access to everyone (or you can restrict this based on your needs)
      allow read: if true;

      // Allow write access only if the user is authenticated
      // and the user ID in the property matches the authenticated user's ID
      allow write: if request.auth != null && request.resource.data.userId == request.auth.uid;
    }
  }
}