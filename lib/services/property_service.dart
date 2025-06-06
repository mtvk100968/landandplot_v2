import 'dart:io';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/property_model.dart';
import 'user_service.dart';
import '../models/buyer_model.dart';

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
      if (property.district == null || property.taluqMandal == null) {
        throw ArgumentError("District and Mandal are required fields.");
      }

      String propertyId =
          await _generatePropertyId(property.district!, property.taluqMandal!);

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

      // Step 4: Create a new Property instance with the uploaded URLs and custom ID.
      // Now including the new fields from the updated model.
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
        taluqMandal: property.taluqMandal,
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
        createdAt: createdAt,
        amenities: property.amenities,
        // agri_amenities: property.agri_amenities,
        stage: property.stage,
        fencing: property.fencing,
        gate: property.gate,
        bore: property.bore,
        pipeline: property.pipeline,
        electricity: property.electricity,
        plantation: property.plantation,
      );

      // Step 5: Add the property to Firestore with the custom property ID
      await _firestore
          .collection(collectionPath)
          .doc(propertyId)
          .set(propertyWithMedia.toMap());

      // Step 6: Link the property to the user's posted properties
      await _firestore.collection('users').doc(property.userId).update({
        'postedPropertyIds': FieldValue.arrayUnion([propertyId])
      });

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
        query = query
            .where('name', isGreaterThanOrEqualTo: searchQuery)
            .where('name', isLessThanOrEqualTo: searchQuery + '\uf8ff');
      }

      QuerySnapshot<Map<String, dynamic>> snapshot = await query.get();

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
    if (propertyIds.isEmpty) {
      return [];
    }

    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection(collectionPath)
          .where(FieldPath.documentId, whereIn: propertyIds)
          .get();

      return snapshot.docs.map((doc) => Property.fromDocument(doc)).toList();
    } catch (e, stacktrace) {
      print('Error fetching properties by IDs: $e');
      print(stacktrace); // Print stack trace for debugging
      Error.throwWithStackTrace(
          Exception('Failed to fetch properties by IDs'), stacktrace);
    }
  }

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
      print('  propertyTypes: $propertyTypes');
      print('  minPricePerUnit: $minPricePerUnit');
      print('  maxPricePerUnit: $maxPricePerUnit');
      print('  minLandArea: $minLandArea');
      print('  maxLandArea: $maxLandArea');
      print('  minLat: $minLat');
      print('  maxLat: $maxLat');
      print('  minLon: $minLon');
      print('  maxLon: $maxLon');
      print('  city: $city');
      print('  district: $district');
      print('  pincode: $pincode');
      print('  searchQuery: $searchQuery');

      // Start building Firestore query
      Query<Map<String, dynamic>> query = _firestore.collection(collectionPath);

      // 1️⃣ Simple equality filters
      if (propertyTypes != null && propertyTypes.isNotEmpty) {
        query = query.where('propertyType', whereIn: propertyTypes);
      }
      if (city != null && city.isNotEmpty) {
        query = query.where('city', isEqualTo: city);
      }
      if (district != null && district.isNotEmpty) {
        query = query.where('district', isEqualTo: district);
      }
      if (pincode != null && pincode.isNotEmpty) {
        query = query.where('pincode', isEqualTo: pincode);
      }
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query
            .where('name', isGreaterThanOrEqualTo: searchQuery)
            .where('name', isLessThanOrEqualTo: '$searchQuery\uf8ff');
      }

      // 3️⃣ Fetch once
      final snapshot = await query.get();
      var properties =
          snapshot.docs.map((d) => Property.fromMap(d.id, d.data())).toList();

      // 4️⃣ Client-side filtering for land area
      // 🔹 3) In-Dart filter **all** ranges: price, land-area, lat/lon
      properties = properties.where((p) {
        final okPrice =
            (minPricePerUnit == null || p.pricePerUnit >= minPricePerUnit) &&
                (maxPricePerUnit == null || p.pricePerUnit <= maxPricePerUnit);
        final okArea = (minLandArea == null || p.landArea >= minLandArea) &&
            (maxLandArea == null || p.landArea <= maxLandArea);
        final okLat = (minLat == null || p.latitude >= minLat) &&
            (maxLat == null || p.latitude <= maxLat);
        final okLon = (minLon == null || p.longitude >= minLon) &&
            (maxLon == null || p.longitude <= maxLon);
        return okPrice && okArea && okLat && okLon;
      }).toList();

      return properties;
    } catch (e, st) {
      print('Error fetching properties with filters: $e\n$st');
      throw Exception('Failed to fetch properties with filters');
    }
  }

  /// **New Method: Add Proposed Price**
  Future<void> addProposedPrice(
      String propertyId, double price, String remark) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId == null) {
        throw Exception("User must be logged in to propose a price.");
      }

      final proposal = {
        'userId': userId,
        'price': price,
        'remark': remark,
        'timestamp': Timestamp.now(),
      };

      await _firestore.collection(collectionPath).doc(propertyId).update({
        'proposedPrices': FieldValue.arrayUnion([proposal]),
      });
    } catch (e, stacktrace) {
      print('Error adding proposed price: $e');
      print(stacktrace); // Print stack trace for debugging
      Error.throwWithStackTrace(
          Exception('Failed to add proposed price'), stacktrace);
    }
  }

  /// **New Method: Get Proposed Prices**
  Future<List<Map<String, dynamic>>> getProposedPrices(
      String propertyId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> doc =
          await _firestore.collection(collectionPath).doc(propertyId).get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        if (data.containsKey('proposedPrices')) {
          return List<Map<String, dynamic>>.from(data['proposedPrices']);
        }
      }
      return [];
    } catch (e, stacktrace) {
      print('Error fetching proposed prices: $e');
      print(stacktrace); // Print stack trace for debugging
      Error.throwWithStackTrace(
          Exception('Failed to fetch proposed prices'), stacktrace);
    }
  }

  /// **Private Helper Method: Upload Media Files**
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

  /// **Private Helper Method: Delete Files**
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

  /// **Private Helper Method: Generate Random String**
  String _generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final rand = DateTime.now().millisecondsSinceEpoch;
    return List.generate(
        length, (index) => chars[(rand + index) % chars.length]).join();
  }

  /// **Private Helper Method: Get File Extension**
  String _getFileExtension(String path) {
    return path.substring(path.lastIndexOf('.'));
  }

  /// **Private Helper Method: Generate Custom Property ID**
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

  /// assign another agent to help find buyers
  Future<void> assignAgent(String propertyId, String agentId) async {
    await _firestore.collection(collectionPath).doc(propertyId).update({
      'assignedAgentIds': FieldValue.arrayUnion([agentId])
    });
  }

  /// agent or user clicks “interested” button
  Future<void> addBuyer(String propertyId, Buyer buyer) async {
    await _firestore.collection(collectionPath).doc(propertyId).update({
      'buyers': FieldValue.arrayUnion([buyer.toMap()]),
      'stage': 'findingBuyers', // if needed
    });
  }

  /// Updates a single buyer’s status, date, price, notes—and flips the overall
  /// property stage to `saleInProgress` when accepted or `sold` when bought.
  Future<void> updateBuyerStatus({
    required String propertyId,
    required String buyerPhone,
    String? status,
    DateTime? visitDate,
    double? priceOffered,
    List<String>? notes,
  }) async {
    final docRef = _firestore.collection(collectionPath).doc(propertyId);
    final snapshot = await docRef.get();
    if (!snapshot.exists) return;

    final data = snapshot.data()!;
    final buyersList = List<Map<String, dynamic>>.from(
      data['buyers'] as List<dynamic>? ?? [],
    );

    // 1) Update the matching buyer entry
    for (var b in buyersList) {
      if (b['phone'] == buyerPhone) {
        if (status != null) b['status'] = status;
        if (visitDate != null) b['date'] = Timestamp.fromDate(visitDate);
        if (priceOffered != null) b['priceOffered'] = priceOffered;
        if (notes != null) b['notes'] = notes;
        b['lastUpdated'] = Timestamp.now();
        break;
      }
    }

    // 2) Prepare the batch update: always replace buyers list,
    //    plus change `stage` if status==accepted/bought
    final updates = <String, dynamic>{'buyers': buyersList};
    if (status == 'accepted') {
      updates['stage'] = 'saleInProgress';
    } else if (status == 'bought') {
      updates['stage'] = 'sold';
    }

    // 3) Commit it
    await docRef.update(updates);
  }

  /// accept exactly one buyer, close find-buyer, open sales-in-progress
  Future<void> acceptBuyer({
    required String propertyId,
    required String buyerPhone,
    required String agentId,
  }) async {
    final ref = _firestore.collection(collectionPath).doc(propertyId);
    final snap = await ref.get();
    if (!snap.exists) return;
    final data = snap.data()!;

    final allBuyers = List<Map<String, dynamic>>.from(data['buyers'] ?? []);
    final idx = allBuyers.indexWhere((b) => b['phone'] == buyerPhone);
    if (idx == -1) return;

    allBuyers[idx]['status'] = 'accepted';

    await ref.update({
      'buyers': allBuyers,
      'winningAgentId': agentId,
      'stage': 'saleInProgress',
    });
  }

  Future<List<Property>> getPropertiesByField(
      String field, dynamic value) async {
    final snap = await FirebaseFirestore.instance
        .collection(collectionPath)
        .where(field, isEqualTo: value)
        .orderBy('createdAt')
        .get();
    return snap.docs.map((d) => Property.fromDocument(d)).toList();
  }

  Future<void> updatePropertyStage(String propertyId, String newStage) =>
      _firestore.doc('properties/$propertyId').update({'stage': newStage});

  Future<void> updateBuyer(
    String propertyId,
    Buyer oldBuyer,
    Buyer updatedBuyer,
    String? agentId,
  ) async {
    final docRef = _firestore.collection('properties').doc(propertyId);

// 1) remove old entry from buyers list
    await docRef.update({
      'buyers': FieldValue.arrayRemove([oldBuyer.toMap()]),
    });

// 2) add updated entry back into buyers
    final newMap = updatedBuyer.toMap();
    await docRef.update({
      'buyers': FieldValue.arrayUnion([newMap]),
    });

    // 3) if accepted, set stage to saleInProgress AND record winningAgentId
    if (updatedBuyer.status == 'accepted') {
      // use passed-in agentId or current user
      final winningAgent = agentId ?? FirebaseAuth.instance.currentUser!.uid;
      await docRef.update({
        'stage': 'saleInProgress',
        'winningAgentId': winningAgent,
      });
    }
  }

  Future<void> updateBuyerByBuyer(
    String propertyId,
    Buyer oldBuyer,
    Buyer newBuyer,
  ) async {
    final docRef = _firestore.collection('properties').doc(propertyId);

    // 1) Remove the old buyer map
    await docRef.update({
      'buyers': FieldValue.arrayRemove([oldBuyer.toMap()]),
    });

    // 2) Add the updated buyer map
    await docRef.update({
      'buyers': FieldValue.arrayUnion([newBuyer.toMap()]),
    });
  }

  Future<void> markSaleInProgress(String propertyId) async {
    await FirebaseFirestore.instance
        .collection('properties')
        .doc(propertyId)
        .update({'stage': 'saleInProgress'});
  }
}
