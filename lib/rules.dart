service cloud.firestore {
  match /databases/{database}/documents {

    // Rules for the users collection
    match /users/{userId} {
      // Allow read and write access only to the authenticated user matching the userId
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // Rules for the properties collection
    match /properties/{propertyId} {
      
      // Allow read access to everyone
      allow read: if true;

      // Allow creating a new property only if:
      // - The user is authenticated
      // - The userId in the data matches the authenticated user's UID
      // - All required fields are present and of the correct type
      allow create: if request.auth != null
                    && request.resource.data.userId == request.auth.uid
                    && request.resource.data.landArea is number
                    && request.resource.data.landPrice is number
                    && request.resource.data.pricePerSqYard is number
                    && request.resource.data.latitude is number
                    && request.resource.data.longitude is number
                    && request.resource.data.images is list;

      // Allow updating a property only if:
      // - The user is authenticated
      // - The existing property belongs to the authenticated user
      // - The updated data maintains the ownership and field integrity
      allow update: if request.auth != null
                    && resource.data.userId == request.auth.uid
                    && request.resource.data.userId == request.auth.uid
                    && request.resource.data.landArea is number
                    && request.resource.data.landPrice is number
                    && request.resource.data.pricePerSqYard is number
                    && request.resource.data.latitude is number
                    && request.resource.data.longitude is number
                    && request.resource.data.images is list;

      // Allow deleting a property only if:
      // - The user is authenticated
      // - The property belongs to the authenticated user
      allow delete: if request.auth != null
                    && resource.data.userId == request.auth.uid;
    }

    // Add additional collections and their rules here if necessary

  }
}