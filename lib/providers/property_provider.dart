import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/property_model.dart';
import 'dart:io';
import '../data/districts_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http; // Import http package
import 'dart:convert'; // Import convert for JSON decoding
import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';

class PropertyProvider with ChangeNotifier {
  Timestamp getCurrentTimestampInIST() {
    DateTime nowUtc = DateTime.now().toUtc();
    DateTime nowIst = nowUtc.add(const Duration(hours: 5, minutes: 30));
    return Timestamp.fromDate(nowIst);
  }

  final String _apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';

  // Step 1: Basic Details
  String _phoneNumber = '';
  String _name = '';
  String _propertyOwnerName = '';
  String _propertyType = 'Plot'; // Default value

  // **New Field: User Type**
  String _userType = 'Owner'; // Default to 'Owner'

  // Step 2: Property Details
  double _area = 0.0;
  double _pricePerUnit = 0.0;
  double _totalPrice = 0.0;
  String _surveyNumber = '';
  List<String> _plotNumbers = [];
  int _bedRooms = 0;
  int _bathRooms = 0;
  int _parkingSpots = 0;

  // Step 3: Address Details
  String _houseNo = '';
  String? _district;
  String _taluqMandal = '';
  String? _village; // <--- Added Village Field
  String _pincode = '';
  String _state = '';
  String _city = '';
  String? _address;
  String? _mandal;

  // Amenities checkboxes for land/farm/agri types
  // ✅ Valid declarations at the top of the class
  bool _fencing = false;
  bool _gate = false;
  bool _bore = false;
  bool _pipeline = false;
  bool _electricity = false;
  bool _plantation = false;
  bool _farmHouseConstructed = false;

  // Step 4: Map Location
  double _latitude = 17.385044; // Default to Hyderabad latitude
  double _longitude = 78.486671; // Default to Hyderabad longitude

  // Additional Fields
  String _roadAccess = ''; // e.g., "Yes/No"
  String _roadType = ''; // e.g., "Paved", "Gravel", "Dirt"
  double _roadWidth = 0.0; // in meters
  String _landFacing = ''; // e.g., "North", "South", etc.

  // **New Field: Venture Name**
  String? _ventureName; // Required for 'Plot' or 'Farm Land'

  // Step 5: Media Upload
  List<File> _imageFiles = []; // List to store image files
  List<File> _videoFiles = []; // List to store video files
  List<File> _documentFiles = []; // List to store document files

  bool _isGeocoding = false;
  bool get isGeocoding => _isGeocoding;

  // **Added Field: Proposed Prices**
  List<Map<String, dynamic>> _proposedPrices = [];

  List<Map<String, dynamic>> get proposedPrices => _proposedPrices;

  void setProposedPrices(List<Map<String, dynamic>> prices) {
    _proposedPrices = prices;
    notifyListeners();
  }

