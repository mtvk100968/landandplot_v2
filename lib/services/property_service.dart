// lib/services/property_service.dart

import 'dart:io';
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/property_model.dart';
import 'user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PropertyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final UserService _userService = UserService();
  static const String collectionPath = 'properties';

  /// Adds a new property to Firestore along with uploading its images, videos, and documents.
  /// Generates a custom property ID based on the district and mandal.
  /// Returns the generated property ID upon successful completion.
  Future<String> addProperty(
    Property property,
    List<File> images, {
    List<File>? videos,
    List<File>? documents,
  }) async {
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

      // Step 3: Set the creation time to IST
      DateTime nowUtc = DateTime.now().toUtc();
      DateTime nowIst = nowUtc.add(Duration(hours: 5, minutes: 30));
      Timestamp createdAt = Timestamp.fromDate(nowIst);

      // Step 4: Create a new Property instance with the uploaded URLs and custom ID
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
        district: property.district,
        village: property.village, // <--- Include Village
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

        // **Set New Fields**
        userType: property.userType,
        ventureName: property.ventureName,

        createdAt: createdAt, // Set the creation time
      );

      // Step 5: Add the property to Firestore with the custom property ID
      await _firestore
          .collection(collectionPath)
          .doc(propertyId)
          .set(propertyWithMedia.toMap());

      // Step 6: Link the property to the user's posted properties
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
          await _firestore.collection(collectionPath).doc(propertyId).get();
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
  Future<void> updateProperty(
    Property property, {
    List<File>? newImages,
    List<File>? newVideos,
    List<File>? newDocuments,
  }) async {
    try {
      List<String> updatedImageUrls = List.from(property.images);
      List<String> updatedVideoUrls = List.from(property.videos);
      List<String> updatedDocumentUrls = List.from(property.documents);

      if (property.id.isEmpty) {
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
          .collection(collectionPath)
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
  Future<void> deleteProperty(
    String propertyId,
    List<String> imageUrls, {
    List<String>? videoUrls,
    List<String>? documentUrls,
    String? userId,
  }) async {
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
      await _firestore.collection(collectionPath).doc(propertyId).delete();

      // Step 5: Remove the property from the user's posted properties
      if (userId != null && userId.isNotEmpty) {
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
  /// Optionally applies a search query on the property name.
  Future<List<Property>> getAllProperties({String? searchQuery}) async {
    try {
      Query<Map<String, dynamic>> query = _firestore.collection(collectionPath);

      // Apply search filter
      if (searchQuery != null && searchQuery.isNotEmpty) {
        // Firestore doesn't support full-text search; this is a basic implementation.
        // For more advanced search, consider integrating with Algolia or Firebase Extensions.
        query = query
            .where('name', isGreaterThanOrEqualTo: searchQuery)
            .where('name', isLessThanOrEqualTo: searchQuery + '\uf8ff');
      }

      QuerySnapshot<Map<String, dynamic>> snapshot = await query.get();
print('Query snapshot fetched: ${snapshot.docs.length} documents');

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

  /// Fetch properties by a list of IDs.
  Future<List<Property>> getPropertiesByIds(List<String> propertyIds) async {
    if (propertyIds.isEmpty) return [];

    QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
        .collection(collectionPath)
        .where(FieldPath.documentId, whereIn: propertyIds)
        .get();

    return snapshot.docs.map((doc) => Property.fromDocument(doc)).toList();
  }

  /// Fetches properties based on various filters.
  Future<List<Property>> getPropertiesWithFilters({
    List<String>? propertyTypes,
    double? minPricePerUnit,
    double? maxPricePerUnit,
    double? minLandArea,
    double? maxLandArea,
    double? minLat,
    double? maxLat,
    double? minLon,
    double? maxLon,
    String? city,
    String? district,
    String? pincode,
    String? searchQuery,
  }) async {
    try {
      print('getPropertiesWithFilters called with:');
      print('propertyTypes: $propertyTypes');
      print('minPricePerUnit: $minPricePerUnit');
      print('maxPricePerUnit: $maxPricePerUnit');
      print('minLandArea: $minLandArea');
      print('maxLandArea: $maxLandArea');
      print('minLat: $minLat');
      print('maxLat: $maxLat');
      print('minLon: $minLon');
      print('maxLon: $maxLon');
      print('city: $city');
      print('district: $district');
      print('pincode: $pincode');
      print('searchQuery: $searchQuery');

      Query<Map<String, dynamic>> query = _firestore.collection(collectionPath);

      // Apply equality filters first
      if (propertyTypes != null && propertyTypes.isNotEmpty) {
        query = query.where('propertyType', whereIn: propertyTypes);
        print('Applied propertyType filter: $propertyTypes');
      }
      if (city != null && city.isNotEmpty) {
        query = query.where('city', isEqualTo: city);
        print('Applied city filter: $city');
      }
      if (district != null && district.isNotEmpty) {
        query = query.where('district', isEqualTo: district);
        print('Applied district filter: $district');
      }
      if (pincode != null && pincode.isNotEmpty) {
        query = query.where('pincode', isEqualTo: pincode);
        print('Applied pincode filter: $pincode');
      }

      // Apply price range filter
      if (minPricePerUnit != null || maxPricePerUnit != null) {
        if (minPricePerUnit != null && maxPricePerUnit != null) {
          query = query.where('pricePerUnit',
              isGreaterThanOrEqualTo: minPricePerUnit,
              isLessThanOrEqualTo: maxPricePerUnit);
          print('Applied pricePerUnit filter: $minPricePerUnit - $maxPricePerUnit');
        } else if (minPricePerUnit != null) {
          query = query.where('pricePerUnit', isGreaterThanOrEqualTo: minPricePerUnit);
          print('Applied min price filter: $minPricePerUnit');
        } else if (maxPricePerUnit != null) {
          query = query.where('pricePerUnit', isLessThanOrEqualTo: maxPricePerUnit);
          print('Applied max price filter: $maxPricePerUnit');
        }
      }

      // Fetch data
      QuerySnapshot<Map<String, dynamic>> snapshot = await query.get();
      print('Number of properties fetched from Firestore before land area filter: ${snapshot.docs.length}');

      // Log the fetched documents for debugging
      snapshot.docs.forEach((doc) {
        print('Fetched property data: ${doc.data()}');
      });

      // Convert Firestore documents to Property objects
      List<Property> properties = snapshot.docs
          .map((doc) => Property.fromMap(doc.id, doc.data()))
          .toList();

      print('Properties before land area filter: ${properties.length}');
      properties.forEach((property) {
        print('Property data: landArea=${property.landArea}, pricePerUnit=${property.pricePerUnit}');
      });

// Apply land area filter
      if (minLandArea != null || maxLandArea != null) {
        properties = properties.where((property) {
          bool matches = true;
          if (minLandArea != null) {
            matches = matches && property.landArea >= minLandArea;
          }
          if (maxLandArea != null) {
            matches = matches && property.landArea <= maxLandArea;
          }
          return matches;
        }).toList();
      }
      print('Properties after land area filter: ${properties.length}');

      return properties;
    } catch (e, stacktrace) {
      print('Error fetching properties with filters: $e');
      print(stacktrace); // Print stack trace for debugging
      throw Exception('Failed to fetch properties with filters');
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
        final String userId =
            FirebaseAuth.instance.currentUser?.uid ?? 'unknown';
        Reference ref = _storage.ref().child('$folder/$userId').child(fileName);
        // Path: /property_images/{userId}/{imageName}

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
        // Continue uploading other files even if one fails
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
        // Continue deleting other files even if one fails
      }
    }
  }

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
