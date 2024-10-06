service firebase.storage {
  match /b/{bucket}/o {
    
    // Rules for property images
    match /property_images/{userId}/{imageName} {
      
      // Allow read access to everyone
      allow read: if true;
      
      // Allow write (upload, delete) access only to the authenticated user matching the userId
      allow write: if  {
        request.auth != null
                   && request.auth.uid == userId
                   // Optional: Enforce file size limit (e.g., max 5MB)
                   && request.resource.size < 5 * 1024 * 1024
                   // Optional: Restrict to specific image MIME types
                   && request.resource.contentType.matches('image/.*');
      }
    }

    // Add additional storage paths and their rules here if necessary

  }
}