  /// **New Method: Submit Proposed Price**
  Future<void> submitProposedPrice(
      String propertyId, double price, String remark) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception("User must be logged in to submit a price proposal.");
      }

      final proposal = {
        'userId': user.uid,
        'price': price,
        'remark': remark,
        'timestamp': getCurrentTimestampInIST(),
      };

      // Add the proposal to Firestore
      await FirebaseFirestore.instance
          .collection('properties')
          .doc(propertyId)
          .update({
        'proposedPrices': FieldValue.arrayUnion([proposal]),
      });

      // Update the local list
      _proposedPrices.add(proposal);
      notifyListeners();
    } catch (e) {
      developer.log("Error submitting proposed price: $e");
      throw Exception("Failed to submit proposed price.");
    }
  }

  /// **New Method: Fetch Proposed Prices**
  Future<void> fetchProposedPrices(String propertyId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> doc = await FirebaseFirestore
          .instance
          .collection('properties')
          .doc(propertyId)
          .get();

      if (doc.exists) {
        final data = doc.data();
        if (data != null && data.containsKey('proposedPrices')) {
          _proposedPrices =
          List<Map<String, dynamic>>.from(data['proposedPrices'] ?? []);
          notifyListeners();
        }
      }
    } catch (e) {
      developer.log("Error fetching proposed prices: $e");
      throw Exception("Failed to fetch proposed prices.");
    }
  }

  // Getters and Setters
  bool get fencing => _fencing;
  void setFencing(bool value) {
    _fencing = value;
    notifyListeners();
  }

  bool get gate => _gate;
  void setGate(bool value) {
    _gate = value;
    notifyListeners();
  }

  bool get bore => _bore;
  void setBore(bool value) {
    _bore = value;
    notifyListeners();
  }

  bool get pipeline => _pipeline;
  void setPipeline(bool value) {
    _pipeline = value;
    notifyListeners();
  }

  bool get electricity => _electricity;
  void setElectricity(bool value) {
    _electricity = value;
    notifyListeners();
  }

  bool get plantation => _plantation;
  void setPlantation(bool value) {
    _plantation = value;
    notifyListeners();
  }

  bool get farmHouseConstructed => _farmHouseConstructed;
  void setFarmHouseConstructed(bool val) {
    _farmHouseConstructed = val;
    notifyListeners();
  }

  // Getters and Setters for Step 1
  String get phoneNumber => _phoneNumber;
  void setPhoneNumber(String value) {
    _phoneNumber = value;
    notifyListeners();
  }

  String get name => _name;
  void setName(String value) {
    _name = value;
    notifyListeners();
  }

  String get propertyOwnerName => _propertyOwnerName;
  void setPropertyOwnerName(String value) {
    _propertyOwnerName = value;
    notifyListeners();
  }

  String get propertyType => _propertyType;
  void setPropertyType(String value) {
    _propertyType = value;
    notifyListeners();
  }

  // **Getters and Setters for User Type**
  String get userType => _userType;
  void setUserType(String value) {
    if (value != _userType) {
      _userType = value;
      notifyListeners();
    }
  }

  // **Getters and Setters for Venture Name**
  String? get ventureName => _ventureName;
  void setVentureName(String value) {
    _ventureName = value;
    notifyListeners();
  }

  // 1. BHK
  int get bedRooms => _bedRooms;
  void setBedRooms(int value) {
    _bedRooms = value; // Extract number from "2 BHK"
    notifyListeners();
  }

  // 2. BATH
  int get bathRooms => _bathRooms;
  void setBathRooms(int value) {
    _bathRooms = value;
    notifyListeners();
  }

  // 3. PKS
  int get parkingSpots => _parkingSpots;
  void setParkingSpots(int value) {
    _parkingSpots = value; // Extract number from "2 PKS"
    notifyListeners();
  }

  // **Getters and Setters for Step 2**
  double get area => _area;
  void setArea(double value) {
    // Removed the constraint to allow 0.0
    _area = value;
    calculateTotalPrice();
    notifyListeners();
  }

  double get pricePerUnit => _pricePerUnit;
  void setPricePerUnit(double value) {
    // Removed the constraint to allow 0.0
    _pricePerUnit = value;
    calculateTotalPrice();
    notifyListeners();
  }

  double get totalPrice => _totalPrice;

  void calculateTotalPrice() {
    if (_propertyType.toLowerCase() == 'agri land') {
      // Property type is measured in acres
      int wholeAcres = _area.floor();
      double fractionalAcres = _area - wholeAcres;
      double guntas = 0.0;

      if (fractionalAcres >= 0.40) {
        // Round up to the next whole acre
        wholeAcres += 1;
        guntas = 0.0;
      } else {
        // Convert fractional acres to guntas
        guntas = fractionalAcres * 40;
      }

      // Calculate price per gunta
      double pricePerGunta = _pricePerUnit / 40;

      // Calculate total price
      _totalPrice = (wholeAcres * _pricePerUnit) + (guntas * pricePerGunta);
    } else {
      // Property type is in square yards (sqyds)
      _totalPrice = _area * _pricePerUnit;
    }
    notifyListeners();
  }

  String get surveyNumber => _surveyNumber;
  void setSurveyNumber(String value) {
    _surveyNumber = value;
    notifyListeners();
  }

  List<String> get plotNumbers => _plotNumbers;
  void addPlotNumber(String plotNumber) {
    if (!_plotNumbers.contains(plotNumber)) {
      _plotNumbers.add(plotNumber);
      notifyListeners();
    }
  }

  String get houseNo => _houseNo;
  void setHouseNo(String value) {
    _houseNo = value;
    notifyListeners();
  }

  void removePlotNumber(String plotNumber) {
    _plotNumbers.remove(plotNumber);
    notifyListeners();
  }

  int parseBedrooms(String? bedroomsString) {
    // e.g. "2 BHK" => 2
    // If user never chose, return 0
    if (bedroomsString == null || bedroomsString.isEmpty) return 0;

    // If your strings are like "1 BHK", "2 BHK", "3 BHK"...
    // split on space:
    final parts = bedroomsString.split(' '); // ["2", "BHK"]
    return int.tryParse(parts.first) ?? 0;
  }

  int parseBath(String? bathString) {
    // e.g. "2 Bath" => 2, or "4+ Bath" => 4
    if (bathString == null || bathString.isEmpty) return 0;

    // If your strings are "1 Bath", "2 Bath", "3 Bath", "4+ Bath"
    // you can handle "4+" specifically:
    if (bathString.startsWith('4+')) {
      return 4; // or 5, depending on how you want to store
    }

    final parts = bathString.split(' '); // ["2", "Bath"]
    return int.tryParse(parts.first) ?? 0;
  }

  int parseParking(String? parkingString) {
    // e.g. "2 PKS" => 2
    if (parkingString == null || parkingString.isEmpty) return 0;

    final parts = parkingString.split(' '); // ["2", "PKS"]
    return int.tryParse(parts.first) ?? 0;
  }

  // Getters and Setters for Step 3
  String? get district => _district;
  void setDistrict(String value) {
    if (value == _district) {
      developer.log('District unchanged: $value');
      return;
    }
    developer.log('Setting new district: $value');
    _district = value;
    _mandal = null;
    notifyListeners();
  }

  String? get mandal => _mandal;
  void setMandal(String value) {
    if (value == _mandal) {
      developer.log('Mandal unchanged: $value');
      return;
    }
    developer.log('Setting new mandal: $value');
    _mandal = value;
    notifyListeners();
  }

  String get taluqMandal => _taluqMandal;
  void setTaluqMandal(String value) {
    _taluqMandal = value;
    notifyListeners();
  }

  String? get village => _village; // <--- Getter for Village
  void setVillage(String value) {
    if (value != _village) {
      _village = value;
      notifyListeners();
    }
  }

  String get city => _city;
  void setCity(String value) {
    _city = value;
    notifyListeners();
  }

  String get pincode => _pincode;
  Future<void> setPincode(String value) async {
    if (value == _pincode) {
      developer.log('Pincode unchanged: $value');
      return;
    }

    developer.log('Setting new pincode: $value');
    _pincode = value;
    notifyListeners();

    if (_pincode.length == 6) {
      try {
        await geocodePincode(_pincode);
      } catch (e) {
        developer.log('Geocoding failed: $e');
      }
    }
  }

  String get state => _state;
  void setStateField(String value) {
    _state = value;
    notifyListeners();
  }

  // New Getter and Setter for Address
  String? get address => _address;
  void setAddress(String value) {
    _address = value;
    notifyListeners();
  }

  // Getters and Setters for Step 4
  double get latitude => _latitude;
  void setLatitude(double value) {
    _latitude = value;
    notifyListeners();
  }

  double get longitude => _longitude;
  void setLongitude(double value) {
    _longitude = value;
    notifyListeners();
  }

  // Getters and Setters for Additional Fields
  String get roadAccess => _roadAccess;
  void setRoadAccess(String value) {
    _roadAccess = value;
    notifyListeners();
  }

  String get roadType => _roadType;
  void setRoadType(String value) {
    _roadType = value;
    notifyListeners();
  }

  double get roadWidth => _roadWidth;
  void setRoadWidth(double value) {
    if (value < 0) throw ArgumentError('Road width cannot be negative');
    _roadWidth = value;
    notifyListeners();
  }

  String get landFacing => _landFacing;
  void setLandFacing(String value) {
    _landFacing = value;
    notifyListeners();
  }

  // Getters and Setters for Step 5
  List<File> get imageFiles => _imageFiles;
  void addImageFile(File file) {
    if (!_imageFiles.contains(file)) {
      _imageFiles.add(file);
      notifyListeners();
    }
  }

  void removeImageFile(File file) {
    _imageFiles.remove(file);
    notifyListeners();
  }

  List<File> get videoFiles => _videoFiles;
  void addVideoFile(File file) {
    if (!_videoFiles.contains(file)) {
      _videoFiles.add(file);
      notifyListeners();
    }
  }

  void removeVideoFile(File file) {
    _videoFiles.remove(file);
    notifyListeners();
  }

  List<File> get documentFiles => _documentFiles;
  void addDocumentFile(File file) {
    if (!_documentFiles.contains(file)) {
      _documentFiles.add(file);
      notifyListeners();
    }
  }

  void removeDocumentFile(File file) {
    _documentFiles.remove(file);
    notifyListeners();
  }

  List<String> _selectedAmenities = [];
  List<String> get selectedAmenities => _selectedAmenities;
  void setSelectedAmenities(List<String> amenities) {
    _selectedAmenities = amenities;
    notifyListeners();
  }

  // ── NEW: agri‐land amenities ─────────────────────────────────────────
  List<String> _agriAmenities = [];
  List<String> get agriAmenities => _agriAmenities;

  void setAgriAmenities(List<String> agri_amenities) {
    _agriAmenities = agri_amenities;
    notifyListeners();
  }

  // Getter for districtList
  List<String> get districtList => districtData.keys.toList();

  // Getter for Mandal List based on District
  List<String> get mandalList {
    if (_district != null && districtData.containsKey(_district!)) {
      return districtData[_district!]!.toSet().toList();
    }
    return [];
  }

  //// Geocode the current pincode to obtain city, district, and state
  Future<void> geocodePincode(String pincode) async {
    _isGeocoding = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    final key = dotenv.env['GOOGLE_MAPS_API_KEY']!;

    // ── STEP 1: PIN → lat/lng ─────────────────────────────────────────
    final geoUri = Uri.https('maps.googleapis.com', '/maps/api/geocode/json', {
      'address': pincode,
      'components': 'country:IN',
      'key': key,
    });
    final geoResp  = await http.get(geoUri);
    final geoJson  = jsonDecode(geoResp.body) as Map<String, dynamic>;

    if (geoJson['status'] != 'OK' || (geoJson['results'] as List).isEmpty) {
      _isGeocoding = false;
      notifyListeners();
      throw Exception('Pincode lookup failed: ${geoJson['status']}');
    }

    final firstResult = geoJson['results'][0] as Map<String, dynamic>;
    final loc = firstResult['geometry']['location'] as Map<String, dynamic>;
    final lat = loc['lat'] as double;
    final lng = loc['lng'] as double;

    // ── STEP 2: REVERSE-GEOCODE for DISTRICT ─────────────────────────
    final revUri = Uri.https('maps.googleapis.com', '/maps/api/geocode/json', {
      'latlng': '$lat,$lng',
      // force only administrative_area_level_2 results
      'result_type': 'administrative_area_level_2',
      'key': key,
    });
    final revResp = await http.get(revUri);
    final revJson = jsonDecode(revResp.body) as Map<String, dynamic>;

    String district = '';
    if (revJson['status'] == 'OK' && (revJson['results'] as List).isNotEmpty) {
      final comps = (revJson['results'][0]['address_components'] as List)
          .cast<Map<String, dynamic>>();
      final d = comps.firstWhere(
            (c) => (c['types'] as List).contains('administrative_area_level_2'),
        orElse: () => <String, dynamic>{},
      );
      if (d.isNotEmpty) district = d['long_name'] as String;
    }

    // ── STEP 3: PULL CITY / STATE / TALUK / VILLAGE from the first hit ──
    String city    = '';
    String state   = '';
    String taluk   = '';
    String village = '';
    for (final comp in firstResult['address_components']
        .cast<Map<String, dynamic>>()) {
      final types = (comp['types'] as List).cast<String>();
      final name  = comp['long_name'] as String;
      if (types.contains('postal_town') || types.contains('locality')) {
        city = name;
      }
      if (types.contains('administrative_area_level_1')) {
        state = name;
      }
      if (types.contains('administrative_area_level_3')) {
        taluk = name;
      }
      if (types.contains('sublocality_level_1') ||
          types.contains('neighborhood')) {
        village = name;
      }
    }

    // ── STEP 4: WRITE BACK INTO YOUR FORM PROVIDER ────────────────────
    setLatitude(lat);
    setLongitude(lng);

    setCity(city);
    setDistrict(district);
    setTaluqMandal(taluk);
    setStateField(state);
    if (village.isNotEmpty) setVillage(village);

    _isGeocoding = false;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  /// Convert provider data to Property model
  Property toProperty() {
    // Note: The actual upload of media files is handled separately.
    // This method should only convert the non-media fields.
    Timestamp createdAt = getCurrentTimestampInIST();

    return Property(
      userId: FirebaseAuth.instance.currentUser?.uid ?? 'unknown',
      name: _name,
      mobileNumber: _phoneNumber,
      propertyType: _propertyType,
      landArea: _area,
      pricePerUnit: _pricePerUnit,
      totalPrice: _totalPrice,
      surveyNumber: _surveyNumber,
      plotNumbers: _propertyType == 'Plot' ? _plotNumbers : [],
      district: _district,
      taluqMandal: taluqMandal,
      village: _village, // <--- Include Village
      city: _city,
      pincode: _pincode,
      state: _state,
      latitude: _latitude,
      longitude: _longitude,
      roadAccess: _roadAccess,
      roadType: _roadType,
      roadWidth: _roadWidth,
      landFacing: _landFacing,
      propertyOwner: _propertyOwnerName,
      images: [], // Will be set after uploading
      videos: [], // Will be set after uploading
      documents: [], // Will be set after uploading
      address: _address,

      // **Set New Fields**
      userType: _userType,
      ventureName: _ventureName,

      createdAt: Timestamp.now(), // or DateTime.now()
      amenities: _selectedAmenities,
      agri_amenities: _agriAmenities,
      fencing: fencing,
      gate: gate,
      bore: bore,
      pipeline: pipeline,
      electricity: electricity,
      plantation: plantation,
    );
  }

  /// Reset the form after submission
  void resetForm() {
    _phoneNumber = '';
    _name = '';
    _propertyOwnerName = '';
    _propertyType = 'Plot';
    _userType = 'Owner'; // Reset User Type
    _ventureName = null; // Reset Venture Name
    _area = 0.0;
    _pricePerUnit = 0.0;
    _totalPrice = 0.0;
    _surveyNumber = '';
    _plotNumbers = [];
    _district = null;
    _village = null; // Reset Village
    _city = '';
    _pincode = '';
    _state = '';
    _latitude = 17.385044;
    _longitude = 78.486671;
    _roadAccess = '';
    _roadType = '';
    _roadWidth = 0.0;
    _landFacing = '';
    _imageFiles.clear();
    _videoFiles.clear();
    _documentFiles.clear();
    _address = '';
    _proposedPrices.clear(); // Reset Proposed Prices
    _selectedAmenities.clear();
    _agriAmenities.clear();
    // ✅ Reset amenities
    notifyListeners();
  }
}
