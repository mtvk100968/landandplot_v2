// lib/services/property_service.dart

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/property_model.dart';
import 'user_service.dart';

class PropertyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final UserService _userService = UserService();

  /// Adds a new property to Firestore along with uploading its images, videos, and documents.
  /// Generates a custom property ID based on the district and mandal.
  /// Returns the generated property ID upon successful completion.
  Future<String> addProperty(Property property, List<File> images,
      {List<File>? videos, List<File>? documents}) async {
    try {
      // Step 1: Generate Custom Property ID
      if (property.district == null || property.mandal == null) {
        throw ArgumentError("District and Mandal are required fields.");
      }

      String propertyId =
          await _generatePropertyId(property.district!, property.mandal!);

      // Step 2: Upload Media Files with Custom Naming
      List<String> imageUrls =
          await _uploadMediaFiles(propertyId, images, 'property_images', 'img');

      List<String> videoUrls = [];
      if (videos != null && videos.isNotEmpty) {
        videoUrls = await _uploadMediaFiles(
            propertyId, videos, 'property_videos', 'vid');
      }

      List<String> documentUrls = [];
      if (documents != null && documents.isNotEmpty) {
        documentUrls = await _uploadMediaFiles(
            propertyId, documents, 'property_documents', 'doc');
      }

      // Step 3: Create a new Property instance with the uploaded URLs and custom ID
      Property propertyWithMedia = Property(
        id: propertyId,
        userId: property.userId,
        name: property.name,
        mobileNumber: property.mobileNumber,
        propertyType: property.propertyType,
        landArea: property.landArea,
        pricePerUnit: property.pricePerUnit,
        totalPrice: property.totalPrice,
        surveyNumber: property.surveyNumber,
        plotNumbers: property.plotNumbers,
        latitude: property.latitude,
        longitude: property.longitude,
        pincode: property.pincode,
        mandal: property.mandal,
        // town: property.town,
        district: property.district,
        state: property.state,
        roadAccess: property.roadAccess,
        roadType: property.roadType,
        roadWidth: property.roadWidth,
        landFacing: property.landFacing,
        images: imageUrls,
        videos: videoUrls,
        documents: documentUrls,
        propertyOwner: property.propertyOwner,
        city: property.city,
        address: property.address,
      );

      // Step 4: Add the property to Firestore with the custom property ID
      await _firestore
          .collection('properties')
          .doc(propertyId)
          .set(propertyWithMedia.toMap());

      // Step 5: Link the property to the user's posted properties
      await _userService.addPropertyToUser(property.userId, propertyId);

      return propertyId;
    } catch (e, stacktrace) {
      print('Error adding property: $e');
      print(stacktrace); // Print stack trace for debugging
      Error.throwWithStackTrace(
          Exception('Failed to add property'), stacktrace);
    }
  }

  /// Fetches a property from Firestore by its ID.
  Future<Property?> getPropertyById(String propertyId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> doc =
          await _firestore.collection('properties').doc(propertyId).get();
      if (doc.exists) {
        return Property.fromMap(doc.id, doc.data()!);
      }
      return null;
    } catch (e, stacktrace) {
      print('Error fetching property: $e');
      print(stacktrace); // Print stack trace for debugging
      Error.throwWithStackTrace(
          Exception('Failed to fetch property'), stacktrace);
    }
  }

  /// Updates an existing property in Firestore.
  /// Optionally handles new image, video, or document uploads if provided.
  Future<void> updateProperty(Property property,
      {List<File>? newImages,
      List<File>? newVideos,
      List<File>? newDocuments}) async {
    try {
      List<String> updatedImageUrls = property.images;
      List<String> updatedVideoUrls = property.videos;
      List<String> updatedDocumentUrls = property.documents;

      if (property.id == null) {
        throw ArgumentError("Property ID is required to update a property.");
      }

      // Upload new images if provided
      if (newImages != null && newImages.isNotEmpty) {
        List<String> newImageUrls = await _uploadMediaFiles(
            property.id, newImages, 'property_images', 'img');
        updatedImageUrls.addAll(newImageUrls);
      }

      // Upload new videos if provided
      if (newVideos != null && newVideos.isNotEmpty) {
        List<String> newVideoUrls = await _uploadMediaFiles(
            property.id, newVideos, 'property_videos', 'vid');
        updatedVideoUrls.addAll(newVideoUrls);
      }

      // Upload new documents if provided
      if (newDocuments != null && newDocuments.isNotEmpty) {
        List<String> newDocumentUrls = await _uploadMediaFiles(
            property.id, newDocuments, 'property_documents', 'doc');
        updatedDocumentUrls.addAll(newDocumentUrls);
      }

      // Create a map from the updated Property object
      Map<String, dynamic> updatedData = property.toMap();
      updatedData['images'] = updatedImageUrls;
      updatedData['videos'] = updatedVideoUrls;
      updatedData['documents'] = updatedDocumentUrls;

      // Update the property document in Firestore
      await _firestore
          .collection('properties')
          .doc(property.id)
          .update(updatedData);
    } catch (e, stacktrace) {
      print('Error updating property: $e');
      print(stacktrace); // Print stack trace for debugging
      Error.throwWithStackTrace(
          Exception('Failed to update property'), stacktrace);
    }
  }

  /// Deletes a property from Firestore and removes its images, videos, and documents from Firebase Storage.
  Future<void> deleteProperty(String propertyId, List<String> imageUrls,
      {List<String>? videoUrls,
      List<String>? documentUrls,
      String? userId}) async {
    try {
      // Step 1: Delete images from Firebase Storage
      if (imageUrls.isNotEmpty) {
        await _deleteFiles(imageUrls);
      }

      // Step 2: Delete videos from Firebase Storage
      if (videoUrls != null && videoUrls.isNotEmpty) {
        await _deleteFiles(videoUrls);
      }

      // Step 3: Delete documents from Firebase Storage
      if (documentUrls != null && documentUrls.isNotEmpty) {
        await _deleteFiles(documentUrls);
      }

      // Step 4: Delete the property document from Firestore
      await _firestore.collection('properties').doc(propertyId).delete();

      // Step 5: Remove the property from the user's posted properties
      if (userId != null) {
        await _firestore.collection('users').doc(userId).update({
          'postedPropertyIds': FieldValue.arrayRemove([propertyId])
        });
      }
    } catch (e, stacktrace) {
      print('Error deleting property: $e');
      print(stacktrace); // Print stack trace for debugging
      Error.throwWithStackTrace(
          Exception('Failed to delete property'), stacktrace);
    }
  }

  /// Fetches all properties from Firestore.
  Future<List<Property>> getAllProperties() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection('properties').get();

      return snapshot.docs
          .map((doc) => Property.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e, stacktrace) {
      print('Error fetching all properties: $e');
      print(stacktrace); // Print stack trace for debugging
      Error.throwWithStackTrace(
          Exception('Failed to fetch properties'), stacktrace);
    }
  }

  /// Private helper method to upload media files to Firebase Storage.
  /// Returns a list of download URLs for the uploaded files.
  Future<List<String>> _uploadMediaFiles(String propertyId, List<File> files,
      String folder, String mediaType) async {
    List<String> downloadUrls = [];
    int index = 1;

    for (File file in files) {
      try {
        // Generate a unique file name based on property ID and media type
        String fileName =
            '${propertyId}_$mediaType$index${_getFileExtension(file.path)}';

        // Define the storage path
        Reference ref =
            _storage.ref().child('$folder/$propertyId').child(fileName);

        // Upload the file
        UploadTask uploadTask = ref.putFile(file);

        // Await the upload task completion
        TaskSnapshot snapshot = await uploadTask.whenComplete(() => null);

        // Get the download URL
        String downloadUrl = await snapshot.ref.getDownloadURL();
        downloadUrls.add(downloadUrl);

        index++;
      } catch (e, stacktrace) {
        print('Error uploading $mediaType file: $e');
        print(stacktrace); // Print stack trace for debugging
      }
    }

    return downloadUrls;
  }

  /// Private helper method to delete files from Firebase Storage given their URLs.
  Future<void> _deleteFiles(List<String> fileUrls) async {
    for (String url in fileUrls) {
      try {
        Reference ref = _storage.refFromURL(url);
        await ref.delete();
      } catch (e, stacktrace) {
        print('Error deleting file $url: $e');
        print(stacktrace); // Print stack trace for debugging
      }
    }
  }
  // Continue deleting other files even if one fails

  /// Private helper method to generate a random string for unique file naming.
  String _generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final rand = DateTime.now().millisecondsSinceEpoch;
    return List.generate(
        length, (index) => chars[(rand + index) % chars.length]).join();
  }

  /// Private helper method to get file extension.
  String _getFileExtension(String path) {
    return path.substring(path.lastIndexOf('.'));
  }

  /// Private helper method to generate a custom property ID.
  Future<String> _generatePropertyId(String district, String mandal) async {
    // Extract first two letters of district and mandal, uppercase
    String districtCode =
        district.length >= 2 ? district.substring(0, 2).toUpperCase() : 'XX';
    String mandalCode =
        mandal.length >= 2 ? mandal.substring(0, 2).toUpperCase() : 'YY';

    String prefix = '$districtCode$mandalCode';

    // Firestore transaction to ensure atomicity
    return await _firestore.runTransaction<String>((transaction) async {
      DocumentReference counterRef = _firestore
          .collection('property_counters')
          .doc('$districtCode$mandalCode');

      DocumentSnapshot counterSnapshot = await transaction.get(counterRef);

      int currentCount = 0;
      if (counterSnapshot.exists) {
        currentCount = counterSnapshot.get('count') ?? 0;
      }

      int newCount = currentCount + 1;

      // Update the counter
      transaction.set(counterRef, {'count': newCount}, SetOptions(merge: true));

      // Format the serial number as a four-digit string
      String serialNumber = newCount.toString().padLeft(4, '0');

      // Combine to form the property ID
      String propertyId = '$prefix$serialNumber';

      return propertyId;
    });
  }
}
